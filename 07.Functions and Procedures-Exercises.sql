#1.	Employees with Salary Above 35000
DELIMITER %%
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
SELECT first_name, last_name FROM employees
WHERE salary > 35000 
ORDER BY first_name, last_name, employee_id;
END %%
CALL usp_get_employees_salary_above_35000();

#2. Employees with Salary Above Number
DELIMITER %%
CREATE PROCEDURE usp_get_employees_salary_above(searched DECIMAL(10,4))
BEGIN
SELECT first_name, last_name FROM employees
WHERE salary >= searched
ORDER BY first_name, last_name, employee_id;
END %%
CALL usp_get_employees_salary_above(45000.0000);

#3.	Town Names Starting With
DELIMITER %%
CREATE PROCEDURE usp_get_towns_starting_with(searched VARCHAR(10))
BEGIN
SELECT `name` AS town_name FROM towns
WHERE `name` LIKE CONCAT(searched, '%')
ORDER BY town_name;
END %%
CALL usp_get_towns_starting_with('b');

#4.	Employees from Town
DELIMITER %%
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
SELECT e.first_name, e.last_name FROM employees AS e
JOIN addresses AS a ON a.address_id = e.address_id
JOIN towns AS t ON a.town_id = t.town_id
WHERE t.`name` = town_name
ORDER BY first_name, last_name, employee_id;
END %%
CALL usp_get_employees_from_town('Sofia');

#5.	Salary Level Function
DELIMITER %%
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(10,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
RETURN ( 
 (CASE
	WHEN salary < 30000 THEN 'Low'
    WHEN salary BETWEEN 30000 AND 50000 THEN 'Average'
    WHEN salary > 50000 THEN 'High'
END ));
END %%
SELECT ufn_get_salary_level(40000) AS salary_Level;

#6.	Employees by Salary Level
DELIMITER %%
CREATE PROCEDURE usp_get_employees_by_salary_level(salaryL VARCHAR(10))
BEGIN
SELECT first_name, last_name FROM employees
WHERE
(CASE 
	WHEN salaryL LIKE 'Low' THEN salary < 30000
    WHEN salaryL LIKE 'Average' THEN salary BETWEEN 30000 AND 50000  
    WHEN salaryL LIKE 'High' THEN salary > 50000  
END)
ORDER BY first_name DESC, last_name DESC;
END %%
CALL usp_get_employees_by_salary_level('High');

#7.	Define Function
DELIMITER %%
CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN(
SELECT LOWER(word) REGEXP(CONCAT('^[',set_of_letters,']+$')));
END %%
SELECT UFN_IS_WORD_COMPRISED('oistmiahf', 'asd') AS result;

#08. Find Full Name
DELIMITER %%
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN 
SELECT (CONCAT(first_name,' ', last_name)) AS full_name FROM account_holders
ORDER BY full_name,id;
END %%
CALL usp_get_holders_full_name();

#9. People with Balance Higher Than
DELIMITER %%
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(`number` INT)
BEGIN 
SELECT ah.first_name, ah.last_name FROM account_holders ah
JOIN accounts a ON ah.id = a.account_holder_id
GROUP BY ah.id
HAVING SUM(a.balance) > `number`
ORDER BY a.account_holder_id;
END %%
CALL usp_get_holders_with_balance_higher_than (7000);

#10.Future Value Function
DELIMITER %%
CREATE FUNCTION ufn_calculate_future_value(`sum` DECIMAL(10,4), yearly_interest_rate DOUBLE, years INT)
RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
RETURN (SELECT (`sum` *(POWER((1 + yearly_interest_rate), years))));
END %%
SELECT ufn_calculate_future_value(1000, 0.5, 5) AS output;

#11.Calculating Interest ?? 50/100
DELIMITER %%
CREATE PROCEDURE usp_calculate_future_value_for_account(id INT, interest_rate DECIMAL(19,4))
BEGIN 
SELECT ah.id AS id, ah.first_name, ah.last_name, a.balance, 
CAST(ROUND(a.balance * (POWER((1 + interest_rate),5)), 4) AS CHAR) AS balance_in_5_years FROM account_holders ah
JOIN accounts a ON a.account_holder_id = ah.id
WHERE ah.id = id
LIMIT 1;

END %%
CALL usp_calculate_future_value_for_account(1, 0.1);

#12.Deposit Money
DELIMITER %%
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(10,4))	
BEGIN 
START TRANSACTION;
IF(money_amount > 0) THEN
UPDATE accounts SET balance = balance + money_amount
WHERE account_id = id;
ELSE
ROLLBACK;
END IF;
END %%
CALL usp_deposit_money(1,10);

#13. Withdraw Money
DELIMITER %%
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DOUBLE)	
BEGIN 
START TRANSACTION;
IF(money_amount > 0) THEN
UPDATE accounts SET balance = balance - money_amount
WHERE account_id = id AND balance > money_amount;
ELSE
ROLLBACK;
END IF;
END %%
CALL usp_withdraw_money(1, 10);

#14.Money Transfer
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DOUBLE)
BEGIN 
START TRANSACTION;
IF(amount > 0 AND (from_account_id IS NOT NULL OR to_account_id IS NOT NULL) AND from_account_id != to_account_id) THEN
UPDATE accounts a 
JOIN accounts b 
SET a.balance = a.balance - amount, b.balance = b.balance + amount
WHERE a.id = from_account_id AND b.id = to_account_id AND a.balance > amount;
ELSE
ROLLBACK;
END IF;
END %%
CALL usp_transfer_money(2, 1, 10); 

#15. Log Accounts Trigger
CREATE TABLE `logs` (
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT,
old_sum DECIMAL(19,4),
new_sum DECIMAL(19,4)
);

CREATE TRIGGER Log_Accounts 
AFTER UPDATE
ON accounts
FOR EACH ROW
BEGIN

INSERT INTO `logs`(account_id, old_sum, new_sum)
VALUES (OLD.id, OLD.balance, NEW.balance);
END;
































