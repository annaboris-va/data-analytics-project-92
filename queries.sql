--Шаг 4. Работа с базой данных. Запрос считает общее количество покупателей из таблицы customers. 
select 
	count(customer_id) as customers_count
from customers;

--Шаг 5. Анализ отдела продаж.
-- Первый отчет о десятке лучших продавцов (у которых наибольшая выручка)
select
	concat (e.first_name, ' ', e.last_name) as seller, --имя и фамилия продавца
	count (s.sales_id) as operations, --количество проведенных сделок
	floor (sum (p.price*s.quantity)) as income--суммарная выручка продавца за все время
from sales as s
join employees as e on e.employee_id = s.sales_person_id 
join products as p on p.product_id = s.product_id 
group by seller
order by income desc
limit 10
;

--Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
with tab as
(select
	concat (e.first_name, ' ', e.last_name) as seller, --имя и фамилия продавца
	count (s.sales_id) as operations, --количество проведенных сделок
	sum (p.price*s.quantity) as income--суммарная выручка продавца за все время
from sales as s
join employees as e on e.employee_id = s.sales_person_id 
join products as p on p.product_id = s.product_id 
group by seller
order by income desc
)
select
	seller,
	floor (income/operations) as average_income
from tab
where floor (income/operations) < (select avg (income/operations) from tab)
order by average_income ASC
;

--Третий отчет содержит информацию о выручке по дням недели для каждого продавца. 
select
	concat (e.first_name, ' ', e.last_name) as seller, --имя и фамилия продавца
	to_char (s.sale_date, 'day') as day_of_week, --день недели
	floor (sum (p.price*s.quantity)) as income--суммарная выручка продавца за все время
from sales as s
join employees as e on e.employee_id = s.sales_person_id 
join products as p on p.product_id = s.product_id 
group by seller, extract (isodow  from s.sale_date), to_char (s.sale_date, 'day')
order by extract (isodow  from s.sale_date), seller
;



--Шаг 6. Анализ покупателей.
--Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+
select 
	'16-25' as age_category,
	count (*) as age_count
from customers
where age >= 16 and age <=25
union 
select 
	'26-40' as age_category,
	count (*) as age_count
from customers
where age >= 26 and age <=40
union 
select 
	'40+' as age_category,
	count (*) as age_count
from customers
where age >= 41
order by age_category
;

--Второй отчет содержит данные по количеству уникальных покупателей и выручке, которую они принесли (по месяцам). 
select
	to_char (s.sale_date, 'yyyy-mm') as selling_month,
	count (distinct s.customer_id) as total_customers,
	floor (sum (p.price*s.quantity)) as income
from sales as s
join products as p on p.product_id = s.product_id 
group by to_char (s.sale_date, 'yyyy-mm')
order by selling_month asc
;

--Третий отчет содержит информацию о покупателях, первая покупка которых была в ходе проведения акций. 
with tab as (
	select 
		s.customer_id,
		concat (c.first_name, ' ', c.last_name) as customer,
		s.sale_date,
		concat (e.first_name, ' ', e.last_name) as seller
	from sales as s
	join employees as e on e.employee_id = s.sales_person_id 
	join products as p on p.product_id = s.product_id 
	join customers as c on c.customer_id = s.customer_id
	where price = 0
	group by s.customer_id, customer, seller, s.sale_date
	order by s.customer_id, s.sale_date),
	rn_tab as (
	SELECT
        customer_id,
		customer,
		sale_date,
		seller,
		row_number () over (partition by customer, DATE_TRUNC('year', sale_date) order by sale_date) as rn
	FROM tab)
select 
	customer,
	sale_date,
	seller
from rn_tab
where rn = 1
order by customer_id
;

