
<div align="center">

# Datová analýza - SQL Projekt 
***RUDOLF PREISS***

</div>

<br />

<div align="center">

 Tento projekt vznikl jako výsledná práce v rámci ENGETO kurzu Datové akademie. <br />
Cílem projektu bylo zpracovat data o mzdách a cenách pomocí PostgreSQL a odpovědět na 5 výzkumných otázek.</div><br />


<div align="center">

### 📚 STRUKTURA REPOZITÁŘE

</div>

- ***Data*** - datové podklady pro projekt
- ***Primární a sekundární tabulky***
  - ***t_Rudolf_Preiss_project_SQL_primary_final*** - tabulka sjednocující data o cenách a mzdách 
  - ***t_Rudolf_Preiss_project_SQL_secondary_final*** - tabulka sjednocující dodatečná data o evropských státech
- ***SQL skripty*** - SQL kódy pro zobrazení primární, sekundární a výsledných tabulek potřebných k zodpovězení otázek
- ***README.md*** - SQL skripty, postupy, tabulky a odpovědi na otázky
- ***Tabulky k otázkám.md*** - výsledné tabulky

<div align="center">
<br />


### 📄 DATA

</div>
  
- ***czechia_payroll*** - údaje o průměrných mzdách a počtech zaměstnanců v ČR členěné podle odvětví a let
- ***czechia_payroll_calculation*** - číselník definující způsob výpočtu mezd, který rozlišuje mezi fyzickým počtem zaměstnanců a počtem přepočteným na plný úvazek
- ***czechia_payroll_industry_branch*** - kódy a názvy pracovních odvětví
- ***czechia_payroll_unit*** - měrné jednotky pro hodnoty v czechia_payroll
- ***czechia_payroll_value_type*** - číselník s kódy údajů o průměrné mzdě a údajů o počtu zaměstnanců.
- ***czechia_price*** - údaje o cenách vybraných potravin v týdenních intervalech napříč kraji ČR.
- ***czechia_price_category*** - číselník s kódy a názvy potravin a jejich měrné jednotky.
- ***czechia_region*** - číselník s kódy a názvy krajů ČR.
- ***economies*** - ekonomické a demografické ukazatele pro jednotlivé státy v průběhu let.
- ***countries*** - přehled geografických, politických a kulturních údajů o veškerých zemích světa<br />


<br />
<div align="center">

### ❓ VÝZKUMNÉ OTÁZKY

</div>

&nbsp;&nbsp;&nbsp;&nbsp; **1.** Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? <br />

   &nbsp;&nbsp;&nbsp;&nbsp; **2.** Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?<br />

   &nbsp;&nbsp;&nbsp;&nbsp; **3.** Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? <br />

   &nbsp;&nbsp;&nbsp;&nbsp; **4.** Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?<br />

   &nbsp;&nbsp;&nbsp;&nbsp; **5.** Má výška HDP vliv na změny ve mzdách a cenách potravin?



<br>
<div align="center">

###  🗂️ OBSAH

</div>

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
    - [⚙️ Postup](#️-postup-5)
    - [🗓️ Tabulka 5.2](#️-tabulka-52)
    - [🎯 Odpověď](#-odpověď-4)

<br>
<br>
<br>
<br>
<div align="center">

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 1

</span>

 ❓ **Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?** 



### 📜 SQL Skript

<br>

</div>


````sql
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
````
<div align="center">

### ⚙️ Postup
<br>
</div>

V primární tabulce ````t_rudolf_preiss_project_sql_primary_final````, ze které budeme data vybírat, nás zajímají pouze 3 sloupce:
 - ````year```` (roky v rozmezí 2006-2018)
 - ````industry_branch```` (typy odvětví)
 - ````avg_wage```` (průměrné přepočtené mzdy na každý rok a odvětví)

V první fázi použijeme dvě CTE (Common Table Expression) - ````wages_first_year```` a ````wages_last_year````, ve kterých vyhledáme průměrnou mzdu na každé odvětví. Obě CTE se od sebe liší pouze rokem, pro který mzdy hledáme.
První CTE filtruje data k prvnímu dostupnému roku (2006)
````sql
    WHERE year = (SELECT MIN(year) FROM t_rudolf_preiss_project_sql_primary_final)
````
a druhé CTE k poslednímu (2018).
````sql
    WHERE year = (SELECT MAX(year) FROM t_rudolf_preiss_project_sql_primary_final)
````
Zároveň je potřeba výsledná CTE seskupit použitím klauzule:
````sql
    GROUP BY industry_branch, avg_wage
````
protože primární tabulka obsahuje duplicitní řádky, které chceme eliminovat.

Ve finální části skriptu používáme ````INNER JOIN```` ke sjednocení obou CTE dohromady pomocí ````industry_branch```` (odvětví). <br>
To nám umožní mzdy pro oba roky snadno horizontálně porovnávat.
````sql
SELECT 
    
FROM wages_first_year wfy 
JOIN wages_last_year wly ON wfy.industry_branch = wly.industry_branch 
````

Stačí již pouze zobrazit jednotlivá odvětví a mzdy pro oba srovnávané roky.

````sql
SELECT 
    wfy.industry_branch,
    wfy.wage_2006,
    wly.wage_2018, 
````
Pro přehlednost jsem zároveň vytvořil dva dodatečné sloupce, které provádějí ke každému řádku kalkulaci rozdílu mezi mzdami obou roků (````wage_diff_absolute````) a také procentuální změny mezi oběma roky (````percentage_wage_change````) pomocí vzorce: 
$$
\text{Procentuální změna} = \left( \frac{\text{Mzda}_{2018} - \text{Mzda}_{2006}}{\text{Mzda}_{2006}} \right) \times 100
$$

````sql
    (wly.wage_2018 - wfy.wage_2006) AS wage_diff_absolute,
    ROUND(((wly.wage_2018 - wfy.wage_2006) / wfy.wage_2006) * 100, 2) AS percentage_wage_change
````
Výsledná tabulka vypadá takto:
<br>

<div align="center">

### 🗓️ Tabulka 1
<br>
</div>

| industry_branch                                              | wage_2006 | wage_2018 | wage_diff_absolute | percentage_wage_change |
|--------------------------------------------------------------|-----------|-----------|--------------------|------------------------|
| Zdravotní a sociální péče                                    | 19042     | 33863     | 14821              | 77.83                  |
| Zpracovatelský průmysl                                       | 18482     | 31890     | 13408              | 72.55                  |
| Zemědělství, lesnictví, rybářství                            | 14818     | 25467     | 10649              | 71.87                  |
| Kulturní, zábavní a rekreační činnosti                       | 16827     | 28399     | 11572              | 68.77                  |
| Ubytování, stravování a pohostinství                         | 11674     | 19270     | 7596               | 65.07                  |
| Velkoobchod a maloobchod; opravy a údržba motorových vozidel | 18223     | 29975     | 11752              | 64.49                  |
| Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu  | 29211     | 46375     | 17164              | 58.76                  |
| Informační a komunikační činnosti                            | 35793     | 56728     | 20935              | 58.49                  |
| Profesní, vědecké a technické činnosti                       | 24645     | 38985     | 14340              | 58.19                  |
| Stavebnictví                                                 | 17850     | 28167     | 10317              | 57.80                  |
| Vzdělávání                                                   | 20030     | 31443     | 11413              | 56.98                  |
| Veřejná správa a obrana; povinné sociální zabezpečení        | 23285     | 36313     | 13028              | 55.95                  |
| Zásobování vodou; činnosti související s odpady a sanacemi   | 18740     | 28724     | 9984               | 53.28                  |
| Doprava a skladování                                         | 19257     | 29460     | 10203              | 52.98                  |
| Těžba a dobývání                                             | 24067     | 36039     | 11972              | 49.74                  |
| Činnosti v oblasti nemovitostí                               | 19242     | 28109     | 8867               | 46.08                  |
| Administrativní a podpůrné činnosti                          | 14444     | 20954     | 6510               | 45.07                  |
| Ostatní činnosti                                             | 16484     | 23697     | 7213               | 43.76                  |
| Peněžnictví a pojišťovnictví                                 | 40027     | 54883     | 14856              | 37.11                  |

<div align="center">

### 🎯 Odpověď
<br>
</div>

&nbsp;&nbsp;&nbsp;&nbsp;Z tabulky vidíme, že přepočtené průměrné mzdy v každém odvětví v průběhu let 2006-2018 v ČR vzrostly. Nejvyšší nárůst proběhl v oblasti Zdravotní a sociální péče (77.83%) a nejnižší v sektoru Peněžnictví a pojišťovnictví (37.11%)

<br>
<br>
<br>
<br>


<div align="center">

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 2

</span>

**❓ Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**



### 📜 SQL Skript

<br>

</div>

````sql
WITH range_years AS (
    SELECT 
        MIN(year) AS first_year, 
        MAX(year) AS last_year 
    FROM t_rudolf_preiss_project_sql_primary_final trppspf 
)
SELECT 
    year,
    food_category,
    avg_wage,
    ROUND(avg_price::numeric , 2) AS avg_price ,
    FLOOR(avg_wage / avg_price) AS num_of_units_purchasable,
    unit
FROM t_rudolf_preiss_project_sql_primary_final trppspf 
JOIN range_years ry 
    ON trppspf.year = ry.first_year OR trppspf.year = ry.last_year
WHERE food_category IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
  AND industry_branch IS NULL
ORDER BY year, food_category;
````
<div align="center">

### ⚙️ Postup
<br>
</div>

K odpovědi na tuto otázku nás v primární tabulce zajímají tyto sloupce:
- ````year```` (roky v rozmezí 2006-2018)
- ````food_category```` (typy potravin)
- ````avg_price```` (průměrná cena na každý rok a potravinu)
- ````unit```` (jednotka množství za cenu (kg, l...))
- ````avg_wage```` (průměrná mzda na každý rok přepočtená na plný úvazek)

V první řadě je potřeba stanovit první a poslední srovnatelné období pro mzdy a ceny. Primární tabulka již je upravena tak, aby nesla pouze data pro roky, ke kterým známe jak informace o mzdách, tak informace o cenách. Stačí nám tedy, když vytvoříme CTE, ve kterém jednoduše vybereme ````MIN```` a ````MAX```` roky primární tabulky, které ve druhé části skriptu použijeme jako "filtr".<br>
První CTE (````range_years````) vypadá takto:
````sql
WITH range_years AS (
    SELECT 
        MIN(year) AS first_year, 
        MAX(year) AS last_year 
    FROM t_rudolf_preiss_project_sql_primary_final trppspf 
)
````
Ve druhé části vybereme roky (````year````), kategorie potravin (````food_category````), průměrnou cenu (````avg_price````), průměrnou mzdu (````avg_wage````), počet celých jednotek zboží které si lze za průměrnou mzdu koupit (````num_of_units_purchasable````) a jednotku množství (````unit````) z primární tabulky. Sloupec ````num_of_units_purchasable```` vzniká vydělením mzdy cenami a následným zaokrouhlením na nejnižší celou hodnotu (funkce ````FLOOR````).

````sql
SELECT 
    year,
    food_category,
    avg_wage,
    ROUND(avg_price::numeric , 2) AS avg_price ,
    FLOOR(avg_wage / avg_price) AS num_of_units_purchasable,
    unit
FROM t_rudolf_preiss_project_sql_primary_final trppspf 
````

Stačí použít ````INNER JOIN```` s CTE ````range_years````, čímž výslednou tabulku omezíme na data dvou roků (2006 a 2018) a filtr ````WHERE````, kterým vybereme pouze data pro potraviny Chléb a Mléko (````food_category IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované'````) a pro průměrné mzdy napříč všemi odvětvími (````industry_branch IS NULL````).

````sql
JOIN range_years ry 
    ON trppspf.year = ry.first_year OR trppspf.year = ry.last_year
WHERE food_category IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
  AND industry_branch IS NULL
````

Výstup na závěr seřadíme vzestupně podle roku a typu potravin pro lepší přehled.

````sql
ORDER BY year, food_category;
````
Výsledná tabulka vypadá takto:

<div align="center">

### 🗓️ Tabulka 2
<br>
</div>

| year | food_category               | avg_wage | avg_price | num_of_units_purchasable | unit |
|------|-----------------------------|----------|-----------|--------------------------|------|
| 2006 | Chléb konzumní kmínový      | 19536    | 16.12     | 1211.0                   | kg   |
| 2006 | Mléko polotučné pasterované | 19536    | 14.44     | 1353.0                   | l    |
| 2018 | Chléb konzumní kmínový      | 32043    | 24.24     | 1321.0                   | kg   |
| 2018 | Mléko polotučné pasterované | 32043    | 19.82     | 1616.0                   | l    |

<div align="center">
<br>

### 🎯 Odpověď
<br>
</div>

&nbsp;&nbsp;&nbsp;&nbsp;Z tabulky vidíme, že v prvním srovnatelném období (2006) si bylo možné za průměrnou mzdu koupit 1353 litrů mléka nebo 1211 kilogramů chleba, zatímco v posledním srovnatelném období (2018) to bylo 1616 litrů mléka nebo 1321 kilogramů chleba .
Z výsledků tedy vidíme, že průměrná kupní síla v České republice, ve vztahu k těmto dvěma komoditám, stoupla.

<br>
<br>
<br>
<br>

<div align="center">

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 3

</span>

**❓ Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?** 



### 📜 SQL Skript

<br>
</div>

````sql
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
````

<div align="center">

### ⚙️ Postup
<br>
</div>

V tomto skriptu pracujeme se třemi sloupci z primární tabulky:
- ````year```` (roky v rozmezí 2006-2018)
- ````food_category```` (typ potraviny)
- ````avg_price```` (průměrná cena na každý rok a potravinu)

Ve skriptu jsem nejdříve použil 3 na sebe navazující CTE (````prices````, ````yoy_growth```` a ````final````).<br>
V CTE ````prices```` prvně selektujeme všechny jedinečné (````DISTINCT````) kombinace našich tří sloupců - let, potravin a cen. V primární tabulce totiž existuje mnoho duplikátních řádků těchto informací, jelikož jsou zároveň napojeny na jednotlivá odvětví mezd. 
Zároveň preventivně použijeme klauzuli (````WHERE avg_price IS NOT NULL````), abychom se vyhnuli inkluzi chybějících hodnot.

````sql
WITH prices AS (
    SELECT DISTINCT
        year,
        food_category,
        avg_price
    FROM t_rudolf_preiss_project_sql_primary_final trppspf
    WHERE avg_price IS NOT NULL
),
````
Ve druhém CTE (````yoy_growth````) vypočítáme změnu cen napříč dostupnými roky. Vybereme nejdříve typy potravin (````food_category````) z prvního CTE a následně použijeme funkci ````LAG```` (umožňující získat cenu z předchozího roku) uvnitř vzorce: 
$$
\text{Procentuální změna} = \left( \frac{\text{Cena}_{\text{roku}} - \text{Cena}_{\text{předchozího roku}}}{\text{Cena}_{\text{předchozího roku}}} \right) \times 100
$$

````sql
yoy_growth AS (
    SELECT
        food_category,
        (((avg_price - LAG(avg_price) OVER (PARTITION BY food_category ORDER BY year )) / 
        LAG(avg_price) OVER (PARTITION BY food_category ORDER BY year)) * 100)::numeric AS percentage_change
    FROM prices
),
````
V posledním CTE pouze zprůměrujeme procentuální změny všech potravin za všechny roky, tak abychom získali pouze jednu procentuální hodnotu na potravinu (````AVG(percentage_change)```` a  ````GROUP BY food_category````)
````sql
final AS (
    SELECT
        food_category,
        ROUND(AVG(percentage_change), 2) AS percentage_change
    FROM yoy_growth
    WHERE percentage_change IS NOT NULL
    GROUP BY food_category 
)
````
V poslední části zobrazíme sloupce ````food_category```` a ````percentage_change```` z CTE ````final````, ale výsledky vyfiltrujeme tak, abychom získali jediný výsledek (````LIMIT 1````) s nejmenší (````ORDER BY percentage_change ASC````) pozitivní (````WHERE percentage_change > 0````) procentuální změnou.

````sql
SELECT *
FROM final
WHERE percentage_change > 0 
ORDER BY percentage_change ASC
LIMIT 1;
````
Výsledná tabulka vypadá takto:

<div align="center">

### 🗓️ Tabulka 3
<br>
</div>

| food_category | percentage_change |
|---------------|-------------------|
| Banány žluté  | 0.81              |


<br>

<div align="center">

### 🎯 Odpověď
<br>
</div>

&nbsp;&nbsp;&nbsp;&nbsp; Nejnižší procentuální nárůst v ceně se v průběhu let 2006-2018 vyskytl u banánů (průměrné roční zdražení - 0.81%).

<br>
<br>
<br>
<br>

<div align="center">

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 4

</span>

**❓ Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**



### 📜 SQL Skript

<br>

</div>


````sql
WITH wages AS (
    SELECT 
        year, 
        avg_wage AS avg_wages
    FROM t_rudolf_preiss_project_sql_primary_final trppspf
    WHERE industry_branch IS NULL
    GROUP BY year, avg_wage
),
prices AS (
    SELECT 
        year, 
        AVG(avg_price) AS avg_prices
    FROM (
        SELECT DISTINCT year, food_category, avg_price
        FROM t_rudolf_preiss_project_sql_primary_final trppspf
    )
    GROUP BY year
),
growth AS (
    SELECT 
        w.year,
        ((w.avg_wages - LAG(w.avg_wages) OVER (ORDER BY w.year)) / LAG(w.avg_wages) OVER (ORDER BY w.year) * 100)::numeric AS wage_growth,
        ((p.avg_prices - LAG(p.avg_prices) OVER (ORDER BY p.year)) / LAG(p.avg_prices) OVER (ORDER BY p.year) * 100)::numeric AS price_growth
    FROM wages w
    JOIN prices p ON w.year = p.year
)
SELECT 
    year,
    ROUND(wage_growth, 2) AS wage_growth,
    ROUND(price_growth, 2) AS price_growth,
    ROUND(price_growth - wage_growth, 2) AS wages_prices_diff
FROM growth
WHERE wage_growth IS NOT NULL 
  AND price_growth IS NOT NULL
ORDER BY year;
````
<div align="center">

### ⚙️ Postup
<br>
</div>

V odpovědi na tuto otázku budeme z primární tabulky používat sloupce:
- ````year```` (roky v rozmezí 2006-2018)
- ````avg_price```` (průměrná cena na každý rok a potravinu)
- ````avg_wage```` (průměrná mzda na každý rok přepočtená na plný úvazek)

V první části vytvoříme 3 CTE (````wages````, ````prices```` a ````growth````), ve kterých budeme z primární tabulky vybírat data průměrných mezd, cen a následně počítat procentuální změny obou metrik.

V prvním CTE nejdříve selektujeme roky (````year````) a průměrnou mzdu (````avg_wage````).
````sql
WITH wages AS (
    SELECT 
        year, 
        avg_wage AS avg_wages
    FROM t_rudolf_preiss_project_sql_primary_final trppspf
````
Dále vybereme pouze ty řádky, kde mzda reprezentuje průměr všech odvětví (````industry_branch IS NULL````) a data seskupíme podle roku a mzdy.

````sql
    WHERE industry_branch IS NULL
    GROUP BY year, avg_wage
````
Ve druhém CTE (````prices````) musíme nejdříve získat všechny jedinečné (````DISTINCT````) kombinace potravin, let a cen;

````sql
    
    FROM (
        SELECT DISTINCT year, food_category, avg_price
        FROM t_rudolf_preiss_project_sql_primary_final trppspf
    )
````

a poté na sloupec ````avg_price```` použít funkci ````AVG````, abychom získali průměrnou cenu napříč všemi typy potravin pro každý rok.

````sql
    SELECT 
        year, 
        AVG(avg_price) AS avg_prices
    
    GROUP BY year
),
````
Ve třetím CTE nejdříve spojíme obě předchozí CTE (````prices```` a ````wages````) pomocí roku

````sql
growth AS (
    SELECT 
        
    FROM wages w
    JOIN prices p ON w.year = p.year
)
````
a poté přidáme sloupec let (````w.year````) a stanovíme každoroční vývoj mezd a cen za použití funkce ````LAG```` a vzorce pro výpočet procentuální změny.

````sql
    SELECT 
        w.year,
        ((w.avg_wages - LAG(w.avg_wages) OVER (ORDER BY w.year)) / LAG(w.avg_wages) OVER (ORDER BY w.year) * 100)::numeric AS wage_growth,
        ((p.avg_prices - LAG(p.avg_prices) OVER (ORDER BY p.year)) / LAG(p.avg_prices) OVER (ORDER BY p.year) * 100)::numeric AS price_growth
````
Stačí pouze upravit výslednou tabulku do finální podoby.
Z CTE ````growth```` vybereme roky, zaokrouhlíme růsty mezd a cen na dvě desetinná místa a pro snazší interpretovatelnost přidáme sloupec rozdílu mezi růsty obou metrik.

````sql
SELECT 
    year,
    ROUND(wage_growth, 2) AS wage_growth,
    ROUND(price_growth, 2) AS price_growth,
    ROUND(price_growth - wage_growth, 2) AS wages_prices_diff
FROM growth
````
Výsledky na závěr upravíme tak, abychom se zbavili roku 2006, pro který nemáme u mezd ani cen srovnání roku předchozího a tak u něj určit procentuální růst nemůžeme.

````sql
WHERE wage_growth IS NOT NULL 
  AND price_growth IS NOT NULL
ORDER BY year;
````
Výsledná tabulka vypadá takto:

<div align="center">

### 🗓️ Tabulka 4
<br>
</div>

| year | wage_growth | price_growth | wages_prices_diff |
|------|-------------|--------------|-------------------|
| 2007 | 7.22        | 6.76         | -0.46             |
| 2008 | 7.85        | 6.18         | -1.67             |
| 2009 | 3.37        | -6.41        | -9.78             |
| 2010 | 2.16        | 1.94         | -0.22             |
| 2011 | 2.49        | 3.35         | 0.86              |
| 2012 | 2.50        | 6.73         | 4.23              |
| 2013 | -0.13       | 5.10         | 5.23              |
| 2014 | 2.91        | 0.74         | -2.17             |
| 2015 | 3.19        | -0.55        | -3.74             |
| 2016 | 4.42        | -1.19        | -5.61             |
| 2017 | 6.74        | 9.63         | 2.89              |
| 2018 | 8.16        | 2.17         | -5.99             |

<div align="center">

### 🎯 Odpověď
<br>
</div>

&nbsp;&nbsp;&nbsp;&nbsp;Z výsledků vidíme, že cenový růst potravin během let 2007–2018 v žádném roce nepřekročil růst mezd výrazným způsobem (tj. více než o 10%). 
Nejvyšší pozitivní rozdíl mezi růstem cen a mezd se objevil v roce 2013 (5.23%). 


<br>
<br>
<br>
<br>

<div align="center">

<span style="font-family: 'Arial Black'; font-style: italic;">

 ##  Otázka 5

</span>

**❓ Má výška HDP vliv na změny ve mzdách a cenách potravin?** 



### 📜 SQL Skript

<br>
</div>


````sql
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
<div align="center">

### ⚙️ Postup
<br>
</div>

V odpovědi na tuto otázku používáme dva skripty. V prvním kombinujeme data z primární i sekundární tabulky pro výpočet růstu HDP, cen a mezd během let 2007-2018. V druhém skriptu počítáme Pearsonovu korelaci HDP s cenami a HDP se mzdami, a to jak v rámci stejného roku, tak i s ročním zpožděním (lagged correlation).<br>
Z primární tabulky nás zajímají sloupce:
- ````year```` (roky v rozmezí 2006-2018)<br>
- ````avg_price```` (průměrná cena na každý rok a potravinu)<br>
- ````avg_wage```` (průměrná mzda na každý rok přepočtená na plný úvazek)<br>
  
a ze sekundární tabulky sloupce:
- ````year```` (roky v rozmezí 2006-2018)<br>
- ````gdp```` (nominální hodnota HDP v dolarech).<br>

V prvním skriptu nejdříve vytvoříme VIEW (````question5_vw````) a poté čtyři CTE (````gdp````, ````wages````, ````prices```` a ````prices_growth````).<br>
V prvním CTE ````gdp```` vybereme ze sekundární tabulky roky, HDP a rovnou vypočítáme růst HDP pomocí funkce ````LAG````.
````sql
WITH gdp AS (
    SELECT 
        year, 
        gdp,
        ((gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year) * 100) AS gdp_growth
    FROM t_rudolf_preiss_project_sql_secondary_final trppssf 
````
Zároveň je potřeba data filtrovat pomocí země, jelikož sekundární tabulka obsahuje informace o všech evropských zemích.

````sql
    WHERE country = 'Czech Republic'
````
Podobně, ve druhém CTE ````wages```` vybereme z primární tabulky roky, průměrnou mzdu a vypočítáme růst mezd.<br>
Data je potřeba filtrovat tak, abychom získali průměrné mzdy skrze všechna odvětví (````industry_branch IS NULL````) a zároveň je seskupit podle roků a mezd.
````sql
wages AS (
    SELECT 
        year, 
        avg_wage,
        ((avg_wage - LAG(avg_wage) OVER (ORDER BY year)) / LAG(avg_wage) OVER (ORDER BY year) * 100) AS wage_growth
    FROM t_rudolf_preiss_project_sql_primary_final trppspf 
    WHERE industry_branch IS NULL
    GROUP BY year, avg_wage
),
````
Ve třetím a čtvrtém CTE se zabýváme cenami. Důvod, proč pro získání růstu cen potřebujeme dvě CTE, je ten, že v prvním CTE musíme před samotným výpočtem nejdříve získat jedinečné (````DISTINCT````) kombinace roků, potravin a cen z důvodu duplicity řádků v primární tabulce. Data zároveň seskupíme pomocí roku.

````sql
prices AS (
    SELECT 
        year, 
        AVG(avg_price) AS avg_price
    FROM (SELECT DISTINCT year, food_category, avg_price FROM t_rudolf_preiss_project_sql_primary_final trppspf )
    GROUP BY year
),
````
Až poté můžeme v posledním CTE provést výpočet růstu cen pomocí funkce ````LAG````. 

````sql
prices_growth AS (
    SELECT 
        year,
        ((avg_price - LAG(avg_price) OVER (ORDER BY year)) / LAG(avg_price) OVER (ORDER BY year) * 100) AS price_growth
    FROM prices
)
````
Ve finálním skriptu všechny CTE sjednotíme pomocí ````INNER JOIN```` na základě roků
````sql
SELECT

FROM gdp g
JOIN wages w ON g.year = w.year
JOIN prices_growth p ON g.year = p.year
````
a zobrazíme procentuální změny zaokrouhlené na dvě desetinná místa.
````sql
SELECT 
    g.year,
    ROUND(g.gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(w.wage_growth::numeric, 2) AS wage_growth,
    ROUND(p.price_growth::numeric, 2) AS price_growth,
FROM gdp g
````
Stačí přidat dva sloupce, pomocí funkce ````LEAD````, které zobrazí růst mezd a cen pro rok následující a umožní nám tak snadný výpočet zpožděné korelace ve druhém skriptu.

````sql
    ROUND(LEAD(w.wage_growth) OVER (ORDER BY g.year)::numeric, 2) AS wage_growth_next_year,
    ROUND(LEAD(p.price_growth) OVER (ORDER BY g.year)::numeric, 2) AS price_growth_next_year
````
Nakonec data chronologicky seřadíme a zbavíme se řádku s rokem 2006 (````WHERE gdp_growth IS NOT NULL````), u kterého nemáme srovnání roku předchozího.
````sql
WHERE gdp_growth IS NOT NULL
ORDER BY g.year;
````
Výsledná tabulka vypadá takto:

<div align="center">

### 🗓️ Tabulka 5.1
<br>
</div>

| year | gdp_growth | wage_growth | price_growth | wage_growth_next_year | price_growth_next_year |
|------|------------|-------------|--------------|-----------------------|------------------------|
| 2007 | 5.57       | 7.22        | 6.76         | 7.85                  | 6.18                   |
| 2008 | 2.69       | 7.85        | 6.18         | 3.37                  | -6.41                  |
| 2009 | -4.66      | 3.37        | -6.41        | 2.16                  | 1.94                   |
| 2010 | 2.43       | 2.16        | 1.94         | 2.49                  | 3.35                   |
| 2011 | 1.76       | 2.49        | 3.35         | 2.50                  | 6.73                   |
| 2012 | -0.79      | 2.50        | 6.73         | -0.13                 | 5.10                   |
| 2013 | -0.05      | -0.13       | 5.10         | 2.91                  | 0.74                   |
| 2014 | 2.26       | 2.91        | 0.74         | 3.19                  | -0.55                  |
| 2015 | 5.39       | 3.19        | -0.55        | 4.42                  | -1.19                  |
| 2016 | 2.54       | 4.42        | -1.19        | 6.74                  | 9.63                   |
| 2017 | 5.17       | 6.74        | 9.63         | 8.16                  | 2.17                   |
| 2018 | 3.20       | 8.16        | 2.17         |                       |                        |


<div align="center">

### ⚙️ Postup
<br>
</div>

Ve druhém skriptu počítáme čtyři korelace z výsledků ````VIEW````, které jsme vytvořili v předchozím skriptu.
Bude nás zajímat:
1) Korelace HDP a mezd v rámci stejného roku
2) Korelace HDP a cen v rámci stejného roku
3) O rok zpoždená korelace mezi HDP a mzdami
4) O rok zpoždená korelace mezi HDP a cenami

Důvodem proč počítáme jak korelaci stejného roku tak korelaci zpožděnou je, že v realitě často existuje časová prodleva mezi tím, než se změny v HDP na ekonomiku státu projeví.
Ve skriptu použijeme funkci ````CORR````, která kalkuluje Pearsonův korelační koeficient.

````sql
-- druhý skript (korelace)

SELECT
	ROUND(CORR(gdp_growth, wage_growth)::numeric, 4) AS corr_gdp_wage,
    ROUND(CORR(gdp_growth, price_growth)::numeric, 4) AS corr_gdp_price,
	ROUND(CORR(gdp_growth, wage_growth_next_year)::numeric, 4) AS lagged_corr_gdp_wage,
    ROUND(CORR(gdp_growth, price_growth_next_year)::numeric, 4) AS lagged_corr_gdp_price
 FROM question5_vw qv;
````

Výsledná tabulka vypadá takto:

<div align="center">

### 🗓️ Tabulka 5.2
<br>
</div>

| corr_gdp_wage | corr_gdp_price | lagged_corr_gdp_wage | lagged_corr_gdp_price |
|---------------|----------------|----------------------|-----------------------|
| 0.4865        | 0.4869         | 0.7006               | -0.0305               |



<div align="center">

### 🎯 Odpověď
<br>
</div>

&nbsp;&nbsp;&nbsp;&nbsp;Z Tabulky 5.2 vidíme, že korelace růstů ve stejném roce, je v rámci vztahů HDP-mzdy i HDP-ceny v zásadě identická (0.4865 a 0.4869).
Obě metriky vykazují středně silnou korelaci s růstem HDP.
Co se týče zpožděného vlivu HDP na změny ve mzdách, korelační koeficient vykazuje hodnotu 0.7006, což indikuje silný pozitivní vztah, zatímco na růst cen se zdá, že HDP nemá žádný zpožděný vliv (korelace = -0.0305).
Z hlediska validity našich výsledků je nutné dodat, že ze všech čtyř typů zkoumaných vztahů, pouze zpožděná korelace mezi HDP a mzdami vykazuje p-hodnotu nízkou natolik, abychom vztah mohli považovat za statisticky signifikantní (p = 0.016).

