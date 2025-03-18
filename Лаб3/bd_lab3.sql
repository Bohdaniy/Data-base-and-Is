-- Лабораторна робота №3
-- З дисципліни: Бази даних та інформаційні системи
-- Студента групи МІТ-31 | Кухарчука Богдана

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
(4, 'Марія Коваленко', 'Харків, вул. Сумська, 20', '+380501234567'),
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

-- Додавання додаткових замовлень
INSERT INTO Orders (OrderID, CargoID, DriverID, RouteID, DeliveryDate, Status) VALUES
(6, 1, 2, 6, '2023-09-10', 'Доставлено'),
(7, 2, 3, 7, '2023-09-12', 'В дорозі'),
(8, 3, 4, 8, '2023-09-15', 'Скасовано'),
(9, 4, 5, 9, '2023-09-18', 'Доставлено'),
(10, 5, 1, 10, '2023-09-20', 'В дорозі'),
(11, 1, 3, 1, '2023-09-22', 'Доставлено'),
(12, 2, 4, 2, '2023-09-25', 'В дорозі'),
(13, 3, 5, 3, '2023-09-28', 'Скасовано'),
(14, 4, 1, 4, '2023-09-30', 'Доставлено'),
(15, 5, 2, 5, '2023-09-05', 'В дорозі');

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
WHERE DeliveryDate BETWEEN '2023-09-01' AND '2023-10-01';

-- 5. Вибірка клієнтів, які зробили більше одного замовлення
SELECT Clients.Name, COUNT(Orders.OrderID) AS TotalOrders
FROM Clients
JOIN Cargo ON Clients.ClientID = Cargo.ClientID
JOIN Orders ON Cargo.CargoID = Orders.CargoID
GROUP BY Clients.ClientID
HAVING COUNT(Orders.OrderID) >= 1;

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

-- 21. Логічні оператори (OR)
-- Вибірка замовлень, які були скасовані або знаходяться в дорозі
SELECT * FROM Orders 
WHERE Status = 'Скасовано' OR Status = 'В дорозі';

-- 22. COUNT() з DISTINCT
-- Вибірка кількості унікальних клієнтів, які зробили замовлення
SELECT COUNT(DISTINCT ClientID) AS UniqueClients
FROM Cargo;

-- 23. SUM() з GROUP BY
-- Вибірка загальної ваги вантажів для кожного типу
SELECT Type, SUM(Weight) AS TotalWeight
FROM Cargo
GROUP BY Type;

-- 24. AVG() з WHERE
-- Вибірка середньої ваги вантажів, які мають вагу більше 500 кг
SELECT AVG(Weight) AS AverageWeight
FROM Cargo
WHERE Weight > 500;

-- 25. MIN() та MAX() з GROUP BY
-- Вибірка найменшої та найбільшої ваги вантажів для кожного типу
SELECT Type, MIN(Weight) AS MinWeight, MAX(Weight) AS MaxWeight
FROM Cargo
GROUP BY Type;

-- 26. INNER JOIN з умовою
-- Вибірка замовлень, де вага вантажу більше 1000 кг
SELECT Orders.OrderID, Cargo.Name, Cargo.Weight
FROM Orders
INNER JOIN Cargo ON Orders.CargoID = Cargo.CargoID
WHERE Cargo.Weight > 1000;

-- 27. LEFT JOIN з умовою
-- Вибірка всіх водіїв та їх замовлень, де статус замовлення "В дорозі"
SELECT Drivers.Name, Orders.OrderID
FROM Drivers
LEFT JOIN Orders ON Drivers.DriverID = Orders.DriverID
WHERE Orders.Status = 'В дорозі';

-- 28. RIGHT JOIN з умовою
-- Вибірка всіх замовлень та їх водіїв, де водії мають ім'я, що починається на "О"
SELECT Orders.OrderID, Drivers.Name
FROM Orders
RIGHT JOIN Drivers ON Orders.DriverID = Drivers.DriverID
WHERE Drivers.Name LIKE 'О%';

-- 29. FULL JOIN з умовою
-- Вибірка всіх замовлень та водіїв, де замовлення мають статус "Доставлено"
SELECT Orders.OrderID, Drivers.Name
FROM Orders
FULL JOIN Drivers ON Orders.DriverID = Drivers.DriverID
WHERE Orders.Status = 'Доставлено';

-- 30. CROSS JOIN з умовою
-- Вибірка всіх можливих комбінацій клієнтів та постачальників, де клієнт із Києва
SELECT Clients.Name AS ClientName, Suppliers.Name AS SupplierName
FROM Clients
CROSS JOIN Suppliers
WHERE Clients.Address LIKE '%Київ%';

-- 31. SELF JOIN з умовою
-- Вибірка клієнтів, які мають однаковий номер телефону
SELECT c1.Name AS Client1, c2.Name AS Client2, c1.Phone
FROM Clients c1
JOIN Clients c2 ON c1.Phone = c2.Phone AND c1.ClientID <> c2.ClientID;

-- 32. Підзапит у WHERE з агрегатною функцією
-- Вибірка замовлень, де вага вантажу більше середньої ваги всіх вантажів
SELECT * FROM Orders
WHERE CargoID IN (
    SELECT CargoID
    FROM Cargo
    WHERE Weight > (SELECT AVG(Weight) FROM Cargo)
);

-- 33. Підзапит у IN з JOIN
-- Вибірка клієнтів, які зробили замовлення на вантажі з типом "Тяжкий вантаж"
SELECT * FROM Clients
WHERE ClientID IN (
    SELECT ClientID
    FROM Cargo
    WHERE Type = 'Тяжкий вантаж'
);

-- 34. NOT EXISTS з JOIN
-- Вибірка постачальників, які не мають жодного вантажу
SELECT * FROM Suppliers
WHERE NOT EXISTS (
    SELECT 1
    FROM Cargo
    WHERE Cargo.SupplierID = Suppliers.SupplierID
);

-- 35. EXISTS з JOIN
-- Вибірка постачальників, які мають хоча б один вантаж
SELECT * FROM Suppliers
WHERE EXISTS (
    SELECT 1
    FROM Cargo
    WHERE Cargo.SupplierID = Suppliers.SupplierID
);

-- 36. UNION з різними колонками
-- Вибірка імен клієнтів та постачальників
SELECT Name FROM Clients
UNION
SELECT ContactPerson FROM Suppliers;

-- 37. INTERSECT з різними колонками
-- Вибірка імен клієнтів, які також є контактними особами постачальників
SELECT Name FROM Clients
INTERSECT
SELECT ContactPerson FROM Suppliers;

-- 38. EXCEPT з різними колонками
-- Вибірка імен клієнтів, які не є контактними особами постачальників
SELECT Name FROM Clients
EXCEPT
SELECT ContactPerson FROM Suppliers;

-- 39. Common Table Expressions (CTE) з агрегатною функцією
-- Вибірка загальної ваги вантажів для кожного клієнта за допомогою CTE
WITH ClientWeights AS (
    SELECT Clients.ClientID, Clients.Name, SUM(Cargo.Weight) AS TotalWeight
    FROM Clients
    JOIN Cargo ON Clients.ClientID = Cargo.ClientID
    GROUP BY Clients.ClientID
)
SELECT * FROM ClientWeights;

-- Вибірка замовлень з ранжуванням за вагою вантажу для кожного типу вантажу
SELECT Orders.OrderID, Cargo.CargoID, Cargo.Weight, Cargo.Type,
       RANK() OVER (PARTITION BY Cargo.Type ORDER BY Cargo.Weight DESC) AS WeightRank
FROM Orders
JOIN Cargo ON Orders.CargoID = Cargo.CargoID;