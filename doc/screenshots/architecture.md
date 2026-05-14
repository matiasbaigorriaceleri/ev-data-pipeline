# Architecture Documentation — Electric Vehicle Data Pipeline

## Table of Contents

1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Layer Descriptions](#layer-descriptions)
4. [Design Decisions](#design-decisions)
5. [Analytical Views](#analytical-views)
6. [Scalability](#scalability)

---

## Overview

This project implements a **layered data architecture** following modern Data Engineering principles. The pipeline is divided into clearly separated responsibilities: ingestion, storage, transformation, and visualization — each handled by the most appropriate tool.

The dataset contains **280,833 records** of registered electric vehicles in Washington State, sourced from the public portal [data.gov](https://catalog.data.gov/dataset/electric-vehicle-population-data).

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                         │
│                                                             │
│         Electric_Vehicle_Population_Data.csv                │
│                    (280,833 rows)                           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    INGESTION LAYER                          │
│                                                             │
│   load.py  →  pandas.read_csv()  →  df.to_sql()            │
│   SQLAlchemy + psycopg2                                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      RAW LAYER                              │
│                                                             │
│         PostgreSQL: raw_electric_vehicle_population         │
│         - Original data, no transformations                 │
│         - Source of truth                                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    CURATED LAYER                            │
│                                                             │
│      PostgreSQL: curated_electric_vehicle_population        │
│      - Data cleaning and normalization                      │
│      - Type casting and null handling                       │
│      - Optimized for analytical queries                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   ANALYTICAL LAYER                          │
│                                                             │
│   vw_ev_registrations_by_year                               │
│   vw_top_ev_models                                          │
│   vw_cafv_geographic_distribution                           │
│   vw_ev_yoy_by_county   (LAG + PARTITION BY)               │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  VISUALIZATION LAYER                        │
│                                                             │
│         Power BI Desktop — DirectQuery mode                 │
│         - EV Registrations Trend                            │
│         - Top 10 EV Models                                  │
│         - CAFV Geographic Distribution Map                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Descriptions

### Raw Layer — `raw_electric_vehicle_population`

The raw layer stores the dataset exactly as it arrives from the source CSV, with no transformations applied. This guarantees:

- **Data lineage** — the original source is always preserved and reproducible
- **Re-processability** — transformations can be re-run at any time without re-ingesting
- **Auditability** — any downstream issue can be traced back to the original record

### Curated Layer — `curated_electric_vehicle_population`

The curated layer applies cleaning and normalization logic on top of the raw data:

- Null value handling
- Data type normalization (strings, integers, decimals)
- Removal of structurally inconsistent records
- Column renaming for analytical consistency

This layer is the **single source of truth** for all analytical views and dashboards.

### Analytical Layer — SQL Views

Views are built on top of the curated layer and encapsulate all business logic. This approach keeps Power BI reports thin and fast, with no transformations happening inside the BI tool.

### Visualization Layer — Power BI

Power BI connects to PostgreSQL using **DirectQuery**, meaning:

- No data is imported or duplicated into Power BI
- Reports always reflect the current state of the database
- The architecture remains decoupled and maintainable

---

## Design Decisions

### Why PostgreSQL?

PostgreSQL was chosen for its robustness, open-source nature, and excellent support for analytical SQL features including window functions, CTEs, and complex aggregations — all required for this project.

### Why DirectQuery over Import Mode?

DirectQuery was chosen to maintain a clean separation between the data layer and the visualization layer. This avoids data duplication and ensures the dashboard always reflects the most recent state of the database without manual refresh.

### Why SQL Views instead of Power BI measures?

Encapsulating business logic in SQL views rather than Power BI DAX measures provides several advantages:

- Logic is reusable across any BI tool or reporting system
- Queries are testable and versionable in Git
- Power BI remains a thin presentation layer, not a transformation engine

### Why a layered architecture?

The Raw → Curated → Analytical pattern is a standard in modern Data Engineering. It provides clear separation of concerns, makes debugging straightforward, and allows each layer to evolve independently.

---

## Analytical Views

### `vw_ev_registrations_by_year`

Answers: *How many electric vehicles are registered per year?*

```sql
SELECT model_year, COUNT(*) AS total_registrations
FROM curated_electric_vehicle_population
GROUP BY model_year
ORDER BY model_year;
```

### `vw_top_ev_models`

Answers: *What are the top 10 electric vehicle models by registration count?*

```sql
SELECT make, model, COUNT(*) AS total
FROM curated_electric_vehicle_population
GROUP BY make, model
ORDER BY total DESC
LIMIT 10;
```

### `vw_cafv_geographic_distribution`

Answers: *Where are CAFV-eligible vehicles concentrated geographically?*

Groups CAFV-eligible vehicles by county and state to identify geographic concentration patterns.

### `vw_ev_yoy_by_county`

Answers: *What is the year-over-year change in EV registrations by county?*

Uses the `LAG()` window function to compare each year against the previous one, partitioned by county:

```sql
LAG(total_registrations) OVER (
    PARTITION BY county
    ORDER BY model_year
)
```

This enables calculation of both absolute difference and percentage growth per county per year.

---

## Scalability

The current architecture is designed to scale with minimal changes:

| Component | Current | Future |
|-----------|---------|--------|
| Orchestration | Manual execution | Apache Airflow |
| Transformations | Raw SQL | dbt (Data Build Tool) |
| Database | Local PostgreSQL | AWS RDS / GCP Cloud SQL |
| Storage | Local CSV | S3 / GCS Data Lake |
| Dashboard | Power BI Desktop | Power BI Service (cloud) |
| Testing | None | pytest + dbt tests |

The layered architecture ensures that each component can be upgraded independently without affecting the rest of the pipeline.

---

*Documentation maintained by Ing. Matias Baigorria — [GitHub](https://github.com/matiasbaigorriaceleri)*
