
<center> 


# Datová analýza - SQL Projekt 
***RUDOLF PREISS***

</center>
<br />

<center> 
❗ Tento projekt vznikl jako výsledná práce v rámci kurzu Datové akademie od ENGETA. ❗<br />
Cílem projektu bylo zpracovat data o mzdách a cenách pomocí PostgreSQL a odpovědět na 5 výzkumných otázek.</center><br />


<center>

### 📚 STRUKTURA REPOZITÁŘE

</center>

- ***Data*** - datové podklady pro projekt
- ***Primární a sekundární tabulka***
  - ***t_Rudolf_Preiss_project_SQL_primary_final*** - tabulka sjednocující data o cenách a mzdách 
  - ***t_Rudolf_Preiss_project_SQL_secondary_final*** - tabulka sjednocující dodatečná data o evropských státech
- ***SQL skripty*** - kódy pro zobrazení primární, sekundární a výsledných tabulek pro odpovědi na otázky
- ***README.md*** - SQL skripty, postupy, tabulky a odpovědi na otázky
- ***Tabulky k otázkám.md*** - výsledné tabulky

<center>
<br />


### 📄 DATA

</center>
  
- ***czechia_payroll*** - údaje o průměrných mzdách a počtech zaměstnanců v ČR členěné podle odvětví a let
- ***czechia_payroll_calculation*** - číselník definující způsob výpočtu, rozlišující mezi fyzickým počtem zaměstnanců a počtem přepočteným na plný úvazek
- ***czechia_payroll_industry_branch*** - kódy a názvy pracovních odvětví
- ***czechia_payroll_unit*** - měrné jednotky pro czechia_payroll
- ***czechia_payroll_value_type*** - číselník s kódy hodnot průměrné mzdy a údaje o počtu zaměstnanců.
- ***czechia_price*** - údaje o cenách vybraných potravin v týdenních intervalech napříč kraji ČR.
- ***czechia_price_category*** - číselník s kódy a názvy potravin a jejich měrné jednotky.
- ***czechia_region*** - číselník s kódy a názvy krajů ČR.
- ***economies*** - ekonomické a demografické ukazatele pro jednotlivé státy v čase.
- ***countries*** - přehled geografických, politických a kulturních údajů o zemích světa<br />


<br />
<center>

### ❓ VÝZKUMNÉ OTÁZKY

</center>

&nbsp;&nbsp;&nbsp;&nbsp; **1.** Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? <br />

   &nbsp;&nbsp;&nbsp;&nbsp; **2.** Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?<br />

   &nbsp;&nbsp;&nbsp;&nbsp; **3.** Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? <br />

   &nbsp;&nbsp;&nbsp;&nbsp; **4.** Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?<br />

   &nbsp;&nbsp;&nbsp;&nbsp; **5.** Má výška HDP vliv na změny ve mzdách a cenách potravin?



<br>
<center>

###  🗂️ OBSAH

</center>

- [Datová analýza - SQL Projekt](#datová-analýza---sql-projekt)
    - [📚 STRUKTURA REPOZITÁŘE](#-struktura-repozitáře)
    - [📄 DATA](#-data)
    - [❓ VÝZKUMNÉ OTÁZKY](#-výzkumné-otázky)
    - [🗂️ OBSAH](#️-obsah)
  - [Otázka 1](#otázka-1)
    - [📜 SQL Skript](#-sql-skript)
    - [⚙️ Postup](#️-postup)
    - [🗓️ Tabulka 1](#️-tabulka-1)
    - [🎯 Odpověď](#-odpověď)
  - [Otázka 2](#otázka-2)
    - [📜 SQL Skript](#-sql-skript-1)
    - [⚙️ Postup](#️-postup-1)
    - [🗓️ Tabulka 2](#️-tabulka-2)
    - [🎯 Odpověď](#-odpověď-1)
  - [Otázka 3](#otázka-3)
    - [📜 SQL Skript](#-sql-skript-2)
    - [⚙️ Postup](#️-postup-2)
    - [🗓️ Tabulka 3](#️-tabulka-3)
    - [🎯 Odpověď](#-odpověď-2)
  - [Otázka 4](#otázka-4)
    - [📜 SQL Skript](#-sql-skript-3)
    - [⚙️ Postup](#️-postup-3)
    - [🗓️ Tabulka 4](#️-tabulka-4)
    - [🎯 Odpověď](#-odpověď-3)
  - [Otázka 5](#otázka-5)
    - [📜 SQL Skript](#-sql-skript-4)
    - [⚙️ Postup](#️-postup-4)
    - [🗓️ Tabulka 5.1](#️-tabulka-51)
    - [🗓️ Tabulka 5.2](#️-tabulka-52)
    - [🎯 Odpověď](#-odpověď-4)

<br>
<br>
<br>
<br>
<center>

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 1

</span>

 ❓ **Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?** 



### 📜 SQL Skript

<br>

</center>


````sql
WITH mzdy_2000 AS (
    SELECT 
        odvetvi,
        prumerna_mzda AS mzda_start
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf 
    WHERE rok = 2000
    GROUP BY odvetvi, prumerna_mzda
),
mzdy_2021 AS (
    SELECT 
        odvetvi,
        prumerna_mzda AS mzda_end
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf 
    WHERE rok = 2021
    GROUP BY odvetvi, prumerna_mzda
)
SELECT 
    m1.odvetvi AS název_odvětví,
    m1.mzda_start AS průměrná_mzda_2000,
    m2.mzda_end AS průměrná_mzda_2021,
    (m2.mzda_end - m1.mzda_start) AS nárůst_mzdy_v_kč,
    ROUND(((m2.mzda_end - m1.mzda_start)::numeric / m1.mzda_start) * 100, 2) AS procentuální_nárůst
FROM mzdy_2000 m1
JOIN mzdy_2021 m2 ON m1.odvetvi = m2.odvetvi
ORDER BY procentuální_nárůst DESC;
````
<center>

### ⚙️ Postup
<br>
</center>

Základem analýzy bylo získat data o mzdách pro dva časové body, roky 2000 a 2021, pomocí Common Table Expressions (CTE). CTE nám umožňují izolovat průměrné mzdy pro 'startovní' a 'cílové' období, čímž eliminujeme šum z ostatních let a získáme tak podklad pro snadné porovnání jednotlivých odvětví.

Ve finální části skriptu dochází k propojení (````JOIN````) těchto sad skrze název odvětví a následnému výpočtu nominálního i procentuálního nárůstu. Výsledná tabulka je řazena sestupně podle procentuálního růstu, což nám přednostně umožňuje identifikovat sektory s nejvyšším tempem růstu.

<center>

### 🗓️ Tabulka 1
<br>
</center>

|název_odvětví                                               |průměrná_mzda_2000|průměrná_mzda_2021|nárůst_mzdy_v_kč|procentuální_nárůst|
|------------------------------------------------------------|------------------|------------------|----------------|-------------------|
|Zdravotní a sociální péče                                   |11968             |47203             |35235           |294.41             |
|Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu |18492             |55925             |37433           |202.43             |
|Vzdělávání                                                  |12205             |36892             |24687           |202.27             |
|Informační a komunikační činnosti                           |22068             |64400             |42332           |191.83             |
|Zpracovatelský průmysl                                      |12836             |35227             |22391           |174.44             |
|Profesní, vědecké a technické činnosti                      |15991             |43681             |27690           |173.16             |
|Ubytování, stravování a pohostinství                        |7518              |20471             |12953           |172.29             |
|Kulturní, zábavní a rekreační činnosti                      |11405             |30690             |19285           |169.09             |
|Velkoobchod a maloobchod; opravy a údržba motorových vozidel|12551             |33602             |21051           |167.72             |
|Zemědělství, lesnictví, rybářství                           |10452             |27626             |17174           |164.31             |
|Činnosti v oblasti nemovitostí                              |12415             |32692             |20277           |163.33             |
|Veřejná správa a obrana; povinné sociální zabezpečení       |15460             |39731             |24271           |156.99             |
|Peněžnictví a pojišťovnictví                                |25171             |62544             |37373           |148.48             |
|Administrativní a podpůrné činnosti                         |10454             |25686             |15232           |145.70             |
|Ostatní činnosti                                            |11140             |27267             |16127           |144.77             |
|Stavebnictví                                                |12607             |30762             |18155           |144.01             |
|Doprava a skladování                                        |13367             |32257             |18890           |141.32             |
|Zásobování vodou; činnosti související s odpady a sanacemi  |13228             |31821             |18593           |140.56             |
|Těžba a dobývání                                            |16567             |38068             |21501           |129.78             |

<center>

### 🎯 Odpověď
<br>
</center>

&nbsp;&nbsp;&nbsp;&nbsp;Z tabulky vidíme, že přepočtené průměrné mzdy v každém odvětví v průběhu let 2000-2021 v ČR vzrostly. Nejvyšší, téměř čtyřnásobný, nárůst proběhl v odvětví Zdravotní a sociální péče (294.41%) a nejnižší v sektoru Těžby a dobývání (129.78%). Druhé a třetí nejvíce rostoucí odvětví z hlediska platů jsou Výroba a rozvod elektřiny, plynu, tepla a klimatizace vzduchu a Vzdělávání (více než trojnsobné zvýšení u obou).

<br>
<br>
<br>
<br>


<center>

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 2

</span>

**❓ Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**



### 📜 SQL Skript

<br>

</center>

````sql
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
````
<center>

### ⚙️ Postup
<br>
</center>

Prvním krokem analýzy byla definice rozmezí sledovaného období pomocí CTE. Místo toho, abych porovnatelné roky zadal manuálně, jsem použil ````MIN```` a ````MAX````. Tento způsob automaticky identifikuje první a poslední rok, pro které existují cenové záznamy v databázi a zajišťuje tak přesnost a adaptabilitu skriptu; pokud by se tabulka v budoucnu rozšířila o nová období.

Hlavní část umožňuje zobrazit oba roky, celorepublikovou průměrnou mzdu (````trppspf.odvetvi IS NULL````), průměrnou cenu a především výpočet reálné kupní síly, vyjádřený jako podíl průměrné mzdy a průměrné ceny vybraných potravin (chleba a mléka). Použití funkce ````FLOOR```` nám umožňuje interpretovat výsledek v podobě celých jednotek zboží, které si občan mohl s průměrnou mzdou pořídit na počátku a na konci daného cyklu. Výsledná tabulka tak poskytuje srozumitelné srovnání dostupnosti obou komodit v čase nezávisle na inflaci.

<center>

### 🗓️ Tabulka 2
<br>
</center>

|rok                                                         |název_produktu|průměrná_mzda|průměrná_cena_za_jednotku|množství_jednotek_k_nákupu|jednotka|
|------------------------------------------------------------|--------------|-------------|-------------------------|--------------------------|--------|
|2006                                                        |Mléko polotučné pasterované|19536        |14.0                     |1353.0                    |l       |
|2006                                                        |Chléb konzumní kmínový|19536        |16.0                     |1211.0                    |kg      |
|2018                                                        |Mléko polotučné pasterované|32043        |20.0                     |1616.0                    |l       |
|2018                                                        |Chléb konzumní kmínový|32043        |24.0                     |1321.0                    |kg      |

<center>

### 🎯 Odpověď
<br>
</center>

&nbsp;&nbsp;&nbsp;&nbsp;Z tabulky vidíme, že v prvním srovnatelném období (rok 2006) jsme si průměrně mohli koupit 1353 litrů mléka nebo 1211 kilogramů chleba, zatímco v posledním srovnatelném období (2018) to bylo 1616 litrů mléka nebo 1321 kilogramů chleba .
Z výsledků vidíme, že průměrná kupní síla v České republice, ve vztahu k těmto dvěma komoditám, stoupla.

<br>
<br>
<br>
<br>

<center>

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 3

</span>

**❓ Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?** 



### 📜 SQL Skript

<br>
</center>

````sql
WITH prices AS (
    SELECT DISTINCT
        rok,
        kategorie_potravin,
        prumerna_cena
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf
    WHERE prumerna_cena IS NOT NULL
),
yoy_growth AS (
    SELECT
        kategorie_potravin,
        (((prumerna_cena - LAG(prumerna_cena) OVER (PARTITION BY kategorie_potravin ORDER BY rok)) / 
        LAG(prumerna_cena) OVER (PARTITION BY kategorie_potravin ORDER BY rok)) *100)::numeric AS growth
    FROM prices
),
final AS (
    SELECT
        kategorie_potravin AS potravina,
        ROUND(AVG(growth), 2) AS průměrný_procentuální_růst
    FROM yoy_growth
    WHERE growth IS NOT NULL
    GROUP BY kategorie_potravin
)
SELECT *
FROM final
WHERE průměrný_procentuální_růst > 0 
ORDER BY průměrný_procentuální_růst ASC
LIMIT 1;
````

<center>

### ⚙️ Postup
<br>
</center>

Klíčovým prvkem analýzy byla transformace absolutních cen na meziroční procentuální změny pomocí funkce ````LAG```` v CTE ````prices```` a ````yoy_growth````. Tento krok je zásadní protože nám umožňuje sledovat relativní pohyb cen nezávisle na jejich nominální hodnotě. 

Ve finální fázi agregujeme tyto roční cenové změny pomocí funkce ````AVG````, čímž získáme stabilní ukazatel dlouhodobého trendu pro každou komoditu. Seřazením těchto průměrných hodnot (````ORDER BY průměrný_procentuální_růst ASC````) a použitím filtrů pro růst kladný (````WHERE průměrný_procentuální_růst > 0````) a zobrazení jediného výsledek (````LIMIT 1;````), jsme schopni přesně určit produkt, který v dlouhodobém horizontu vykazoval nejnižší tempo cenového nárůstu.

<center>

### 🗓️ Tabulka 3
<br>
</center>

|potravina                                                   |průměrný_procentuální_růst|
|------------------------------------------------------------|--------------------------|
|Banány žluté                                                |0.81                      |


<center>

### 🎯 Odpověď
<br>
</center>

&nbsp;&nbsp;&nbsp;&nbsp;Odpovědí jsou Banány žluté.

<br>
<br>
<br>
<br>

<center>

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 4

</span>

**❓ Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**



### 📜 SQL Skript

<br>

</center>


````sql
WITH wages AS (
    SELECT 
        rok, 
        prumerna_mzda AS wage
    FROM "t_Rudolf_Preiss_project_SQL_primary_final" trppspf
    WHERE odvetvi IS NULL
    GROUP BY rok, prumerna_mzda
),
prices AS (
    SELECT 
        rok, 
        AVG(prumerna_cena) AS avg_basket_price
    FROM (
        SELECT DISTINCT rok, kategorie_potravin, prumerna_cena 
        FROM "t_Rudolf_Preiss_project_SQL_primary_final"
    ) sub
    GROUP BY rok
),
growth_comparison AS (
    SELECT 
        w.rok,
        ((w.wage - LAG(w.wage) OVER (ORDER BY w.rok)) / LAG(w.wage) OVER (ORDER BY w.rok) * 100)::numeric AS wage_growth,
        ((p.avg_basket_price - LAG(p.avg_basket_price) OVER (ORDER BY p.rok)) / LAG(p.avg_basket_price) OVER (ORDER BY p.rok) * 100)::numeric AS price_growth
    FROM wages w
    JOIN prices p ON w.rok = p.rok
)
SELECT 
    rok,
    ROUND(wage_growth, 2) AS růst_mezd_v_procentech,
    ROUND(price_growth, 2) AS růst_cen_potravin_v_procentech,
    ROUND(price_growth - wage_growth, 2) AS rozdíl_v_procentech
FROM growth_comparison
WHERE wage_growth IS NOT NULL 
  AND price_growth IS NOT NULL
ORDER BY rok;
````
<center>

### ⚙️ Postup
<br>
</center>

Analýza se opírá o zpracování dvou datových toků – celorepublikových průměrných mezd (````WHERE odvetvi IS NULL````) a průměrných cen reprezentativního koše potravin. V rámci CTE ````prices```` dochází k agregaci cen všech sledovaných komodit do průměrných ročních hodnot, zatímco CTE ````wages```` hledá národní roční průměr mezd. To nám umožňuje srovnávat obě metriky na jednotné časové ose.

Dalším krokem byla aplikace funkce ````LAG```` v CTE ````growth_comparison````, která slouží k výpočtu meziročního procentuálního růstu pro obě oblasti. Finální část skriptu pak tyto dva trendy staví proti sobě a počítá jejich vzájemný rozdíl. Tento postup umožňuje snadno identifikovat roky, kdy tempo zdražování potravin předstihlo růst mezd a došlo tak k reálnému oslabení kupní síly obyvatelstva ČR.


<center>

### 🗓️ Tabulka 4
<br>
</center>

|rok |růst_mezd_v_procentech|růst_cen_potravin_v_procentech|rozdíl_v_procentech|
|----|----------------------|------------------------------|-------------------|
|2007|7.22                  |6.76                          |-0.46              |
|2008|7.85                  |6.18                          |-1.67              |
|2009|3.37                  |-6.41                         |-9.78              |
|2010|2.16                  |1.94                          |-0.22              |
|2011|2.49                  |3.35                          |0.86               |
|2012|2.50                  |6.73                          |4.23               |
|2013|-0.13                 |5.10                          |5.23               |
|2014|2.91                  |0.74                          |-2.17              |
|2015|3.19                  |-0.55                         |-3.74              |
|2016|4.42                  |-1.19                         |-5.61              |
|2017|6.74                  |9.63                          |2.89               |
|2018|8.16                  |2.17                          |-5.99              |

<center>

### 🎯 Odpověď
<br>
</center>

&nbsp;&nbsp;&nbsp;&nbsp;Z výsledků analýzy nám dostupných dat lze konstatovat, že nárůst mezd je v průměru vyšší než inflace vybraných komodit. Tabulka dokazuje, že cenový růst potravin, ve srovnatelném období let 2007–2018, v žádném roce nepřekročil růst mezd výrazným způsobem (tj. více než o 10%). 
Nejvyšší zaznamenaný pozitivní rozdíl mezi růstem cen a mezd se objevil v roce 2013 (5.23%). 


<br>
<br>
<br>
<br>

<center>

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 5

</span>

**❓ Má výška HDP vliv na změny ve mzdách a cenách potravin?** 



### 📜 SQL Skript

<br>
</center>


````sql
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


-- druhý skript (korelace)

SELECT
	ROUND(CORR(růst_hdp, růst_mezd)::numeric, 4) AS korelace_hdp_mzdy,
    ROUND(CORR(ov.růst_hdp, růst_cen)::numeric, 4) AS korelace_hdp_ceny,
	ROUND(CORR(růst_hdp, růst_mezd_následující_rok)::numeric, 4) AS zpožděná_korelace_hdp_mzdy,
    ROUND(CORR(ov.růst_hdp, růst_cen_následující_rok)::numeric, 4) AS zpožděná_korelace_hdp_ceny
 FROM otazka_5_vw ov;
````
<center>

### ⚙️ Postup
<br>
</center>

Analýza v tomto případě propojuje primární tabulku se sekundární, za účelem zkoumání vztahu mezi HDP a změny ve mzdách a cenách. Skript používá sérii několika CTE k výpočtu meziročních procentuálních změn pro všechny tři veličiny. Důvod, proč pro růst cen používáme dvě CTE je, že v primární tabulce jsou data o potravinách napojená na odvětví mezd, což vede ke klonování identických řádků s informacemi o cenách kategorií potravin. My samozřejmě nechceme, aby opakující se hodnoty zkreslily naše průměry a musíme tedy z primární tabulky nejprve vyhledat unikátní (````DISTINCT````) kombinace roků, kategorií potravin a průměrných cen.

Ve finální části prvního skriptu ````SELECT````ujeme všechny tři typy procentuálních růstů a přidáme do výsledné tabulky pomocí funkce ````LEAD```` dva další sloupce, které zobrazují vývoj mezd a cen v roce následujícím. Tento krok jsem provedl proto, že v druhé části skriptu chci kvantifikovat jak okamžitý vliv HDP na mzdy/ceny, tak i vliv (o rok) zpožděný.

Ve druhém skriptu je využita statistická funkce CORR k výpočtu Pearsonova korelačního koeficientu. Výpočet, jak jsem již zmínil, probíhá ve dvou rovinách: pro aktuální rok a pro roční časový posun, což nám umožňuje přesně stanovit nejen sílu závislosti, ale i to, zda má růst HDP vyšší predikční hodnotu pro okamžitý vývoj trhu, nebo zda se jeho vliv projevuje s ročním zpožděním.


<center>

### 🗓️ Tabulka 5.1
<br>
</center>

|rok |růst_hdp|růst_mezd|růst_cen|růst_mezd_následující_rok|růst_cen_následující_rok|
|----|--------|---------|--------|-------------------------|------------------------|
|2001|3.04    |8.74     |        |8.03                     |                        |
|2002|1.57    |8.03     |        |5.82                     |                        |
|2003|3.58    |5.82     |        |6.28                     |                        |
|2004|4.81    |6.28     |        |5.04                     |                        |
|2005|6.60    |5.04     |        |6.54                     |                        |
|2006|6.77    |6.54     |        |7.22                     |6.76                    |
|2007|5.57    |7.22     |6.76    |7.85                     |6.18                    |
|2008|2.69    |7.85     |6.18    |3.37                     |-6.41                   |
|2009|-4.66   |3.37     |-6.41   |2.16                     |1.94                    |
|2010|2.43    |2.16     |1.94    |2.49                     |3.35                    |
|2011|1.76    |2.49     |3.35    |2.50                     |6.73                    |
|2012|-0.79   |2.50     |6.73    |-0.13                    |5.10                    |
|2013|-0.05   |-0.13    |5.10    |2.91                     |0.74                    |
|2014|2.26    |2.91     |0.74    |3.19                     |-0.55                   |
|2015|5.39    |3.19     |-0.55   |4.42                     |-1.19                   |
|2016|2.54    |4.42     |-1.19   |6.74                     |9.63                    |
|2017|5.17    |6.74     |9.63    |8.16                     |2.17                    |
|2018|3.20    |8.16     |2.17    |7.89                     |                        |
|2019|2.31    |7.89     |        |3.16                     |                        |
|2020|-5.60   |3.16     |        |                         |                        |

<center>

### 🗓️ Tabulka 5.2
<br>
</center>

|korelace_hdp_mzdy|korelace_hdp_ceny|zpožděná_korelace_hdp_mzdy|zpožděná_korelace_hdp_ceny|
|-----------------|-----------------|--------------------------|--------------------------|
|0.4356           |0.4869           |0.6695                    |0.0931                    |


<center>

### 🎯 Odpověď
<br>
</center>

Z tabulky vidíme, že korelace mezi změnami ve výši HDP a růstem mezd následující rok je 0.6695, což naznačuje středně silný vztah. Na růst cen se zdá, že HDP nemá žádný zpoždený vliv (korelace - 0.0931).
Když se podíváme na korelace mezi změnami ve stejném roce, zdá se, že hdp má střední vliv na obě metriky, přičemž o trochu větší na ceny potravin (korelace - 0.4869).
Z hlediska validity našich výsledku je avšak nutné zmínit, že ze všech čtyř typů zkoumaných vztahů, pouze zpožděná korelace mezi HDP a mzdami vykazuje p-hodnotu nízkou natolik, abychom vztah mohli považovat za statisticky signifikantní (p-hodnota = 0.0017).

