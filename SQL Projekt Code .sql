-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

SELECT 
    cp.payroll_year AS rok,
    cpib.name AS název_odvětví,
    ROUND(AVG(cp.value)::numeric, 0) AS průměrná_mzda
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib 
    ON cp.industry_branch_code = cpib.code
JOIN czechia_payroll_value_type cpvt 
    ON cp.value_type_code = cpvt.code AND cpvt.code = 5958
JOIN czechia_payroll_calculation cpc 
    ON cp.calculation_code = cpc.code AND cpc.code = 200
WHERE 
    cp.industry_branch_code IS NOT NULL
GROUP BY 
    cp.payroll_year, 
    cpib.name
ORDER BY 
    cpib.name, 
    cp.payroll_year;


WITH mzda_2000 AS (
    SELECT 
        industry_branch_code,
        ROUND(AVG(value)::numeric, 0) AS průměrná_mzda_2000
    FROM czechia_payroll
    WHERE payroll_year = 2000 
      AND value_type_code = 5958 
      AND calculation_code = 200
    GROUP BY industry_branch_code
),
mzda_2021 AS (
    SELECT 
        industry_branch_code,
        ROUND(AVG(value)::numeric, 0) AS průměrná_mzda_2021
    FROM czechia_payroll
    WHERE payroll_year = 2021 
      AND value_type_code = 5958 
      AND calculation_code = 200
    GROUP BY industry_branch_code
)
SELECT 
    cpib.name AS název_odvětví,
    m0.průměrná_mzda_2000,
    m21.průměrná_mzda_2021,
    m21.průměrná_mzda_2021 - m0.průměrná_mzda_2000 AS nárůst_mzdy_v_kč,
    ROUND(((m21.průměrná_mzda_2021 - m0.průměrná_mzda_2000) / m0.průměrná_mzda_2000::numeric) * 100, 2) AS procentuální_nárůst
FROM mzda_2000 m0
JOIN mzda_2021 m21 ON m0.industry_branch_code = m21.industry_branch_code
JOIN czechia_payroll_industry_branch cpib ON m0.industry_branch_code = cpib.code
ORDER BY procentuální_nárůst DESC;

-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH průměrná_mzda_výpočet AS (
    SELECT 
        payroll_year AS rok,
        AVG(value) AS prům_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958
      AND calculation_code = 200
      AND industry_branch_code IS NULL
    GROUP BY payroll_year
),
roční_ceny AS (
    SELECT 
        EXTRACT(YEAR FROM date_from) AS rok_ceny,
        category_code AS kód_kategorie,
        AVG(value) AS průměrná_cena
    FROM czechia_price
    WHERE category_code IN (111301, 114201)
      AND region_code IS NULL
    GROUP BY rok_ceny, kód_kategorie
),
srovnatelná_data AS (
    SELECT 
        mz.rok,
        ce.kód_kategorie,
        cpc.name AS název_produktu,
        cpc.price_unit AS jednotka_ceny,
        mz.prům_mzda,
        ce.průměrná_cena
    FROM průměrná_mzda_výpočet mz
    JOIN roční_ceny ce ON mz.rok = ce.rok_ceny
    JOIN czechia_price_category cpc ON ce.kód_kategorie = cpc.code
)
SELECT 
    rok,
     název_produktu,
    ROUND(prům_mzda::numeric, 0) AS průměrná_mzda,
    ROUND(průměrná_cena::numeric, 2) AS průměrná_cena,
    jednotka_ceny,
    FLOOR(prům_mzda / průměrná_cena) AS množství_k_nákupu
FROM srovnatelná_data
WHERE rok = (SELECT MIN(rok) FROM srovnatelná_data)
   OR rok = (SELECT MAX(rok) FROM srovnatelná_data)
ORDER BY rok, název_produktu;


-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 

WITH roční_ceny_potravin AS (
    SELECT 
        EXTRACT(YEAR FROM date_from) AS rok_srovnání,
        category_code AS kód_kategorie,
        AVG(value) AS průměrná_cena
    FROM czechia_price
    WHERE region_code IS NULL
    GROUP BY rok_srovnání, kód_kategorie
),
meziroční_růst AS (
    SELECT 
        rok_srovnání,
        kód_kategorie,
        průměrná_cena,
        LAG(průměrná_cena) OVER (PARTITION BY kód_kategorie ORDER BY rok_srovnání) AS předchozí_cena
    FROM roční_ceny_potravin
),
průměrný_růst_kategorie AS (
    SELECT 
        kód_kategorie,
        AVG((průměrná_cena - předchozí_cena) / předchozí_cena) * 100 AS průměrný_procentuální_růst
    FROM meziroční_růst
    WHERE předchozí_cena IS NOT NULL
    GROUP BY kód_kategorie
)
SELECT 
    cpc.name AS potravina,
    ROUND(prk.průměrný_procentuální_růst::numeric, 2) AS průměrný_roční_nárůst_v_procentech
FROM průměrný_růst_kategorie prk
JOIN czechia_price_category cpc ON prk.kód_kategorie = cpc.code
ORDER BY průměrný_roční_nárůst_v_procentech ASC;


-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?


WITH roční_mzdy AS (
    SELECT 
        payroll_year AS rok,
        AVG(value) AS průměrná_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958 
      AND calculation_code = 200
      AND industry_branch_code IS NULL
    GROUP BY rok
),
roční_ceny_celkem AS (
    SELECT 
        EXTRACT(YEAR FROM date_from) AS rok_ceny,
        AVG(value) AS průměrná_cena
    FROM czechia_price
    WHERE region_code IS NULL
    GROUP BY rok_ceny
),
výpočet_růstu AS (
    SELECT 
        m.rok,
        ((m.průměrná_mzda - LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) / LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) * 100 AS růst_mezd,
        ((c.průměrná_cena - LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) / LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) * 100 AS růst_cen
    FROM roční_mzdy m
    JOIN roční_ceny_celkem c ON m.rok = c.rok_ceny
)
SELECT 
    rok,
    ROUND(růst_mezd::numeric, 2) AS růst_mezd_v_procentech,
    ROUND(růst_cen::numeric, 2) AS růst_cen_potravin_v_procentech,
    ROUND((růst_cen - růst_mezd)::numeric, 2) AS rozdíl_v_procentech
FROM výpočet_růstu
WHERE (růst_cen - růst_mezd) > 10
ORDER BY rok;


-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?

WITH roční_hdp AS (
    SELECT 
        year AS rok,
        gdp AS hdp,
        ((gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year)) * 100 AS růst_hdp
    FROM economies
    WHERE country = 'Czech Republic'
),
roční_mzdy AS (
    SELECT 
        payroll_year AS rok,
        AVG(value) AS průměrná_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958 AND calculation_code = 200 AND industry_branch_code IS NULL
    GROUP BY rok
),
roční_ceny AS (
    SELECT 
        EXTRACT(YEAR FROM date_from) AS rok_ceny,
        AVG(value) AS průměrná_cena
    FROM czechia_price
    WHERE region_code IS NULL
    GROUP BY rok_ceny
),
metriky_růstu AS (
    SELECT 
        h.rok,
        h.růst_hdp,
        ((m.průměrná_mzda - LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) / LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) * 100 AS růst_mezd,
        ((c.průměrná_cena - LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) / LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) * 100 AS růst_cen
    FROM roční_hdp h
    LEFT JOIN roční_mzdy m ON h.rok = m.rok
    LEFT JOIN roční_ceny c ON h.rok = c.rok_ceny
)
SELECT 
    rok,
    ROUND(růst_hdp::numeric, 2) AS růst_HDP,
    ROUND(růst_mezd::numeric, 2) AS růst_mezd,
    ROUND(růst_cen::numeric, 2) AS růst_cen,
    ROUND(LEAD(růst_mezd) OVER (ORDER BY rok)::numeric, 2) AS růst_mezd_následující_rok,
    ROUND(LEAD(růst_cen) OVER (ORDER BY rok)::numeric, 2) AS růst_cen_následující_rok
FROM metriky_růstu
WHERE růst_hdp IS NOT NULL 
  AND (růst_mezd IS NOT NULL OR růst_cen IS NOT NULL)
ORDER BY rok;




