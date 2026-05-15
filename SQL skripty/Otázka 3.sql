-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH prices AS (
    SELECT DISTINCT
        year,
        food_category,
        avg_price
    FROM t_rudolf_preiss_project_sql_primary_final trppspf
    WHERE avg_price IS NOT NULL
),
yoy_growth AS (
    SELECT
        food_category,
        (((avg_price - LAG(avg_price) OVER (PARTITION BY food_category ORDER BY year )) / 
        LAG(avg_price) OVER (PARTITION BY food_category ORDER BY year)) * 100)::numeric AS percentage_change
    FROM prices
),
final AS (
    SELECT
        food_category,
        ROUND(AVG(percentage_change), 2) AS percentage_change
    FROM yoy_growth
    WHERE percentage_change IS NOT NULL
    GROUP BY food_category 
)
SELECT *
FROM final
WHERE percentage_change > 0 
ORDER BY percentage_change ASC
LIMIT 1;