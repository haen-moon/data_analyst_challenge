# Data Analyst Challenge

## Objective

The goal of the ETL process is to design a structured data pipeline that ingests the provided source files, cleans and standardises them for consistency, and models them into an analysis-ready schema.

## Data Architecture & Layering

A three-layer data warehouse architecture was implemented to transform the source data (structured CSV files) into clean, traceable, and analysis-ready datasets for BI reporting.

- Ingestion layer: maintains exact copies of the source files in the raw schema.
- Processing layer: standardizes formats and enforces data quality rules in the clean schema.
- Analytics layer: presents analysis-ready, business-friendly views optimized for dashboard reporting.

## Repository Structure
```
data_analyst_challenge/
│
│
├── docs/                               # Project documentation and architecture details
│   ├── data_relationship.jpg           # raw data relationship diagram
│   ├── data_logic.jpg                  # logical data model diagram
│   ├── data_flow.jpg                   # finalised data flow diagram
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── raw/                            # Scripts for extracting and loading raw data
│   ├── clean/                          # Scripts for cleaning and transforming data
│   ├── mart/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
└── .gitignore                          # Files and directories to be ignored by Git
```

## Project Walk-through Documentation
- **[Data Engineering - ETL](https://haenmoon.notion.site/Data-Engineering-ETL-25398f0d5a5680c1be83ec29d90a7534):** ETL process walk-through
- **[Data Analytics - EDA](https://haenmoon.notion.site/Data-Analytics-EDA-25498f0d5a56804b936be8295da97052):** EDA queries and result analysis

## License
This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.