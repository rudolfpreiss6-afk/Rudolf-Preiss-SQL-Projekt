<center> 

# SQL Projekt

</center>

***Otázky a odpovědi***

***Autor***: Rudolf Preiss <br />


**Obsah**
- [SQL Projekt](#sql-projekt)
  - [Otázka 1](#otázka-1)
    - [Postup](#postup)
    - [Tabulka 1.1](#tabulka-11)
    - [Odpověď](#odpověď)
    - [Tabulka 1.2](#tabulka-12)
  - [Otázka 2](#otázka-2)
    - [Postup](#postup-1)
    - [Tabulka 2.1](#tabulka-21)
    - [Odpověď](#odpověď-1)
  - [Otázka 3](#otázka-3)
    - [Postup](#postup-2)
    - [Tabulka 3.1](#tabulka-31)
    - [Tabulka 3.2](#tabulka-32)
    - [Odpověď](#odpověď-2)
  - [Otázka 4](#otázka-4)
    - [Postup](#postup-3)
    - [Tabulka 4.1](#tabulka-41)
    - [Odpověď](#odpověď-3)
  - [Otázka 5](#otázka-5)
    - [Postup](#postup-4)
    - [Tabulka 5.1](#tabulka-51)
    - [Odpověď](#odpověď-4)



## Otázka 1 
**Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

````sql
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
````


### Postup

&nbsp;&nbsp;&nbsp;&nbsp;V první části query jsem vytvořil dvě CTE (Common Table Expressions) - mzda_2000 a mzda_2021, 
````sql
WITH mzda_2000 AS (
),
mzda_2021 AS ()
````
které slouží jako dočasné tabulky pouze pro potřeby první otázky.
V obou CTE nás zajímá pouze industry_branch_code (A = Zemědělství, lesnictví, rybářství, B = Těžba a dobývání atd.) a průměrná mzda na dané odvětví.
````sql
SELECT 
    industry_branch_code,
    ROUND(AVG(value)::numeric, 0) AS průměrná_mzda_2021
    FROM czechia_payroll

    GROUP BY industry_branch_code
````
U obou CTE zároveň chceme, aby mzdy odpovídaly prvnímu a poslednímu roku, abychom průměrovali pouze hrubé mzdy na zaměstnance a aby byly mzdy přepočtené na plný úvazek.
````sql
    WHERE payroll_year = 2021 
    AND value_type_code = 5958 
    AND calculation_code = 200
````
&nbsp;&nbsp;&nbsp;&nbsp;V druhé části chceme vytvořit finální tabulku. Za prvé potřebujeme získat jméno odvětví místo pomocí INNER JOIN s tabulkou czechia_payroll_industry_branch.
````sql
SELECT 
    cpib.name AS název_odvětví,
FROM mzda_2000 m0
JOIN czechia_payroll_industry_branch cpib ON m0.industry_branch_code = cpib.code
````
Za druhé chceme vidět průměrnou mzdu za oba roky u každého odvětví a její nárůst v Kč i procentech.
````sql
    m0.průměrná_mzda_2000,
    m21.průměrná_mzda_2021,
    m21.průměrná_mzda_2021 - m0.průměrná_mzda_2000 AS nárůst_mzdy_v_kč,
    ROUND(((m21.průměrná_mzda_2021 - m0.průměrná_mzda_2000) / m0.průměrná_mzda_2000::numeric) * 100, 2) AS procentuální_nárůst
````
Zbývá pouze do query pomocí JOIN funkce přidat tabulku průměrné mzdy za rok 2021 a pro přehlednost seřadit odvětví podle procntuálního nárustu mezd.
````sql
JOIN mzda_2021 m21 ON m0.industry_branch_code = m21.industry_branch_code

ORDER BY procentuální_nárůst DESC;
````
Výsledná tabulka vypadá takto:

### Tabulka 1.1
|název_odvětví|průměrná_mzda_2000|průměrná_mzda_2021|nárůst_mzdy_v_kč|procentuální_nárůst|
|-------------|------------------|------------------|----------------|-------------------|
|Zdravotní a sociální péče|11968|47203|35235|294.41|
|Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu|18492|55925|37433|202.43|
|Vzdělávání|12205|36892|24687|202.27|
|Informační a komunikační činnosti|22068|64400|42332|191.83|
|Zpracovatelský průmysl|12836|35227|22391|174.44|
|Profesní, vědecké a technické činnosti|15991|43681|27690|173.16|
|Ubytování, stravování a pohostinství|7518|20471|12953|172.29|
|Kulturní, zábavní a rekreační činnosti|11405|30690|19285|169.09|
|Velkoobchod a maloobchod; opravy a údržba motorových vozidel|12551|33602|21051|167.72|
|Zemědělství, lesnictví, rybářství|10452|27626|17174|164.31|
|Činnosti v oblasti nemovitostí|12415|32692|20277|163.33|
|Veřejná správa a obrana; povinné sociální zabezpečení|15460|39731|24271|156.99|
|Peněžnictví a pojišťovnictví|25171|62544|37373|148.48|
|Administrativní a podpůrné činnosti|10454|25686|15232|145.70|
|Ostatní činnosti|11140|27267|16127|144.77|
|Stavebnictví|12607|30762|18155|144.01|
|Doprava a skladování|13367|32257|18890|141.32|
|Zásobování vodou; činnosti související s odpady a sanacemi|13228|31821|18593|140.56|
|Těžba a dobývání|16567|38068|21501|129.78|


### Odpověď

&nbsp;&nbsp;&nbsp;&nbsp;Z tabulky vidíme, že přepočtené průměrné mzdy v každém odvětví mezi roky 2000 a 2021 v ČR vzrostly. Nejvyšší, téměř čtyřnásobný nárůst, proběhl v odvětví Zdravotní a sociální péče (294.41%) a nejnižší v sektoru Těžby a dobývání (129.78%). Druhé a třetí nejvíce rostoucí odvětví z hlediska platů jsou Výroba a rozvod elektřiny, plynu, tepla a klimatizace vzduchu a Vzdělávání (více než trojnsobné zvýšení u obou).


Pokud by nás pro zajímavost zajímalo, jestli mzdy kdykoliv v letech 2000 až 2021 v některých ze sektorů meziročně poklesly, mohli bychom použít následující query:<br>
<br>

````sql
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
````
&nbsp;&nbsp;&nbsp;&nbsp;Ve stručnosti vysvětlím, co v query děláme.
V prvním CTE z tabulky czechia_payroll, podobně jako v předchozím query, vytahujeme přepočtenou průměrnou mzdu na odvětví a rok.
V druhém CTE za pomocí funkce LAG, připojíme sloupec, který obsahuje hodnotu mzdy předchozího roku.
````sql
SELECT *,
        LAG(průměrná_mzda) OVER (PARTITION BY název_odvětví ORDER BY rok) AS mzda_předchozího_roku
    FROM mzdy)
````
PARTITION BY název_odvětví zajišťuje, že informace pro mzdu_předchozího_roku je vždy v rámci toho samého odvětví (neskáče z odvětví do odvětví).
ORDER BY rok zajišťuje, že předtím než je informace získána, data jsou seřazeny vzestupně podle roku.
V poslední části stačí připojit meziroční rozdíl v kč a procentech a vyfiltrovat tabulku, aby ukazovala pouze řádky, kdy je průměrná mzda oproti předchozímu roku nižší.

````sql
SELECT *,
    průměrná_mzda - mzda_předchozího_roku AS rozdíl_v_kč,
    ROUND(((průměrná_mzda - mzda_předchozího_roku) / mzda_předchozího_roku::numeric) * 100, 2)::text || '%' AS pokles_v_procentech
from výpočet_poklesu
where průměrná_mzda < mzda_předchozího_roku
ORDER BY rok, název_odvětví;
````

Query vygeneruje tuto tabulku:

### Tabulka 1.2
|rok|název_odvětví|průměrná_mzda|mzda_předchozího_roku|rozdíl_v_kč|pokles_v_procentech|
|---|-------------|-------------|---------------------|-----------|-------------------|
|2009|Činnosti v oblasti nemovitostí|20706|20790|-84|-0.40%|
|2009|Těžba a dobývání|28361|29273|-912|-3.12%|
|2009|Ubytování, stravování a pohostinství|12334|12472|-138|-1.11%|
|2009|Zemědělství, lesnictví, rybářství|17645|17764|-119|-0.67%|
|2010|Profesní, vědecké a technické činnosti|31602|31791|-189|-0.59%|
|2010|Veřejná správa a obrana; povinné sociální zabezpečení|26944|27035|-91|-0.34%|
|2010|Vzdělávání|23023|23416|-393|-1.68%|
|2011|Doprava a skladování|23062|23063|-1|0.00%|
|2011|Ubytování, stravování a pohostinství|13131|13205|-74|-0.56%|
|2011|Veřejná správa a obrana; povinné sociální zabezpečení|26331|26944|-613|-2.28%|
|2011|Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu|40202|40296|-94|-0.23%|
|2013|Administrativní a podpůrné činnosti|16829|17041|-212|-1.24%|
|2013|Činnosti v oblasti nemovitostí|22152|22553|-401|-1.78%|
|2013|Informační a komunikační činnosti|46155|46641|-486|-1.04%|
|2013|Kulturní, zábavní a rekreační činnosti|20511|20808|-297|-1.43%|
|2013|Peněžnictví a pojišťovnictví|46317|50801|-4484|-8.83%|
|2013|Profesní, vědecké a technické činnosti|31825|32817|-992|-3.02%|
|2013|Stavebnictví|22379|22850|-471|-2.06%|
|2013|Těžba a dobývání|31487|32540|-1053|-3.24%|
|2013|Velkoobchod a maloobchod; opravy a údržba motorových vozidel|23130|23324|-194|-0.83%|
|2013|Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu|40762|42657|-1895|-4.44%|
|2013|Zásobování vodou; činnosti související s odpady a sanacemi|23616|23718|-102|-0.43%|
|2014|Těžba a dobývání|31302|31487|-185|-0.59%|
|2015|Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu|40453|41094|-641|-1.56%|
|2016|Těžba a dobývání|31626|31809|-183|-0.58%|
|2020|Činnosti v oblasti nemovitostí|29320|31470|-2150|-6.83%|
|2020|Ubytování, stravování a pohostinství|19897|20929|-1032|-4.93%|
|2021|Kulturní, zábavní a rekreační činnosti|30690|31738|-1048|-3.30%|
|2021|Stavebnictví|30762|30957|-195|-0.63%|
|2021|Veřejná správa a obrana; povinné sociální zabezpečení|39731|40644|-913|-2.25%|
|2021|Vzdělávání|36892|37978|-1086|-2.86%|
|2021|Zemědělství, lesnictví, rybářství|27626|28705|-1079|-3.76%|

V tabulce můžeme vidět 32 instancí, u kterých průměrné mzdy v určitých odvětvích meziročně poklesly. Jedná se zejména o roky 2013 (11 odvětví vykázalo propad mezd o proti přechozímu roku), 2021 (5 odvětví), 2009 (4 odvětví) a rok 2011 (4 odvětví).
Závěrem však lze říct, že průmerné mzdy dlouhodobě (mezi roky 2000 a 2021) napříč všemi odvětvími 
rostou.


## Otázka 2
**Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**
````sql
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
````
### Postup

&nbsp;&nbsp;&nbsp;&nbsp;V první řadě je potřeba vědět, že tabulka czechia_payroll v řadcích, kde industry_branch_code je prázdný (NULL), nabízí vážený průměr mezd všech odvětví (průměrná mzda je přepočtena podle počtu zaměstnanců na odvětví). 
To využijeme v prvním CTE. Z tabulky jsem vytáhl rok a přepočtený vážený průměr mzdy seskupený podle let.
````sql
    SELECT 
        payroll_year AS rok_mzdy,
        AVG(value) AS prům_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958 AND calculation_code = 200 AND industry_branch_code is null
    GROUP BY payroll_year
````
&nbsp;&nbsp;&nbsp;&nbsp;V druhém CTE se zabýváme ceny produktů. Za prvé použijeme funkci EXTRACT, abychom získali stejné srovnatelné časové období jako mzdy.
````sql
    SELECT    
        extract(YEAR FROM date_from) AS rok_ceny,
````
Za druhé propojíme tabulku czechia_price s tabulkou czechia_price_category, která, stejně jako czechia_price obsahuje kód, ale i název potravin.
Nás zajímají pouze tyto produkty: Chléb konzumní kmínový (kód: 111301) a Mléko polotučné pasterované (kód: 114201).
Zároveň chceme výsledek fitrovat tak, aby region_code z tabulky czechia_price byl prázdný (data odpovídala celé ČR, nikoliv určitým regionům).

````sql
    SELECT
        
        cpc.name as název_produktu,

    JOIN czechia_price_category cpc ON cp.category_code = cpc.code
    WHERE cp.category_code IN (111301, 114201) AND cp.region_code IS NULL
````
Stačí pouze přidat průmernou cenu, její jednotku a data seskupit:

````sql
    SELECT 
        AVG(cp.value) AS průměrná_cena,
        cpc.price_unit AS jednotka_ceny
    FROM czechia_price cp

    GROUP BY rok_ceny, cp.category_code, cpc.name, cpc.price_unit
````
&nbsp;&nbsp;&nbsp;&nbsp;V poslední části query použijeme sloupec roků jako index, kterým spojíme tabulku mezd a cen dohromady. 
 ````sql
SELECT 
    m.rok_mzdy AS rok

FROM mzdy_výpočet m
JOIN ceny_výpočet c ON m.rok_mzdy = c.rok_ceny
````
Zároveň víme, že chceme porovnat pouze první a poslední srovnatelné období. Query tedy musíme filtorvat tak, aby se nejvyšší a nejnižší rok ocitl v obou předchozích CTE.

````sql
WHERE m.rok_mzdy = (SELECT MIN(rok_mzdy) FROM mzdy_výpočet WHERE rok_mzdy IN (SELECT rok_ceny FROM ceny_výpočet))
OR m.rok_mzdy = (SELECT MAX(rok_mzdy) FROM mzdy_výpočet WHERE rok_mzdy IN (SELECT rok_ceny FROM ceny_výpočet))
````
Na závěr stačí přidat všechny ostatní sloupce: název produktu, zaokrouhlenou průměrnou cenu, zaokrouhlenou průměrnou mzdu a množství produktu k nákupu za průměrnou mzdu (mzda / cena).
Množství k nákupu jsem zároveň zaokrouhlil směrem dolů na nejbližší celou jednotku (funkce FLOOR)
a stejně jako u průměrné ceny jsem sloupec změnil na textový datový typ, abych za hodnotu mohl přidat jednotku.

````sql
    c.název_produktu,
    ROUND(m.prům_mzda::numeric, 0) as průměrná_mzda,
    ROUND(c.průměrná_cena::numeric, 2)::text || ' / ' || c.jednotka_ceny AS průměrná_cena,
    floor(m.prům_mzda / c.průměrná_cena)::text || ' ' || c.jednotka_ceny AS množství_k_nákupu

ORDER BY rok, název_produktu
````
&nbsp;&nbsp;&nbsp;&nbsp;Tabulka vypadá takto:

### Tabulka 2.1
|rok|název_produktu|průměrná_mzda|průměrná_cena|množství_k_nákupu|
|---|--------------|-------------|-------------|-----------------|
|2006|Chléb konzumní kmínový|19536|16.12 / kg|1211 kg|
|2006|Mléko polotučné pasterované|19536|14.44 / l|1353 l|
|2018|Chléb konzumní kmínový|32043|24.24 / kg|1321 kg|
|2018|Mléko polotučné pasterované|32043|19.82 / l|1616 l|

### Odpověď
Z tabulky vidíme, že v prvním srovnatelném období (rok 2006) jsme si průměrně mohli koupit 1211 kilogramů chleba nebo 1353 litrů mléka, zatímco v posledním srovnatelném období (2018) to bylo 1321 kilogramů chleba nebo 1616 litrů mléka.
Z výsledku vidíme, že ve vztahu k těmto dvěma potravinám průměrná mzda stoupla.


## Otázka 3
**Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?** 

````sql
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
````

````sql
SELECT *
FROM ceny_vw
WHERE průměrný_procentuální_růst = (
    SELECT MIN(průměrný_procentuální_růst)
    FROM ceny_vw
    WHERE průměrný_procentuální_růst > 0
);
````

### Postup

&nbsp;&nbsp;&nbsp;&nbsp;V první řadě jsem vytvořil VIEW, které nám umožní uchovat informace o inflaci všech potravin.

````sql
create view ceny_vw AS
````

&nbsp;&nbsp;&nbsp;&nbsp;Nejdříve budeme potřebovat data o cenách potravin na každý rok. Vytvoříme CTE uvnitř našeho VIEW a extrahujeme rok ze sloupce date_from v tabulce czechia_price.

````sql
WITH roční_ceny_potravin AS (
    SELECT 
        EXTRACT(YEAR FROM date_from) as rok_srovnání,

    FROM czechia_price)
````
Dále do SELECT přidáme kód kategorie a průměrnou cenu pomocí funkce AVG. Zároveň chceme, aby se data vztahovala na celou ČR a proto musíme filtrovat tak, aby region_code byl null.
Stačí už jenom použít funkci GROUP BY, aby se průměrná cena mohla agregovat.

````sql
    SELECT 
        category_code AS kód_kategorie,
        AVG(value) AS průměrná_cena
    FROM czechia_price
    WHERE region_code is null
    GROUP BY rok_srovnání, kód_kategorie
````
&nbsp;&nbsp;&nbsp;&nbsp; V druhé části pouze vytvoříme další CTE a vybereme kód kategorie a roky z předchozího CTE, 

````sql
předchozí_cena_data AS (
    SELECT
        kód_kategorie AS kk,
        rok_srovnání AS rok_předchozí,
    FROM roční_ceny_potravin
)
````
ale k danému roku přiřadíme průměrné ceny za předchozí rok pomocí funkce LAG.

````sql
LAG(průměrná_cena) OVER (PARTITION BY kód_kategorie ORDER BY rok_srovnání) AS předchozí_cena
````

&nbsp;&nbsp;&nbsp;&nbsp;V poslední části query v zásadě slučujeme data z obou tabulek.
Data budeme vytahovat z prvního CTE (roční_ceny_potravin) a musíme tedy JOINovat druhé CTE přes kategorii a kód (je potřeba použít oba sloupce, jinak JOIN neproběhne správně).

````sql
SELECT 

FROM roční_ceny_potravin rcp
JOIN předchozí_cena_data pcd 
    ON rcp.kód_kategorie = pcd.kk and rcp.rok_srovnání = pcd.rok_předchozí
````
Dále přidáme tabulku czechia_price_category, abychom mohli zobrazit názvy kategorií a nikoliv jejich kódy.

````sql
JOIN czechia_price_category cpc 
    ON rcp.kód_kategorie = cpc.code
````
Nyní vybereme název potraviny z tabulky czechia_price_category a zaokrouhlený průměrný procentuální růst pomocí vzorce: 
$$i = \left( \frac{\text{Cena}_{\text{ roku}} - \text{Cena}_{\text{ předchozího roku}}}{\text{Cena}_{\text{ předchozího roku}}} \right) \times 100$$

````sql
SELECT 
    cpc.name AS potravina,
    ROUND(AVG((rcp.průměrná_cena - pcd.předchozí_cena) / pcd.předchozí_cena)::numeric, 4) * 100 AS průměrný_procentuální_růst
FROM roční_ceny_potravin rcp
````

Stačí pouze výsledek VIEW filtrovat pomocí WHERE,

````sql
WHERE pcd.předchozí_cena IS NOT NULL
````
což eliminuje první rok cen, pro které nemáme srovnání předchozího roku. A dále finální tabulku seskupit pomocí názvu potravin a seřadit podle procentuálního růstu.

````sql
GROUP BY cpc.name
ORDER BY průměrný_procentuální_růst;
````
&nbsp;&nbsp;&nbsp;&nbsp;Kdybychom nyní chtěli vidět výslednou tabulku, stačilo by použít dotaz:

````sql
SELECT *
FROM ceny_vw
````
### Tabulka 3.1

|potravina|průměrný_procentuální_růst|
|---------|----------------------------------|
|Cukr krystalový|-1.92|
|Rajská jablka červená kulatá|-0.74|
|Banány žluté|0.81|
|Vepřová pečeně s kostí|0.99|
|Přírodní minerální voda uhličitá|1.03|
|Šunkový salám|1.85|
|Jablka konzumní|2.01|
|Pečivo pšeničné bílé|2.20|
|Hovězí maso zadní bez kosti|2.53|
|Kapr živý|2.60|
|Jakostní víno bílé|2.70|
|Pivo výčepní, světlé, lahvové|2.86|
|Eidamská cihla|2.92|
|Mléko polotučné pasterované|2.98|
|Rostlinný roztíratelný tuk|3.23|
|Kuřata kuchaná celá|3.38|
|Pomeranče|3.60|
|Jogurt bílý netučný|3.96|
|Chléb konzumní kmínový|3.97|
|Konzumní brambory|4.18|
|Rýže loupaná dlouhozrnná|5.00|
|Mrkev|5.24|
|Pšeničná mouka hladká|5.24|
|Těstoviny vaječné|5.27|
|Vejce slepičí čerstvá|5.55|
|Máslo|6.67|
|Papriky|7.29|

&nbsp;&nbsp;&nbsp;&nbsp;Otázka se nás ale ptala u které kategorie potravin je nejnižší meziroční perecentuální nárůst.
Stačí použít následující query, kde pomocí LIMIT 1 vybíráme ***jedinou*** potravinu, jejíž průměrný cenový růst je ***nejmenší*** - MIN(průměrný_procentuální_růst) a zároveň ***vyšší než 0*** (WHERE průměrný_procentuální_růst > 0).

````sql
SELECT potravina, MIN(průměrný_procentuální_růst) as průměrný_procentuální_růst 
FROM ceny_vw
WHERE průměrný_procentuální_růst > 0
group by ceny_vw.potravina 
LIMIT 1
````

### Tabulka 3.2

|potravina|průměrný_procentuální_růst|
|---------|--------------------------|
|Banány žluté|0.81|

### Odpověď

Odpovědí jsou Banány žluté.

## Otázka 4
**Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

````sql
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
````

### Postup

&nbsp;&nbsp;&nbsp;&nbsp;V query opět vytváříme 2 CTE (roční_ceny a roční_mzdy), které následně pomocí JOIN funkce sjednotíme ve třetím CTE (výpočet_růstu) a na závěr vytváříme finální podobu tabulky.

&nbsp;&nbsp;&nbsp;&nbsp;Stručně vysvětlím co děláme v prvních dvou CTE.
V prvním CTE z tabulky czechia_payroll vytahujeme rok a průměrnou mzdu (AVG(value)).
Filtrujeme tak, aby value_type_code byl 5958 (průměrná hrubá mzda na zaměstnance) a calculation_code = 200 (přepočtená mzda). Zároveň chceme získat data napříč všemi odvětvími - industry_branch_code is null a seskupit je podle roku.

````sql
WITH roční_mzdy as (
SELECT payroll_year AS rok, AVG(value) AS průměrná_mzda
FROM czechia_payroll
where value_type_code = 5958 and calculation_code = 200
and industry_branch_code IS NULL
    GROUP BY rok),
````

&nbsp;&nbsp;&nbsp;&nbsp;V druhém CTE z tabulky czechia_price musíme rok extrahovat (EXTRACT(YEAR FROM date_from)), jelikož hodnoty obshaují i dny a měsíce. Průměrnou cenu získáme stejným způsobem jako v předchozím CTE - AVG(value).
Data chceme za celou ČR (where region_code is null) a seskupené podle roku.

````sql
roční_ceny AS (
SELECT 
EXTRACT(YEAR FROM date_from) AS rok_ceny, AVG(value) as průměrná_cena
FROM czechia_price
WHERE region_code is null
group by rok_ceny
),
````

&nbsp;&nbsp;&nbsp;&nbsp;Ve třetím CTE používáme pro výpočet procentuálního růstu mezd a cen vzorek [(prům. mzda roku - prům. mzda předchozího roku) / prům. mzda předchozího roku] * 100 .
Pro výpočet průměrné mzdy předchozího roku je potřeba funkce LAG napříč vzestupně seřazenými roky.


````sql
výpočet_růstu AS (
SELECT 

((m.průměrná_mzda - LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) / LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) * 100 as růst_mezd,
((c.průměrná_cena - LAG(c.průměrná_cena) over (ORDER BY c.rok_ceny)) / LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) * 100 AS růst_cen
)
````
Zároveň pomocí INNER JOIN sloučíme tabulky cen a mezd skrze rok.

````sql
SELECT 
m.rok,

FROM roční_mzdy m
JOIN roční_ceny c ON m.rok = c.rok_ceny
````

Je potřeba zmínit, že jelikož jsou průměrné mzdy zaznamenány od roku 2000 a průměrné ceny od roku 2006, INNER JOIN zahrne rok 2006 do výsledné tabulky. Pro tento rok, ale ceny nemají srovnání předchozího roku a výledek výpočtu vzorce bude prázdný (NULL). Rok 2006 tedy v následujícím kroku vymažeme.

&nbsp;&nbsp;&nbsp;&nbsp;V poslední části pouze vytváříme finální podobu tabulky. Do query vložíme společné roky obou odvětví, a procentuální růst cen a mezd zaokrouhlíme na dvě destinná čísla.

````sql
SELECT 
    rok, ROUND(růst_mezd::numeric, 2) as růst_mezd_v_procentech,
    ROUND(růst_cen::numeric, 2) as růst_cen_potravin_v_procentech,

FROM výpočet_růstu
````

Chceme také zobrazit rozdíl růstu cen a mezd a smazat rok 2006, pro který nemáme u cen předchozí srovnatelné období. Na závěr seřadíme tabulku podle roku.

````sql
SELECT 
    ROUND((růst_cen - růst_mezd)::numeric, 2) AS rozdíl_v_procentech
FROM výpočet_růstu
where růst_cen - růst_mezd is not null
ORDER BY rok;
````

### Tabulka 4.1

|rok|růst_mezd_v_procentech|růst_cen_potravin_v_procentech|rozdíl_v_procentech|
|---|----------------------|------------------------------|-------------------|
|2007|7.22|6.35|-0.87|
|2008|7.85|6.41|-1.44|
|2009|3.37|-6.81|-10.18|
|2010|2.16|1.77|-0.40|
|2011|2.49|3.50|1.01|
|2012|2.50|6.92|4.42|
|2013|-0.13|5.55|5.68|
|2014|2.91|0.89|-2.02|
|2015|3.19|-0.56|-3.75|
|2016|4.42|-1.12|-5.54|
|2017|6.74|9.98|3.24|
|2018|8.16|1.95|-6.21|

### Odpověď
&nbsp;&nbsp;&nbsp;&nbsp;Výsledná tabulka ukazuje, že cenový růst, ve srovnatelném období let 2007–2018, v žádném roce nepřekročil růst mezd výrazným způsobem (tj. více než o 10%). 
Nejvyšší zaznamenaný rozdíl mezi růstem cen a mezd se objevil v roce 2013 (5.68%).

Kdybychom v posledním query do podmínky WHERE přidali;

````sql
and (růst_cen - růst_mezd) > 10
````

vznikla by prázdná tabulka, což potvrzuje naše výsledky.


## Otázka 5
**Má výška HDP vliv na změny ve mzdách a cenách potravin?** 


````sql
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
````

### Postup

&nbsp;&nbsp;&nbsp;&nbsp;V prvním CTE pracujeme s novou tabulkou economies, která obsahuje řadu indikátorů o jednotlivých zemích včetně hdp.
Z tabulky vybereme rok, hdp a vytvoříme sloupec procentuálního růstu hdp pomocí LAG funkce a vzorce [(HDP roku - HDP předchozího roku) / HDP předchozího roku] * 100.
Tabulku stačí filtrovat pomocí sloupce 'country' = 'Czech Republic'.

````sql
 with roční_hdp as (
 SELECT year as rok, gdp as hdp,
 ((gdp - LAG(gdp) OVER (order by year)) / LAG(gdp) OVER (order by year)) * 100 as růst_hdp from economies
    where country = 'Czech Republic'
),
````
&nbsp;&nbsp;&nbsp;&nbsp;V druhém a třetím CTE opět vybíráme průměrné roční mzdy a ceny. Mzdy jsou přepočtené na hlavní úvazek a skrze všechna odvětví. Ceny jsou v rámci celé ČR.

````sql
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
````

&nbsp;&nbsp;&nbsp;&nbsp;Ve čtvrtém CTE, počítáme růst jednotlivých indexů.
Z prvního CTE, stačí pouze přidat rok a růst hdp.

````sql
výpočet_růstu as
(SELECT h.rok, h.růst_hdp,

    from roční_hdp h)
````

Dále potřebujeme, pomocí funkce JOIN, připojit informace o mzdách a cenách.
Důvod proč používáme LEFT JOIN je, že časová období jsou u všech tří tabulek odlišná. Otázka se nás ptá, jaký vliv má HDP na ceny a mzdy a budeme proto používat HDP jako hlavní osu, bez ohledu na to, jestli máme ke všem rokům HDP obě informace o mzdách i cenách.

````sql
left JOIN roční_mzdy m on h.rok = m.rok
left JOIN roční_ceny c ON h.rok = c.rok_ceny
````

Stačí pouze použít LAG funkci přes seřazené roky pro získání ceny/mzdy předchozího roku a vzorec, který jsme již několikrát použili;

$$i = \left( \frac{\text{Cena/Mzda}_{\text{ roku}} - \text{Cena/Mzda}_{\text{ předchozího roku}}}{\text{Cena/mzda}_{\text{ předchozího roku}}} \right) \times 100$$

a získáme procentuální růst mezd a cen.

````sql
(SELECT
((m.průměrná_mzda - LAG(m.průměrná_mzda) over (order by m.rok)) / LAG(m.průměrná_mzda) OVER (ORDER BY m.rok)) * 100 as růst_mezd,
((c.průměrná_cena - LAG(c.průměrná_cena) over (order by c.rok_ceny)) / LAG(c.průměrná_cena) OVER (ORDER BY c.rok_ceny)) * 100 AS růst_cen
)
````
&nbsp;&nbsp;&nbsp;&nbsp;V posledním CTE budeme vytvářet dva sloupce s informací o růstu mezd a cen k následujícímu roku.
Nejdříve SELECTujeme všechno z přechozího CTE (tj. všechny dosud vytvořené informace).

````sql
růst_lead AS (
    SELECT *
    from výpočet_růstu)
````

A nyní použijeme funkci LEAD, která nám umožní posunout růst mezd a cen o rok dále (opak funkce LAG).

````sql
    SELECT *, LEAD(růst_mezd) over (ORDER BY rok) as růst_mezd_nasl_rok,
        lead(růst_cen) OVER (ORDER BY rok) AS růst_cen_nasl_rok from výpočet_růstu
````

&nbsp;&nbsp;&nbsp;&nbsp;Ve finálním query upravujeme tabulku do finální podoby a přidáváme dva další sloupce s korelací mezi nárůstem HDP a růstem cen a mezd o rok později.
Nejdříve připojíme všechny údaje z posledního CTE a zaokrouhlíme je na poslední dvě desetinná místa.

````sql
SELECT 
rok,
round(růst_hdp::numeric, 2) as růst_HDP,
round(růst_mezd::numeric, 2) as růst_mezd,
ROUND(růst_cen::numeric, 2) as růst_cen,
ROUND(růst_mezd_nasl_rok::numeric, 2) AS růst_mezd_následující_rok,
ROUND(růst_cen_nasl_rok::numeric, 2) AS růst_cen_následující_rok

from růst_lead
````

Sql nabízí funkci CORR, která vezme Y (závislá proměnná) a X (nezávislá proměnná) jako 2 argumenty a filtr OVER. V našem případě necháme OVER() prázdný a dostaneme tak korelaci pro celou datovou sadu.

````sql
round(CORR(růst_mezd_nasl_rok, růst_hdp) over ()::numeric, 4) as korelace_HDP_mzdy,
round(CORR(růst_cen_nasl_rok, růst_hdp) OVER ()::numeric, 4) as korelace_HDP_ceny
````

Stačí seřadit data podle roku a filtrovat tak, aby tabulka ukazovala pouze řádky, ve kterých se vyskytuje růst hdp spolu s růstem mezd, růstem cen nebo obojím.

````sql
WHERE růst_hdp is not null and (růst_mezd IS NOT NULL OR růst_cen IS NOT NULL)
order by rok;
````

### Tabulka 5.1

|rok|růst_hdp|růst_mezd|růst_cen|růst_mezd_následující_rok|růst_cen_následující_rok|korelace_hdp_mzdy|korelace_hdp_ceny|
|---|--------|---------|--------|-------------------------|------------------------|-----------------|-----------------|
|2001|3.04|8.74||8.03||0.6689|0.0760|
|2002|1.57|8.03||5.82||0.6689|0.0760|
|2003|3.58|5.82||6.28||0.6689|0.0760|
|2004|4.81|6.28||5.04||0.6689|0.0760|
|2005|6.60|5.04||6.54||0.6689|0.0760|
|2006|6.77|6.54||7.22|6.35|0.6689|0.0760|
|2007|5.57|7.22|6.35|7.85|6.41|0.6689|0.0760|
|2008|2.69|7.85|6.41|3.37|-6.81|0.6689|0.0760|
|2009|-4.66|3.37|-6.81|2.16|1.77|0.6689|0.0760|
|2010|2.43|2.16|1.77|2.49|3.50|0.6689|0.0760|
|2011|1.76|2.49|3.50|2.50|6.92|0.6689|0.0760|
|2012|-0.79|2.50|6.92|-0.13|5.55|0.6689|0.0760|
|2013|-0.05|-0.13|5.55|2.91|0.89|0.6689|0.0760|
|2014|2.26|2.91|0.89|3.19|-0.56|0.6689|0.0760|
|2015|5.39|3.19|-0.56|4.42|-1.12|0.6689|0.0760|
|2016|2.54|4.42|-1.12|6.74|9.98|0.6689|0.0760|
|2017|5.17|6.74|9.98|8.16|1.95|0.6689|0.0760|
|2018|3.20|8.16|1.95|7.89||0.6689|0.0760|
|2019|2.31|7.89||3.15||0.6689|0.0760|
|2020|-5.60|3.15||||0.6689|0.0760|

### Odpověď
Z tabulky vidíme, že korelace mezi růstem HDP a růstem mezd následující rok je 0.6689, což naznačuje středně silný vztah. Nevíme ale, jestli se jedná pouze o korelaci nebo i kauzalitu. U růstu cen se zdá, že HDP nehraje žádný vliv (korelace - 0.0760) 