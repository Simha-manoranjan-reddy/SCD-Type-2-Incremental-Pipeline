# Azure SQL to Databricks SCD Type 2 Incremental Pipeline

## Project Overview

This project implements an end-to-end Azure Data Engineering pipeline that extracts customer data from Azure SQL Database, loads it into ADLS Gen2 using Azure Data Factory, processes it in Azure Databricks, and maintains historical changes using Slowly Changing Dimension Type 2 logic.

The pipeline uses watermark-based incremental loading to process only new or changed records from the source system.

## Architecture

<img src="https://github.com/Simha-manoranjan-reddy/SCD-Type-2-Incremental-Pipeline/blob/main/Architecture/Designer.png" alt="Description of image" width="1000">

