-- Практическая работа № 29. Создание пользователей в MS SQL Server
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_Prava

-- Подготовка: создание БД, таблиц и данных
CREATE DATABASE Magazin_Prava;
GO
USE Magazin_Prava;
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

-- 3.1. Создание имени входа, пользователя и привилегий (пользователь с индивидуальными правами).
USE Magazin_Prava;
GO
CREATE LOGIN Shangaraev WITH PASSWORD = 'Shan_Pass#2026', CHECK_POLICY = OFF;
CREATE USER Shangaraev_User FOR LOGIN Shangaraev;

GRANT SELECT ON dbo.Otdel   TO Shangaraev_User;
GRANT SELECT ON dbo.Product TO Shangaraev_User;
DENY  UPDATE, DELETE ON dbo.Product TO Shangaraev_User;
GO

-- 3.2. Создание новой роли с привилегиями на все таблицы и пользователей этой роли.
CREATE ROLE Zaveduyushchiy;

-- чтение всех таблиц
GRANT SELECT ON dbo.Otdel    TO Zaveduyushchiy;
GRANT SELECT ON dbo.Product  TO Zaveduyushchiy;
GRANT SELECT ON dbo.Supplier TO Zaveduyushchiy;
GRANT SELECT ON dbo.Invoice  TO Zaveduyushchiy;
GRANT SELECT ON dbo.Employee TO Zaveduyushchiy;
GRANT SELECT ON dbo.Delivery TO Zaveduyushchiy;
-- добавление и изменение рабочих таблиц
GRANT INSERT, UPDATE ON dbo.Product  TO Zaveduyushchiy;
GRANT INSERT, UPDATE ON dbo.Supplier TO Zaveduyushchiy;
GRANT INSERT, UPDATE ON dbo.Invoice  TO Zaveduyushchiy;
GRANT INSERT, UPDATE ON dbo.Delivery TO Zaveduyushchiy;

CREATE LOGIN Log_Zav1 WITH PASSWORD = 'Zav1_Pass#2026', CHECK_POLICY = OFF;
CREATE USER Zav_Ivanova FOR LOGIN Log_Zav1;
ALTER ROLE Zaveduyushchiy ADD MEMBER Zav_Ivanova;

CREATE LOGIN Log_Zav2 WITH PASSWORD = 'Zav2_Pass#2026', CHECK_POLICY = OFF;
CREATE USER Zav_Petrov FOR LOGIN Log_Zav2;
ALTER ROLE Zaveduyushchiy ADD MEMBER Zav_Petrov;
GO

-- 3.3. Создание пользователя с системной ролью (db_datareader).
CREATE LOGIN Log_Buh WITH PASSWORD = 'Buh_Pass#2026', CHECK_POLICY = OFF;
CREATE USER Buh_Smirnova FOR LOGIN Log_Buh;
ALTER ROLE db_datareader ADD MEMBER Buh_Smirnova;
GO

-- 3.4. Создание пользователя «Кладовщик» с привилегиями на отдельные таблицы.
CREATE LOGIN Log_Sklad WITH PASSWORD = 'Sklad_Pass#2026', CHECK_POLICY = OFF;
CREATE USER Sklad_Nazarov FOR LOGIN Log_Sklad;

GRANT SELECT ON dbo.Product  TO Sklad_Nazarov;
GRANT SELECT ON dbo.Supplier TO Sklad_Nazarov;
GRANT SELECT, INSERT, UPDATE ON dbo.Invoice  TO Sklad_Nazarov;
GRANT SELECT, INSERT, UPDATE ON dbo.Delivery TO Sklad_Nazarov;
GO

-- 3.5. Просмотр созданных пользователей, ролей и выданных привилегий.
SELECT dp.name AS [Пользователь], dp.type_desc AS [Тип]
FROM sys.database_principals dp
WHERE dp.name IN (N'Shangaraev_User', N'Zav_Ivanova', N'Zav_Petrov', N'Buh_Smirnova', N'Sklad_Nazarov', N'Zaveduyushchiy');

SELECT USER_NAME(p.grantee_principal_id) AS [Кому],
       OBJECT_NAME(p.major_id)           AS [Таблица],
       p.permission_name                 AS [Привилегия],
       p.state_desc                      AS [Состояние]
FROM sys.database_permissions p
WHERE p.class = 1 AND USER_NAME(p.grantee_principal_id) <> N'public'
ORDER BY [Кому], [Таблица], [Привилегия];

-- 4.1. Пользователь Shangaraev_User.
EXECUTE AS USER = N'Shangaraev_User';
    SELECT * FROM dbo.Otdel;                              -- выполняется
    SELECT p.Name_product, p.Price FROM dbo.Product p;    -- выполняется
    UPDATE dbo.Product SET Price = Price + 1;             -- ОШИБКА: отказано в разрешении UPDATE (DENY)
    SELECT * FROM dbo.Employee;                           -- ОШИБКА: отказано в разрешении SELECT
REVERT;

-- 4.2. Пользователь Zav_Ivanova (роль Zaveduyushchiy).
EXECUTE AS USER = N'Zav_Ivanova';
    SELECT * FROM dbo.Employee;                           -- выполняется
    INSERT dbo.Product (Nomenclature_number, Name_product, Price, Namber_otdel)
    VALUES (100, N'Йогурт', 55.00, 1);                    -- выполняется
    UPDATE dbo.Product SET Price = 58.00 WHERE Nomenclature_number = 100;   -- выполняется
    DELETE FROM dbo.Product WHERE Nomenclature_number = 100;                -- ОШИБКА: нет права DELETE
REVERT;

-- 4.3. Пользователь Sklad_Nazarov.
EXECUTE AS USER = N'Sklad_Nazarov';
    INSERT dbo.Invoice (Namber_invoice, Invoice_date, Id_employee_ok, Id_supplier)
    VALUES (105, GETDATE(), 7, 4);                        -- выполняется
    INSERT dbo.Delivery (Id_delivery, Namber_invoice, Nomenclature_number, Quantity)
    VALUES (9, 105, 7, 40);                               -- выполняется
    SELECT * FROM dbo.Otdel;                              -- ОШИБКА: нет права SELECT
REVERT;

-- 4.4. Пользователь Buh_Smirnova (db_datareader).
EXECUTE AS USER = N'Buh_Smirnova';
    SELECT * FROM dbo.Delivery;                           -- выполняется
    SELECT * FROM dbo.Employee;                           -- выполняется
    DELETE FROM dbo.Delivery WHERE Id_delivery = 9;       -- ОШИБКА: нет права DELETE
REVERT;

-- 4.5. Отзыв привилегии (REVOKE) и проверка.
REVOKE SELECT ON dbo.Product FROM Shangaraev_User;

EXECUTE AS USER = N'Shangaraev_User';
    SELECT * FROM dbo.Product;                            -- ОШИБКА: привилегия отозвана
REVERT;

-- 4.6. Удаление тестовых пользователей, роли и имён входа (после проверки).
ALTER ROLE Zaveduyushchiy DROP MEMBER Zav_Ivanova;
ALTER ROLE Zaveduyushchiy DROP MEMBER Zav_Petrov;
DROP USER Zav_Ivanova;  DROP USER Zav_Petrov;
DROP ROLE Zaveduyushchiy;
DROP USER Shangaraev_User;  DROP USER Buh_Smirnova;  DROP USER Sklad_Nazarov;
GO
USE master;
DROP LOGIN Shangaraev;  DROP LOGIN Log_Zav1;  DROP LOGIN Log_Zav2;
DROP LOGIN Log_Buh;     DROP LOGIN Log_Sklad;
