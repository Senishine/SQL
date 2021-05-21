-- Создание представления -- создает таблицу  с именем, фамилией клиента, статусами заказов и кол-вом сделанных заказов.

CREATE OR REPLACE VIEW customers_orders AS 
	select delivery_status.name, first_name, last_name, orders_count 
		from 
			(select customer_id, delivery_status_id, count(*) as orders_count
		from delivery
		group by customer_id, delivery_status_id) as t
		left join customers on t.customer_id = customers.id
		left join delivery_status on t.delivery_status_id = delivery_status.id;

	-- Создание представления - создает таблицу с id, именем, фамилией курьера и кол-вом доставленных заказов с разбивкой по годам и месяцам.
	 
CREATE OR REPLACE VIEW couriers_orders AS 
     	select couriers.id, couriers.first_name, couriers.last_name, 
     	concat_ws('-', year(completion_date), monthname(completion_date)) as `year_month`, count(*) as orders_count
		from couriers
		left join local_tracking lt on couriers.id = lt.courier_id 
		left join delivery on delivery.track_number = lt.track_number 
		group by couriers.id, couriers.first_name, couriers.last_name, concat_ws('-', year(completion_date), monthname(completion_date))
		order by `year_month`desc;
	
-- Создание процедуры - создает строку с заказом в таблице local_tracking.
     
drop procedure if exists complete_delivery;

DELIMITER //

create procedure complete_delivery (track_number INT, courier_id INT, vehicle_id INT)
begin
	declare country_var varchar(255);
	declare city_var varchar(255);
	declare address varchar(255);

	select country.name, city.name, delivery_address into country_var, city_var, address
	from delivery
	join country on delivery.destination_country_id = country.id 
	join city on delivery.destination_city_id = city.id 
	where delivery.track_number = track_number;

	insert into local_tracking (`track_number`, `courier_id`, `destination_point`, `vehicle_id`)
	values (track_number, courier_id, concat_ws(', ', country_var, city_var, address), vehicle_id);
end //

-- Создание триггера - обновляет статус заказа на "доставлен" в таблице local_tracking.

drop trigger if exists update_delivery_status;

DELIMITER //

create TRIGGER update_delivery_status BEFORE INSERT ON local_tracking
FOR EACH ROW 
begin
	update delivery SET delivery_status_id = (select id from delivery_status ds where name = 'delivered')
	where new.track_number = track_number 
		and delivery_status_id not in (select id from delivery_status ds2 where name in ('delivered', 'cancelled'));
end //

 -- Запрос с применением оконных функций - выводит имя, фамилию самого молодого и самого пожилого курьера, города доставки, min и max стоимость заказов,
 -- кол-во заказов в города, сумму всех заказов в эти города и среднюю стоимость заказов.
 
select distinct 
	FIRST_VALUE(CONCAT_WS(" ", first_name, last_name)) 
    OVER (w ORDER BY birthday_at DESC) AS youngest,
  	FIRST_VALUE(CONCAT_WS(" ", first_name, last_name)) 
    OVER (w ORDER BY birthday_at ASC) AS oldest,
    city.name as city,
    min(final_price) over w as min_price, 
    max(final_price) over w as max_price,
    count(*) over w as orders_count,
    sum(final_price) over w as orders_sum,
    avg(final_price) over w as avg_price
		from delivery 
	join local_tracking lt on delivery.track_number  = lt.track_number 
	left join couriers c on lt.courier_id = c.id
	left join city on destination_city_id = city.id
	window  w as (partition by destination_city_id);
     
     
     
     
     
   