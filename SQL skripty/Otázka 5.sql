-- Má výška HDP vliv na změny ve mzdách a cenách potravin?

-- první skript

CREATE VIEW question5_vw AS
WITH gdp AS (
    SELECT 
        year, 
        gdp,
        ((gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year) * 100) AS gdp_growth
    FROM t_rudolf_preiss_project_sql_secondary_final trppssf 
    WHERE country = 'Czech Republic'
),
wages AS (
    SELECT 
        year, 
        avg_wage,
        ((avg_wage - LAG(avg_wage) OVER (ORDER BY year)) / LAG(avg_wage) OVER (ORDER BY year) * 100) AS wage_growth
    FROM t_rudolf_preiss_project_sql_primary_final trppspf 
    WHERE industry_branch IS NULL
    GROUP BY year, avg_wage
),
prices AS (
    SELECT 
        year, 
        AVG(avg_price) AS avg_price
    FROM (SELECT DISTINCT year, food_category, avg_price FROM t_rudolf_preiss_project_sql_primary_final trppspf )
    GROUP BY year
),
prices_growth AS (
    SELECT 
        year,
        ((avg_price - LAG(avg_price) OVER (ORDER BY year)) / LAG(avg_price) OVER (ORDER BY year) * 100) AS price_growth
    FROM prices
)
SELECT 
    g.year,
    ROUND(g.gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(w.wage_growth::numeric, 2) AS wage_growth,
    ROUND(p.price_growth::numeric, 2) AS price_growth,
    ROUND(LEAD(w.wage_growth) OVER (ORDER BY g.year)::numeric, 2) AS wage_growth_next_year,
    ROUND(LEAD(p.price_growth) OVER (ORDER BY g.year)::numeric, 2) AS price_growth_next_year
FROM gdp g
JOIN wages w ON g.year = w.year
JOIN prices_growth p ON g.year = p.year
WHERE gdp_growth IS NOT NULL
ORDER BY g.year;


-- druhý skript (korelace)

SELECT
	ROUND(CORR(gdp_growth, wage_growth)::numeric, 4) AS corr_gdp_wage,
    ROUND(CORR(gdp_growth, price_growth)::numeric, 4) AS corr_gdp_price,
	ROUND(CORR(gdp_growth, wage_growth_next_year)::numeric, 4) AS lagged_corr_gdp_wage,
    ROUND(CORR(gdp_growth, price_growth_next_year)::numeric, 4) AS lagged_corr_gdp_price
 FROM question5_vw qv;
````