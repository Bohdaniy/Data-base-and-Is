
CREATE USER admin WITH PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON DATABASE logistics_company TO admin;

CREATE USER moderator WITH PASSWORD 'moderator123';
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO moderator;

CREATE USER regular_user WITH PASSWORD 'user123';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO regular_user;

SELECT rolname FROM pg_roles WHERE rolname = 'admin';

-- Очищення таблиць, які залежать від інших
TRUNCATE TABLE Orders CASCADE;
TRUNCATE TABLE Drivers CASCADE;
TRUNCATE TABLE Cargo CASCADE;

-- Очищення таблиць, на які є посилання
TRUNCATE TABLE Vehicles CASCADE;
TRUNCATE TABLE Routes CASCADE;
TRUNCATE TABLE Clients CASCADE;
TRUNCATE TABLE Suppliers CASCADE;



-- Додавання клієнтів
INSERT INTO Clients (ClientID, Name, Address, Phone) VALUES
(1, 'Іван Петренко', 'Київ, вул. Хрещатик, 10', '+380501234567'),
(2, 'Олена Сидорова', 'Львів, вул. Степана Бандери, 5', '+380671234567'),
(3, 'Петро Іванов', 'Одеса, вул. Дерибасівська, 15', '+380931234567'),
(4, 'Марія Коваленко', 'Харків, вул. Сумська, 20', '+380631234567'),
(5, 'Андрій Шевченко', 'Дніпро, вул. Набережна, 25', '+380501112233');

-- Додавання постачальників
INSERT INTO Suppliers (SupplierID, Name, Address, ContactPerson) VALUES
(1, 'ТОВ "Логістика"', 'Харків, вул. Сумська, 20', 'Петро Іванов'),
(2, 'ПП "Транспорт"', 'Одеса, вул. Дерибасівська, 15', 'Олег Сидоров'),
(3, 'ТОВ "Вантажник"', 'Київ, вул. Хрещатик, 10', 'Ірина Петренко'),
(4, 'ТОВ "Експрес Доставка"', 'Львів, вул. Степана Бандери, 5', 'Марія Коваленко'),
(5, 'ТОВ "Швидкий Вантаж"', 'Дніпро, вул. Набережна, 25', 'Андрій Шевченко');

-- Додавання транспортних засобів
INSERT INTO Vehicles (VehicleID, Brand, LicensePlate, Capacity) VALUES
(1, 'Volvo', 'BB1234CC', 5000),
(2, 'Mercedes', 'BB5678DD', 7000),
(3, 'MAN', 'AA9101CC', 6000),
(4, 'Scania', 'AA1122DD', 5500),
(5, 'Renault', 'AA3344EE', 4500);

-- Додавання водіїв
INSERT INTO Drivers (DriverID, Name, Phone, VehicleID) VALUES
(1, 'Василь Коваленко', '+380501112233', 1),
(2, 'Микола Грищенко', '+380502223344', 2),
(3, 'Олександр Петренко', '+380503334455', 3),
(4, 'Ірина Сидорова', '+380504445566', 4),
(5, 'Олег Іванов', '+380505556677', 5);

-- Додавання вантажів
INSERT INTO Cargo (CargoID, Name, Weight, Type, SupplierID, ClientID) VALUES
(1, 'Меблі', 1000.50, 'Тяжкий вантаж', 1, 1),
(2, 'Електроніка', 200.75, 'Легкий вантаж', 2, 2),
(3, 'Будівельні матеріали', 1500.00, 'Тяжкий вантаж', 3, 3),
(4, 'Продукти харчування', 300.25, 'Швидкопсувний вантаж', 4, 4),
(5, 'Одяг', 150.00, 'Легкий вантаж', 5, 5);

-- Додавання маршрутів
INSERT INTO Routes (RouteID, StartPoint, EndPoint, Distance) VALUES
(1, 'Київ', 'Львів', 540.5),
(2, 'Одеса', 'Харків', 650.3),
(3, 'Дніпро', 'Київ', 480.0),
(4, 'Львів', 'Одеса', 720.0),
(5, 'Харків', 'Дніпро', 300.0),
(6, 'Київ', 'Одеса', 470.0),
(7, 'Львів', 'Харків', 600.0),
(8, 'Дніпро', 'Львів', 550.0),
(9, 'Одеса', 'Дніпро', 400.0),
(10, 'Харків', 'Київ', 480.0);

-- Додавання замовлень
INSERT INTO Orders (OrderID, CargoID, DriverID, RouteID, DeliveryDate, Status) VALUES
(1, 1, 1, 1, '2023-10-15', 'Доставлено'),
(2, 2, 2, 2, '2023-10-16', 'В дорозі'),
(3, 3, 3, 3, '2023-10-17', 'Скасовано'),
(4, 4, 4, 4, '2023-10-18', 'Доставлено'),
(5, 5, 5, 5, '2023-10-19', 'В дорозі');


-- 1. Вибірка всіх даних із таблиць
SELECT * FROM Clients;
SELECT * FROM Orders;
SELECT * FROM Routes;
SELECT * FROM Drivers;
SELECT * FROM Vehicles;
SELECT * FROM Suppliers;
SELECT * FROM Cargo;

-- 2. Вибірка замовлень зі статусом "Доставлено"
SELECT * FROM Orders WHERE Status = 'Доставлено';

-- 3. Сортування замовлень за датою доставки (від найновіших до найстаріших)
SELECT * FROM Orders ORDER BY DeliveryDate DESC;

-- 4. Вибірка замовлень, які були доставлені за останній місяць
SELECT * FROM Orders 
WHERE DeliveryDate BETWEEN '2023-09-01' AND '2023-09-30';

-- 5. Вибірка клієнтів, які зробили більше одного замовлення
SELECT Clients.Name, COUNT(Orders.OrderID) AS TotalOrders
FROM Clients
JOIN Cargo ON Clients.ClientID = Cargo.ClientID
JOIN Orders ON Cargo.CargoID = Orders.CargoID
GROUP BY Clients.ClientID
HAVING COUNT(Orders.OrderID) > 1;

-- 6. Вибірка водіїв та кількості замовлень, які вони виконали
SELECT Drivers.Name, COUNT(Orders.OrderID) AS TotalOrders
FROM Drivers
JOIN Orders ON Drivers.DriverID = Orders.DriverID
GROUP BY Drivers.DriverID;

-- 7. Вибірка загальної ваги вантажів, доставлених кожним водієм
SELECT Drivers.Name, SUM(Cargo.Weight) AS TotalWeight
FROM Drivers
JOIN Orders ON Drivers.DriverID = Orders.DriverID
JOIN Cargo ON Orders.CargoID = Cargo.CargoID
GROUP BY Drivers.DriverID;

-- 8. Вибірка середньої ваги вантажів за типом
SELECT Type, AVG(Weight) AS AverageWeight
FROM Cargo
GROUP BY Type;

-- 9. Вибірка замовлень, які були скасовані
SELECT * FROM Orders WHERE Status = 'Скасовано';

-- 10. Вибірка клієнтів, які ще не отримали свої замовлення
SELECT Clients.Name, Orders.OrderID, Orders.Status
FROM Clients
JOIN Cargo ON Clients.ClientID = Cargo.ClientID
JOIN Orders ON Cargo.CargoID = Orders.CargoID
WHERE Orders.Status != 'Доставлено';

-- 11. Вибірка загальної кількості замовлень за кожен місяць
SELECT TO_CHAR(DeliveryDate, 'YYYY-MM') AS Month, COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY TO_CHAR(DeliveryDate, 'YYYY-MM')
ORDER BY Month;

-- 12. Вибірка замовлень з найбільшою вагою вантажу
SELECT Orders.OrderID, Cargo.Name, Cargo.Weight
FROM Orders
JOIN Cargo ON Orders.CargoID = Cargo.CargoID
ORDER BY Cargo.Weight DESC
LIMIT 5;

-- 13. Вибірка загальної відстані, яку подолали водії
SELECT Drivers.Name, SUM(Routes.Distance) AS TotalDistance
FROM Drivers
JOIN Orders ON Drivers.DriverID = Orders.DriverID
JOIN Routes ON Orders.RouteID = Routes.RouteID
GROUP BY Drivers.DriverID;

-- 14. Вибірка клієнтів, які зробили замовлення на найбільшу суму (вага * відстань)
SELECT Clients.Name, SUM(Cargo.Weight * Routes.Distance) AS TotalCost
FROM Clients
JOIN Cargo ON Clients.ClientID = Cargo.ClientID
JOIN Orders ON Cargo.CargoID = Orders.CargoID
JOIN Routes ON Orders.RouteID = Routes.RouteID
GROUP BY Clients.ClientID
ORDER BY TotalCost DESC;

-- 15. Вибірка замовлень, які були доставлені з порушенням термінів
SELECT Orders.OrderID, Orders.DeliveryDate, Orders.Status
FROM Orders
WHERE DeliveryDate < CURRENT_DATE AND Status != 'Доставлено';

-- 16. Вибірка кількості замовлень за кожним типом вантажу
SELECT Cargo.Type, COUNT(Orders.OrderID) AS TotalOrders
FROM Cargo
JOIN Orders ON Cargo.CargoID = Orders.CargoID
GROUP BY Cargo.Type;

-- 17. Вибірка замовлень, які були доставлені в певне місто
SELECT Orders.OrderID, Routes.EndPoint
FROM Orders
JOIN Routes ON Orders.RouteID = Routes.RouteID
WHERE Routes.EndPoint = 'Львів';

-- 18. Вибірка загальної кількості замовлень для кожного клієнта
SELECT Clients.Name, COUNT(Orders.OrderID) AS TotalOrders
FROM Clients
JOIN Cargo ON Clients.ClientID = Cargo.ClientID
JOIN Orders ON Cargo.CargoID = Orders.CargoID
GROUP BY Clients.ClientID;

-- 19. Вибірка замовлень, які були доставлені вчасно
SELECT Orders.OrderID, Orders.DeliveryDate, Orders.Status
FROM Orders
WHERE DeliveryDate <= CURRENT_DATE AND Status = 'Доставлено';

-- 20. Вибірка загальної кількості замовлень за кожен день
SELECT DeliveryDate, COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY DeliveryDate
ORDER BY DeliveryDate;