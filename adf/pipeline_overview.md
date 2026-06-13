
# ADF Pipeline Overview



![Alternative Text to describe the image](https://github.com/Simha-manoranjan-reddy/SCD-Type-2-Incremental-Pipeline/blob/main/adf/Designer%20(1).png)



## Pipeline Name

```text
PL_SQL_TO_GOLD_CUSTOMER_SCD2_INCREMENTAL
```

## Purpose

This Azure Data Factory pipeline performs incremental ingestion from Azure SQL Database to ADLS Gen2 and triggers Databricks notebooks to process the Silver and Gold layers.

The pipeline uses watermark-based incremental loading. It reads the last successful watermark value, extracts only new or changed records from Azure SQL, writes the data to the Bronze layer, triggers Databricks notebooks, and updates the watermark only after the Gold SCD Type 2 load succeeds.

---

## Pipeline Flow

```text
Lookup_LastWatermark
        ↓
Lookup_CurrentWatermark
        ↓
Copy_SQL_Incremental_To_Bronze
        ↓
NB_Bronze_To_Silver_Incremental
        ↓
NB_Gold_SCD2_Incremental
        ↓
StoredProcedure_UpdateWatermark
```

---

## Activity 1: Lookup_LastWatermark

### Purpose

Reads the last successfully processed watermark value from the Azure SQL control table.

### Source Query

```sql
SELECT LastWatermarkValue
FROM dbo.WatermarkControl
WHERE TableName = 'SourceCustomer';
```

### Expected Output

```text
LastWatermarkValue
```

For the first run, the expected value is:

```text
1900-01-01 00:00:00
```

This allows the first pipeline run to behave like an initial full load.

---

## Activity 2: Lookup_CurrentWatermark

### Purpose

Gets the current maximum `UpdatedDate` value from the Azure SQL source table.

This value is captured at the start of the pipeline run and used as the upper boundary for incremental extraction.

### Source Query

```sql
SELECT MAX(UpdatedDate) AS CurrentWatermarkValue
FROM dbo.SourceCustomer;
```

### Expected Output

```text
CurrentWatermarkValue
```

---

## Activity 3: Copy_SQL_Incremental_To_Bronze

### Purpose

Copies only new or changed records from Azure SQL Database to the ADLS Gen2 Bronze layer.

### Source

```text
Azure SQL Database
dbo.SourceCustomer
```

### Sink

```text
ADLS Gen2 Bronze Layer
```

### Bronze Path Pattern

```text
bronze/customer/incremental/batch_id=<ADF_PIPELINE_RUN_ID>/customer_incremental.parquet
```

### Incremental Filter Logic

```sql
UpdatedDate > LastWatermarkValue
AND UpdatedDate <= CurrentWatermarkValue
```

This ensures that only records inserted or updated after the last successful pipeline run are copied.

---

## Activity 4: NB_Bronze_To_Silver_Incremental

### Purpose

Triggers the Databricks notebook that reads the Bronze parquet file, cleans the data, generates hash values, removes duplicates within the batch, and appends the data into the Silver Delta table.

### Notebook

```text
01_bronze_to_silver_customer_incremental
```

### Base Parameters

```json
{
  "bronze_path": "@concat('abfss://cdcbronze@delearn.dfs.core.windows.net/bronze/customer/incremental/batch_id=', pipeline().RunId, '/customer_incremental.parquet')",
  "batch_id": "@pipeline().RunId"
}
```

### Output Table

```text
scd_project.silver_customer_incremental
```

### Silver Processing

```text
1. Read Bronze parquet file.
2. Cast CustomerID to integer.
3. Trim string columns.
4. Standardize Email to lowercase.
5. Add SourceSystem.
6. Add BatchID.
7. Add IngestionDate.
8. Generate HashValue.
9. Deduplicate records within the current batch.
10. Append records into the Silver Delta table.
```

---

## Activity 5: NB_Gold_SCD2_Incremental

### Purpose

Triggers the Databricks notebook that applies SCD Type 2 logic in the Gold layer.

The notebook processes only the current batch from Silver using the ADF pipeline run ID as `BatchID`.

### Notebook

```text
02_gold_customer_scd2_incremental
```

### Base Parameters

```json
{
  "batch_id": "@pipeline().RunId"
}
```

### Input Table

```text
scd_project.silver_customer_incremental
```

### Output Table

```text
scd_project.dim_customer_scd2
```

### Output View

```text
scd_project.vw_current_customer
```

### Gold Processing

```text
1. Read current batch from Silver.
2. Check whether the Gold table exists.
3. If Gold does not exist, perform initial SCD Type 2 load.
4. If Gold exists, compare incoming Silver records with current Gold records.
5. Detect changes using HashValue.
6. Expire old current records for changed customers.
7. Insert new current records for changed customers.
8. Insert new customers.
9. Keep unchanged customers as-is.
10. Create or refresh the current customer view.
```

---

## Activity 6: StoredProcedure_UpdateWatermark

### Purpose

Updates the watermark table only after the Gold SCD Type 2 notebook succeeds.

This ensures that records are not skipped if the pipeline fails before Gold processing completes.

### Stored Procedure

```text
dbo.usp_UpdateWatermark
```

### Parameters

```text
TableName = SourceCustomer
NewWatermarkValue = @activity('Lookup_CurrentWatermark').output.firstRow.CurrentWatermarkValue
```

### Stored Procedure Logic

```sql
UPDATE dbo.WatermarkControl
SET
    LastWatermarkValue = @NewWatermarkValue,
    UpdatedDate = SYSDATETIME()
WHERE TableName = @TableName;
```

---

## Dependency Rule

The Stored Procedure activity must run only after the Gold notebook activity succeeds.

Correct dependency:

```text
NB_Gold_SCD2_Incremental Success
        ↓
StoredProcedure_UpdateWatermark
```

Do not update the watermark after the Copy activity.

Do not update the watermark after the Silver notebook activity.

The watermark should be updated only after the complete Gold SCD Type 2 processing is successful.

---

## First Run Behavior

For the first run, the watermark value is:

```text
1900-01-01 00:00:00
```

So the pipeline extracts all existing records from the source table.

This acts as the initial full load.

Expected Day 1 load:

```text
101
102
103
104
105
```

Expected Gold result:

```text
Gold total count: 5
Gold current count: 5
Gold history count: 0
```

---

## Incremental Run Behavior

For later runs, the pipeline extracts only records where:

```sql
UpdatedDate > LastWatermarkValue
AND UpdatedDate <= CurrentWatermarkValue
```

Example Day 2 changes:

```text
101 city changed
102 phone changed
104 email changed
106 new customer inserted
```

Expected Day 2 incremental extraction:

```text
101
102
104
106
```

Expected Gold result after Day 2:

```text
Gold total count: 9
Gold current count: 6
Gold history count: 3
```

Example Day 3 changes:

```text
101 phone changed
103 city changed
105 email changed
107 new customer inserted
```

Expected Day 3 incremental extraction:

```text
101
103
105
107
```

Expected Gold result after Day 3:

```text
Gold total count: 13
Gold current count: 7
Gold history count: 6
```

---

## Final Output

After successful execution, the pipeline produces:

```text
1. Bronze parquet batch file in ADLS Gen2.
2. Silver Delta table in Databricks.
3. Gold SCD Type 2 Delta table in Databricks.
4. Current customer view for BI consumption.
5. Updated watermark value in Azure SQL.
```

---

## Important Notes

```text
ADF is used for orchestration and ingestion.
Databricks is used for transformation and SCD Type 2 processing.
Azure SQL stores the source data and watermark control table.
ADLS Gen2 stores Bronze batch files and reference parquet outputs.
Gold Delta table is the main BI-ready output.
```

---

## Failure Handling Consideration

The watermark update is treated as the final commit step of the pipeline.

If the pipeline fails before Gold processing completes, the watermark should not be updated.

This allows the same incremental records to be picked again in the next run and prevents data loss.
