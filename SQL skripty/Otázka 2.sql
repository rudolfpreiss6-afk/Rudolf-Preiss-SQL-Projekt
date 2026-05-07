--Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


WITH range_years AS (
    SELECT 
        MIN(rok) AS first_year, 
        MAX(rok) AS last_year 
    FROM "t_Rudolf_Preiss_project_SQL_primary_final"
    WHERE prumerna_cena IS NOT NULL
)
SELECT 
    trppspf.rok,
    trppspf.kategorie_potravin AS název_produktu,
    ROUND(trppspf.prumerna_mzda) AS průměrná_mzda,
    ROUND(trppspf.prumerna_cena) AS průměrná_cena_za_jednotku ,
    FLOOR(trppspf.prumerna_mzda / trppspf.prumerna_cena) AS množství_jednotek_k_nákupu,
    trppspf.jednotka
FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf
JOIN range_years ry 
    ON trppspf.rok = ry.first_year OR trppspf.rok = ry.last_year
WHERE trppspf.kategorie_potravin IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
  AND trppspf.odvetvi IS NULL
ORDER BY trppspf.rok ASC, trppspf.kategorie_potravin DESC;