-- 1
select first_name, last_name from employees
where first_name LIKE 'Sa%'
order by employee_id;

-- 2
select first_name, last_name from employees
where last_name LIKE '%ei%'
order by employee_id;

-- 3
select first_name from employees
where department_id in (3,10) and
year(hire_date) between 1995 and 2005
order by employee_id;

-- 4
select first_name, last_name from employees
where job_title not like '%engineer%'
order by employee_id;

-- 5
select `name` from towns as `name`
where char_length(`name`) = 6 or char_length(`name`) = 5
order by `name` asc;

-- 6
select * from towns
where `name` like ('m%') or `name` like ('k%') or `name` like ('b%') or `name` like ('e%')
order by `name` asc;

-- 7
select * from towns
where `name` not like ('r%') and `name` not like ('b%') and `name` not like ('d%')
order by `name` asc;

-- 8
create view `v_employees_hired_after_2000` as
select `first_name`, `last_name` from `employees`
where year(`hire_date`) > 2000;
select * from `v_employees_hired_after_2000`;

-- 9
select first_name, last_name from employees
where char_length(last_name) = 5;

-- 10
select country_name, iso_code from countries
where country_name like '%a%a%a%'
order by iso_code asc;

-- 11
SELECT 
    peak_name,
    river_name,
    CONCAT(LOWER(peak_name), substring(lower(river_name),2)) AS mix
FROM
    peaks,
    rivers
WHERE
    RIGHT(peak_name, 1) = LEFT(LOWER(river_name), 1)
ORDER BY mix;

-- 12
select `name`, date_format(`start`, '%Y-%m-%d') as `start` from games
where year(`start`) between 2011 and 2012
order by `start`, `name` limit 50;

-- 13
select user_name, substring(email, locate('@', email)+1) as `email provider` from users
order by `email provider`, user_name;

-- 14
select user_name,ip_address from users
where ip_address like '___.1%.%.___'
order by user_name;

-- 15
SELECT 
    `name`,
    (CASE
        WHEN HOUR(`start`) BETWEEN 0 AND 11 THEN 'Morning'
        WHEN HOUR(`start`) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(`start`) BETWEEN 18 AND 23 THEN 'Evening'
    END) AS 'Parts of the day',
    (CASE
        WHEN duration <= 3 THEN 'Extra Short'
        WHEN duration BETWEEN 3 AND 6 THEN 'Short'
        WHEN duration BETWEEN 6 AND 10 THEN 'Long'
        WHEN duration > 10 OR duration IS NULL THEN 'Extra Long'
    END) AS Duration
FROM
    games;
    
-- 16
SELECT product_name, order_date, DATE_ADD(`order_date`, INTERVAL 3 DAY) 
AS pay_due, DATE_ADD(`order_date`, INTERVAL 1 MONTH) 
AS deliver_due from orders;




    































