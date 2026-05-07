
-- kontrola, které evropské země jsou v tabulce countries a nejsou v tabulce economies

SELECT 
    distinct(c.country)
FROM countries c
LEFT JOIN economies e 
    ON c.country  = e.country 
WHERE c.continent = 'Europe' 
  AND e.country IS NULL; 

-- spojení tabulek economies a countries pro evropské země

CREATE TABLE "t_Rudolf_Preiss_project_SQL_secondary_final" AS
SELECT 
    e.country, 
    e.year, 
    e.gdp, 
    e.population, 
    c.continent 
FROM economies e 
LEFT JOIN (
    SELECT DISTINCT country, continent 
    FROM countries c 
) c ON c.country = e.country 
WHERE c.continent = 'Europe';