use goods_delivery;

-- Подзапросы:

-- Запрос, который выводит имена и фамилии всех клиентов,сделавших заказы, стоимость которых выше средней

SELECT first_name, last_name
FROM customers
where customers.id IN (SELECT customer_id
              FROM delivery
              WHERE final_price > (SELECT AVG(final_price)
                          from delivery));
                         
-- Определить клиентов, сделавших самый дорогой заказ

SELECT first_name, last_name
FROM customers
WHERE customers.id IN (SELECT customer_id
               FROM delivery
               WHERE final_price = (SELECT MAX(final_price)
                            FROM delivery));
                
-- Запрос, который выводит заказы клиентов на минимальную сумму, их имя, фамилию, и город отправления и назначения
         
SELECT customer_id, first_name, last_name, cust_or.id, min_order,
dep_city.name as departure_city, departure_address,
dest_city.name as destination_city, delivery_address
	FROM 
		(select delivery.id, customer_id, first_name, last_name, 
		min(final_price) as min_order, 
		departure_city_id,
		departure_address, 
		destination_city_id, 
		delivery_address
		from delivery, customers 
		where delivery.customer_id = customers.id
		group by customer_id, first_name, last_name
		order by min_order) as cust_or
			left join city as dep_city on dep_city.id = cust_or.departure_city_id
			left join city as dest_city on dest_city.id = cust_or.destination_city_id;

-- Запрос, который выводит имя, фамилию курьера, кол-во доставленныз заказов и их общую сумму

select courier_id, first_name, last_name, count(*) as orders_count, sum(final_price) as orders_sum
from local_tracking
join couriers on couriers.id = local_tracking.courier_id
join delivery on delivery.track_number = local_tracking.track_number 
group by courier_id, first_name, last_name
order by orders_sum DESC;

                           
-- Запрос, который выводит номер отслеживания заказа, имя, фамилию курьера и тип транспортного средства, используемого при доставке заказа

select track_number, first_name, last_name, vehicle_type
from ((local_tracking join couriers on local_tracking.courier_id = couriers.id)
	 join vehicle on local_tracking.vehicle_id = vehicle.id);


-- Запрос, который выводит, сколько заказов в какие страны уехало

select count(delivery.track_number) as orders, country.name as country
from delivery, country
where delivery.destination_country_id = country.id 
group by country
order by orders desc;

 