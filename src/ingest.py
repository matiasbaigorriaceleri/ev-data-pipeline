import pandas as pd

# Path del archivo CSV
file_path = "data/raw/Electric_Vehicle_Population_Data.csv"

# Leer CSV
df = pd.read_csv(file_path)

# Mostrar primeras filas
print("\nFirst 5 rows:\n")
print(df.head())

# Mostrar estructura
print("\nDataset info:\n")
print(df.info())

# Mostrar columnas
print("\nColumns:\n")
print(df.columns)

# Mostrar cantidad de registros
print(f"\nTotal records: {len(df)}")