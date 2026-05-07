--SQL dotaz který sjednocuje data o mzdách a cenách potravin 

CREATE TABLE "t_Rudolf_Preiss_project_SQL_primary_final" AS
WITH v_payroll AS (
	SELECT 
        cp.payroll_year AS rok,
        cpib.name AS odvetvi,
        ROUND(AVG(cp.value)) AS prumerna_mzda
    FROM czechia_payroll cp
    LEFT JOIN czechia_payroll_industry_branch  cpib 
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958 
      AND cp.calculation_code = 200
      AND cp.value IS NOT NULL
    GROUP BY cp.payroll_year, cpib.name
),
v_price AS (
    SELECT 
        EXTRACT(YEAR FROM cp.date_from) AS rok,
        cpc.name AS kategorie_potravin,
        AVG(cp.value) AS prumerna_cena,
        cpc.price_unit AS jednotka
    FROM czechia_price cp
    JOIN czechia_price_category cpc 
        ON cp.category_code = cpc.code
    WHERE cp.region_code IS NULL 
    GROUP BY rok, cpc.name, cpc.price_unit
)
SELECT 
    p.rok,
    p.odvetvi,
    p.prumerna_mzda,
    pr.kategorie_potravin,
    pr.prumerna_cena,
    pr.jednotka
FROM v_payroll p
LEFT JOIN v_price pr ON p.rok = pr.rok;