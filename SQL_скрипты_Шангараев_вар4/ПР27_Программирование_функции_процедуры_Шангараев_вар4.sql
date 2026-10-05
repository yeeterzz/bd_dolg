-- Практическая работа № 27. Программирование, функции и процедуры
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Torgovlya

-- Подготовка: создание БД, таблиц и данных (в «Сотрудники» добавлены столбцы «Год» и «Премия»)
CREATE DATABASE Torgovlya;
GO
USE Torgovlya;
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

ALTER TABLE Employee ADD God INT NULL, Premiya DECIMAL(10,2) NULL;
GO

-- 1. Вывести предложение «Студент Андрей Петров является ударником». Имя, фамилия и успеваемость заданы через переменные.
DECLARE @Imya        NVARCHAR(30) = N'Андрей';
DECLARE @Familiya    NVARCHAR(30) = N'Петров';
DECLARE @Uspevaemost NVARCHAR(30) = N'ударником';

PRINT N'Студент ' + @Imya + N' ' + @Familiya + N' является ' + @Uspevaemost;

-- значения можно менять, например:
SET @Imya = N'Амир';
SET @Familiya = N'Шангараев';
PRINT N'Студент ' + @Imya + N' ' + @Familiya + N' является ' + @Uspevaemost;

-- 4. Заполнить таблицу «Сотрудники» данными, пока год не станет текущим, начиная с 2018. В каждой итерации год увеличивается на 1.
DECLARE @God INT = 2018;
DECLARE @Id  INT = (SELECT ISNULL(MAX(Id_employee), 0) + 1 FROM dbo.Employee);

WHILE @God <= YEAR(GETDATE())
BEGIN
    INSERT dbo.Employee (Id_employee, FName, LName, Dolzhnost, Namber_otdel, God, Premiya)
    VALUES (@Id,     N'Волков',  N'Артём', N'Продавец', 1, @God, 3000 + (@God - 2018) * 500),
           (@Id + 1, N'Зайцева', N'Алина', N'Кассир',   2, @God, 2000 + (@God - 2018) * 400);

    SET @Id  = @Id + 2;
    SET @God = @God + 1;       -- год увеличивается на 1
END;

-- проверка
SELECT e.God AS [Год], COUNT(*) AS [Сотрудников], SUM(e.Premiya) AS [Сумма премий]
FROM dbo.Employee e
WHERE e.God IS NOT NULL
GROUP BY e.God
ORDER BY e.God;

-- 2. Вывести «В ___ выплачено сотрудникам премии ___ рублей». Год и сумма заданы через переменные.
DECLARE @God   INT = 2020;
DECLARE @Summa DECIMAL(12,2) = 0;

-- сумму можно задать вручную (SET @Summa = 25000) или рассчитать по таблице:
SELECT @Summa = ISNULL(SUM(e.Premiya), 0)
FROM dbo.Employee e
WHERE e.God = @God;

PRINT N'В ' + CAST(@God AS NVARCHAR(4)) + N' выплачено сотрудникам премии '
      + CAST(@Summa AS NVARCHAR(20)) + N' рублей';

-- 3. Если в текущем году не было премий — «В текущем году премий не было», иначе «В текущем году премии были».
IF EXISTS (SELECT 1
           FROM dbo.Employee e
           WHERE e.God = YEAR(GETDATE()) AND e.Premiya > 0)
    PRINT N'В текущем году премии были';
ELSE
    PRINT N'В текущем году премий не было';

-- 5.1. Функция, возвращающая фамилию заверяющего сотрудника по его ID.
CREATE FUNCTION dbo.fn_Zaveril_FName (@Id_employee INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Result NVARCHAR(50);
    SELECT @Result = e.FName FROM dbo.Employee e WHERE e.Id_employee = @Id_employee;
    RETURN @Result;
END;
GO

-- 5.2. Функция, возвращающая название поставщика по его ID.
CREATE FUNCTION dbo.fn_Postavshik_Name (@Id_supplier INT)
RETURNS NVARCHAR(60)
AS
BEGIN
    DECLARE @Result NVARCHAR(60);
    SELECT @Result = s.Name_company FROM dbo.Supplier s WHERE s.Id_supplier = @Id_supplier;
    RETURN @Result;
END;
GO

-- 5.3. Проверка: номер и дата накладной, фамилия заверяющего сотрудника и название поставщика.
SELECT i.Namber_invoice AS [№ накладной],
       i.Invoice_date AS [Дата],
       dbo.fn_Zaveril_FName(i.Id_employee_ok) AS [Заверил],
       dbo.fn_Postavshik_Name(i.Id_supplier) AS [Поставщик]
FROM dbo.Invoice i;

-- 5.4. Проверка: фамилия заверяющего сотрудника и сколько раз он заверил накладные.
SELECT dbo.fn_Zaveril_FName(i.Id_employee_ok) AS [Заверяющий сотрудник],
       COUNT(*) AS [Заверил накладных]
FROM dbo.Invoice i
GROUP BY i.Id_employee_ok;

-- 5.5. Проверка: название поставщика и сколько раз он сделал поставки (количество накладных).
SELECT dbo.fn_Postavshik_Name(i.Id_supplier) AS [Поставщик],
       COUNT(*) AS [Количество поставок]
FROM dbo.Invoice i
GROUP BY i.Id_supplier;

-- 6.1. Функция, формирующая таблицу: номер и дата накладной, фамилия заверяющего сотрудника, название поставщика.
CREATE FUNCTION dbo.fn_Nakladnye_Info ()
RETURNS @T TABLE (
    Namber_invoice  INT,
    Invoice_date    DATE,
    Zaveril         NVARCHAR(50),
    Postavshik      NVARCHAR(60)
)
AS
BEGIN
    INSERT @T
    SELECT i.Namber_invoice, i.Invoice_date,
           dbo.fn_Zaveril_FName(i.Id_employee_ok),
           dbo.fn_Postavshik_Name(i.Id_supplier)
    FROM dbo.Invoice i;
    RETURN;
END;
GO

-- 6.2. Проверка работы функции и сохранение результата в новую таблицу.
SELECT * FROM dbo.fn_Nakladnye_Info();

SELECT * INTO dbo.Nakladnye_Info FROM dbo.fn_Nakladnye_Info();
SELECT * FROM dbo.Nakladnye_Info;

-- 7.1. Процедура: если количество в поставке меньше 50, увеличить его на 5 %.
CREATE PROCEDURE dbo.pr_Uvelichit_Kolichestvo
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Delivery
    SET Quantity = CEILING(Quantity * 1.05)
    WHERE Quantity < 50;
END;
GO

-- 7.2. Запуск процедуры и вывод результата запросом (до и после).
SELECT d.Id_delivery AS [ID строки], d.Quantity AS [Количество до] FROM dbo.Delivery d ORDER BY d.Id_delivery;

EXEC dbo.pr_Uvelichit_Kolichestvo;

SELECT d.Id_delivery AS [ID строки], d.Quantity AS [Количество после] FROM dbo.Delivery d ORDER BY d.Id_delivery;
