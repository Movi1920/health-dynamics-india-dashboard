USE health_india_2024;

SELECT
    RANK() OVER (ORDER BY p.mo_shortfall DESC)   AS shortfall_rank,
    s.state_name,
    s.state_category,
    p.total_rural_phcs,
    p.mo_sanctioned,
    p.mo_in_position,
    p.mo_vacant,
    p.mo_shortfall,
    ROUND(
        (p.mo_vacant / NULLIF(p.mo_sanctioned, 0)) * 100, 1
    ) AS vacancy_rate_pct,
    ROUND(
        (p.mo_in_position / NULLIF(p.total_rural_phcs, 0)), 2
    ) AS doctors_per_phc
FROM fact_phc_staffing_rural p
JOIN dim_states s ON p.state_id = s.state_id
WHERE p.mo_shortfall IS NOT NULL
  AND p.mo_shortfall > 0
ORDER BY p.mo_shortfall DESC
LIMIT 15;


USE health_india_2024;

SELECT
    s.state_name,
    b.area_type_id,
    a.area_type,
    b.total_phcs,
    b.govt_bldg,
    b.rented_bldg,
    b.panchayat_bldg,
    ROUND((b.govt_bldg / NULLIF(b.total_phcs, 0)) * 100, 1)      AS govt_pct,
    ROUND((b.rented_bldg / NULLIF(b.total_phcs, 0)) * 100, 1)    AS rented_pct,
    ROUND((b.panchayat_bldg / NULLIF(b.total_phcs, 0)) * 100, 1) AS panchayat_pct
FROM fact_phc_buildings b
JOIN dim_states   s ON b.state_id    = s.state_id
JOIN dim_area_types a ON b.area_type_id = a.area_type_id
WHERE b.total_phcs IS NOT NULL
  AND b.total_phcs > 0
ORDER BY b.rented_bldg DESC, s.state_name;


USE health_india_2024;

SELECT
    s.state_name,
    p.rural_pop_est,
    p.sc_required,
    p.sc_in_position,
    p.sc_shortfall,
    ROUND(p.rural_pop_est / NULLIF(p.sc_in_position, 0))   AS actual_pop_per_sc,
    5000                                                    AS iphs_norm_pop_per_sc,
    CASE
    
        WHEN p.sc_shortfall IS NULL THEN 'SURPLUS — exceeds requirement'
        WHEN p.sc_in_position >= p.sc_required THEN 'MET'
        WHEN (p.sc_required - p.sc_in_position) / p.sc_required >= 0.30 THEN 'CRITICAL SHORTAGE (>30%)'
        ELSE 'SHORTAGE'
    END AS coverage_status
FROM fact_population_shortfall p
JOIN dim_states s ON p.state_id = s.state_id
WHERE p.rural_pop_est > 0
ORDER BY actual_pop_per_sc DESC;



USE health_india_2024;

SELECT
    s.state_name,
    i.total_phcs,
    i.phcs_functioning_24x7,
    ROUND((i.phcs_functioning_24x7 / NULLIF(i.total_phcs, 0)) * 100, 1) AS pct_24x7,
    p.mo_in_position,
    p.mo_sanctioned,
    p.mo_vacant,
    ROUND((p.mo_vacant / NULLIF(p.mo_sanctioned, 0)) * 100, 1)          AS mo_vacancy_pct,
    CASE
        WHEN ROUND((i.phcs_functioning_24x7/NULLIF(i.total_phcs,0))*100,1) < 50
         AND ROUND((p.mo_vacant/NULLIF(p.mo_sanctioned,0))*100,1) > 40
        THEN '⚠ DOUBLE CRISIS'
        WHEN ROUND((i.phcs_functioning_24x7/NULLIF(i.total_phcs,0))*100,1) < 50
        THEN 'Low 24x7 Coverage'
        WHEN ROUND((p.mo_vacant/NULLIF(p.mo_sanctioned,0))*100,1) > 40
        THEN 'High Doctor Vacancy'
        ELSE 'Adequate'
    END AS crisis_flag
FROM fact_phc_infrastructure_rural i
JOIN fact_phc_staffing_rural        p ON i.state_id = p.state_id
JOIN dim_states                     s ON i.state_id = s.state_id
WHERE i.total_phcs IS NOT NULL AND i.total_phcs > 0
ORDER BY pct_24x7 ASC, mo_vacancy_pct DESC;

USE health_india_2024;

-- PHC vs CHC OT availability comparison
SELECT
    s.state_name,
    'PHC' AS facility_type,
    i.total_phcs            AS total_facilities,
    i.with_functional_ot    AS with_ot,
    ROUND((i.with_functional_ot / NULLIF(i.total_phcs, 0)) * 100, 1) AS ot_availability_pct
FROM fact_phc_infrastructure_rural i
JOIN dim_states s ON i.state_id = s.state_id
WHERE i.total_phcs IS NOT NULL AND i.total_phcs > 0

UNION ALL

SELECT
    'All India' AS state_name,
    'CHC Rural' AS facility_type,
    5639        AS total_facilities,
    3830        AS with_ot,
    67.9        AS ot_availability_pct

UNION ALL

SELECT
    'All India' AS state_name,
    'CHC Urban' AS facility_type,
    788         AS total_facilities,
    568         AS with_ot,
    72.1        AS ot_availability_pct

ORDER BY facility_type, ot_availability_pct ASC;


USE health_india_2024;

-- Step 1: Government sector doctor breakdown
WITH govt_doctors AS (
    SELECT 'MO at Rural PHC'                    AS source, 29949 AS in_position_doctors
    UNION ALL SELECT 'Surgeons+Specialists at CHC Rural', 5223
    UNION ALL SELECT 'GDMO (Allopathic) at CHC Rural',   16483
    UNION ALL SELECT 'MO at PHC Urban (est.)',            6300
),
total_govt AS (
    SELECT SUM(in_position_doctors) AS total_govt_doctors FROM govt_doctors
)
SELECT
    g.source,
    g.in_position_doctors,
    ROUND(g.in_position_doctors * 100.0 / t.total_govt_doctors, 1) AS pct_of_total
FROM govt_doctors g
CROSS JOIN total_govt t;



SELECT 
    'India – All Registered (NMC 2023)'      AS comparison, 
    1.34  AS doctors_millions, 
    1.42  AS population_billions, 
    ROUND(1340000/1420000.0, 3)              AS doctors_per_1000, 
    IF(1340000/1420000.0 >= 1,'YES','NO')    AS who_standard_met
UNION ALL
SELECT 'India – Govt Primary+CHC (HDI 2024)', 0.058, 1.42, ROUND(58000/1420000.0, 3), IF(58000/1420000.0 >= 1,'YES','NO')
UNION ALL
SELECT 'WHO Standard',                NULL, NULL, 1.000, 'BENCHMARK'
UNION ALL
SELECT 'China (2022 est.)',           NULL, NULL, 3.310, 'YES'
UNION ALL
SELECT 'Russia (2022 est.)',          NULL, NULL, 4.010, 'YES'
UNION ALL
SELECT 'United States (2022 est.)',   NULL, NULL, 2.640, 'YES';


USE health_india_2024;

SELECT
    s.state_name,
    p.rural_pop_est,
    ps.mo_in_position                                              AS phc_mo_in_position,
    ROUND(p.rural_pop_est / NULLIF(ps.mo_in_position, 0))         AS rural_persons_per_phc_mo,
    ROUND(ps.mo_in_position / NULLIF(p.rural_pop_est, 0) * 1000, 3) AS phc_mo_per_1000_rural_pop,
    CASE
        WHEN (ps.mo_in_position / NULLIF(p.rural_pop_est, 0) * 1000) >= 1.0 THEN '✓ Meets WHO standard'
        WHEN (ps.mo_in_position / NULLIF(p.rural_pop_est, 0) * 1000) >= 0.5 THEN 'Moderate gap'
        ELSE '✗ Critical gap'
    END AS who_status
FROM fact_population_shortfall  p
JOIN fact_phc_staffing_rural    ps ON p.state_id = ps.state_id
JOIN dim_states                  s  ON p.state_id = s.state_id
WHERE p.rural_pop_est > 0
  AND ps.mo_in_position IS NOT NULL
ORDER BY phc_mo_per_1000_rural_pop ASC;



USE health_india_2024;

WITH anaesthetist_ranked AS (
    SELECT
        s.state_name,
        sp.sanctioned,
        sp.in_position,
        sp.vacant,
        ROUND((sp.vacant / NULLIF(sp.sanctioned, 0)) * 100, 1) AS vacancy_rate_pct,
        RANK() OVER (ORDER BY sp.vacant DESC)                   AS vacancy_rank
    FROM fact_chc_specialists_rural sp
    JOIN dim_states s ON sp.state_id = s.state_id
    WHERE sp.specialist_role = 'Anaesthetist'
      AND sp.sanctioned IS NOT NULL
      AND sp.sanctioned > 0
)
SELECT
    vacancy_rank,
    state_name,
    sanctioned,
    in_position,
    vacant,
    vacancy_rate_pct,
    LAG(vacancy_rate_pct) OVER (ORDER BY vacancy_rank)       AS prev_state_vacancy_pct,
    ROUND(
        vacancy_rate_pct - LAG(vacancy_rate_pct) OVER (ORDER BY vacancy_rank),
        1
    )                                                        AS gap_vs_prev_state_pct
FROM anaesthetist_ranked
ORDER BY vacancy_rank
LIMIT 15;