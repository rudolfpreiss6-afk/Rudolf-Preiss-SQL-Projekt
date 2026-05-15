
-- kontrola, které evropské země jsou v tabulce countries a nejsou v tabulce economies

SELECT 
    DISTINCT(c.country)
FROM countries c
LEFT JOIN economies e 
    ON c.country  = e.country 
WHERE c.continent = 'Europe' 
  AND e.country IS NULL; 

-- spojení tabulek economies a countries pro evropské země

CREATE TABLE t_rudolf_preiss_project_SQL_secondary_final AS
SELECT 
    e.country, 
    e.year, 
    e.gdp, 
    e.population, 
    c.continent 
FROM economies e 
INNER JOIN (
    SELECT DISTINCT year 
    FROM t_rudolf_preiss_project_sql_primary_final trppspf 
) timeline ON e.year = timeline.year 
LEFT JOIN (
    SELECT DISTINCT country, continent 
    FROM countries c 
) c ON c.country = e.country 
WHERE c.continent = 'Europe'
ORDER BY e.country, e.year; 