-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH mzda_2000 as (
SELECT industry_branch_code,
ROUND(AVG(value)::numeric, 0) AS průměrná_mzda_2000
    FROM czechia_payroll
    WHERE payroll_year = 2000 
    and value_type_code = 5958 
    and calculation_code = 200
GROUP BY industry_branch_code
),
mzda_2021 AS (
SELECT 
    industry_branch_code,
ROUND(AVG(value)::numeric, 0) AS průměrná_mzda_2021
    from czechia_payroll
    WHERE payroll_year = 2021 
    and value_type_code = 5958 
    and calculation_code = 200
    GROUP BY industry_branch_code
)
SELECT 
cpib.name AS název_odvětví,
m0.průměrná_mzda_2000,
m21.průměrná_mzda_2021,
m21.průměrná_mzda_2021 - m0.průměrná_mzda_2000 as nárůst_mzdy_v_kč,
    ROUND(((m21.průměrná_mzda_2021 - m0.průměrná_mzda_2000) / m0.průměrná_mzda_2000::numeric) * 100, 2) AS procentuální_nárůst
from mzda_2000 m0
join mzda_2021 m21 on m0.industry_branch_code = m21.industry_branch_code
JOIN czechia_payroll_industry_branch cpib ON m0.industry_branch_code = cpib.code
ORDER BY procentuální_nárůst DESC;

--druhá část 

with mzdy as (
    SELECT 
        cp.payroll_year AS rok,
        cpib.name AS název_odvětví,
        ROUND(AVG(cp.value)::numeric, 0) as průměrná_mzda
    from czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib 
        ON cp.industry_branch_code = cpib.code
    WHERE cp.calculation_code = 200 and cp.value_type_code = 5958 and
          cp.industry_branch_code IS NOT null
    group by cp.payroll_year, cpib.name),
výpočet_poklesu AS (
    SELECT *,
        LAG(průměrná_mzda) OVER (PARTITION BY název_odvětví ORDER BY rok) AS mzda_předchozího_roku
    FROM mzdy)
SELECT *,
    průměrná_mzda - mzda_předchozího_roku AS rozdíl_v_kč,
    ROUND(((průměrná_mzda - mzda_předchozího_roku) / mzda_předchozího_roku::numeric) * 100, 2)::text || '%' AS pokles_v_procentech
from výpočet_poklesu
where průměrná_mzda < mzda_předchozího_roku
ORDER BY rok, název_odvětví;

-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH mzdy_výpočet as (
    SELECT 
        payroll_year AS rok_mzdy,
        AVG(value) AS prům_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958 AND calculation_code = 200 AND industry_branch_code is null
    GROUP BY payroll_year),
ceny_výpočet AS (
    SELECT 
        extract(YEAR FROM date_from) AS rok_ceny,
        AVG(cp.value) AS průměrná_cena,
        cpc.name as název_produktu,
        cpc.price_unit AS jednotka_ceny
    FROM czechia_price cp
    JOIN czechia_price_category cpc ON cp.category_code = cpc.code
    WHERE cp.category_code IN (111301, 114201) AND cp.region_code IS NULL
    GROUP BY rok_ceny, cp.category_code, cpc.name, cpc.price_unit)
SELECT 
    m.rok_mzdy AS rok,
    c.název_produktu,
    ROUND(m.prům_mzda::numeric, 0) as průměrná_mzda,
    ROUND(c.průměrná_cena::numeric, 2)::text || ' / ' || c.jednotka_ceny AS průměrná_cena,
    floor(m.prům_mzda / c.průměrná_cena)::text || ' ' || c.jednotka_ceny AS množství_k_nákupu
FROM mzdy_výpočet m
JOIN ceny_výpočet c ON m.rok_mzdy = c.rok_ceny
WHERE m.rok_mzdy = (SELECT MIN(rok_mzdy) FROM mzdy_výpočet WHERE rok_mzdy IN (SELECT rok_ceny FROM ceny_výpočet))
OR m.rok_mzdy = (SELECT MAX(rok_mzdy) FROM mzdy_výpočet WHERE rok_mzdy IN (SELECT rok_ceny FROM ceny_výpočet))
ORDER BY rok, název_produktu;

-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 

create view ceny_vw AS
WITH roční_ceny_potravin AS (
    SELECT 
        EXTRACT(YEAR FROM date_from) as rok_srovnání,
        category_code AS kód_kategorie,
        AVG(value) AS průměrná_cena
    FROM czechia_price
    WHERE region_code is null
    GROUP BY rok_srovnání, kód_kategorie
),
předchozí_cena_data AS (
    SELECT
        kód_kategorie AS kk,
        rok_srovnání AS rok_předchozí,
        LAG(průměrná_cena) OVER (PARTITION BY kód_kategorie ORDER BY rok_srovnání) AS předchozí_cena
    FROM roční_ceny_potravin
)
SELECT 
    cpc.name AS potravina,
    ROUND(AVG((rcp.průměrná_cena - pcd.předchozí_cena) / pcd.předchozí_cena)::numeric, 4) * 100 AS průměrný_procentuální_růst
FROM roční_ceny_potravin rcp
JOIN czechia_price_category cpc 
    ON rcp.kód_kategorie = cpc.code
JOIN předchozí_cena_data pcd 
    ON rcp.kód_kategorie = pcd.kk and rcp.rok_srovnání = pcd.rok_předchozí
WHERE pcd.předchozí_cena IS NOT NULL
GROUP BY cpc.name
ORDER BY průměrný_procentuální_růst;

--druhá část 

SELECT potravina, MIN(průměrný_procentuální_růst) as průměrný_procentuální_růst 
FROM ceny_vw
WHERE průměrný_procentuální_růst > 0
group by ceny_vw.potravina 
LIMIT 1;


-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?


WITH roční_mzdy as (
SELECT payroll_year AS rok, AVG(value) AS průměrná_mzda
FROM czechia_payroll
where value_type_code = 5958 and calculation_code = 200
and industry_branch_code IS NULL
    GROUP BY rok),
roční_ceny AS (
SELECT 
EXTRACT(YEAR FROM date_from) AS rok_ceny, AVG(value) as průměrná_cena
FROM czechia_price
WHERE region_code is null
group by rok_ceny
),
výpočet_růstu AS (
SELECT 
m.rok,
((m.průměrná_mzda - LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) / LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) * 100 as růst_mezd,
((c.průměrná_cena - LAG(c.průměrná_cena) over (ORDER BY c.rok_ceny)) / LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) * 100 AS růst_cen
FROM roční_mzdy m
JOIN roční_ceny c ON m.rok = c.rok_ceny
)
SELECT 
    rok, ROUND(růst_mezd::numeric, 2) as růst_mezd_v_procentech,
    ROUND(růst_cen::numeric, 2) as růst_cen_potravin_v_procentech,
    ROUND((růst_cen - růst_mezd)::numeric, 2) AS rozdíl_v_procentech
FROM výpočet_růstu
where růst_cen - růst_mezd is not null
ORDER BY rok;



-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?


 with roční_hdp as (
 SELECT year as rok, gdp as hdp,
 ((gdp - LAG(gdp) OVER (order by year)) / LAG(gdp) OVER (order by year)) * 100 as růst_hdp from economies
    where country = 'Czech Republic'
),
roční_mzdy AS (select 
payroll_year AS rok,
avg(value) AS průměrná_mzda
    from czechia_payroll
    WHERE value_type_code = 5958 AND calculation_code = 200 AND industry_branch_code IS NULL
group by rok
),
roční_ceny as ( select
EXTRACT(YEAR FROM date_from) as rok_ceny,
avg(value) as průměrná_cena
from czechia_price
where region_code is null
GROUP BY rok_ceny
),
výpočet_růstu as
(SELECT h.rok, h.růst_hdp,
((m.průměrná_mzda - LAG(m.průměrná_mzda) over (order by m.rok)) / LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) * 100 as růst_mezd,
((c.průměrná_cena - LAG(c.průměrná_cena) over (order by c.rok_ceny)) / LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) * 100 AS růst_cen
    from roční_hdp h
left JOIN roční_mzdy m on h.rok = m.rok
left JOIN roční_ceny c ON h.rok = c.rok_ceny
),
růst_lead AS (
    SELECT *,LEAD(růst_mezd) over (ORDER BY rok) as růst_mezd_nasl_rok,
        lead(růst_cen) OVER (ORDER BY rok) AS růst_cen_nasl_rok from výpočet_růstu
)
SELECT 
rok,
round(růst_hdp::numeric, 2) as růst_HDP,
round(růst_mezd::numeric, 2) as růst_mezd,
ROUND(růst_cen::numeric, 2) as růst_cen,
ROUND(růst_mezd_nasl_rok::numeric, 2) AS růst_mezd_následující_rok,
ROUND(růst_cen_nasl_rok::numeric, 2) AS růst_cen_následující_rok,
round(CORR(růst_mezd_nasl_rok, růst_hdp) over ()::numeric, 4) as korelace_HDP_mzdy,
round(CORR(růst_cen_nasl_rok, růst_hdp) OVER ()::numeric, 4) as korelace_HDP_ceny
from růst_lead
WHERE růst_hdp is not null and (růst_mezd IS NOT NULL OR růst_cen IS NOT NULL)
order by rok;




