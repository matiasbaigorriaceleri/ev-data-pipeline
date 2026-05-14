# Electric Vehicle Data Pipeline

A complete **end-to-end Data Engineering pipeline** built to ingest, transform, and visualize Electric Vehicle population data using Python, PostgreSQL, and Power BI.

---

## Project Overview

This project was developed as a technical challenge to demonstrate real-world Data Engineering skills. It covers the full data lifecycle:

- **Ingestion** of a public CSV dataset into a relational database
- **Transformation** through a curated data layer and analytical SQL views
- **Visualization** via an interactive Power BI dashboard

**Dataset used:** [Electric Vehicle Population Data](https://catalog.data.gov/dataset/electric-vehicle-population-data) — 280,833 records

---

## Architecture

```
CSV Raw Data
     ↓
Python Ingestion Pipeline  (load.py)
     ↓
PostgreSQL — Raw Layer     (raw_electric_vehicle_population)
     ↓
PostgreSQL — Curated Layer (curated_electric_vehicle_population)
     ↓
Analytical Views           (SQL Window Functions + Aggregations)
     ↓
Power BI Dashboard         (DirectQuery)
```

---

## Tech Stack

| Layer             | Technology                        |
|-------------------|-----------------------------------|
| Ingestion         | Python 3.12, Pandas, SQLAlchemy   |
| Database          | PostgreSQL 17                     |
| Transformation    | SQL (Window Functions, CTEs)      |
| Visualization     | Power BI Desktop (DirectQuery)    |
| DB Driver         | psycopg2                          |

---

## Project Structure

```
ev-data-pipeline/
│
├── data/
│   └── Electric_Vehicle_Population_Data.csv
│
├── ingestion/
│   └── load.py                  # Python ingestion script
│
├── sql/
│   ├── 01_raw_layer.sql         # Raw table creation
│   ├── 02_curated_layer.sql     # Curated table transformation
│   ├── 03_view_registrations_by_year.sql
│   ├── 04_view_top_ev_models.sql
│   ├── 05_view_cafv_geographic.sql
│   └── 06_view_yoy_by_county.sql
│
├── dashboard/
│   └── ev_dashboard.pbix        # Power BI dashboard file
│
├── doc/
│   └── architecture.md          # Architecture documentation
│
├── requirements.txt
└── README.md
```

---

## Getting Started

### Prerequisites

- Python 3.12+
- PostgreSQL 17
- Power BI Desktop

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/ev-data-pipeline.git
cd ev-data-pipeline
```

### 2. Set up the Python environment

```bash
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS/Linux

pip install -r requirements.txt
```

### 3. Set up PostgreSQL

Create the database and user:

```sql
CREATE DATABASE ev_db;
CREATE USER ev_user WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE ev_db TO ev_user;
```

### 4. Configure your connection

Edit the connection string inside `ingestion/load.py`:

```python
DATABASE_URL = "postgresql://ev_user:admin123@localhost:5432/ev_db"
```

### 5. Run the ingestion pipeline

```bash
python ingestion/load.py
```

Expected output:

```
Data loaded successfully into table: raw_electric_vehicle_population
Total rows loaded: 280833
```

### 6. Run the SQL transformations

Execute the scripts in the `sql/` folder in order (01 → 06) using your PostgreSQL client (pgAdmin, DBeaver, or psql).

### 7. Connect Power BI

Open `dashboard/ev_dashboard.pbix` in Power BI Desktop and update the PostgreSQL connection to point to your local server.

---

## Analytical Views

| View | Description |
|------|-------------|
| `vw_ev_registrations_by_year`    | EV registrations count grouped by model year |
| `vw_top_ev_models`               | Top 10 EV models by registration volume |
| `vw_cafv_geographic_distribution`| CAFV-eligible vehicles by county and state |
| `vw_ev_yoy_by_county`            | Year-over-year registration change per county using `LAG()` |

---

## Dashboard Preview

The Power BI dashboard includes:

- **EV Registrations Trend** — Line chart showing yearly growth
- **Top 10 Electric Vehicle Models** — Bar chart with manufacturer comparison
- **CAFV Geographic Distribution** — Interactive map by county/state

---

## Key SQL Concepts Used

- `GROUP BY` + `COUNT(*)` for aggregations
- `LAG()` window function for year-over-year analysis
- `PARTITION BY county ORDER BY model_year` for per-county growth tracking
- Analytical views for dashboard decoupling

---

## Requirements

```
pandas
sqlalchemy
psycopg2-binary
```

Install with:

```bash
pip install -r requirements.txt
```

---

## Future Improvements

- [ ] Orchestration with **Apache Airflow**
- [ ] Transformations with **dbt**
- [ ] Cloud migration to **AWS RDS** or **GCP BigQuery**
- [ ] CI/CD pipeline for automated data refresh
- [ ] Unit tests for ingestion logic

---

## Author

**Ing. Matias Baigorria**
Data Engineer — passionate about building scalable, clean, and production-ready data solutions.

[![LinkedIn](https://www.linkedin.com/in/matiasbaigorriaceleri/)]
[![GitHub](https://github.com/matiasbaigorriaceleri)]

---

## License

This project is open source and available under the [MIT License](LICENSE).
