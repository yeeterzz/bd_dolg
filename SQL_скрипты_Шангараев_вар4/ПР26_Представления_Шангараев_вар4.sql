-- Практическая работа № 26. Создание представлений
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_View

-- Подготовка: создание БД, таблиц и данных
CREATE DATABASE Magazin_View;
GO
USE Magazin_View;
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

-- 1.1. Создать представление SOTR1: ID сотрудника, фамилия, номер отдела.
CREATE VIEW dbo.SOTR1
AS
SELECT e.Id_employee, e.FName, e.Namber_otdel
FROM dbo.Employee e;
GO

SELECT * FROM dbo.SOTR1;

-- 1.2. Добавить через представление нового сотрудника, проверить его в представлении и в базовой таблице.
INSERT dbo.SOTR1 (Id_employee, FName, Namber_otdel)
VALUES (9, N'Орлов', 1);

-- в представлении
SELECT * FROM dbo.SOTR1 WHERE Id_employee = 9;
-- в базовой таблице
SELECT e.* FROM dbo.Employee e WHERE e.Id_employee = 9;

-- 1.3. Изменить через представление номер отдела сотрудника, проверить изменения.
UPDATE dbo.SOTR1
SET Namber_otdel = 2
WHERE Id_employee = 9;

SELECT * FROM dbo.SOTR1 WHERE Id_employee = 9;
SELECT e.* FROM dbo.Employee e WHERE e.Id_employee = 9;

-- 2. Создать представление OTD_SOTR, определяющее, во всех ли отделах есть сотрудники.
CREATE VIEW dbo.OTD_SOTR (Namber_otdel, Name_otdel, Kol_sotr, Status)
AS
SELECT o.Namber_otdel,
       o.Name_otdel,
       ISNULL(n.Kol, 0),
       CASE WHEN n.Kol IS NULL THEN N'Сотрудников нет' ELSE N'Есть сотрудники' END
FROM dbo.Otdel o
LEFT JOIN (SELECT s.Namber_otdel, COUNT(s.Id_employee) AS Kol
           FROM dbo.SOTR1 s
           GROUP BY s.Namber_otdel) n
       ON o.Namber_otdel = n.Namber_otdel;
GO

SELECT * FROM dbo.OTD_SOTR;

-- 3.1. Добавить новый отдел.
INSERT dbo.Otdel (Namber_otdel, Name_otdel, Nachalnik)
VALUES (5, N'Кулинария', N'Фёдорова');

SELECT * FROM dbo.Otdel;

-- 3.2. Проверить, что в новом отделе нет сотрудников (представление не запускаем заново — данные пересчитываются автоматически).
SELECT * FROM dbo.OTD_SOTR;
-- для отдела 5: Kol_sotr = 0, Status = 'Сотрудников нет'

-- 3.3. Добавить сотрудника, работающего в новом отделе.
INSERT dbo.SOTR1 (Id_employee, FName, Namber_otdel)
VALUES (10, N'Воронова', 5);

SELECT * FROM dbo.SOTR1;

-- 3.4. Проверить, что в новом отделе появился один сотрудник.
SELECT * FROM dbo.OTD_SOTR;
-- для отдела 5: Kol_sotr = 1, Status = 'Есть сотрудники'

-- 3.5. Перевести другого сотрудника в новый отдел.
UPDATE dbo.SOTR1
SET Namber_otdel = 5
WHERE Id_employee = 9;

SELECT * FROM dbo.SOTR1;

-- 3.6. Проверить, что в новом отделе стало больше сотрудников (изменение произошло автоматически).
SELECT * FROM dbo.OTD_SOTR;
-- для отдела 5: Kol_sotr = 2

-- сводная проверка по базовой таблице
SELECT e.Namber_otdel, COUNT(*) AS Kol FROM dbo.Employee e GROUP BY e.Namber_otdel;
