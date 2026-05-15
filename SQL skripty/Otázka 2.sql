--Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


WITH range_years AS (
    SELECT 
        MIN(year) AS first_year, 
        MAX(year) AS last_year 
    FROM t_rudolf_preiss_project_sql_primary_final trppspf 
)
SELECT 
    year,
    food_category,
    avg_wage,
    ROUND(avg_price::numeric , 2) AS avg_price ,
    FLOOR(avg_wage / avg_price) AS num_of_units_purchasable,
    unit
FROM t_rudolf_preiss_project_sql_primary_final trppspf 
JOIN range_years ry 
    ON trppspf.year = ry.first_year OR trppspf.year = ry.last_year
WHERE food_category IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
  AND industry_branch IS NULL
ORDER BY year, food_category;