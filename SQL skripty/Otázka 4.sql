-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH wages AS (
    SELECT 
        year, 
        avg_wage AS avg_wages
    FROM t_rudolf_preiss_project_sql_primary_final trppspf
    WHERE industry_branch IS NULL
    GROUP BY year, avg_wage
),
prices AS (
    SELECT 
        year, 
        AVG(avg_price) AS avg_prices
    FROM (
        SELECT DISTINCT year, food_category, avg_price
        FROM t_rudolf_preiss_project_sql_primary_final trppspf
        )
    GROUP BY year
),
growth AS (
    SELECT 
        w.year,
        ((w.avg_wages - LAG(w.avg_wages) OVER (ORDER BY w.year)) / LAG(w.avg_wages) OVER (ORDER BY w.year) * 100)::numeric AS wage_growth,
        ((p.avg_prices - LAG(p.avg_prices) OVER (ORDER BY p.year)) / LAG(p.avg_prices) OVER (ORDER BY p.year) * 100)::numeric AS price_growth
    FROM wages w
    JOIN prices p ON w.year = p.year
)
SELECT 
    year,
    ROUND(wage_growth, 2) AS wage_growth,
    ROUND(price_growth, 2) AS price_growth,
    ROUND(price_growth - wage_growth, 2) AS wages_prices_diff
FROM growth
WHERE wage_growth IS NOT NULL 
  AND price_growth IS NOT NULL
ORDER BY year;