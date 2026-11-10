# Hospital Billing Analytics Platform : Medallion Architecture with Lakeflow Spark Declarative Pipelines

An end-to-end Hospital billing ETL pipeline on Azure Databricks, built with Lakeflow Spark Declarative Pipelines (SQL) and the Medallion Architecture (Bronze → Silver → Gold). It turns a raw, messy sales CSV into trusted, business-ready reporting tables, with data-quality tracking and reconciliation across layers.

<img width="858" height="478" alt="architecture" src="https://github.com/user-attachments/assets/6095a5b2-707d-4cbf-bc24-bbf478f48d2f" />

# Table of Contents
-  Business Problem and Objectives
-  Architecture
-  Pipeline Lineage
-  Tech Stack
-  Dataset
-  Layer Details
-  Data Quality Rules
-  Reconciliation
-  How to Run
-  Business Requirements Coverage
-  Key Learnings
-  Future Improvements

# Business Problem and Objectives
The hospital has no automatic way to turn the raw billing file into numbers it can trust. This project builds a repeatable pipeline that keeps the original file, cleans the data, prepares summary tables and shows them in a dashboard.

## Project Objectives
- Load the billing CSV into Databricks from a Unity Catalog Volume.
- Keep the raw data in a Bronze table.
- Clean the data in a Silver table and keep the bad rows in a separate rejected table.
- Create Gold summary tables for monthly revenue, departments, branches and payers.
- Count the data problems and check that no row was lost.
- Build one dashboard in Databricks AI/BI or Power BI.

# Architecture
hospital_billing_raw.csv (Unity Catalog Volume) → Bronze (raw, traceable) → Silver (cleaned, validated) → Gold (business aggregates) → Databricks SQL / dashboards / BI tools

| Layer | Purpose | Key Actions |
|---|---|---|
| Bronze | Preserve source data | Load CSV, keep original values, add ingestion metadata |
| Silver | Improve trust and consistency | Remove duplicates, fix text, fill blanks, drop bad rows (and keep them in a rejected table) |
| Gold | Serve business questions | GROUP BY month, department, branch and payer; count data problems |

# Pipeline Lineage
<img width="938" height="616" alt="Pipeline_lineage" src="https://github.com/user-attachments/assets/d321bfbe-2369-4c6a-acce-bae3d160322a" />

| Object | Type | Description |
|---|---|---|
| bronze_hospital_billing | Streaming Table | Raw ingested sales records |
| silver_billing_rejected | Materialized view | Stores billing records that fail data quality validations |
| silver_billing_clean | Materialized view | Cleaned and validated records |
| gold_data_quality | Materialized view | Issue counts and validation status (reads Bronze and Silver) |
| gold_branch_summary | Materialized view | Stores region, city, hospital_branch-wise visit counts, total revenue |
| gold_payer_summary | Materialized view | Stores pivot-type-wise visit counts, total revenue, insurance amount and pending amount |
| gold_monthly_summary | Materialized view | Stores monthly branch-wise visit counts, total revenue, and insurance amounts |
| gold_department_summary | Materialized view | Stores department-wise visit counts and total revenue |

Materialized views refresh incrementally where possible. 

# Tech Stack
- Azure Databricks
- Lakeflow Spark Declarative Pipelines (SQL)
- Unity Catalog (Volumes)
- Delta Lake
- Databricks SQL

# Dataset
The learning dataset hospital_billing_raw.csv is synthetic (made up for this project). It has 1,010 rows and 20 columns covering 330 patient visits in 2025.

# Layer Details
## Bronze Layer
- Reads the CSV from a Unity Catalog Volume: /Volumes/healthcare_catalog/healthcare_catalog_billing/healthcare_catalog_billing_raw_files.csv
- Keeps source values unchanged
- Adds ingestion metadata: e.g. _ingest_timestamp, _source_file

## Silver Layer
- Created or refreshed the silver_billing_clean materialized view.
- Used SELECT DISTINCT to remove duplicate records.
- Applied CAST to convert columns into appropriate data types.
- Used TRIM to remove leading and trailing spaces.
- Used COALESCE to handle NULL values by replacing them with default values.
- Applied CASE WHEN to replace negative quantities and unit prices with zero.
- Used WHERE conditions to filter records based on validation rules.
- Standardized billing data and prepared clean, reliable records for the Gold l

## Gold Layer
- gold_data_quality_summary : missing, invalid, duplicate and suspicious counts.
- gold_branch_summary : Created an aggregated summary by grouping data based on region, city, and hospital_branch by counting visits and total_revenue for each branch.
- gold_payer_summary : Created an aggregated summary by grouping billing data based on payer_type and calculating visits, total_revenue, insurance_amount, paid_amount and pending amount for each payer.
- gold_monthly_revenue : Created an aggregated summary by grouping billing data by month and calculating visits, total_revenue, insurance_amount, and monthly revenue trends.
- gold_department_summary : Created an aggregated summary by grouping data based on department and calculating visits and total_revenue for each department.

## Data Quality Rules
| Rule | Treatment |
|---|---|
| Completeness | Identify missing or NULL values in important columns |
| Uniqueness | Check duplicate bill_id and transaction records |
| Validity | Ensure quantity, unit_price and total_amount are valid |
| Accuracy | Verify total_amount and calculations |
| Consistency | Maintain consistent department_name, dates and payment status |
| Range Check | Identify negative quantities, prices and amounts |
| Referential Integrity | Ensure bill_id, patient_id and visit_id references are valid |
| Suspicious Records | Identify unusual total_amount or transactions for further investigation |

# Reconciliation 
| Check_name | issue_type | Affected Rows |
|---|---|---|
| Row balance (bronze = clean + rejected + duplicate) | Reconciliation | 0 |
| Duplicate Rows | Problem | 20 |
| Invalid quantity | Problem | 14 |
| Missing department | Problem | 12 |
| Negative price | Problem | 8 |
| Missing payer | Problem | 10 |
| Missing amount | Problem | 15 |

# How to Run
1. Upload hospital_billing_raw.csv to a Unity Catalog Volume and confirm read permissions.
2. Clone this repo into your Databricks workspace (Repos / Git folder).
3. Create a new Lakeflow Spark Declarative Pipeline and add the SQL files under pipeline/ as source code.
4. Set the target catalog and schema.
5. Run the pipeline (Start or Full refresh).
6. Run the checks in validation/ and query the Gold tables.

# Business Requirement Coverage
| ID | Requirement | Status |
|---|---|---|
| BR-01 | Monthly revenue | gold_monthly_revenue |
| BR-02 | Department performance | gold_department_summary |
| BR-03 | Branch performance | gold_branch_summary |
| BR-04 | Payer analysis | gold_payer_summary |
| BR-05 | Data quality visibility | gold_data_quality |
| BR-06 | Reconciliation | Bronze rows = clean rows + rejected rows + duplicates removed |
| BR-07 | Repeatability | Managed Lakeflow pipeline |
| BR-08 | Dashboard | Dashboard based on gold tables for better insights |

# Key Learnings
- Understanding Medallion Architecture.
- SQL-based ETL pipeline development.
- Data cleaning and validation.
- Implementing data quality rules.
- Creating Gold summary tables.
- Data reconciliation and dashboard reporting.

# Future Improvements
- Automate ETL pipeline execution.
- Implement real-time data processing.
- Enhance data quality checks.
- Improve dashboard performance.
- Add advanced analytics and reporting.






