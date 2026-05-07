
--Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH mzdy_2000 AS (
    SELECT 
        odvetvi,
        prumerna_mzda AS mzda_start
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf 
    WHERE rok = 2000
    GROUP BY odvetvi, prumerna_mzda
),
mzdy_2021 AS (
    SELECT 
        odvetvi,
        prumerna_mzda AS mzda_end
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf 
    WHERE rok = 2021
    GROUP BY odvetvi, prumerna_mzda
)
SELECT 
    m1.odvetvi AS název_odvětví,
    m1.mzda_start AS průměrná_mzda_2000,
    m2.mzda_end AS průměrná_mzda_2021,
    (m2.mzda_end - m1.mzda_start) AS nárůst_mzdy_v_kč,
    ROUND(((m2.mzda_end - m1.mzda_start)::numeric / m1.mzda_start) * 100, 2) AS procentuální_nárůst
FROM mzdy_2000 m1
JOIN mzdy_2021 m2 ON m1.odvetvi = m2.odvetvi
ORDER BY procentuální_nárůst DESC;
