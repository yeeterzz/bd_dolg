-- Практическая работа № 19. Вложенные запросы
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Zarplata_Sotr

-- Подготовка: создание БД, таблиц и данных
CREATE DATABASE Zarplata_Sotr;
GO
USE Zarplata_Sotr;
GO

CREATE TABLE City (
    Id_city    INT           PRIMARY KEY,
    City_name  NVARCHAR(50)  NOT NULL
);
CREATE TABLE Street (
    Id_street    INT           PRIMARY KEY,
    Street_name  NVARCHAR(50)  NOT NULL,
    Id_city      INT           NOT NULL REFERENCES City(Id_city)
);
CREATE TABLE Category (
    Id_category    INT            PRIMARY KEY,
    Category_name  NVARCHAR(30)   NOT NULL,
    Oklad          DECIMAL(10,2)  NOT NULL
);
CREATE TABLE Months (
    Month_number  INT           PRIMARY KEY,
    Month_name    NVARCHAR(20)  NOT NULL,
    Work_days     INT           NOT NULL
);
CREATE TABLE Employee (
    Tab_number    INT           PRIMARY KEY,
    FName         NVARCHAR(50)  NOT NULL,      -- фамилия
    LName         NVARCHAR(50)  NOT NULL,      -- имя
    Id_street     INT           NOT NULL REFERENCES Street(Id_street),
    House         NVARCHAR(10)  NULL,
    Id_category   INT           NOT NULL REFERENCES Category(Id_category),
    Kids_count    INT           NOT NULL DEFAULT 0
);
CREATE TABLE Salary (
    Id_zp         INT            PRIMARY KEY,
    Tab_number    INT            NOT NULL REFERENCES Employee(Tab_number),
    Month_number  INT            NOT NULL REFERENCES Months(Month_number),
    Days_worked   INT            NOT NULL,
    Accrued       DECIMAL(10,2)  NOT NULL,     -- начислено
    Withheld      DECIMAL(10,2)  NOT NULL      -- удержано
);
GO

INSERT City VALUES (1, N'Казань'), (2, N'Москва'), (3, N'Набережные Челны');
INSERT Street VALUES (1, N'Баумана', 1), (2, N'Ленина', 1), (3, N'Пушкина', 1),
                     (4, N'Арбат', 2), (5, N'Тверская', 2), (6, N'Мира', 3);
INSERT Category VALUES (1, N'Высшая', 45000), (2, N'Первая', 38000), (3, N'Вторая', 30000);
INSERT Months VALUES (1, N'январь', 20), (2, N'февраль', 20), (3, N'март', 22);

INSERT Employee (Tab_number, FName, LName, Id_street, House, Id_category, Kids_count) VALUES
(21, N'Иванов',     N'Пётр',   1, N'10', 1, 2),
(22, N'Петрова',    N'Анна',   2, N'4',  1, 1),
(23, N'Сидоров',    N'Олег',   3, N'15', 1, 0),
(24, N'Кузнецова',  N'Мария',  4, N'8',  2, 3),
(25, N'Сахаров',    N'Игорь',  1, N'22', 2, 1),
(26, N'Смирнов',    N'Андрей', 1, N'7',  2, 2),
(27, N'Галимова',   N'Лейла',  5, N'3',  2, 0),
(28, N'Назаров',    N'Ильдар', 6, N'12', 3, 1),
(29, N'Орлова',     N'Елена',  2, N'31', 3, 2),
(30, N'Ахмадуллин', N'Рустам', 3, N'9',  3, 0);

INSERT Salary (Id_zp, Tab_number, Month_number, Days_worked, Accrued, Withheld) VALUES
(1, 21, 1, 20, 45000.00, 5850.00),
(2, 21, 2, 20, 45000.00, 5850.00),
(3, 21, 3, 22, 45000.00, 5850.00),
(4, 22, 1, 20, 45000.00, 5850.00),
(5, 22, 2, 20, 40000.00, 5200.00),
(6, 22, 3, 22, 45000.00, 5850.00),
(7, 23, 1, 20, 40000.00, 5200.00),
(8, 23, 2, 20, 40000.00, 5200.00),
(9, 23, 3, 22, 40000.00, 5200.00),
(10, 24, 1, 20, 40000.00, 5200.00),
(11, 24, 2, 20, 35000.00, 4550.00),
(12, 24, 3, 22, 35000.00, 4550.00),
(13, 25, 1, 20, 35000.00, 4550.00),
(14, 25, 2, 20, 35000.00, 4550.00),
(15, 25, 3, 22, 35000.00, 4550.00),
(16, 26, 1, 20, 35000.00, 4550.00),
(17, 26, 2, 20, 35000.00, 4550.00),
(18, 26, 3, 22, 35000.00, 4550.00),
(19, 27, 1, 20, 35000.00, 4550.00),
(20, 27, 2, 20, 35000.00, 4550.00),
(21, 27, 3, 22, 30000.00, 3900.00),
(22, 28, 1, 20, 30000.00, 3900.00),
(23, 28, 2, 20, 30000.00, 3900.00),
(24, 28, 3, 22, 30000.00, 3900.00),
(25, 29, 1, 20, 25000.00, 3250.00),
(26, 29, 2, 20, 25000.00, 3250.00),
(27, 29, 3, 22, 30000.00, 3900.00),
(28, 30, 1, 20, 25000.00, 3250.00),
(29, 30, 2, 20, 25000.00, 3250.00),
(30, 30, 3, 22, 25000.00, 3250.00);
GO

-- 1. Фамилии сотрудников, которые живут на улице «Баумана».
SELECT e.FName AS [Фамилия]
FROM Employee e
WHERE e.Id_street IN (SELECT s.Id_street
                      FROM Street s
                      WHERE s.Street_name = N'Баумана');

-- 2. Фамилии сотрудников, у которых высшая категория.
SELECT e.FName AS [Фамилия]
FROM Employee e
WHERE e.Id_category IN (SELECT c.Id_category
                        FROM Category c
                        WHERE c.Category_name = N'Высшая');

-- 3. Шаг 1. Название улиц в городе Казани: определить код города.
SELECT c.Id_city
FROM City c
WHERE c.City_name = N'Казань';

-- 3. Шаг 2. Выбрать улицы по найденному коду города (код 1 — результат шага 1).
SELECT s.Street_name AS [Улица]
FROM Street s
WHERE s.Id_city = 1;

-- 3. Шаг 3. Объединить шаги в один вложенный запрос.
SELECT s.Street_name AS [Улица]
FROM Street s
WHERE s.Id_city = (SELECT c.Id_city
                   FROM City c
                   WHERE c.City_name = N'Казань');

-- 4. Шаг 1. Табельные номера сотрудников той же категории, что и сотрудник 26: определить категорию сотрудника 26.
SELECT e.Id_category
FROM Employee e
WHERE e.Tab_number = 26;

-- 4. Шаг 2. Найти сотрудников с этой категорией (код 2 — результат шага 1).
SELECT e.Tab_number AS [Табельный номер]
FROM Employee e
WHERE e.Id_category = 2 AND e.Tab_number <> 26;

-- 4. Шаг 3. Вложенный запрос.
SELECT e.Tab_number AS [Табельный номер]
FROM Employee e
WHERE e.Id_category = (SELECT e2.Id_category
                       FROM Employee e2
                       WHERE e2.Tab_number = 26)
  AND e.Tab_number <> 26;

-- 5. Фамилии сотрудников, которые живут на той же улице, что и сотрудник Сахаров.
SELECT e.FName AS [Фамилия]
FROM Employee e
WHERE e.Id_street = (SELECT e2.Id_street
                     FROM Employee e2
                     WHERE e2.FName = N'Сахаров')
  AND e.FName <> N'Сахаров';

-- 6. Шаг 1. Фамилии сотрудников, у которых начисленная зарплата равна средней зарплате по предприятию: вычислить среднюю начисленную зарплату.
SELECT AVG(z.Accrued) AS [Средняя зарплата по предприятию]
FROM Salary z;

-- 6. Шаг 2. Найти табельные номера сотрудников с начислением, равным средней (35000 — результат шага 1).
SELECT DISTINCT z.Tab_number
FROM Salary z
WHERE z.Accrued = 35000;

-- 6. Шаг 3. Вложенный запрос, возвращающий фамилии.
SELECT e.FName AS [Фамилия]
FROM Employee e
WHERE e.Tab_number IN (SELECT z.Tab_number
                       FROM Salary z
                       WHERE z.Accrued = (SELECT AVG(z2.Accrued)
                                          FROM Salary z2));

-- 7. Название месяца, в котором начислена минимальная зарплата, в виде: название месяца, фонд оплаты труда за месяц.
SELECT m.Month_name AS [Название месяца],
       SUM(z.Accrued) AS [Фонд оплаты труда за месяц]
FROM Months m
INNER JOIN Salary z ON z.Month_number = m.Month_number
GROUP BY m.Month_name
HAVING SUM(z.Accrued) = (SELECT MIN(f.Fond)
                         FROM (SELECT SUM(z2.Accrued) AS Fond
                               FROM Salary z2
                               GROUP BY z2.Month_number) f);

-- 8. Шаг 1. Фамилии сотрудников и их зарплата за весь период: суммарное начисление по табельным номерам.
SELECT z.Tab_number, SUM(z.Accrued) AS Total_accrued
FROM Salary z
GROUP BY z.Tab_number;

-- 8. Шаг 2. Подставить результат шага 1 как вложенный запрос и добавить фамилии.
SELECT e.FName AS [Фамилия],
       (SELECT SUM(z.Accrued)
        FROM Salary z
        WHERE z.Tab_number = e.Tab_number) AS [Начислено за весь период]
FROM Employee e
ORDER BY e.FName;

-- 8. Шаг 3. Тот же результат с вложенным запросом во FROM.
SELECT e.FName AS [Фамилия], t.Total_accrued AS [Начислено за весь период]
FROM Employee e
INNER JOIN (SELECT z.Tab_number, SUM(z.Accrued) AS Total_accrued
            FROM Salary z
            GROUP BY z.Tab_number) t
        ON t.Tab_number = e.Tab_number
ORDER BY e.FName;
