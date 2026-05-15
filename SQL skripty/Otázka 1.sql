
--Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH wages_first_year AS (
    SELECT 
        industry_branch,
        avg_wage AS wage_2006
    FROM t_rudolf_preiss_project_sql_primary_final 
    WHERE year = (SELECT MIN(year) FROM t_rudolf_preiss_project_sql_primary_final)
    GROUP BY industry_branch, avg_wage 
),
wages_last_year AS (
    SELECT 
        industry_branch,
        avg_wage AS wage_2018
    FROM t_rudolf_preiss_project_sql_primary_final 
    WHERE year = (SELECT MAX(year) FROM t_rudolf_preiss_project_sql_primary_final)
    GROUP BY industry_branch, avg_wage
)
SELECT 
    wfy.industry_branch,
    wfy.wage_2006,
    wly.wage_2018, 
    (wly.wage_2018 - wfy.wage_2006) AS wage_diff_absolute,
    ROUND(((wly.wage_2018 - wfy.wage_2006) / wfy.wage_2006) * 100, 2) AS percentage_wage_change
FROM wages_first_year wfy 
JOIN wages_last_year wly ON wfy.industry_branch = wly.industry_branch 
ORDER BY percentage_wage_change DESC;
