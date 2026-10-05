-- Практическая работа № 11. Создание простых запросов
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_Produktov

-- Подготовка: создание БД, таблиц и тестовых данных
CREATE DATABASE Magazin_Produktov;
GO
USE Magazin_Produktov;
GO

CREATE TABLE Otdel (
    Namber_otdel  INT           PRIMARY KEY,
    Name_otdel    NVARCHAR(50)  NOT NULL,
    Max_employee  INT           NOT NULL
);

CREATE TABLE Employee (
    Id_employee   INT            PRIMARY KEY,
    FName         NVARCHAR(50)   NOT NULL,      -- фамилия
    Birth_date    DATE           NULL,
    Oklad         DECIMAL(10,2)  NOT NULL,
    Premiya       DECIMAL(10,2)  NULL,
    Namber_otdel  INT            NULL REFERENCES Otdel(Namber_otdel)
);

CREATE TABLE Product (
    Nomenclature_number  INT            PRIMARY KEY,
    Name_product         NVARCHAR(60)   NOT NULL,
    Price                DECIMAL(10,2)  NOT NULL,
    Namber_otdel         INT            NOT NULL REFERENCES Otdel(Namber_otdel)
);

CREATE TABLE Supplier (
    Id_supplier    INT           PRIMARY KEY,
    Name_supplier  NVARCHAR(60)  NOT NULL,
    Phone          NVARCHAR(20)  NULL,
    Street         NVARCHAR(50)  NULL,
    House          NVARCHAR(10)  NULL
);

CREATE TABLE Invoice (
    Namber_invoice  INT   PRIMARY KEY,
    Invoice_date    DATE  NOT NULL,
    Id_supplier     INT   NOT NULL REFERENCES Supplier(Id_supplier)
);

CREATE TABLE Invoice_item (
    Id_item              INT  PRIMARY KEY,
    Nomenclature_number  INT  NOT NULL REFERENCES Product(Nomenclature_number),
    Namber_invoice       INT  NOT NULL REFERENCES Invoice(Namber_invoice),
    Quantity             INT  NOT NULL
);
GO

INSERT Otdel VALUES (1, N'Молочный', 5), (2, N'Мясной', 4), (3, N'Хлебобулочный', 4), (4, N'Бакалея', 6);

INSERT Employee (Id_employee, FName, Birth_date, Oklad, Premiya, Namber_otdel) VALUES
(1,  N'Иванов',     '1988-03-14', 32000,  5000, 1),
(2,  N'Петрова',    '1990-07-21', 28000,  NULL, 1),
(3,  N'Сидоров',    '1985-11-02', 35000,  7000, 2),
(4,  N'Кузнецова',  '1993-01-30', 27000,  2000, 2),
(5,  N'Смирнов',    '1979-05-18', 41000,  9000, 3),
(6,  N'Галимова',   '1995-09-09', 26000,  NULL, 3),
(7,  N'Назаров',    '1991-12-25', 30000,  3000, 4),
(8,  N'Фёдорова',   '1987-04-04', 29000,  NULL, 4),
(9,  N'Ахмадуллин', '1982-08-16', 45000, 10000, 4),
(10, N'Орлова',     '1998-02-11', 25000,  1500, 1),
(11, N'Сахаров',    '1980-06-30', 38000,  6000, NULL),
(12, N'Шарипов',    NULL,         31000,  NULL, 2);

INSERT Product (Nomenclature_number, Name_product, Price, Namber_otdel) VALUES
(1,  N'Молоко 3,2',          78.50, 1), (2,  N'Кефир 1',            65.00, 1),
(3,  N'Сметана 20',          92.00, 1), (4,  N'Творог 5',          120.00, 1),
(5,  N'Говядина',           540.00, 2), (6,  N'Свинина',           410.00, 2),
(7,  N'Куриное филе',       320.00, 2), (8,  N'Колбаса варёная',   380.00, 2),
(9,  N'Хлеб Бородинский',    56.00, 3), (10, N'Батон нарезной',     48.00, 3),
(11, N'Булочка с маком',     35.00, 3), (12, N'Сахар',              75.00, 4),
(13, N'Гречка',             110.00, 4), (14, N'Рис',                95.00, 4),
(15, N'Масло подсолнечное', 160.00, 4), (16, N'Макароны',           70.00, 4);

INSERT Supplier VALUES
(1, N'ООО Молочный край', N'+7-843-111-11-11', N'Ленина',   N'5'),
(2, N'АО Мясной двор',    N'+7-843-222-22-22', N'Баумана',  N'12'),
(3, N'ИП Хлебов',         N'+7-843-333-33-33', N'Гагарина', N'7'),
(4, N'ООО Бакалея-Опт',   N'+7-843-444-44-44', N'Пушкина',  N'21');

INSERT Invoice VALUES
(101, '2026-09-01', 1), (102, '2026-09-03', 2), (103, '2026-09-05', 3),
(104, '2026-09-08', 4), (105, '2026-09-10', 1), (106, '2026-09-12', 2);

INSERT Invoice_item (Id_item, Nomenclature_number, Namber_invoice, Quantity) VALUES
(1, 1, 101, 50),  (2, 2, 101, 40),  (3, 3, 105, 30),  (4, 4, 105, 20),
(5, 5, 102, 25),  (6, 6, 102, 30),  (7, 7, 106, 40),  (8, 8, 106, 15),
(9, 9, 103, 60),  (10, 10, 103, 80), (11, 11, 103, 50), (12, 12, 104, 100),
(13, 13, 104, 70), (14, 14, 104, 60), (15, 15, 104, 45), (16, 16, 104, 90),
(17, 1, 105, 60), (18, 5, 106, 20);
GO

-- Запрос 1. Вывести сотрудников, у которых оклад больше 30000.
SELECT e.FName AS [Фамилия], e.Oklad AS [Оклад]
FROM Employee e
WHERE e.Oklad > 30000;

-- Запрос 2. Вывести сотрудников с окладом выше 28000, которые не работают в бакалее (отдел 4). Операторы AND и NOT.
SELECT e.FName AS [Фамилия], e.Oklad AS [Оклад], e.Namber_otdel AS [№ отдела]
FROM Employee e
WHERE e.Oklad > 28000 AND NOT e.Namber_otdel = 4;

-- Запрос 3. Вывести продукты молочного (1) или хлебобулочного (3) отделов. Оператор OR.
SELECT p.Name_product AS [Продукт], p.Price AS [Цена], p.Namber_otdel AS [№ отдела]
FROM Product p
WHERE p.Namber_otdel = 1 OR p.Namber_otdel = 3;

-- Запрос 4. Вывести продукты мясного или бакалейного отделов, цена которых не выше 400.
SELECT p.Name_product AS [Продукт], p.Price AS [Цена], p.Namber_otdel AS [№ отдела]
FROM Product p
WHERE (p.Namber_otdel = 2 OR p.Namber_otdel = 4) AND NOT p.Price > 400;

-- Запрос 5. Вывести сотрудников: либо с окладом больше 30000 и указанной премией, либо с окладом меньше 27000 не из молочного отдела.
SELECT e.FName AS [Фамилия], e.Oklad AS [Оклад], e.Premiya AS [Премия], e.Namber_otdel AS [№ отдела]
FROM Employee e
WHERE (e.Oklad > 30000 AND e.Premiya IS NOT NULL)
   OR (e.Oklad < 27000 AND NOT e.Namber_otdel = 1);

-- Запрос 6. Вычислить общий доход сотрудника (оклад + премия). Если премии нет, считать её равной 0.
SELECT e.FName AS [Фамилия],
       e.Oklad AS [Оклад],
       ISNULL(e.Premiya, 0) AS [Премия],
       e.Oklad + ISNULL(e.Premiya, 0) AS [Общий доход]
FROM Employee e;

-- Запрос 7. Показать цену продукта с наценкой 10 % и размер наценки.
SELECT p.Name_product AS [Продукт],
       p.Price AS [Цена],
       ROUND(p.Price * 1.1, 2) AS [Цена с наценкой 10%],
       ROUND(p.Price * 0.1, 2) AS [Размер наценки]
FROM Product p;

-- Запрос 8. Вывести продукты отделов 1 и 3.
SELECT p.Name_product AS [Продукт], p.Namber_otdel AS [№ отдела]
FROM Product p
WHERE p.Namber_otdel IN (1, 3);

-- Запрос 9. Вывести сотрудников, которые не работают в отделах 1 и 2.
SELECT e.FName AS [Фамилия], e.Namber_otdel AS [№ отдела]
FROM Employee e
WHERE e.Namber_otdel NOT IN (1, 2);

-- Запрос 10. Вывести продукты с ценой от 100 до 200 рублей.
SELECT p.Name_product AS [Продукт], p.Price AS [Цена]
FROM Product p
WHERE p.Price BETWEEN 100 AND 200;

-- Запрос 11. Вывести сотрудников, оклад которых не входит в диапазон от 27000 до 35000.
SELECT e.FName AS [Фамилия], e.Oklad AS [Оклад]
FROM Employee e
WHERE e.Oklad NOT BETWEEN 27000 AND 35000;

-- Запрос 12. Вывести продукты, название которых начинается на букву «М».
SELECT p.Name_product AS [Продукт], p.Price AS [Цена]
FROM Product p
WHERE p.Name_product LIKE N'М%';

-- Запрос 13. Вывести сотрудников, фамилия которых не заканчивается на «ов».
SELECT e.FName AS [Фамилия]
FROM Employee e
WHERE e.FName NOT LIKE N'%ов';

-- Запрос 14. Вывести сотрудников, которым не назначена премия.
SELECT e.FName AS [Фамилия], e.Oklad AS [Оклад]
FROM Employee e
WHERE e.Premiya IS NULL;

-- Запрос 15. Вывести сотрудников, у которых известна дата рождения.
SELECT e.FName AS [Фамилия], e.Birth_date AS [Дата рождения]
FROM Employee e
WHERE e.Birth_date IS NOT NULL;

-- Запрос 16. Определить категорию продукта по номеру отдела.
SELECT p.Name_product AS [Продукт],
       p.Price AS [Цена],
       CASE p.Namber_otdel
            WHEN 1 THEN N'Молочная продукция'
            WHEN 2 THEN N'Мясная продукция'
            WHEN 3 THEN N'Хлебобулочные изделия'
            ELSE N'Бакалея'
       END AS [Категория]
FROM Product p;
