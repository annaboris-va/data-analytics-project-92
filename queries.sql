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

--Третий отчет Третий отчет содержит информацию о выручке по дням недели для каждого продавца. 
select
	concat (e.first_name, ' ', e.last_name) as seller, --имя и фамилия продавца
	to_char (s.sale_date, 'Day') as day_of_week, --день недели
	floor (sum (p.price*s.quantity)) as income--суммарная выручка продавца за все время
from sales as s
join employees as e on e.employee_id = s.sales_person_id 
join products as p on p.product_id = s.product_id 
group by seller, extract (isodow  from s.sale_date), to_char (s.sale_date, 'Day')
order by extract (isodow  from s.sale_date), seller
;