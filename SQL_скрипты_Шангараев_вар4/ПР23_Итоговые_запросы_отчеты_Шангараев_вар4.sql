-- Практическая работа № 23. Итоговые запросы и отчёты
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_Itogi

-- Подготовка: создание БД, таблиц и базовых данных
CREATE DATABASE Magazin_Itogi;
GO
USE Magazin_Itogi;
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
    Namber_otdel         INT            NOT NULL REFERENCES Otdel(Namber_otdel)
);
CREATE TABLE Supplier (
    Id_supplier   INT           PRIMARY KEY,
    Name_company  NVARCHAR(60)  NOT NULL,
    Phone         NVARCHAR(20)  NULL
);
CREATE TABLE Employee (
    Id_employee   INT           PRIMARY KEY,
    FName         NVARCHAR(50)  NOT NULL,      -- фамилия
    LName         NVARCHAR(50)  NULL,          -- имя
    Dolzhnost     NVARCHAR(50)  NULL,
    Namber_otdel  INT           NULL REFERENCES Otdel(Namber_otdel)
);
CREATE TABLE Invoice (
    Namber_invoice   INT   PRIMARY KEY,
    Invoice_date     DATE  NOT NULL,
    Id_employee_ok   INT   NULL REFERENCES Employee(Id_employee),   -- ID заверившего сотрудника
    Id_supplier      INT   NOT NULL REFERENCES Supplier(Id_supplier)
);
CREATE TABLE Delivery (
    Id_delivery          INT  PRIMARY KEY,
    Namber_invoice       INT  NOT NULL REFERENCES Invoice(Namber_invoice),
    Nomenclature_number  INT  NOT NULL REFERENCES Product(Nomenclature_number),
    Quantity             INT  NOT NULL
);
GO

INSERT Otdel VALUES (1, N'Молочный', N'Иванова'), (2, N'Мясной', N'Петров'),
                    (3, N'Хлебобулочный', N'Сидорова'), (4, N'Бакалея', N'Кузнецов');
INSERT Product VALUES
(1, N'Молоко', 78.50, 1), (2, N'Кефир', 65.00, 1), (3, N'Говядина', 540.00, 2), (4, N'Свинина', 410.00, 2),
(5, N'Хлеб Бородинский', 56.00, 3), (6, N'Батон', 48.00, 3), (7, N'Гречка', 110.00, 4), (8, N'Сахар', 75.00, 4);
INSERT Supplier VALUES (1, N'ООО Молочный край', N'+7-843-111-11-11'), (2, N'АО Мясной двор', N'+7-843-222-22-22'),
                       (3, N'ИП Хлебов', N'+7-843-333-33-33'), (4, N'ООО Бакалея-Опт', N'+7-843-444-44-44');
INSERT Employee (Id_employee, FName, LName, Dolzhnost, Namber_otdel) VALUES
(1, N'Иванов',     N'Пётр',   N'Продавец',  1), (2, N'Петрова',  N'Анна',   N'Кассир',    1),
(3, N'Сидоров',    N'Олег',   N'Мясник',    2), (4, N'Кузнецова', N'Мария', N'Продавец',  2),
(5, N'Смирнов',    N'Игорь',  N'Пекарь',    3), (6, N'Галимова', N'Лейла',  N'Продавец',  3),
(7, N'Назаров',    N'Ильдар', N'Кладовщик', 4), (8, N'Ахмадуллин', N'Рустам', N'Грузчик', 4);
INSERT Invoice VALUES (101, '2026-09-01', 1, 1), (102, '2026-09-03', 3, 2), (103, '2026-09-05', 5, 3), (104, '2026-09-08', 7, 4);
INSERT Delivery VALUES (1, 101, 1, 50), (2, 101, 2, 40), (3, 102, 3, 25), (4, 102, 4, 30),
                       (5, 103, 5, 60), (6, 103, 6, 80), (7, 104, 7, 70), (8, 104, 8, 100);
GO

-- Добавление столбцов «Год» и «Премия» и данных (всего 24 строки, часть создана копированием)
ALTER TABLE Employee ADD God INT NULL, Premiya DECIMAL(10,2) NULL;
GO

-- заполняем существующие 8 строк (2022 год)
UPDATE Employee SET God = 2022, Premiya = 3000 WHERE Id_employee = 1;
UPDATE Employee SET God = 2022, Premiya = 4500 WHERE Id_employee = 2;
UPDATE Employee SET God = 2022, Premiya = 2500 WHERE Id_employee = 3;
UPDATE Employee SET God = 2022, Premiya = 5000 WHERE Id_employee = 4;
UPDATE Employee SET God = 2022, Premiya = 3500 WHERE Id_employee = 5;
UPDATE Employee SET God = 2022, Premiya = 6000 WHERE Id_employee = 6;
UPDATE Employee SET God = 2022, Premiya = 2000 WHERE Id_employee = 7;
UPDATE Employee SET God = 2022, Premiya = 4000 WHERE Id_employee = 8;

-- добавляем те же сотрудники за 2023 и 2024 годы (копирование с изменением премии)
INSERT Employee (Id_employee, FName, LName, Dolzhnost, Namber_otdel, God, Premiya) VALUES
(9, N'Иванов', N'Пётр', N'Продавец', 1, 2023, 3300),
(10, N'Петрова', N'Анна', N'Кассир', 1, 2023, 5000),
(11, N'Сидоров', N'Олег', N'Мясник', 2, 2023, 2800),
(12, N'Кузнецова', N'Мария', N'Продавец', 2, 2023, 5500),
(13, N'Смирнов', N'Игорь', N'Пекарь', 3, 2023, 3900),
(14, N'Галимова', N'Лейла', N'Продавец', 3, 2023, 6600),
(15, N'Назаров', N'Ильдар', N'Кладовщик', 4, 2023, 2200),
(16, N'Ахмадуллин', N'Рустам', N'Грузчик', 4, 2023, 4400),
(17, N'Иванов', N'Пётр', N'Продавец', 1, 2024, 3800),
(18, N'Петрова', N'Анна', N'Кассир', 1, 2024, 5600),
(19, N'Сидоров', N'Олег', N'Мясник', 2, 2024, 3100),
(20, N'Кузнецова', N'Мария', N'Продавец', 2, 2024, 6200),
(21, N'Смирнов', N'Игорь', N'Пекарь', 3, 2024, 4400),
(22, N'Галимова', N'Лейла', N'Продавец', 3, 2024, 7500),
(23, N'Назаров', N'Ильдар', N'Кладовщик', 4, 2024, 2500),
(24, N'Ахмадуллин', N'Рустам', N'Грузчик', 4, 2024, 5000);
GO

SELECT * FROM Employee ORDER BY God, Id_employee;

-- 1. Сумма премий, выплаченных сотрудникам в разные годы в разных отделах.
SELECT o.Name_otdel AS [Отдел], e.God AS [Год], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY o.Name_otdel, e.God
ORDER BY o.Name_otdel, e.God;

-- 2.1. Сумма премий по годам с общим итогом.
SELECT e.God AS [Год], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
GROUP BY ROLLUP(e.God);

-- 2.2. Сумма премий по отделам с общим итогом.
SELECT o.Name_otdel AS [Отдел], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY ROLLUP(o.Name_otdel);

-- 2.3. Сумма премий по годам и отделам с итогами по отделам и общим итогом.
SELECT o.Name_otdel AS [Отдел], e.God AS [Год], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY ROLLUP(o.Name_otdel, e.God);

-- 3.1. Сумма премий по отделам и годам с промежуточными итогами по отделам, по годам и общим итогом.
SELECT o.Name_otdel AS [Отдел], e.God AS [Год], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY CUBE(o.Name_otdel, e.God);

-- 4. Сумма премий по отделам и годам, итоги по отделам, итоги по годам и общий итог — с помощью UNION ALL.
SELECT o.Name_otdel AS [Отдел], e.God AS [Год], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY o.Name_otdel, e.God
UNION ALL
SELECT o.Name_otdel, NULL, SUM(e.Premiya)
FROM Employee e INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY o.Name_otdel
UNION ALL
SELECT NULL, e.God, SUM(e.Premiya)
FROM Employee e
GROUP BY e.God
UNION ALL
SELECT NULL, NULL, SUM(e.Premiya)
FROM Employee e;

-- 5.1. Сумма премий с группировкой по отделам и отдельно по годам.
SELECT o.Name_otdel AS [Отдел], e.God AS [Год], SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY GROUPING SETS ((o.Name_otdel), (e.God));

-- 6.1. Группировка по отделам и по годам с подписями «Промежуточный итог…» и «Общий итог».
SELECT
    CASE WHEN GROUPING(o.Name_otdel) = 1 AND GROUPING(e.God) = 1 THEN N'Общий итог'
         WHEN GROUPING(o.Name_otdel) = 1 THEN N'Промежуточный итог по годам'
         ELSE o.Name_otdel
    END AS [Отдел],
    CASE WHEN GROUPING(e.God) = 1 AND GROUPING(o.Name_otdel) = 0 THEN N'Промежуточный итог по отделу'
         WHEN GROUPING(e.God) = 1 THEN N''
         ELSE CAST(e.God AS NVARCHAR(10))
    END AS [Год],
    SUM(e.Premiya) AS [Сумма премий]
FROM Employee e
INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
GROUP BY GROUPING SETS ((o.Name_otdel), (e.God), ());

-- 7.1. Отчёт: отдел — годы (премии по годам в столбцах).
SELECT pv.Name_otdel AS [Отдел], pv.[2022], pv.[2023], pv.[2024]
FROM (
    SELECT o.Name_otdel, e.God, e.Premiya
    FROM Employee e
    INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
) src
PIVOT (SUM(src.Premiya) FOR src.God IN ([2022], [2023], [2024])) pv
ORDER BY pv.Name_otdel;

-- 7.2. Отчёт: отдел — годы с итогом по отделу и строкой «Итого по годам».
SELECT ISNULL(pv.Name_otdel, N'Итого по годам') AS [Отдел],
       SUM(pv.[2022]) AS [2022],
       SUM(pv.[2023]) AS [2023],
       SUM(pv.[2024]) AS [2024],
       SUM(ISNULL(pv.[2022], 0) + ISNULL(pv.[2023], 0) + ISNULL(pv.[2024], 0)) AS [Итого по отделу]
FROM (
    SELECT o.Name_otdel, e.God, e.Premiya
    FROM Employee e
    INNER JOIN Otdel o ON o.Namber_otdel = e.Namber_otdel
) src
PIVOT (SUM(src.Premiya) FOR src.God IN ([2022], [2023], [2024])) pv
GROUP BY ROLLUP(pv.Name_otdel)
ORDER BY GROUPING(pv.Name_otdel), pv.Name_otdel;

-- 7.3. Отчёт: сотрудники — годы с итогом по сотруднику и строкой «Итого по годам».
SELECT ISNULL(pv.FName, N'Итого по годам') AS [Сотрудник],
       SUM(pv.[2022]) AS [2022],
       SUM(pv.[2023]) AS [2023],
       SUM(pv.[2024]) AS [2024],
       SUM(ISNULL(pv.[2022], 0) + ISNULL(pv.[2023], 0) + ISNULL(pv.[2024], 0)) AS [Итого по сотруднику]
FROM (
    SELECT e.FName, e.God, e.Premiya
    FROM Employee e
) src
PIVOT (SUM(src.Premiya) FOR src.God IN ([2022], [2023], [2024])) pv
GROUP BY ROLLUP(pv.FName)
ORDER BY GROUPING(pv.FName), pv.FName;
