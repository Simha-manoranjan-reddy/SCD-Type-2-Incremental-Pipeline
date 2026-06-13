# SCD Type 2 Incremental Pipeline

## Project Overview

This project demonstrates an end-to-end Azure Data Engineering solution that extracts customer data from Azure SQL Database, stores it in Azure Data Lake Storage Gen2 (ADLS Gen2), and processes it using Azure Databricks.

The pipeline implements Watermark-Based Incremental Loading to process only new or modified records from the source system. Historical data is preserved using Slowly Changing Dimension (SCD) Type 2 logic, enabling complete tracking of customer record changes over time.

---
## Architecture

<img src="https://github.com/Simha-manoranjan-reddy/SCD-Type-2-Incremental-Pipeline/blob/main/Architecture/Designer.png" alt="Architecture Diagram" width="1000">

---

## Business Problem

Organizations often need to maintain a complete history of changes made to customer records while avoiding expensive full-table reloads.

This solution addresses that challenge by:

* Capturing only new and updated records using watermark-based incremental loading.
* Preserving historical versions of customer data using SCD Type 2 methodology.
* Supporting analytical reporting and audit requirements.
* Improving efficiency by processing only changed data.

---

## Key Features

* Watermark-Based Incremental Data Loading
* Slowly Changing Dimension (SCD) Type 2 Implementation
* Azure Data Factory Orchestration
* Azure Data Lake Storage Gen2 Integration
* Azure Databricks Data Processing
* Historical Data Tracking
* Automated Change Detection
* Scalable Lakehouse Architecture

---



## Technology Stack

| Service                      | Purpose                                       |
| ---------------------------- | --------------------------------------------- |
| Azure SQL Database           | Source system                                 |
| Azure Data Factory           | Data ingestion and orchestration              |
| Azure Data Lake Storage Gen2 | Raw and processed data storage                |
| Azure Databricks             | Data transformation and SCD Type 2 processing |
| Delta Lake                   | Data storage and merge operations             |

---

## Pipeline Workflow

### Step 1: Extract Incremental Data

Azure Data Factory retrieves the latest watermark value and extracts only new or updated customer records from Azure SQL Database.

### Step 2: Load to Data Lake

Incremental data is loaded into Azure Data Lake Storage Gen2 for further processing.

### Step 3: Process in Databricks

Azure Databricks reads the incoming data and performs data transformations.

### Step 4: Apply SCD Type 2 Logic

The pipeline detects inserts and updates:

* New records are inserted directly.
* Updated records expire the current version.
* A new version of the record is created with updated values.

### Step 5: Update Watermark

The latest processed timestamp is stored for the next incremental run.

---

## SCD Type 2 Implementation

The pipeline maintains historical versions of customer records using the following fields:

| Column    | Description                   |
| --------- | ----------------------------- |
| StartDate | Record effective start date   |
| EndDate   | Record expiration date        |
| IsCurrent | Indicates active record (Y/N) |

When a customer record changes:

1. Existing active record is marked as inactive.
2. End date is updated.
3. New version of the record is inserted.
4. New record is marked as current.

---

## Sample SCD Type 2 Output

### Source Record Before Update

| CustomerID | CustomerName | City      |
| ---------- | ------------ | --------- |
| 101        | John Doe     | Hyderabad |

### Source Record After Update

| CustomerID | CustomerName | City      |
| ---------- | ------------ | --------- |
| 101        | John Doe     | Bangalore |

### Dimension Table Result

| CustomerID | CustomerName | City      | StartDate  | EndDate    | IsCurrent |
| ---------- | ------------ | --------- | ---------- | ---------- | --------- |
| 101        | John Doe     | Hyderabad | 2025-01-01 | 2025-06-01 | N         |
| 101        | John Doe     | Bangalore | 2025-06-01 | NULL       | Y         |

This ensures historical data is retained while identifying the latest active version of each customer record.

---

## Repository Structure

```text
SCD-Type-2-Incremental-Pipeline/
│
├── ADF/
│   ├── Datasets/
│   ├── LinkedServices/
│   └── Pipelines/
│
├── Databricks/
│   └── Notebooks/
│
├── SQL/
│   ├── SourceScripts/
│   └── WatermarkScripts/
│
├── Architecture/
│   └── Designer.png
│
└── README.md
```

---

## Learning Outcomes

Through this project, I gained hands-on experience with:

* Azure Data Factory pipeline development
* Incremental data loading strategies
* Slowly Changing Dimension Type 2 implementation
* Azure Data Lake Storage Gen2
* Azure Databricks transformations
* Delta Lake operations
* End-to-end Azure Data Engineering workflows

---



## Author

**Simha Manoranjan Reddy**

Azure Data Engineering Project
