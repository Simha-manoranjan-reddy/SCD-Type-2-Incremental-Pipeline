# Azure SQL to Databricks SCD Type 2 Incremental Pipeline

## Project Overview

This project implements an end-to-end Azure Data Engineering pipeline that extracts customer data from Azure SQL Database, loads it into ADLS Gen2 using Azure Data Factory, processes it in Azure Databricks, and maintains historical changes using Slowly Changing Dimension Type 2 logic.

The pipeline uses watermark-based incremental loading to process only new or changed records from the source system.

## Architecture

```text
Azure SQL Database
        ↓
Azure Data Factory
        ↓
ADLS Gen2 Bronze Layer
        ↓
Azure Databricks Silver Layer
        ↓
Azure Databricks Gold SCD Type 2 Dimension
        ↓
Power BI / BI Consumption
