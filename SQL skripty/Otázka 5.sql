-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?

CREATE VIEW Otazka_5_vw AS
WITH hdp AS (
    SELECT 
        year AS rok, 
        gdp,
        ((gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year) * 100) AS rust_hdp
    FROM "t_Rudolf_Preiss_project_SQL_secondary_final"
    WHERE country = 'Czech Republic'
),
mzdy AS (
    SELECT 
        rok, 
        prumerna_mzda,
        ((prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY rok)) / LAG(prumerna_mzda) OVER (ORDER BY rok) * 100) AS rust_mezd
    FROM "t_Rudolf_Preiss_project_SQL_primary_final"
    WHERE odvetvi IS NULL
    GROUP BY rok, prumerna_mzda
),
ceny AS (
    SELECT 
        rok, 
        AVG(prumerna_cena) AS avg_price
    FROM (SELECT DISTINCT rok, kategorie_potravin, prumerna_cena FROM "t_Rudolf_Preiss_project_SQL_primary_final") sub
    GROUP BY rok
),
ceny_rust AS (
    SELECT 
        rok,
        ((avg_price - LAG(avg_price) OVER (ORDER BY rok)) / LAG(avg_price) OVER (ORDER BY rok) * 100) AS rust_cen
    FROM ceny
)
SELECT 
    h.rok,
    ROUND(h.rust_hdp::numeric, 2) AS růst_hdp,
    ROUND(m.rust_mezd::numeric, 2) AS růst_mezd,
    ROUND(c.rust_cen::numeric, 2) AS růst_cen,
    ROUND(LEAD(m.rust_mezd) OVER (ORDER BY h.rok)::numeric, 2) AS růst_mezd_následující_rok,
    ROUND(LEAD(c.rust_cen) OVER (ORDER BY h.rok)::numeric, 2) AS růst_cen_následující_rok
FROM hdp h
LEFT JOIN mzdy m ON h.rok = m.rok
LEFT JOIN ceny_rust c ON h.rok = c.rok
WHERE h.rok BETWEEN 2001 AND 2020
ORDER BY h.rok;


-- druhá část (korelace)

SELECT
	ROUND(CORR(růst_hdp, růst_mezd)::numeric, 4) AS korelace_hdp_mzdy,
    ROUND(CORR(ov.růst_hdp, růst_cen)::numeric, 4) AS korelace_hdp_ceny,
	ROUND(CORR(růst_hdp, růst_mezd_následující_rok)::numeric, 4) AS zpožděná_korelace_hdp_mzdy,
    ROUND(CORR(ov.růst_hdp, růst_cen_následující_rok)::numeric, 4) AS zpožděná_korelace_hdp_ceny
 FROM otazka_5_vw ov;