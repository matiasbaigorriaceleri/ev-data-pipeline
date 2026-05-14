DROP TABLE IF EXISTS curated_electric_vehicle_population;

CREATE TABLE curated_electric_vehicle_population AS

SELECT
    vin_110,
    TRIM(county) AS county,
    TRIM(city) AS city,
    state,
    postal_code,
    model_year,
    UPPER(make) AS make,
    UPPER(model) AS model,
    electric_vehicle_type,
    clean_alternative_fuel_vehicle_cafv_eligibility AS cafv_eligibility,
    electric_range,
    legislative_district,
    dol_vehicle_id,
    vehicle_location,
    electric_utility,
    "2020_census_tract"

FROM raw_electric_vehicle_population

WHERE model_year IS NOT NULL;