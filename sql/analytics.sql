-- =====================================================
-- VIEW 1 - Registrations by Year
-- =====================================================

DROP VIEW IF EXISTS vw_ev_registrations_by_year;

CREATE VIEW vw_ev_registrations_by_year AS

SELECT
    model_year,
    COUNT(*) AS total_registrations
FROM curated_electric_vehicle_population
GROUP BY model_year
ORDER BY model_year;

-- =====================================================
-- VIEW 2 - Top 10 EV Models
-- =====================================================

DROP VIEW IF EXISTS vw_top_ev_models;

CREATE VIEW vw_top_ev_models AS

SELECT
    make,
    model,
    COUNT(*) AS registration_count
FROM curated_electric_vehicle_population
GROUP BY make, model
ORDER BY registration_count DESC
LIMIT 10;


-- =====================================================
-- VIEW 3 - CAFV Geographic Distribution
-- =====================================================

DROP VIEW IF EXISTS vw_cafv_geographic_distribution;

CREATE VIEW vw_cafv_geographic_distribution AS

SELECT
    county,
    state,
    COUNT(*) AS cafv_eligible_vehicles
FROM curated_electric_vehicle_population
WHERE cafv_eligibility ILIKE '%Eligible%'
GROUP BY county, state
ORDER BY cafv_eligible_vehicles DESC;



-- =====================================================
-- VIEW 4 - Year over Year Registrations by County
-- =====================================================

DROP VIEW IF EXISTS vw_ev_yoy_by_county;

CREATE VIEW vw_ev_yoy_by_county AS

WITH yearly_registrations AS (

    SELECT
        county,
        model_year,
        COUNT(*) AS registration_count
    FROM curated_electric_vehicle_population
    GROUP BY county, model_year

),

yoy_analysis AS (

    SELECT
        county,
        model_year,
        registration_count,

        LAG(registration_count)
        OVER (
            PARTITION BY county
            ORDER BY model_year
        ) AS previous_year_count

    FROM yearly_registrations

)

SELECT
    county,
    model_year,
    registration_count,
    previous_year_count,

    registration_count - previous_year_count
        AS yoy_difference,

    ROUND(
        (
            (registration_count - previous_year_count)::numeric
            / NULLIF(previous_year_count, 0)
        ) * 100,
        2
    ) AS yoy_percentage_change

FROM yoy_analysis

ORDER BY county, model_year;