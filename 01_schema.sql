-- ============================================================
-- HEALTH DYNAMICS OF INDIA 2023-24
-- MySQL Star Schema — Project 2
-- Source: Ministry of Health & Family Welfare (March 2024)
-- Author: Vikas
-- ============================================================

CREATE DATABASE IF NOT EXISTS health_india_2024;
USE health_india_2024;

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

CREATE TABLE dim_states (
    state_id        TINYINT UNSIGNED PRIMARY KEY,
    state_name      VARCHAR(60)  NOT NULL,
    state_category  ENUM('State','UT') NOT NULL
);

CREATE TABLE dim_facility_types (
    facility_type_id  TINYINT UNSIGNED PRIMARY KEY,
    facility_code     VARCHAR(20) NOT NULL,
    facility_name     VARCHAR(60) NOT NULL,
    care_level        VARCHAR(20) NOT NULL   -- Primary / Secondary / Tertiary
);

CREATE TABLE dim_area_types (
    area_type_id  TINYINT UNSIGNED PRIMARY KEY,
    area_type     VARCHAR(10) NOT NULL       -- Rural / Urban / Tribal
);

-- ============================================================
-- FACT TABLE 1 — Facility Counts (HDI_1 / HDI_4)
-- One row per state per area_type
-- ============================================================
CREATE TABLE fact_health_facilities (
    facility_count_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id           TINYINT UNSIGNED NOT NULL,
    num_districts      SMALLINT UNSIGNED,
    num_villages       INT UNSIGNED,
    sc_rural           INT UNSIGNED,
    sc_urban           SMALLINT UNSIGNED,
    sc_tribal          INT UNSIGNED,
    phc_rural          INT UNSIGNED,
    phc_urban          SMALLINT UNSIGNED,
    phc_tribal         SMALLINT UNSIGNED,
    chc_rural          SMALLINT UNSIGNED,
    chc_urban          SMALLINT UNSIGNED,
    chc_tribal         SMALLINT UNSIGNED,
    sdh_total          SMALLINT UNSIGNED,
    dh_total           SMALLINT UNSIGNED,
    medical_colleges_total SMALLINT UNSIGNED,
    FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

-- ============================================================
-- FACT TABLE 2 — Population & Facility Shortfall (HDI_4 Table 4)
-- SC/PHC/CHC required vs in-position in Rural areas
-- ============================================================
CREATE TABLE fact_population_shortfall (
    shortfall_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id        TINYINT UNSIGNED NOT NULL,
    rural_pop_est   INT UNSIGNED,          -- Estimated mid-year rural population 2024
    sc_required     INT UNSIGNED,          -- SC needed per IPHS norm (1 per 5,000 rural pop)
    sc_in_position  INT UNSIGNED,
    sc_shortfall    INT UNSIGNED,          -- NULL = surplus
    phc_required    INT UNSIGNED,
    phc_in_position INT UNSIGNED,
    phc_shortfall   INT UNSIGNED,
    chc_required    INT UNSIGNED,
    chc_in_position INT UNSIGNED,
    chc_shortfall   INT UNSIGNED,
    FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

-- ============================================================
-- FACT TABLE 3 — PHC Buildings by State & Area (HDI_6 Tables 22-24)
-- ============================================================
CREATE TABLE fact_phc_buildings (
    phc_bldg_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id        TINYINT UNSIGNED NOT NULL,
    area_type_id    TINYINT UNSIGNED NOT NULL,
    total_phcs      SMALLINT UNSIGNED,
    govt_bldg       SMALLINT UNSIGNED,
    rented_bldg     SMALLINT UNSIGNED,
    panchayat_bldg  SMALLINT UNSIGNED,
    to_construct    SMALLINT UNSIGNED,
    FOREIGN KEY (state_id)     REFERENCES dim_states(state_id),
    FOREIGN KEY (area_type_id) REFERENCES dim_area_types(area_type_id)
);

-- ============================================================
-- FACT TABLE 4 — PHC Infrastructure Rural (HDI_6 Table 25)
-- ============================================================
CREATE TABLE fact_phc_infrastructure_rural (
    phc_infra_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id             TINYINT UNSIGNED NOT NULL,
    total_phcs           SMALLINT UNSIGNED,
    phcs_functioning_24x7 SMALLINT UNSIGNED,
    with_labour_room     SMALLINT UNSIGNED,
    with_functional_ot   SMALLINT UNSIGNED,
    FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

-- ============================================================
-- FACT TABLE 5 — PHC Doctor Staffing Rural (HDI_6 Table 33)
-- ============================================================
CREATE TABLE fact_phc_staffing_rural (
    phc_staff_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id        TINYINT UNSIGNED NOT NULL,
    total_rural_phcs SMALLINT UNSIGNED,
    mo_sanctioned   SMALLINT UNSIGNED,
    mo_in_position  SMALLINT UNSIGNED,
    mo_vacant       SMALLINT UNSIGNED,
    mo_shortfall    SMALLINT UNSIGNED,     -- NULL = surplus
    FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

-- ============================================================
-- FACT TABLE 6 — CHC Human Resources In-Position (HDI_7)
-- One row per state; all values = In Position count
-- ============================================================
CREATE TABLE fact_chc_human_resources (
    chc_hr_id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id                TINYINT UNSIGNED NOT NULL,
    -- ANM at SC
    anm_sc_rural            INT UNSIGNED,
    anm_sc_tribal           INT UNSIGNED,
    -- HW Male at SC
    hwm_sc_rural            INT UNSIGNED,
    hwm_sc_urban            INT UNSIGNED,
    hwm_sc_tribal           INT UNSIGNED,
    -- CHO at SC
    cho_sc_total            INT UNSIGNED,
    -- MO at PHC
    mo_phc_rural            INT UNSIGNED,
    mo_phc_urban            INT UNSIGNED,
    mo_phc_tribal           INT UNSIGNED,
    -- CHC Specialists (Rural)
    surgeons_chc_rural      SMALLINT UNSIGNED,
    ob_gyn_chc_rural        SMALLINT UNSIGNED,
    physicians_chc_rural    SMALLINT UNSIGNED,
    paediatricians_chc_rural SMALLINT UNSIGNED,
    anaesthetists_chc_rural  SMALLINT UNSIGNED,
    gdmo_chc_rural          SMALLINT UNSIGNED,
    nursing_chc_rural       INT UNSIGNED,
    -- CHC Specialists (Urban)
    surgeons_chc_urban      SMALLINT UNSIGNED,
    ob_gyn_chc_urban        SMALLINT UNSIGNED,
    physicians_chc_urban    SMALLINT UNSIGNED,
    paediatricians_chc_urban SMALLINT UNSIGNED,
    anaesthetists_chc_urban  SMALLINT UNSIGNED,
    gdmo_chc_urban          SMALLINT UNSIGNED,
    nursing_chc_urban       INT UNSIGNED,
    -- CHC Specialists (Tribal)
    surgeons_chc_tribal     SMALLINT UNSIGNED,
    ob_gyn_chc_tribal       SMALLINT UNSIGNED,
    physicians_chc_tribal   SMALLINT UNSIGNED,
    paediatricians_chc_tribal SMALLINT UNSIGNED,
    anaesthetists_chc_tribal  SMALLINT UNSIGNED,
    gdmo_chc_tribal         SMALLINT UNSIGNED,
    nursing_chc_tribal      INT UNSIGNED,
    FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

-- ============================================================
-- FACT TABLE 7 — CHC Specialist Staffing Rural (Sanctioned + In Position)
-- Combined table with one row per state per specialist role
-- ============================================================
CREATE TABLE fact_chc_specialists_rural (
    specialist_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    state_id        TINYINT UNSIGNED NOT NULL,
    specialist_role VARCHAR(30) NOT NULL,   -- Paediatrician / Anaesthetist / GDMO / Radiographer / Nursing / Pharmacist / Lab_Tech
    chcs_total      SMALLINT UNSIGNED,
    required        SMALLINT UNSIGNED,      -- NULL if not applicable
    sanctioned      SMALLINT UNSIGNED,
    in_position     SMALLINT UNSIGNED,
    vacant          SMALLINT UNSIGNED,
    shortfall       SMALLINT UNSIGNED,      -- NULL = surplus
    FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

-- ============================================================
-- FACT TABLE 8 — CHC Surgeons Urban (HDI_7 Table 78) — summary
-- ============================================================
-- All India: Total CHCs=788, Sanctioned=496, In Position=254, Vacant=244

-- ============================================================
-- INDEXES for query performance
-- ============================================================
CREATE INDEX idx_phc_state  ON fact_phc_staffing_rural(state_id);
CREATE INDEX idx_pop_state  ON fact_population_shortfall(state_id);
CREATE INDEX idx_phc_infra  ON fact_phc_infrastructure_rural(state_id);
CREATE INDEX idx_phcb_state ON fact_phc_buildings(state_id, area_type_id);
CREATE INDEX idx_spec_role  ON fact_chc_specialists_rural(specialist_role);

