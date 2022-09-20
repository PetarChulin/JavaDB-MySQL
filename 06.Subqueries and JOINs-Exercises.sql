#1.	Employee Address
SELECT 
    e.employee_id, e.job_title, a.address_id, a.address_text
FROM
    employees AS e
        JOIN
    addresses AS a
WHERE
    a.address_id = e.address_id
ORDER BY address_id
LIMIT 5;

#2.	Addresses with Towns
SELECT 
    e.first_name, e.last_name, t.`name`, a.address_text
FROM
    employees AS e
        JOIN
    towns AS t
        JOIN
    addresses AS a
WHERE
    a.address_id = e.address_id AND t.town_id = a.town_id
ORDER BY first_name , last_name
LIMIT 5;

#3.	Sales Employee
SELECT e.employee_id, e.first_name, e.last_name, d.`name` AS department_name
FROM employees AS e
JOIN departments AS d
WHERE 
	e.department_id = d.department_id AND d.`name` = "Sales"
    ORDER BY employee_id desc;

#4.	Employee Departments
SELECT 
    e.employee_id,
    e.first_name,
    e.salary,
    d.`name` AS department_name
FROM
    employees AS e
        JOIN
    departments AS d
WHERE
    e.department_id = d.department_id
        AND salary > 15000
ORDER BY d.department_id DESC
LIMIT 5;

#5.	Employees Without Project
SELECT 
    e.employee_id, e.first_name
FROM
    employees AS e
        LEFT JOIN
    employees_projects AS p ON e.employee_id = p.employee_id
WHERE p.project_id IS NULL
ORDER BY employee_id DESC
LIMIT 3;

# 6.Employees Hired After
SELECT e.first_name, e.last_name, e.hire_date, d.`name` AS dept_name
FROM employees AS e
JOIN departments AS d ON e.department_id = d.department_id
WHERE e.hire_date > '1999-01-01'  AND d.`name` = 'Sales' OR d.`name` = 'Finance'
ORDER BY hire_date;

#7.	Employees with Project
SELECT 
    e.employee_id, e.first_name, p.`name` AS project_name
FROM
    employees AS e
        JOIN
    employees_projects AS ep ON e.employee_id = ep.employee_id
        JOIN
    projects AS p ON p.project_id = ep.project_id
AND
    DATE(p.start_date) > '2002-08-13' AND p.end_date IS NULL                
ORDER BY e.first_name , p.`name`
LIMIT 5;

#8.	Employee 24
SELECT e.employee_id, e.first_name, if(YEAR(p.start_date) >= '2005', NULL , p.`name`) 
AS project_name
	FROM employees AS e 
    JOIN employees_projects AS ep
    ON ep.employee_id = e.employee_id
    JOIN projects AS p 
    ON p.project_id = ep.project_id
    WHERE e.employee_id = 24
    
    ORDER BY project_name;
    

#9.	Employee Manager
SELECT 
    e.employee_id,
    e.first_name,
    e.manager_id,
    m.first_name AS manager_name
FROM
    employees AS e
        JOIN
    employees AS m ON e.manager_id = m.employee_id
        AND e.manager_id IN (3 , 7)
ORDER BY first_name;

#10.Employee Summary
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    d.`name` AS department_name
FROM
    employees AS e
        JOIN
    employees AS m
        JOIN
    departments AS d ON e.manager_id = m.employee_id
        AND e.department_id = d.department_id
ORDER BY employee_id
LIMIT 5;

#11.Min Average Salary
SELECT 
    AVG(salary) AS min_average_salary
FROM
    employees
GROUP BY department_id
ORDER BY min_average_salary
LIMIT 1;

#12.Highest Peaks in Bulgaria
SELECT 
    mc.country_code, m.mountain_range, p.peak_name, p.elevation
FROM
    mountains_countries AS mc
        JOIN
    countries AS c ON c.country_code = mc.country_code
        JOIN
    peaks AS p
        RIGHT JOIN
    mountains AS m ON m.id = mc.mountain_id
        AND p.mountain_id = m.id
WHERE
    c.country_name = 'Bulgaria'
        AND p.elevation > 2835
ORDER BY elevation DESC;

#13.Count Mountain Ranges
SELECT 
    mc.country_code, COUNT(m.mountain_range) AS mountain_range
FROM
    mountains_countries AS mc
        JOIN
    countries AS c ON c.country_code = mc.country_code
        JOIN
    mountains AS m ON m.id = mc.mountain_id

        WHERE c.country_name IN ('Bulgaria', 'Russia', 'United States')
        GROUP BY mc.country_code
        ORDER BY mountain_range DESC;
       
#14.Countries with Rivers
SELECT 
    c.country_name, r.river_name
FROM
    continents AS ct
        JOIN
    countries AS c ON c.continent_code = ct.continent_code
        LEFT JOIN
    countries_rivers AS cr ON cr.country_code = c.country_code
        LEFT JOIN
    rivers AS r ON r.id = cr.river_id
WHERE
    ct.continent_name = 'Africa'
ORDER BY c.country_name
LIMIT 5;  

#15.*Continents and Currencies
SELECT 
    c.continent_code,
    c.currency_code,
    COUNT(currency_code) AS currency_usage
FROM
    countries AS c
GROUP BY c.currency_code , c.continent_code
HAVING currency_usage > 1
    AND currency_usage = (SELECT 
        COUNT(currency_code) AS most_used
    FROM
        countries AS a
    WHERE
        c.continent_code = a.continent_code
    GROUP BY a.currency_code
    ORDER BY most_used DESC
    LIMIT 1)
ORDER BY continent_code, currency_code;

#16. Countries Without Any Mountains
SELECT 
    COUNT(c.country_code) AS country_count
FROM
    countries AS c
        LEFT JOIN
    mountains_countries AS mc ON c.country_code = mc.country_code
        LEFT JOIN
    mountains AS m ON m.id = mc.mountain_id
WHERE
    m.mountain_range IS NULL;
    
   


























