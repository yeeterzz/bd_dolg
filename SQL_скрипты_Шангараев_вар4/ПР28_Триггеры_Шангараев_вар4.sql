-- Практическая работа № 28. Создание триггеров
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_Trigger

-- Подготовка: создание БД, таблиц и данных
CREATE DATABASE Magazin_Trigger;
GO
USE Magazin_Trigger;
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

-- 1.1. Создать таблицу SOTR с помощью INTO из таблицы «Сотрудники»: ID сотрудника, фамилия, номер отдела.
SELECT e.Id_employee, e.FName, e.Namber_otdel
INTO dbo.SOTR
FROM dbo.Employee e;

SELECT * FROM dbo.SOTR;

-- 1.2. Триггер SOTR_INS: выводит информацию о попытке добавления и количестве добавленных строк пользователем.
CREATE TRIGGER dbo.SOTR_INS
ON dbo.SOTR
AFTER INSERT
AS
BEGIN
    DECLARE @Kol INT = (SELECT COUNT(*) FROM inserted);
    PRINT N'Пользователь ' + SUSER_SNAME() + N' выполнил попытку добавления в таблицу SOTR. '
          + N'Добавлено строк: ' + CAST(@Kol AS NVARCHAR(10));
END;
GO

-- 1.3. Тестирование триггера: добавление одной строки, нескольких строк и вставка без строк.
-- одна строка
INSERT dbo.SOTR (Id_employee, FName, Namber_otdel) VALUES (9, N'Орлов', 1);

-- три строки одной командой
INSERT dbo.SOTR (Id_employee, FName, Namber_otdel)
VALUES (10, N'Воронова', 2), (11, N'Лисин', 3), (12, N'Беляева', 4);

-- попытка добавления, при которой не добавлено ни одной строки
INSERT dbo.SOTR (Id_employee, FName, Namber_otdel)
SELECT Id_employee, FName, Namber_otdel FROM dbo.SOTR WHERE 1 = 0;

SELECT * FROM dbo.SOTR;

-- 2.1. Создать таблицу «Товары»: номенклатурный номер, название, цена оптовая, наценка, цена розничная.
CREATE TABLE dbo.Tovary (
    Nomenclature_number  INT            PRIMARY KEY,
    Name_tovar           NVARCHAR(60)   NOT NULL,
    Price_opt            DECIMAL(10,2)  NOT NULL,     -- цена оптовая
    Nacenka              DECIMAL(10,2)  NOT NULL,     -- наценка (руб.)
    Price_rozn           DECIMAL(10,2)  NULL          -- цена розничная (считает триггер)
);
GO

-- 2.2. Заполнить таблицу данными командой INSERT (3 строки).
INSERT dbo.Tovary (Nomenclature_number, Name_tovar, Price_opt, Nacenka) VALUES
(1, N'Молоко',   60.00, 15.00),
(2, N'Говядина', 450.00, 90.00),
(3, N'Гречка',   85.00, 20.00);

SELECT * FROM dbo.Tovary;     -- Price_rozn пока NULL

-- 2.3. Триггер Tovary_Price: при добавлении или изменении данных автоматически считает цену розничную = цена оптовая + наценка.
CREATE TRIGGER dbo.Tovary_Price
ON dbo.Tovary
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET t.Price_rozn = t.Price_opt + t.Nacenka
    FROM dbo.Tovary t
    INNER JOIN inserted i ON t.Nomenclature_number = i.Nomenclature_number;
END;
GO

-- 2.4. Проверка работы триггера на добавление и изменение данных.
-- добавление: цена розничная должна заполниться автоматически
INSERT dbo.Tovary (Nomenclature_number, Name_tovar, Price_opt, Nacenka)
VALUES (4, N'Сахар', 70.00, 12.00);
SELECT * FROM dbo.Tovary WHERE Nomenclature_number = 4;     -- 82.00

-- изменение наценки: цена розничная пересчитывается
UPDATE dbo.Tovary SET Nacenka = 25.00 WHERE Nomenclature_number = 1;
SELECT * FROM dbo.Tovary WHERE Nomenclature_number = 1;     -- 85.00

-- изменение оптовой цены
UPDATE dbo.Tovary SET Price_opt = 500.00 WHERE Nomenclature_number = 2;
SELECT * FROM dbo.Tovary WHERE Nomenclature_number = 2;     -- 590.00

-- пересчёт для строк, добавленных до создания триггера
UPDATE dbo.Tovary SET Nacenka = Nacenka WHERE Price_rozn IS NULL;
SELECT * FROM dbo.Tovary;
