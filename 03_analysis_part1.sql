USE health_india_2024;

SELECT 'dim_states'                  AS table_name, COUNT(*) AS row_count FROM dim_states
UNION ALL
SELECT 'dim_facility_types',          COUNT(*) FROM dim_facility_types
UNION ALL
SELECT 'dim_area_types',              COUNT(*) FROM dim_area_types
UNION ALL
SELECT 'fact_health_facilities',      COUNT(*) FROM fact_health_facilities
UNION ALL
SELECT 'fact_population_shortfall',   COUNT(*) FROM fact_population_shortfall
UNION ALL
SELECT 'fact_phc_buildings',          COUNT(*) FROM fact_phc_buildings
UNION ALL
SELECT 'fact_phc_infrastructure_rural', COUNT(*) FROM fact_phc_infrastructure_rural
UNION ALL
SELECT 'fact_phc_staffing_rural',     COUNT(*) FROM fact_phc_staffing_rural
UNION ALL
SELECT 'fact_chc_specialists_rural',  COUNT(*) FROM fact_chc_specialists_rural
UNION ALL
SELECT 'fact_chc_human_resources',    COUNT(*) FROM fact_chc_human_resources;