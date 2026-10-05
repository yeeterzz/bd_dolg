-- Практическая работа № 17. Многотабличные запросы и соединения (JOIN)
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_Join

-- Подготовка: создание БД, таблиц и данных
CREATE DATABASE Magazin_Join;
GO
USE Magazin_Join;
GO

CREATE TABLE Otdel (
    Namber_otdel  INT           PRIMARY KEY,
    Name_otdel    NVARCHAR(50)  NOT NULL,
    Nachalnik     NVARCHAR(50)  NULL
);
CREATE TABLE Product (
    Nomenclature_number  INT            PRIMARY KEY,
    Name_product         NVARCHAR(60)   NOT NULL,
    Price                DECIMAL(10,2)  NOT NULL,
    Namber_otdel         INT            NULL REFERENCES Otdel(Namber_otdel)   -- NULL разрешён
);
CREATE TABLE Supplier (
    Id_supplier   INT           PRIMARY KEY,
    Name_company  NVARCHAR(60)  NOT NULL,
    Phone         NVARCHAR(20)  NULL
);
CREATE TABLE Invoice (
    Namber_invoice  INT   PRIMARY KEY,
    Invoice_date    DATE  NOT NULL,
    Id_supplier     INT   NULL REFERENCES Supplier(Id_supplier)
);
CREATE TABLE Employee (
    Id_employee   INT           PRIMARY KEY,
    FName         NVARCHAR(50)  NOT NULL,
    LName         NVARCHAR(50)  NULL,
    Dolzhnost     NVARCHAR(50)  NULL,
    Namber_otdel  INT           NULL REFERENCES Otdel(Namber_otdel)
);
CREATE TABLE Delivery (
    Id_delivery          INT  PRIMARY KEY,
    Namber_invoice       INT  NULL REFERENCES Invoice(Namber_invoice),
    Nomenclature_number  INT  NULL REFERENCES Product(Nomenclature_number),
    Quantity             INT  NOT NULL
);
GO

INSERT Otdel VALUES
(1, N'Молочный', N'Иванова'), (2, N'Мясной', N'Петров'), (3, N'Хлебобулочный', N'Сидорова'),
(4, N'Бакалея', N'Кузнецов'), (5, N'Кулинария', NULL);          -- в отделе 5 нет товаров и сотрудников

INSERT Product VALUES
(1,  N'Молоко',             78.50, 1), (2,  N'Кефир',              65.00, 1),
(3,  N'Сметана',            92.00, 1), (4,  N'Творог',            120.00, 1),
(5,  N'Говядина',          540.00, 2), (6,  N'Свинина',           410.00, 2),
(7,  N'Куриное филе',      320.00, 2), (8,  N'Хлеб Бородинский',   56.00, 3),
(9,  N'Батон',              48.00, 3), (10, N'Гречка',            110.00, 4),
(11, N'Сахар',              75.00, 4), (12, N'Сезонный товар',    250.00, NULL);   -- товар без отдела

INSERT Supplier VALUES
(1, N'ООО Молочный край', N'+7-843-111-11-11'), (2, N'АО Мясной двор', N'+7-843-222-22-22'),
(3, N'ИП Хлебов', N'+7-843-333-33-33'), (4, N'ООО Бакалея-Опт', N'+7-843-444-44-44'),
(5, N'ООО Новый поставщик', N'+7-843-555-55-55');                 -- ни одной накладной

INSERT Invoice VALUES
(101, '2026-09-01', 1), (102, '2026-09-03', 2), (103, '2026-09-05', 3),
(104, '2026-09-08', 4), (105, '2026-09-10', 1), (106, '2026-09-12', 2);

INSERT Employee VALUES
(1, N'Иванов',   N'Пётр',    N'Продавец',   1), (2, N'Смирнова', N'Анна',   N'Кассир',     1),
(3, N'Сидоров',  N'Олег',    N'Мясник',     2), (4, N'Галимова', N'Лейла',  N'Продавец',   2),
(5, N'Назаров',  N'Ильдар',  N'Пекарь',     3), (6, N'Орлова',   N'Мария',  N'Продавец',   4),
(7, N'Ахмадуллин', N'Рустам', N'Кладовщик', 4), (8, N'Сахаров',  N'Игорь',  N'Грузчик', NULL);  -- без отдела

INSERT Delivery VALUES
(1, 101, 1, 50), (2, 101, 2, 40), (3, 105, 3, 30), (4, 105, 4, 20), (5, 102, 5, 25),
(6, 102, 6, 30), (7, 106, 7, 40), (8, 103, 8, 60), (9, 103, 9, 80), (10, 104, 10, 70),
(11, 104, 11, 100), (12, 106, 5, 20), (13, 105, 1, 60), (14, 104, 10, 30);
GO

-- Запрос 1. Соединение двух таблиц по равенству с синонимами.
SELECT p.Name_product AS [Продукт], p.Price AS [Цена], o.Name_otdel AS [Отдел]
FROM Product p
INNER JOIN Otdel o ON p.Namber_otdel = o.Namber_otdel;

-- Запрос 2. Соединение двух таблиц по равенству с условием отбора: товары мясного отдела.
SELECT p.Name_product AS [Продукт], p.Price AS [Цена], o.Name_otdel AS [Отдел]
FROM Product p
INNER JOIN Otdel o ON p.Namber_otdel = o.Namber_otdel
WHERE o.Name_otdel = N'Мясной';

-- Запрос 3. Соединение трёх таблиц по равенству с условием отбора: поставки поставщика «ООО Молочный край».
SELECT s.Name_company AS [Поставщик], i.Namber_invoice AS [№ накладной],
       i.Invoice_date AS [Дата], d.Quantity AS [Количество]
FROM Delivery d
INNER JOIN Invoice  i ON d.Namber_invoice = i.Namber_invoice
INNER JOIN Supplier s ON i.Id_supplier = s.Id_supplier
WHERE s.Name_company = N'ООО Молочный край';

-- Запрос 4. Несимметричное соединение: пары товаров одного отдела, где первый товар дешевле второго.
SELECT o.Name_otdel AS [Отдел],
       p1.Name_product AS [Более дешёвый товар], p1.Price AS [Цена 1],
       p2.Name_product AS [Более дорогой товар], p2.Price AS [Цена 2]
FROM Product p1
INNER JOIN Product p2 ON p1.Namber_otdel = p2.Namber_otdel AND p1.Price < p2.Price
INNER JOIN Otdel o    ON o.Namber_otdel = p1.Namber_otdel;

-- Запрос 5. Соединение нескольких таблиц и агрегатные функции: по каждому отделу количество товаров, средняя цена и общая стоимость поставленных товаров.
SELECT o.Name_otdel AS [Отдел],
       COUNT(DISTINCT p.Nomenclature_number) AS [Кол-во товаров],
       AVG(p.Price) AS [Средняя цена],
       SUM(d.Quantity * p.Price) AS [Сумма поставок]
FROM Otdel o
INNER JOIN Product  p ON p.Namber_otdel = o.Namber_otdel
INNER JOIN Delivery d ON d.Nomenclature_number = p.Nomenclature_number
GROUP BY o.Name_otdel;

-- Запрос 6. Соединение нескольких таблиц и CASE: ценовая группа товара с указанием отдела и поставленного количества.
SELECT p.Name_product AS [Продукт], o.Name_otdel AS [Отдел], d.Quantity AS [Поставлено],
       CASE WHEN p.Price < 100 THEN N'Эконом'
            WHEN p.Price < 300 THEN N'Средний'
            ELSE N'Премиум'
       END AS [Ценовая группа]
FROM Product p
INNER JOIN Otdel    o ON o.Namber_otdel = p.Namber_otdel
INNER JOIN Delivery d ON d.Nomenclature_number = p.Nomenclature_number;

-- Запрос 7. Левое внешнее соединение: все отделы и их сотрудники (отдел без сотрудников выводится с NULL).
SELECT o.Name_otdel AS [Отдел], e.FName AS [Сотрудник]
FROM Otdel o
LEFT JOIN Employee e ON e.Namber_otdel = o.Namber_otdel;

-- Запрос 8. Правое внешнее соединение: все поставщики и их накладные (поставщик без накладных выводится с NULL).
SELECT s.Name_company AS [Поставщик], i.Namber_invoice AS [№ накладной], i.Invoice_date AS [Дата]
FROM Invoice i
RIGHT JOIN Supplier s ON i.Id_supplier = s.Id_supplier;

-- Запрос 9. Полное внешнее соединение: все товары и все отделы (товар без отдела и отдел без товаров).
SELECT p.Name_product AS [Продукт], o.Name_otdel AS [Отдел]
FROM Product p
FULL JOIN Otdel o ON p.Namber_otdel = o.Namber_otdel;

-- Запрос 10. Вывести название отдела и общую сумму товаров в нём; если в отделе нет товаров, вывести сообщение.
SELECT o.Name_otdel AS [Отдел],
       CASE WHEN COUNT(p.Nomenclature_number) = 0 THEN N'В отделе нет товаров'
            ELSE CAST(SUM(p.Price) AS NVARCHAR(20))
       END AS [Общая сумма товаров]
FROM Otdel o
LEFT JOIN Product p ON p.Namber_otdel = o.Namber_otdel
GROUP BY o.Name_otdel;

-- Запрос 11. Вывести название поставщика, который не оформил ни одной накладной.
SELECT s.Name_company AS [Поставщик без накладных]
FROM Supplier s
LEFT JOIN Invoice i ON i.Id_supplier = s.Id_supplier
WHERE i.Namber_invoice IS NULL;

-- Запрос 12. Вывести номер накладной, дату, название продукта, его цену, количество и сумму поставки.
SELECT i.Namber_invoice AS [№ накладной], i.Invoice_date AS [Дата],
       p.Name_product AS [Продукт], p.Price AS [Цена], d.Quantity AS [Количество],
       p.Price * d.Quantity AS [Сумма поставки]
FROM Invoice i
INNER JOIN Delivery d ON d.Namber_invoice = i.Namber_invoice
INNER JOIN Product  p ON p.Nomenclature_number = d.Nomenclature_number
ORDER BY i.Namber_invoice;

-- Запрос 13. Определить товары, находящиеся в одном отделе (несимметричное соединение): название отдела, товар 1, товар 2.
SELECT o.Name_otdel AS [Отдел], p1.Name_product AS [Товар 1], p2.Name_product AS [Товар 2]
FROM Product p1
INNER JOIN Product p2 ON p1.Namber_otdel = p2.Namber_otdel
                     AND p1.Nomenclature_number < p2.Nomenclature_number
INNER JOIN Otdel o    ON o.Namber_otdel = p1.Namber_otdel
ORDER BY o.Name_otdel;

-- Запрос 14. Определить, какие сотрудники отвечают за какие продукты: название отдела, фамилия сотрудника, название товара.
SELECT o.Name_otdel AS [Отдел], e.FName AS [Сотрудник], p.Name_product AS [Товар]
FROM Otdel o
INNER JOIN Employee e ON e.Namber_otdel = o.Namber_otdel
INNER JOIN Product  p ON p.Namber_otdel = o.Namber_otdel
ORDER BY o.Name_otdel, e.FName;

-- Запрос 15. Определить название компании-поставщика и сумму его поставок, начиная с большей суммы.
SELECT s.Name_company AS [Поставщик], SUM(d.Quantity * p.Price) AS [Сумма поставок]
FROM Supplier s
INNER JOIN Invoice  i ON i.Id_supplier = s.Id_supplier
INNER JOIN Delivery d ON d.Namber_invoice = i.Namber_invoice
INNER JOIN Product  p ON p.Nomenclature_number = d.Nomenclature_number
GROUP BY s.Name_company
ORDER BY [Сумма поставок] DESC;

-- Запрос 16. Определить сотрудников, не закреплённых ни за одним отделом, и отделы, в которых нет ни одного сотрудника, с выводом сообщения.
SELECT e.FName AS [Сотрудник], o.Name_otdel AS [Отдел],
       CASE WHEN o.Namber_otdel IS NULL THEN N'Сотрудник не закреплён ни за одним отделом'
            WHEN e.Id_employee  IS NULL THEN N'В отделе нет ни одного сотрудника'
       END AS [Сообщение]
FROM Employee e
FULL JOIN Otdel o ON e.Namber_otdel = o.Namber_otdel
WHERE o.Namber_otdel IS NULL OR e.Id_employee IS NULL;

-- Запрос 17. Вывести номер накладной, количество позиций и количество единиц товара в ней, общую сумму поставки; сортировка по сумме по убыванию.
SELECT i.Namber_invoice AS [№ накладной],
       COUNT(d.Id_delivery) AS [Позиций в накладной],
       SUM(d.Quantity) AS [Всего единиц товара],
       SUM(d.Quantity * p.Price) AS [Сумма поставки]
FROM Invoice i
INNER JOIN Delivery d ON d.Namber_invoice = i.Namber_invoice
INNER JOIN Product  p ON p.Nomenclature_number = d.Nomenclature_number
GROUP BY i.Namber_invoice
ORDER BY [Сумма поставки] DESC;
