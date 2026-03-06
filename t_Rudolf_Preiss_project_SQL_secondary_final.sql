--SQL dotaz který filtruje hlavní údaje o evropských státech od roku 2000


with europe as (
select distinct country from countries where continent = 'Europe' )
select country, year, gdp, taxes, gini from economies e 
where country in (select country from europe) and e.gdp is not null and e."year" >= 2000
order by country, "year" ;