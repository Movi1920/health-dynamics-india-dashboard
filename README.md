# health-dynamics-india-dashboard
End-to-end healthcare analytics — MySQL + Power BI dashboard on India NHM 2023-24 data
# Health Dynamics of India 2023-24
### End-to-End Healthcare Analytics | MySQL + Power BI

## Project Overview
An end-to-end data analytics project analyzing India's rural healthcare infrastructure crisis using National Health Mission (NHM) data 2023-24. The project covers data extraction from government reports, database design, SQL analysis, and an interactive Power BI dashboard.

**Tools Used:** MySQL | Power BI | Python | Excel  
**Data Source:** National Health Mission, Government of India 2023-24  
**Dataset:** 36 Indian states and union territories | 7 fact tables | Star schema

---

## Business Questions Answered

1. Which states have the highest PHC doctor shortfall and vacancy rate?
2. How does India's doctors-per-1000-population compare to the WHO benchmark of 1.0?
3. Which states have the lowest Operation Theatre (OT) availability at PHCs?
4. What is the specialist vacancy rate at Community Health Centres (CHC) by state?
5. How is PHC building ownership distributed across states (govt vs rented vs panchayat)?
6. Which states face the most critical combined healthcare infrastructure crisis?
7. What is the rural population vs healthcare facility shortfall by state?

---

## Dashboard Pages

| Page | Title | Key Visuals |
|------|-------|-------------|
| 1 | Executive Summary | KPI cards, Top 10 states by doctor shortfall |
| 2 | Staffing Crisis | Doctor vacancy % and specialist vacancy % by state |
| 3 | Infrastructure Readiness | PHC building ownership, OT availability bottom 10 states |
| 4 | WHO Benchmark Analysis | PHC doctor shortfall vs WHO standard, national average KPI |

**Features:** Page navigation, custom state-level tooltip, dark theme

---

## Database Schema
Star schema with `dim_states` as central dimension connected to 7 fact tables covering PHC staffing, CHC specialists, infrastructure, buildings, population shortfall, health facilities, and human resources.

---

## Key Findings
- India's national average: **0.09 doctors per 1,000 rural population** vs WHO standard of 1.0 — **10x below benchmark**
- **Zero Indian states** meet the WHO minimum standard
- Uttar Pradesh has the highest PHC doctor shortfall: **3,002 positions vacant**
- National doctor vacancy rate: **24.59%** | Specialist vacancy rate: **30.13%**
- Only **22.29%** of PHCs have functional Operation Theatres
