-- Практическая работа № 21. Запросы для работы с наборами данных
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Remont_Dorog (БД «Ремонт дорог» из практической работы № 9)

-- Исходные таблицы и данные
CREATE DATABASE Remont_Dorog;
GO
USE Remont_Dorog;
GO

CREATE TABLE Repair_Brigade (                       -- Ремонтные бригады
    Id_brigade     INT IDENTITY(1,1) PRIMARY KEY,
    Name_brigade   NVARCHAR(50)  NOT NULL UNIQUE,
    Workers_count  INT           NOT NULL CHECK (Workers_count BETWEEN 15 AND 30),
    Phone          NVARCHAR(20)  NULL UNIQUE
);
CREATE TABLE Technic (                              -- Техника
    Id_technic    INT IDENTITY(1,1) PRIMARY KEY,
    Name_technic  NVARCHAR(60)   NOT NULL UNIQUE,
    Price         DECIMAL(10,2)  NOT NULL DEFAULT 500000
                  CHECK (Price BETWEEN 300000 AND 1000000),
    Id_brigade    INT            NOT NULL REFERENCES Repair_Brigade(Id_brigade)
);
GO

INSERT Repair_Brigade (Name_brigade, Workers_count, Phone) VALUES
(N'Дорожник',   20, N'+7-843-100-00-01'), (N'Магистраль', 25, N'+7-843-100-00-02'),
(N'Асфальт',    18, N'+7-843-100-00-03'), (N'Мост',       28, N'+7-843-100-00-04'),
(N'Трасса',     22, N'+7-843-100-00-05');

INSERT Technic (Name_technic, Price, Id_brigade) VALUES
(N'Экскаватор ЭО-4321',       820000, 1), (N'Бульдозер Т-170',          690000, 1),
(N'Дорожный каток BOMAG',     540000, 2), (N'Автокран КС-45717',        950000, 2),
(N'Буровая установка УБШМ',   780000, 3), (N'Асфальтоукладчик ABG',     910000, 3),
(N'Грейдер ДЗ-98',            620000, 4), (N'Самосвал КамАЗ-6520',      470000, 4),
(N'Погрузчик Амкодор',        430000, 5), (N'Бетономешалка СБ-92',      350000, 5);
GO

-- 1. Добавить в таблицу «Техника» поле «Классификация техники».
ALTER TABLE Technic ADD Classification NVARCHAR(30) NULL;
GO
SELECT * FROM Technic;

-- 2. Заполнить поле «Классификация техники» командами UPDATE и INSERT (новые строки сразу с классификацией).
UPDATE Technic SET Classification = N'Землеройная'     WHERE Name_technic LIKE N'Экскаватор%' OR Name_technic LIKE N'Бульдозер%' OR Name_technic LIKE N'Грейдер%';
UPDATE Technic SET Classification = N'Грузоподъёмная'   WHERE Name_technic LIKE N'Автокран%' OR Name_technic LIKE N'Погрузчик%';
UPDATE Technic SET Classification = N'Буровая'          WHERE Name_technic LIKE N'Буровая%';
UPDATE Technic SET Classification = N'Дорожная'         WHERE Name_technic LIKE N'Дорожный каток%' OR Name_technic LIKE N'Асфальтоукладчик%';
UPDATE Technic SET Classification = N'Транспортная'     WHERE Name_technic LIKE N'Самосвал%' OR Name_technic LIKE N'Бетономешалка%';

INSERT Technic (Name_technic, Price, Id_brigade, Classification) VALUES
(N'Экскаватор-погрузчик JCB', 880000, 4, N'Землеройная'),
(N'Автокран Галичанин',       990000, 5, N'Грузоподъёмная');

SELECT * FROM Technic;

-- 3. Добавить таблицу «Строительные бригады» (номер бригады, название). Для запроса 11 добавлено также поле «Количество работников».
CREATE TABLE Build_Brigade (                         -- Строительные бригады
    Id_build_brigade  INT IDENTITY(1,1) PRIMARY KEY,
    Name_brigade      NVARCHAR(50)  NOT NULL,
    Workers_count     INT           NULL
);
GO

-- 4. Заполнить «Строительные бригады» командами INSERT и UPDATE так, чтобы некоторые названия совпадали с названиями из «Ремонтные бригады».
INSERT Build_Brigade (Name_brigade, Workers_count) VALUES
(N'Магистраль', 24), (N'Фундамент', 16), (N'Каркас', 19), (N'Монолит', 27), (N'Асфальт', 21);

-- переименовываем одну бригаду, чтобы появилось ещё одно совпадение
UPDATE Build_Brigade SET Name_brigade = N'Мост' WHERE Name_brigade = N'Каркас';

SELECT * FROM Build_Brigade;

-- 5. Бригады, которые являются или ремонтными, или строительными, или и теми и другими (UNION, без повторов).
SELECT rb.Name_brigade AS [Бригада] FROM Repair_Brigade rb
UNION
SELECT bb.Name_brigade FROM Build_Brigade bb;

-- 6. То же без уникальности строк (UNION ALL).
SELECT rb.Name_brigade AS [Бригада] FROM Repair_Brigade rb
UNION ALL
SELECT bb.Name_brigade FROM Build_Brigade bb;

-- 7. Бригады, которые являются ремонтными и строительными одновременно (INTERSECT).
SELECT rb.Name_brigade AS [Бригада] FROM Repair_Brigade rb
INTERSECT
SELECT bb.Name_brigade FROM Build_Brigade bb;

-- 8. Бригады, которые являются только ремонтными (EXCEPT).
SELECT rb.Name_brigade AS [Только ремонтные бригады] FROM Repair_Brigade rb
EXCEPT
SELECT bb.Name_brigade FROM Build_Brigade bb;

-- 9. Бригады, которые являются только строительными (EXCEPT).
SELECT bb.Name_brigade AS [Только строительные бригады] FROM Build_Brigade bb
EXCEPT
SELECT rb.Name_brigade FROM Repair_Brigade rb;

-- 10. Бригады, которые являются только строительными и только ремонтными (симметрическая разность: EXCEPT в обе стороны и UNION).
(SELECT rb.Name_brigade AS [Бригада] FROM Repair_Brigade rb
 EXCEPT
 SELECT bb.Name_brigade FROM Build_Brigade bb)
UNION
(SELECT bb.Name_brigade FROM Build_Brigade bb
 EXCEPT
 SELECT rb.Name_brigade FROM Repair_Brigade rb);

-- 11. То же с учётом количества работников и с указанием вида бригады.
SELECT rb.Name_brigade AS [Бригада], rb.Workers_count AS [Количество работников], N'только ремонтная' AS [Вид]
FROM Repair_Brigade rb
WHERE rb.Name_brigade NOT IN (SELECT bb.Name_brigade FROM Build_Brigade bb)
UNION ALL
SELECT bb.Name_brigade, bb.Workers_count, N'только строительная'
FROM Build_Brigade bb
WHERE bb.Name_brigade NOT IN (SELECT rb.Name_brigade FROM Repair_Brigade rb)
ORDER BY [Вид], [Бригада];

-- 12. Шаг 1. Цена каждой техники индивидуально.
SELECT t.Classification AS [Классификация], t.Name_technic AS [Техника], t.Price AS [Цена]
FROM Technic t
ORDER BY t.Classification, t.Name_technic;

-- 12. Шаг 2. Средняя цена техники по классификациям.
SELECT t.Classification AS [Классификация], AVG(t.Price) AS [Средняя цена]
FROM Technic t
GROUP BY t.Classification;

-- 12. Шаг 3. Объединить шаги 1 и 2 в одной таблице: строки со средней ценой — под строками с индивидуальными значениями.
SELECT [Классификация], [Техника], [Цена]
FROM (
    SELECT t.Classification AS [Классификация], t.Name_technic AS [Техника], t.Price AS [Цена], 0 AS Sort_ord
    FROM Technic t
    UNION ALL
    SELECT t.Classification, N'Средняя цена по классификации', AVG(t.Price), 1
    FROM Technic t
    GROUP BY t.Classification
) x
ORDER BY [Классификация], Sort_ord, [Техника];

-- 13. Шаг 1. Стоимость техники, итог по каждой классификации и общий итог (ROLLUP).
SELECT t.Classification AS [Классификация], t.Name_technic AS [Техника], SUM(t.Price) AS [Стоимость]
FROM Technic t
GROUP BY ROLLUP(t.Classification, t.Name_technic);

-- 13. Шаг 2. Подписать итоговые строки и расположить их под индивидуальными значениями (GROUPING + сортировка).
SELECT CASE WHEN GROUPING(t.Classification) = 1 THEN N'Общий итог по всем классификациям'
            ELSE t.Classification END AS [Классификация],
       CASE WHEN GROUPING(t.Classification) = 1 THEN N''
            WHEN GROUPING(t.Name_technic) = 1 THEN N'Итого по классификации'
            ELSE t.Name_technic END AS [Техника],
       SUM(t.Price) AS [Стоимость]
FROM Technic t
GROUP BY ROLLUP(t.Classification, t.Name_technic)
ORDER BY GROUPING(t.Classification), t.Classification, GROUPING(t.Name_technic), t.Name_technic;
