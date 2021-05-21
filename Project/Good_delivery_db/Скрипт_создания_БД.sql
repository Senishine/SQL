-- Сервис по доставке товаров

drop database if exists goods_delivery;
create database goods_delivery;

use goods_delivery;

-- Заказы

drop table if exists delivery;

CREATE TABLE delivery
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT null COMMENT 'Номер заказа',
	track_number INT unique NOT NULL COMMENT 'Номер для отслеживания заказа, сложная комбинация цифр',
	customer_id INT NOT NULL COMMENT 'Номер клиента, сделавшего заказ',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания заказа',
	completion_date DATETIME COMMENT 'Время завершения заказа',
	departure_country_id INT NOT null COMMENT 'Страна отправления',
	departure_city_id INT NOT null COMMENT 'Город отправления',
	departure_address VARCHAR(255) NOT null COMMENT 'Адрес отправления',
	destination_country_id INT NOT null COMMENT 'Страна назначения',
	destination_city_id INT NOT null COMMENT 'Город назначения',
	delivery_address VARCHAR(255) NOT null COMMENT 'Адрес назначения',
	delivery_status_id INT NOT NULL COMMENT 'Статус заказа',
	final_price Decimal Comment 'Окончательная цена'
	
) COMMENT 'Информация о доставляемом заказе';

drop table if exists delivery_status;

CREATE TABLE delivery_status
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT null COMMENT 'Номер заказа',
	name VARCHAR(35) NOT null COMMENT 'Статус заказа'
);

-- Статус заказа

INSERT INTO delivery_status(id, name) VALUES
(1, 'new'),
(2, 'packaging'),
(3, 'on track'),
(4, 'cancelled'),
(5, 'delivered');

-- Детальная информация о заказе

drop table if exists delivery_info;

CREATE TABLE delivery_info
(
	delivery_id INT NOT NULL,
	weight INT UNSIGNED NOT null COMMENT 'Вес товара',
	volume INT UNSIGNED NOT null COMMENT 'Объем товара',
	max_size INT UNSIGNED NOT null COMMENT 'Максимальный габарит груза - max ширина, max длина или max глубина',
	characteristic VARCHAR(255) COMMENT 'Особые характеристики груза: хрупкий, жидкий...',
	packaging VARCHAR(255) COMMENT 'Упаковка груза',
	tariff_id INT NOT null COMMENT 'Тариф расчета стоимости доставки'
) COMMENT 'Характеристики доставляемого заказа';

-- Курьеры

drop table if exists couriers;

CREATE TABLE couriers
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	first_name VARCHAR(255) NOT null COMMENT 'Имя курьера',
	last_name VARCHAR(255) NOT null COMMENT 'Фамилия курьера',
	birthday_at DATE not null COMMENT 'Дата рождения',
	phone_number VARCHAR(255) NOT NULL
) COMMENT 'Курьеры';

-- Транспортные средства

drop table if exists vehicle;

CREATE TABLE vehicle
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	model VARCHAR(255) NOT null COMMENT 'Модель ТС',
	brand VARCHAR(255) NOT null COMMENT 'Марка ТС',
	year_of_production YEAR COMMENT 'Год выпуска ТС',
	vehicle_number VARCHAR(255) not null COMMENT 'Номер ТС',
	vehicle_type VARCHAR(255) not null COMMENT 'Тип ТС'
) COMMENT 'Транспортные средства';

-- Клиенты

drop table if exists customers;

CREATE TABLE customers
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	first_name VARCHAR(255) NOT null COMMENT 'Имя клиента',
	last_name VARCHAR(255) NOT null COMMENT 'Фамилия клиента',
	phone_number VARCHAR(255) NOT NULL,
	country_id INT NOT null COMMENT 'Страна нахождения клиента',
	city_id INT NOT null COMMENT 'Город нахождения клиента',
	district VARCHAR(255) NOT null COMMENT 'Район',
	street VARCHAR(255) NOT null COMMENT 'Улица проживания',
	house INT NOT null COMMENT 'Номер дома',
	apartment INT NOT null COMMENT 'Номер квартиры'
);

-- Отслеживание международных заказов

drop table if exists global_tracking;

CREATE TABLE global_tracking
(
	track_number INT unique NOT null COMMENT 'Сложный номер для отслеживания заказа',
	gts_id INT NOT null COMMENT 'Идентификационный номер организации-перевозчика',
	destination_point VARCHAR(255) NOT null COMMENT 'Пункт назначения',
	track_time DATETIME not null COMMENT 'Время события',
	track_status ENUM('arrived', 'left')
) COMMENT 'Отслеживание местонахождения международного заказа';

-- Global Transport Service

drop table if exists gts;

CREATE TABLE gts
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT null COMMENT 'Идентификационный номер организации-перевозчика',
	company_name VARCHAR(255) NOT null COMMENT 'Название организации-перевозчика',
	country_id INT NOT null COMMENT 'Страна нахождения организации-перевозчика',
	city_id INT NOT null COMMENT 'Город нахождения организации-перевозчика',
	business_address VARCHAR(255) NOT null COMMENT 'Юридический адрес организации-перевозчика',
	phone_number VARCHAR(255) NOT null COMMENT 'Телефон организации-перевозчика',
	current_account INT NOT null COMMENT 'Расчетный счет организации-перевозчика'
) COMMENT = 'Сервисы по доставке международных грузов';

-- Отслеживание местных заказов в пределах страны

drop table if exists local_tracking;

CREATE TABLE local_tracking
(
	track_number INT unique NOT null COMMENT 'Сложный номер для отслеживания заказа',
	courier_id INT NOT null,
	destination_point VARCHAR(255) NOT null COMMENT 'Пункт доставки',
	vehicle_id INT NOT null COMMENT 'Тип ТС'
) COMMENT 'Отслеживание местонахождения заказа по России';

-- Тарифы

drop table if exists tariffs;

CREATE TABLE tariffs 
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT null COMMENT 'Номер тарифа',
	name VARCHAR(255) NOT null COMMENT 'Название тарифа',
	description VARCHAR(255) NOT null COMMENT 'Описание тарифа',
	base_price DECIMAL NOT null COMMENT 'Начальная цена тарифа'
) COMMENT 'Тарифы';

-- Страны

drop table if exists country;

CREATE TABLE country
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT null COMMENT 'Номер страны',
	name VARCHAR(255) NOT null COMMENT 'Название страны'
) COMMENT 'Страны';         

-- Города

drop table if exists city;

CREATE TABLE city
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT null COMMENT 'Номер города',
	name VARCHAR(255) NOT null COMMENT 'Название города'
) COMMENT 'Города';

-- Внешние ключи

ALTER TABLE delivery
  ADD CONSTRAINT delivery_customer_id_fk
    FOREIGN KEY (customer_id) REFERENCES customers(id)
     ON DELETE cascade
       ON UPDATE cascade;
      
ALTER TABLE delivery
  ADD CONSTRAINT delivery_depart_country_id_fk
    FOREIGN KEY (departure_country_id) REFERENCES country(id)
     ON DELETE cascade
       ON UPDATE cascade;   
      
ALTER TABLE delivery
  ADD CONSTRAINT delivery_departure_city_id_fk
    FOREIGN KEY (departure_city_id) REFERENCES city(id)
     ON DELETE cascade
       ON UPDATE cascade;   
      
ALTER TABLE delivery
  ADD CONSTRAINT delivery_destination_country_id_fk
    FOREIGN KEY (destination_country_id) REFERENCES country(id)
     ON DELETE cascade
       ON UPDATE cascade;   
      
ALTER TABLE delivery
  ADD CONSTRAINT delivery_destination_city_id_fk
    FOREIGN KEY (destination_city_id) REFERENCES city(id)
     ON DELETE cascade
       ON UPDATE cascade; 
      
ALTER TABLE delivery
  ADD CONSTRAINT delivery_status_id_fk
    FOREIGN KEY (delivery_status_id) REFERENCES delivery_status(id)
     ON DELETE cascade
       ON UPDATE cascade;
      
ALTER TABLE delivery_info
  ADD CONSTRAINT delivery_info_id_fk
    FOREIGN KEY (delivery_id) REFERENCES delivery(id)
     ON DELETE cascade
       ON UPDATE cascade;
      
ALTER TABLE delivery_info
  ADD CONSTRAINT delivery_info_tariff_id_fk
    FOREIGN KEY (tariff_id) REFERENCES tariffs(id)
     ON DELETE cascade
       ON UPDATE cascade;

ALTER TABLE customers
  ADD CONSTRAINT customers_country_id_fk
    FOREIGN KEY (country_id) REFERENCES country(id)
     ON DELETE cascade
       ON UPDATE cascade;   
      
ALTER TABLE customers
  ADD CONSTRAINT customers_city_id_fk
    FOREIGN KEY (city_id) REFERENCES city(id)
     ON DELETE cascade
       ON UPDATE cascade; 
      
ALTER TABLE global_tracking
  ADD CONSTRAINT global_tracking_gts_id_fk
    FOREIGN KEY (gts_id) REFERENCES gts(id)
     ON DELETE cascade
       ON UPDATE cascade; 
      
ALTER TABLE gts
  ADD CONSTRAINT gts_country_id_fk
    FOREIGN KEY (country_id) REFERENCES country(id)
     ON DELETE cascade
       ON UPDATE cascade; 
      
ALTER TABLE gts
  ADD CONSTRAINT gts_city_id_fk
    FOREIGN KEY (city_id) REFERENCES city(id)
     ON DELETE cascade
       ON UPDATE cascade; 

ALTER TABLE local_tracking
  ADD CONSTRAINT local_tracking_courier_id_fk
    FOREIGN KEY (courier_id) REFERENCES couriers(id)
     ON DELETE cascade
       ON UPDATE cascade; 

ALTER TABLE local_tracking
  ADD CONSTRAINT local_tracking_vehicle_id_fk
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id)
     ON DELETE cascade
       ON UPDATE cascade; 
      
ALTER TABLE local_tracking
  ADD CONSTRAINT local_tracking_track_num_fk
    FOREIGN KEY (track_number) REFERENCES delivery(track_number)
     ON DELETE cascade
       ON UPDATE cascade; 
      
ALTER TABLE global_tracking
  ADD CONSTRAINT global_tracking_track_num_fk
    FOREIGN KEY (track_number) REFERENCES delivery(track_number)
     ON DELETE cascade
       ON UPDATE cascade; 

create index couriers_last_name_idx on couriers(last_name);

create index couriers_first_name_last_name_idx on couriers(first_name, last_name);

create index customers_first_name_last_name_idx on customers(first_name, last_name);

create index gts_company_name_idx on gts(company_name);

















