import pandas as pd
from sqlalchemy import create_engine

# =========================
# Read CSV
# =========================

file_path = "data/raw/Electric_Vehicle_Population_Data.csv"

df = pd.read_csv(file_path)

# =========================
# Normalize column names
# =========================

df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
    .str.replace(r"[^\w]", "", regex=True)
)

# =========================
# PostgreSQL connection
# =========================

connection_string = (
    "postgresql+psycopg2://postgres:admin123@127.0.0.1:5432/ev_pipeline"
)

engine = create_engine(connection_string)

# =========================
# Load into PostgreSQL
# =========================

table_name = "raw_electric_vehicle_population"

df.to_sql(
    table_name,
    engine,
    if_exists="replace",
    index=False
)

print(f"\nData loaded successfully into table: {table_name}")
print(f"Total rows loaded: {len(df)}")