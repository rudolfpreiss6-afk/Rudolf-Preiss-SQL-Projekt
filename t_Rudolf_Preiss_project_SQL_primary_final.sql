--SQL dotaz který sjednocuje data o mzdách a cenách potravin 


with payroll as (
select cp.payroll_year as year, cp.value, cp.value_type_code, 
cpvt."name" as value_meaning, cp.industry_branch_code as kód_odvětví, 
cpib.name as odvětví, cp.unit_code, cpu."name" as unit_meaning, cp.calculation_code as calculation_meaning, 
cpc."name" as calcul_name, cp.id from czechia_payroll cp 
join czechia_payroll_value_type cpvt on cpvt.code = cp.value_type_code 
join czechia_payroll_industry_branch cpib on cpib.code = cp.industry_branch_code
join czechia_payroll_calculation cpc on cp.calculation_code = cpc.code
join czechia_payroll_unit cpu on cpu.code = cp.unit_code
),
payroll_final as (select year, value as avg_salary, value_meaning, calcul_name as typ_mzdy, 
odvětví, 
id as payroll_id
from payroll 
where value_type_code = 5958 
and value is not null and calculation_meaning = 200
),
prices as (select extract(year from date_from) as rok, value as avg_price,
cpc."name" as potravina, 
cr.name as kraj, 
p.id as price_id 
from czechia_price p
join czechia_price_category cpc on p.category_code = cpc.code 
left join czechia_region cr on p.region_code = cr.code
)
select pf.year, pf.odvětví, pf.avg_salary, pr.potravina, pr.avg_price, pr.kraj
from payroll_final pf
left join prices pr on pf.year = pr.rok 
order by pf.year, pr.potravina;
