-- Практическая работа № 13. Создание запросов с использованием агрегатных функций
-- Выполнил: Шангараев Амир Марселевич, группа ИС231-4, вариант 4
-- База данных: Magazin_Produktov (из практической работы № 11)

-- Запрос 1. SUM с условием: сумма окладов сотрудников бакалейного отдела (отдел 4).
SELECT SUM(e.Oklad) AS [Сумма окладов отдела 4]
FROM Employee e
WHERE e.Namber_otdel = 4;

-- Запрос 2. SUM с группировкой и условием для группировки: фонд оплаты труда по отделам, где сумма окладов больше 90000.
SELECT e.Namber_otdel AS [№ отдела],
       SUM(e.Oklad + ISNULL(e.Premiya, 0)) AS [Фонд оплаты труда]
FROM Employee e
WHERE e.Namber_otdel IS NOT NULL
GROUP BY e.Namber_otdel
HAVING SUM(e.Oklad) > 90000;

-- Запрос 3. MIN с условием: минимальная цена продукта в мясном отделе.
SELECT MIN(p.Price) AS [Минимальная цена в мясном отделе]
FROM Product p
WHERE p.Namber_otdel = 2;

-- Запрос 4. MIN с группировкой: минимальный оклад по отделам, где он меньше 28000.
SELECT e.Namber_otdel AS [№ отдела], MIN(e.Oklad) AS [Минимальный оклад]
FROM Employee e
WHERE e.Namber_otdel IS NOT NULL
GROUP BY e.Namber_otdel
HAVING MIN(e.Oklad) < 28000;

-- Запрос 5. MAX с условием: максимальная цена продукта в молочном отделе.
SELECT MAX(p.Price) AS [Максимальная цена в молочном отделе]
FROM Product p
WHERE p.Namber_otdel = 1;

-- Запрос 6. MAX с группировкой: максимальная цена по отделам, где она больше 300 рублей.
SELECT p.Namber_otdel AS [№ отдела], MAX(p.Price) AS [Максимальная цена]
FROM Product p
GROUP BY p.Namber_otdel
HAVING MAX(p.Price) > 300;

-- Запрос 7. AVG с условием: средняя цена продуктов хлебобулочного отдела.
SELECT AVG(p.Price) AS [Средняя цена в хлебобулочном отделе]
FROM Product p
WHERE p.Namber_otdel = 3;

-- Запрос 8. AVG с группировкой: средний оклад по отделам, где он больше 30000.
SELECT e.Namber_otdel AS [№ отдела], AVG(e.Oklad) AS [Средний оклад]
FROM Employee e
WHERE e.Namber_otdel IS NOT NULL
GROUP BY e.Namber_otdel
HAVING AVG(e.Oklad) > 30000;

-- Запрос 9. COUNT с условием: количество сотрудников, которым назначена премия, при окладе выше 28000.
SELECT COUNT(e.Premiya) AS [Сотрудников с премией]
FROM Employee e
WHERE e.Oklad > 28000;

-- Запрос 10. COUNT с WHERE, GROUP BY и HAVING: количество продуктов дороже 50 рублей по отделам, где таких продуктов не менее 3.
SELECT p.Namber_otdel AS [№ отдела], COUNT(*) AS [Количество продуктов]
FROM Product p
WHERE p.Price > 50
GROUP BY p.Namber_otdel
HAVING COUNT(*) >= 3;

-- Запрос 11. Статистика по ценам продуктов дороже 50 рублей по отделам (количество, минимум, максимум, среднее, сумма), только отделы не менее чем с тремя такими продуктами.
SELECT p.Namber_otdel AS [№ отдела],
       COUNT(*)     AS [Количество],
       MIN(p.Price) AS [Мин. цена],
       MAX(p.Price) AS [Макс. цена],
       AVG(p.Price) AS [Средняя цена],
       SUM(p.Price) AS [Сумма цен]
FROM Product p
WHERE p.Price > 50
GROUP BY p.Namber_otdel
HAVING COUNT(*) >= 3;

-- Запрос 12. Статистика по сотрудникам отделов (количество, средний оклад, максимальная премия, общая сумма окладов), только отделы со средним окладом выше 28000.
SELECT e.Namber_otdel AS [№ отдела],
       COUNT(e.Id_employee) AS [Сотрудников],
       AVG(e.Oklad)         AS [Средний оклад],
       MAX(e.Premiya)       AS [Макс. премия],
       SUM(e.Oklad)         AS [Сумма окладов]
FROM Employee e
WHERE e.Namber_otdel IS NOT NULL
GROUP BY e.Namber_otdel
HAVING AVG(e.Oklad) > 28000;

-- Запрос 13. Сумма окладов по отделам с названием отдела, определяемым простым CASE.
SELECT CASE e.Namber_otdel
            WHEN 1 THEN N'Молочный'
            WHEN 2 THEN N'Мясной'
            WHEN 3 THEN N'Хлебобулочный'
            WHEN 4 THEN N'Бакалея'
            ELSE N'Без отдела'
       END AS [Отдел],
       SUM(e.Oklad) AS [Сумма окладов]
FROM Employee e
GROUP BY e.Namber_otdel;

-- Запрос 14. Определить ценовую группу отдела по средней цене продуктов (поисковый CASE).
SELECT p.Namber_otdel AS [№ отдела],
       AVG(p.Price) AS [Средняя цена],
       CASE WHEN AVG(p.Price) < 100 THEN N'Недорогие'
            WHEN AVG(p.Price) < 250 THEN N'Средние'
            ELSE N'Дорогие'
       END AS [Ценовая группа]
FROM Product p
GROUP BY p.Namber_otdel;

-- Запрос 15. Сравнить фонд окладов отдела с условным планом 90000 с помощью IIF.
SELECT e.Namber_otdel AS [№ отдела],
       SUM(e.Oklad) AS [Фонд окладов],
       IIF(SUM(e.Oklad) > 90000, N'Выше плана', N'В пределах плана') AS [Оценка]
FROM Employee e
WHERE e.Namber_otdel IS NOT NULL
GROUP BY e.Namber_otdel;
