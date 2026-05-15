--SQL dotaz který sjednocuje data o mzdách a cenách potravin 

CREATE TABLE t_rudolf_preiss_project_SQL_primary_final AS
WITH payroll AS (
	SELECT 
        cp.payroll_year AS payroll_year,
        cpib.name AS industry_branch,
        ROUND(AVG(cp.value)) AS avg_wage
    FROM czechia_payroll cp
    LEFT JOIN czechia_payroll_industry_branch  cpib 
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958 
      AND cp.calculation_code = 200
      AND cp.value IS NOT NULL
    GROUP BY cp.payroll_year, cpib.name
),
prices AS (
    SELECT 
        EXTRACT(YEAR FROM cp.date_from) AS prices_year,
        cpc.name AS food_category,
        AVG(cp.value) AS avg_price,
        cpc.price_unit AS unit
    FROM czechia_price cp
    JOIN czechia_price_category cpc 
        ON cp.category_code = cpc.code
    WHERE cp.region_code IS NULL 
    GROUP BY prices_year, cpc.name, cpc.price_unit
)
SELECT 
    p.payroll_year AS year,
    p.industry_branch,
    p.avg_wage,
    pr.food_category,
    pr.avg_price,
    pr.unit 
FROM payroll p
INNER JOIN prices pr ON p.payroll_year = pr.prices_year;