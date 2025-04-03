-- Видалення тригерів
DROP TRIGGER IF EXISTS update_driver_stats_after_delivery ON deliveries;
DROP TRIGGER IF EXISTS track_delivery_status_changes ON deliveries;

-- Видалення функцій
DROP FUNCTION IF EXISTS update_driver_stats();
DROP FUNCTION IF EXISTS log_delivery_changes();
DROP FUNCTION IF EXISTS calculate_avg_delivery_time(integer);

-- Видалення таблиць (у правильному порядку для уникнення помилок залежностей)
DROP TABLE IF EXISTS delivery_logs;
DROP TABLE IF EXISTS driver_stats;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS cargo_types;
DROP TABLE IF EXISTS clients;

-- Видалення користувацького типу
DROP TYPE IF EXISTS delivery_status;


-- Таблиця клієнтів
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    tax_number VARCHAR(20) UNIQUE,
    discount_percent NUMERIC(5,2) DEFAULT 0,
    loyalty_points INT DEFAULT 0,
    notes TEXT
);

-- Таблиця типів вантажу
CREATE TABLE cargo_types (
    cargo_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_refrigeration BOOLEAN DEFAULT FALSE,
    requires_special_handling BOOLEAN DEFAULT FALSE,
    hazardous_material BOOLEAN DEFAULT FALSE,
    max_weight NUMERIC(10,2),
    min_temperature NUMERIC(5,2),
    max_temperature NUMERIC(5,2),
    special_requirements TEXT
);

-- Таблиця водіїв
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    license_number VARCHAR(20) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    hire_date DATE NOT NULL,
    birth_date DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'on_leave', 'fired')),
    salary NUMERIC(10,2),
    vehicle_preference INT
);

-- Таблиця транспортних засобів
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    capacity_kg NUMERIC(10,2) NOT NULL,
    volume_m3 NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'in_use', 'maintenance')),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    fuel_type VARCHAR(20),
    insurance_number VARCHAR(30)
);

-- Користувацький тип для статусу доставки
CREATE TYPE delivery_status AS ENUM (
    'pending', 
    'in_transit', 
    'delivered', 
    'delayed', 
    'cancelled',
    'returned'
);

-- Таблиця доставок
CREATE TABLE deliveries (
    delivery_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(client_id) NOT NULL,
    driver_id INT REFERENCES drivers(driver_id) NOT NULL,
    vehicle_id INT REFERENCES vehicles(vehicle_id) NOT NULL,
    cargo_type_id INT REFERENCES cargo_types(cargo_type_id) NOT NULL,
    pickup_address TEXT NOT NULL,
    delivery_address TEXT NOT NULL,
    distance NUMERIC(10,2) NOT NULL,
    weight NUMERIC(10,2) NOT NULL,
    volume NUMERIC(10,2) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    delivery_start TIMESTAMP,
    delivery_end TIMESTAMP,
    status delivery_status DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    payment_status VARCHAR(20) DEFAULT 'unpaid',
    priority INT DEFAULT 1
);

-- Таблиця для логування змін доставок
CREATE TABLE delivery_logs (
    log_id SERIAL PRIMARY KEY,
    delivery_id INT NOT NULL REFERENCES deliveries(delivery_id),
    old_status delivery_status,
    new_status delivery_status,
    changed_by VARCHAR(50) NOT NULL,
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    change_reason TEXT,
    ip_address VARCHAR(50),
    user_agent TEXT,
    additional_info JSONB
);

-- Таблиця статистики водіїв
CREATE TABLE driver_stats (
    driver_id INT PRIMARY KEY REFERENCES drivers(driver_id),
    total_deliveries INT DEFAULT 0,
    total_distance NUMERIC(10,2) DEFAULT 0,
    avg_delivery_time INTERVAL,
    last_delivery_date TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rating NUMERIC(3,2),
    late_deliveries INT DEFAULT 0,
    on_time_deliveries INT DEFAULT 0,
    fuel_efficiency NUMERIC(10,2)
);

-- Наповнення таблиці клієнтів
INSERT INTO clients (company_name, contact_person, phone, email, address, tax_number, discount_percent, loyalty_points) VALUES
('ТОВ "Ромашка"', 'Іваненко Петро', '+380501234567', 'romashka@example.com', 'м. Київ, вул. Хрещатик, 1', '12345678', 5.00, 100),
('АТ "Соняшник"', 'Петренко Олена', '+380671234567', 'sonyashnyk@example.com', 'м. Львів, вул. Степана Бандери, 15', '23456789', 3.50, 75),
('ПП "Ластівка"', 'Сидоренко Ігор', '+380631234567', 'lastivka@example.com', 'м. Одеса, вул. Дерибасівська, 10', '34567890', 0.00, 30),
('ТОВ "Весна"', 'Коваленко Марія', '+380501234568', 'vesna@example.com', 'м. Харків, вул. Сумська, 20', '45678901', 2.00, 50),
('АТ "Зима"', 'Шевченко Андрій', '+380671234568', 'zyma@example.com', 'м. Дніпро, вул. Набережна, 5', '56789012', 4.50, 120),
('ТОВ "Осінь"', 'Мельник Олександр', '+380501234569', 'osin@example.com', 'м. Вінниця, вул. Соборна, 12', '67890123', 1.50, 40),
('ПП "Літо"', 'Бондаренко Наталія', '+380671234569', 'lito@example.com', 'м. Чернівці, вул. Українська, 8', '78901234', 0.00, 15),
('ТОВ "Гранд"', 'Ткаченко Віктор', '+380501234570', 'grand@example.com', 'м. Запоріжжя, вул. Перемоги, 25', '89012345', 7.00, 200),
('АТ "Експрес"', 'Шевчук Ольга', '+380671234570', 'express@example.com', 'м. Івано-Франківськ, вул. Галицька, 3', '90123456', 2.50, 60),
('ТОВ "Транзит"', 'Ковальчук Михайло', '+380501234571', 'transit@example.com', 'м. Тернопіль, вул. Шевченка, 17', '01234567', 5.50, 90);

-- Наповнення таблиці типів вантажу
INSERT INTO cargo_types (type_name, description, requires_refrigeration, requires_special_handling, hazardous_material, max_weight) VALUES
('Продукти харчування', 'Харчові продукти', TRUE, FALSE, FALSE, 10000),
('Будівельні матеріали', 'Цегла, пісок, цемент', FALSE, FALSE, FALSE, 20000),
('Електроніка', 'Побутова техніка, комп''ютери', FALSE, TRUE, FALSE, 5000),
('Меблі', 'Дерев''яні та металеві меблі', FALSE, FALSE, FALSE, 15000),
('Хімічні речовини', 'Лаки, фарби, розчинники', FALSE, TRUE, TRUE, 8000),
('Фармацевтика', 'Лікарські засоби', TRUE, TRUE, FALSE, 3000),
('Одяг та взуття', 'Готовий одяг', FALSE, FALSE, FALSE, 7000),
('Косметика', 'Парфумерія, косметичні засоби', FALSE, FALSE, FALSE, 4000),
('Документи', 'Важливі документи', FALSE, TRUE, FALSE, 100),
('Тварини', 'Домашні тварини', TRUE, TRUE, FALSE, 1000);

-- Наповнення таблиці водіїв
INSERT INTO drivers (first_name, last_name, license_number, phone, email, hire_date, birth_date, status, salary) VALUES
('Олексій', 'Мельник', 'АВ123456', '+380501234572', 'olexii.melnyk@example.com', '2020-05-15', '1985-03-10', 'active', 25000),
('Михайло', 'Шевченко', 'ВС654321', '+380671234572', 'mykhailo.shevchenko@example.com', '2019-03-10', '1982-07-22', 'active', 27000),
('Андрій', 'Коваль', 'СА789012', '+380631234573', 'andrii.koval@example.com', '2021-01-20', '1990-11-15', 'active', 23000),
('Наталія', 'Бондаренко', 'АК345678', '+380501234573', 'nataliia.bondarenko@example.com', '2022-06-05', '1988-05-18', 'active', 24000),
('Віктор', 'Ткаченко', 'ВТ901234', '+380671234573', 'viktor.tkachenko@example.com', '2018-11-15', '1980-09-30', 'on_leave', 26000),
('Сергій', 'Павленко', 'РА567890', '+380501234574', 'serhii.pavlenko@example.com', '2020-08-20', '1987-02-25', 'active', 24500),
('Ольга', 'Шевчук', 'ОШ123789', '+380671234574', 'olha.shevchuk@example.com', '2021-04-12', '1992-12-05', 'active', 23500),
('Іван', 'Петренко', 'ІП456123', '+380631234574', 'ivan.petrenko@example.com', '2019-07-30', '1983-10-15', 'active', 25500),
('Марія', 'Кравченко', 'МК789456', '+380501234575', 'mariia.kravchenko@example.com', '2022-02-18', '1991-04-20', 'active', 22500),
('Дмитро', 'Олійник', 'ДО123456', '+380671234575', 'dmitro.oliinyk@example.com', '2020-10-05', '1986-08-12', 'active', 26500);

-- Наповнення таблиці транспортних засобів
INSERT INTO vehicles (registration_number, make, model, year, capacity_kg, volume_m3, status, last_maintenance_date, next_maintenance_date, fuel_type) VALUES
('АА1234ВВ', 'Volvo', 'FH16', 2019, 20000, 82, 'available', '2023-01-15', '2023-07-15', 'diesel'),
('ВС5678АА', 'MAN', 'TGX', 2020, 18000, 76, 'available', '2023-02-20', '2023-08-20', 'diesel'),
('СЕ9012КК', 'Scania', 'R500', 2021, 22000, 85, 'in_use', '2023-03-10', '2023-09-10', 'diesel'),
('АК3456ММ', 'Mercedes-Benz', 'Actros', 2018, 19000, 78, 'available', '2023-04-05', '2023-10-05', 'diesel'),
('ВТ7890РР', 'DAF', 'XF', 2020, 21000, 80, 'maintenance', '2023-05-12', '2023-11-12', 'diesel'),
('РА1234ТТ', 'Renault', 'T Range', 2021, 17000, 75, 'available', '2023-06-18', '2023-12-18', 'diesel'),
('ІВ5678СС', 'Iveco', 'S-Way', 2022, 18500, 77, 'available', '2023-07-22', '2024-01-22', 'diesel'),
('КУ9012НН', 'Kamaz', '54901', 2020, 23000, 88, 'in_use', '2023-08-30', '2024-02-28', 'diesel'),
('МІ3456РР', 'Mitsubishi', 'Fuso', 2019, 15000, 70, 'available', '2023-09-15', '2024-03-15', 'diesel'),
('НІ7890ЛЛ', 'Nissan', 'Atleon', 2021, 16000, 72, 'available', '2023-10-20', '2024-04-20', 'diesel');

-- Наповнення таблиці доставок (10 записів, 5 зі статусом 'delivered')
INSERT INTO deliveries (
    client_id, driver_id, vehicle_id, cargo_type_id, 
    pickup_address, delivery_address, distance, weight, volume, price,
    delivery_start, delivery_end, status, payment_status
) VALUES
(1, 1, 1, 1, 'м. Київ, вул. Хрещатик, 1', 'м. Львів, вул. Степана Бандери, 15', 540, 5000, 30, 8500, 
 '2023-05-10 08:00:00', '2023-05-10 18:30:00', 'delivered', 'paid'),
(2, 2, 2, 2, 'м. Львів, вул. Степана Бандери, 15', 'м. Одеса, вул. Дерибасівська, 10', 790, 15000, 45, 12000, 
 '2023-05-11 07:30:00', '2023-05-11 21:15:00', 'delivered', 'paid'),
(3, 3, 3, 3, 'м. Одеса, вул. Дерибасівська, 10', 'м. Харків, вул. Сумська, 20', 660, 8000, 25, 9500, 
 '2023-05-12 09:00:00', '2023-05-12 20:45:00', 'delivered', 'paid'),
(4, 1, 4, 4, 'м. Харків, вул. Сумська, 20', 'м. Дніпро, вул. Набережна, 5', 220, 12000, 60, 7500, 
 '2023-05-13 10:00:00', '2023-05-13 14:30:00', 'delivered', 'paid'),
(5, 4, 1, 5, 'м. Дніпро, вул. Набережна, 5', 'м. Київ, вул. Хрещатик, 1', 480, 7000, 35, 8000, 
 '2023-05-14 08:30:00', '2023-05-14 17:45:00', 'delivered', 'paid'),
(6, 5, 2, 6, 'м. Вінниця, вул. Соборна, 12', 'м. Чернівці, вул. Українська, 8', 320, 2500, 15, 6000, 
 '2023-05-15 09:00:00', NULL, 'in_transit', 'unpaid'),
(7, 6, 3, 7, 'м. Запоріжжя, вул. Перемоги, 25', 'м. Івано-Франківськ, вул. Галицька, 3', 420, 6000, 28, 7000, 
 '2023-05-16 10:30:00', NULL, 'in_transit', 'unpaid'),
(8, 7, 4, 8, 'м. Тернопіль, вул. Шевченка, 17', 'м. Львів, вул. Степана Бандери, 15', 130, 3500, 18, 4500, 
 '2023-05-17 08:00:00', NULL, 'pending', 'unpaid'),
(9, 8, 5, 9, 'м. Київ, вул. Хрещатик, 1', 'м. Одеса, вул. Дерибасівська, 10', 480, 50, 2, 3000, 
 '2023-05-18 11:00:00', NULL, 'pending', 'unpaid'),
(10, 9, 6, 10, 'м. Харків, вул. Сумська, 20', 'м. Дніпро, вул. Набережна, 5', 220, 800, 5, 3500, 
 '2023-05-19 09:30:00', NULL, 'pending', 'unpaid');



 -- 1. Функція для розрахунку середнього часу доставки для певного типу вантажу
CREATE OR REPLACE FUNCTION calculate_avg_delivery_time(input_cargo_type_id INT) 
RETURNS INTERVAL AS $$
DECLARE
    avg_time INTERVAL;
BEGIN
    SELECT AVG(delivery_end - delivery_start) INTO avg_time
    FROM deliveries
    WHERE cargo_type_id = input_cargo_type_id
    AND status = 'delivered';
    
    RETURN avg_time;
END;
$$ LANGUAGE plpgsql;

-- 2. Функція для логування змін статусу доставки
CREATE OR REPLACE FUNCTION log_delivery_changes() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status <> NEW.status THEN
        INSERT INTO delivery_logs (
            delivery_id, 
            old_status, 
            new_status, 
            changed_by,
            change_reason,
            ip_address
        )
        VALUES (
            NEW.delivery_id, 
            OLD.status, 
            NEW.status, 
            current_user,
            'Status changed via system',
            inet_client_addr()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Функція для оновлення статистики водія
CREATE OR REPLACE FUNCTION update_driver_stats() 
RETURNS TRIGGER AS $$
BEGIN
    -- Оновлюємо статистику тільки для завершених доставок
    IF NEW.status = 'delivered' THEN
        -- Оновлення або вставка статистики
        INSERT INTO driver_stats (
            driver_id, 
            total_deliveries, 
            total_distance, 
            last_delivery_date,
            last_updated
        )
        VALUES (
            NEW.driver_id, 
            1, 
            NEW.distance, 
            NEW.delivery_end,
            CURRENT_TIMESTAMP
        )
        ON CONFLICT (driver_id) 
        DO UPDATE SET
            total_deliveries = driver_stats.total_deliveries + 1,
            total_distance = driver_stats.total_distance + NEW.distance,
            last_delivery_date = NEW.delivery_end,
            last_updated = CURRENT_TIMESTAMP;
        
        -- Оновлення середнього часу доставки
        UPDATE driver_stats ds
        SET avg_delivery_time = (
            SELECT AVG(delivery_end - delivery_start)
            FROM deliveries
            WHERE driver_id = NEW.driver_id
            AND status = 'delivered'
        ),
        on_time_deliveries = (
            SELECT COUNT(*)
            FROM deliveries
            WHERE driver_id = NEW.driver_id
            AND status = 'delivered'
            AND (delivery_end - delivery_start) <= (distance * INTERVAL '1 minute' / 10)  -- Припускаємо 10 км/хв як норму
        ),
        late_deliveries = (
            SELECT COUNT(*)
            FROM deliveries
            WHERE driver_id = NEW.driver_id
            AND status = 'delivered'
            AND (delivery_end - delivery_start) > (distance * INTERVAL '1 minute' / 10)
        ),
        rating = CASE 
            WHEN (SELECT COUNT(*) FROM deliveries WHERE driver_id = NEW.driver_id AND status = 'delivered') > 0
            THEN 5.0 - (SELECT COUNT(*) FROM deliveries 
                       WHERE driver_id = NEW.driver_id 
                       AND status = 'delivered'
                       AND (delivery_end - delivery_start) > (distance * INTERVAL '1 minute' / 10)) * 0.1
            ELSE 5.0
        END
        WHERE driver_id = NEW.driver_id;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 4. Функція для автоматичного оновлення часу модифікації при оновленні доставки
CREATE OR REPLACE FUNCTION update_delivery_timestamp() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Тригер для відстеження змін статусу доставки
CREATE TRIGGER track_delivery_status_changes
AFTER UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION log_delivery_changes();

-- Тригер для оновлення статистики водія після змін у доставках
CREATE TRIGGER update_driver_stats_after_delivery
AFTER INSERT OR UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION update_driver_stats();

-- Тригер для автоматичного оновлення часу модифікації
CREATE TRIGGER update_delivery_modified_time
BEFORE UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION update_delivery_timestamp();


-- Заповнення статистики водіїв на основі існуючих доставок
INSERT INTO driver_stats (
    driver_id, 
    total_deliveries, 
    total_distance, 
    avg_delivery_time,
    last_delivery_date,
    last_updated,
    on_time_deliveries,
    late_deliveries,
    rating
)
SELECT 
    d.driver_id,
    COUNT(del.delivery_id) AS total_deliveries,
    COALESCE(SUM(del.distance), 0) AS total_distance,
    AVG(del.delivery_end - del.delivery_start) AS avg_delivery_time,
    MAX(del.delivery_end) AS last_delivery_date,
    CURRENT_TIMESTAMP AS last_updated,
    COUNT(CASE WHEN (del.delivery_end - del.delivery_start) <= (del.distance * INTERVAL '1 minute' / 10) THEN 1 END) AS on_time_deliveries,
    COUNT(CASE WHEN (del.delivery_end - del.delivery_start) > (del.distance * INTERVAL '1 minute' / 10) THEN 1 END) AS late_deliveries,
    CASE 
        WHEN COUNT(del.delivery_id) > 0 
        THEN 5.0 - COUNT(CASE WHEN (del.delivery_end - del.delivery_start) > (del.distance * INTERVAL '1 minute' / 10) THEN 1 END) * 0.1
        ELSE 5.0
    END AS rating
FROM drivers d
LEFT JOIN deliveries del ON d.driver_id = del.driver_id AND del.status = 'delivered'
GROUP BY d.driver_id
ON CONFLICT (driver_id) 
DO UPDATE SET
    total_deliveries = EXCLUDED.total_deliveries,
    total_distance = EXCLUDED.total_distance,
    avg_delivery_time = EXCLUDED.avg_delivery_time,
    last_delivery_date = EXCLUDED.last_delivery_date,
    last_updated = EXCLUDED.last_updated,
    on_time_deliveries = EXCLUDED.on_time_deliveries,
    late_deliveries = EXCLUDED.late_deliveries,
    rating = EXCLUDED.rating;

	
SELECT * FROM clients LIMIT 10;

SELECT driver_id, first_name, last_name, license_number, status FROM drivers;

SELECT delivery_id, client_id, driver_id, status 
FROM deliveries 
ORDER BY status;

SELECT cargo_type_id, type_name, calculate_avg_delivery_time(cargo_type_id) AS avg_time
FROM cargo_types
WHERE cargo_type_id IN (1, 2, 3);

-- Оновлюємо статус доставки
UPDATE deliveries SET status = 'delivered' 
WHERE delivery_id = 8 AND status = 'pending';

-- Перевіряємо лог
SELECT * FROM delivery_logs WHERE delivery_id = 8;

-- Перевіряємо статистику водія до оновлення
SELECT * FROM driver_stats WHERE driver_id = 7;

-- Створюємо нову завершену доставку
INSERT INTO deliveries (
    client_id, driver_id, vehicle_id, cargo_type_id, 
    pickup_address, delivery_address, distance, weight, volume, price,
    delivery_start, delivery_end, status
) VALUES (
    3, 7, 3, 3, 'м. Київ', 'м. Львів', 540, 5000, 30, 8500,
    '2023-05-20 08:00:00', '2023-05-20 18:00:00', 'delivered'
);

-- Перевіряємо оновлену статистику
SELECT * FROM driver_stats WHERE driver_id = 7;

SELECT 
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    ds.total_deliveries,
    ds.total_distance,
    ds.avg_delivery_time,
    ds.rating
FROM drivers d
JOIN driver_stats ds ON d.driver_id = ds.driver_id
ORDER BY ds.rating DESC;


SELECT 
    ct.type_name,
    COUNT(d.delivery_id) AS deliveries_count,
    AVG(d.distance) AS avg_distance,
    AVG(d.price) AS avg_price,
    calculate_avg_delivery_time(ct.cargo_type_id) AS avg_delivery_time
FROM cargo_types ct
LEFT JOIN deliveries d ON ct.cargo_type_id = d.cargo_type_id
GROUP BY ct.cargo_type_id, ct.type_name;

-- Спроба створити доставку з неіснуючим водієм (має викликати помилку)
INSERT INTO deliveries (client_id, driver_id, vehicle_id, cargo_type_id, ...)
VALUES (1, 999, 1, 1, ...);

-- Спроба встановити неіснуючий статус (має викликати помилку)
UPDATE deliveries SET status = 'invalid_status' WHERE delivery_id = 1;

EXPLAIN ANALYZE
SELECT * FROM driver_stats 
WHERE total_deliveries > 1 
ORDER BY rating DESC;