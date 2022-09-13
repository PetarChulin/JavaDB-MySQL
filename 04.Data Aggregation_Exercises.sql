#1.	 Records' Count
SELECT COUNT(*) FROM wizzard_deposits;

#2.	 Longest Magic Wand
SELECT max(magic_wand_size) FROM wizzard_deposits;

#3. Longest Magic Wand Per Deposit Groups
select deposit_group,  max(magic_wand_size) as longest_magic_wand from wizzard_deposits
group by (deposit_group)
order by longest_magic_wand asc, deposit_group asc;

#4. Smallest Deposit Group Per Magic Wand Size* ??
select deposit_group
from wizzard_deposits
group by deposit_group
order by avg(magic_wand_size)
limit 1;

#5.	 Deposits Sum
select deposit_group, sum(deposit_amount) as total_sum from wizzard_deposits
group by deposit_group
order by total_sum;

#6. Deposits Sum for Ollivander Family
select deposit_group, sum(deposit_amount) as total_sum from wizzard_deposits
where magic_wand_creator = 'Ollivander Family'
group by deposit_group
order by deposit_group;

#7.	Deposits Filter
select deposit_group, sum(deposit_amount) as total_sum from wizzard_deposits
where magic_wand_creator = 'Ollivander Family'
group by deposit_group
having total_sum < 150000
order by total_sum desc;

#8. Deposit Charge
select deposit_group, magic_wand_creator, min(deposit_charge) as min_deposit_charge 
from wizzard_deposits
group by deposit_group, magic_wand_creator
order by  magic_wand_creator, deposit_group;

#9. Age Groups
select (CASE
        WHEN age BETWEEN 0 AND 10 THEN '[0-10]'
        WHEN age BETWEEN 11 AND 20 THEN '[11-20]'
        WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
        WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
        WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
        WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
        WHEN age >= 61 THEN '[61+]'
    END) as age_group, count(age) as wizard_count from wizzard_deposits
    group by age_group
    order by age_group;
    
#10. First Letter
select left(first_name, 1) as first_letter from wizzard_deposits
where deposit_group = 'Troll Chest'
group by first_letter
order by first_letter;

#11. Average Interest 
select deposit_group,is_deposit_expired, avg(deposit_interest) as average_interest  
from wizzard_deposits
where deposit_start_date > '1985-01-01'
group by deposit_group, is_deposit_expired
order by deposit_group desc, is_deposit_expired;

#12. Employees Minimum Salaries
select department_id, min(salary) as minimum_salary from employees
where department_id in (2,5,7) and hire_date > '2000-01-01'
group by department_id
order by department_id;

#13. Employees Average Salaries
create table HighPaid as
select * from employees
where salary > 30000 and manager_id != 42;

UPDATE HighPaid 
SET 
    salary = salary + 5000
WHERE
    department_id = 1;

SELECT 
    department_id, AVG(salary) AS avg_salary
FROM
    HighPaid
GROUP BY department_id
ORDER BY department_id;

#14. Employees Maximum Salaries
select department_id, max(salary) as max_salary from employees
group by department_id
having max_salary not between 30000 and 70000
order by department_id;

#15. Employees Count Salaries
select count(manager_id is null) - count(manager_id) as `` from employees;

#16. 3rd Highest Salary*
select e.department_id,
(
	select distinct a.salary
	from employees as a
    where a.department_id = e.department_id
	order by a.salary desc
	limit 1 offset 2
) 
as third_highest_salary from employees as e
group by e.department_id
having third_highest_salary is not null
order by e.department_id;

#17. Salary Challenge**
select e.first_name, e.last_name, e.department_id 
from employees as e
where e.salary > (
	select avg(a.salary) from employees as a
    where a.department_id = e.department_id
)
order by e.department_id , e.employee_id
limit 10;

#18. Departments Total Salaries
SELECT 
    e.department_id,
    (SELECT 
            SUM(a.salary)
        FROM
            employees AS a
        WHERE
            a.department_id = e.department_id) AS total_salary
FROM
    employees AS e
GROUP BY e.department_id
ORDER BY e.department_id;


























