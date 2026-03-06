<center> 

# Rudolf Preiss SQL Projekt 
</center>

&nbsp;&nbsp;&nbsp;&nbsp;Tento projekt vznikl jako výsledná práce v rámci kurzu Datové akademie od ENGETO.
Cílem projektu bylo zpracovat pomocí SQL data o mzdách a cenách z těchto datových podkladů:
  
- ***czechia_payroll*** - údaje o průměrných mzdách a počtech zaměstnanců v ČR členěné podle odvětví a let
- ***czechia_payroll_calculation*** - číselník definující způsob výpočtu, rozlišující mezi fyzickým počtem zaměstnanců a počtem přepočteným na plný úvazek
- ***czechia_payroll_industry_branch*** - kódy a názvy pracovních odvětví
- ***czechia_payroll_unit*** - měrné jednotky pro czechia_payroll
- ***czechia_payroll_value_type*** - číselník s kódy hodnot průměrné mzdy a údaje o počtu zaměstnanců.
- ***czechia_price*** - údaje o cenách vybraných potravin v týdenních intervalech napříč kraji ČR.
- ***czechia_price_category*** - číselník s kódy a názvy potravin a jejich měrné jednotky.
- ***czechia_region*** - číselník s kódy a názvy krajů ČR.
- ***economies*** - ekonomické a demografické ukazatele pro jednotlivé státy v čase.
- ***countries*** - přehled geografických, politických a kulturních údajů o zemích světa


a odpovědět na následující otázky:

- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?


Struktura souborů v tomto repozitáři:

- <ins>SQL Projekt Data</ins> - datové podklady pro projekt
- <ins>SQL Projekt Code</ins> - kód ke zobrazení tabulek pro odpovědi na otázky
- <ins>Tabulky k otázkám</ins> - výsledné tabulky
- <ins>Průvodní listina</ins> - SQL kód, tabulky, postup, jaký jsem pro psaní kódu použil a odpovědi na otázky
- <ins>t_Rudolf_Preiss_project_SQL_primary_final</ins> - kód ke sjednocení tabulek cen, mezd a všech ostatních podtabulek na totožné porovnatelné období. 
- <ins>t_Rudolf_Preiss_project_SQL_secondary_final</ins> - kód ke zobrazení dodatečných dat o evropských státech

