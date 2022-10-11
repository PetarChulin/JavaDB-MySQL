#CREATE DATABASE `Royal United Kingsman – Bank`;
#1.	Section 1: Data Definition Language (DDL) 
#01. Table Design 

CREATE TABLE clients (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
age INT(11) NOT NULL
);

CREATE TABLE bank_accounts (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
account_number VARCHAR(10) NOT NULL,
balance DECIMAL(10,2) NOT NULL,
client_id INT(11) UNIQUE NOT NULL,

CONSTRAINT fk_ba_c FOREIGN KEY (client_id)
        REFERENCES clients (`id`)
);

CREATE TABLE cards (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
card_number VARCHAR(19) NOT NULL,
card_status VARCHAR(7) NOT NULL,
bank_account_id INT(11)  NOT NULL,

CONSTRAINT fk_c_ba FOREIGN KEY (bank_account_id)
        REFERENCES bank_accounts (`id`)
);


CREATE TABLE branches (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE employees (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) NOT NULL,
started_on 	DATE NOT NULL,
branch_id INT(11),

CONSTRAINT fk_e_b FOREIGN KEY (branch_id)
        REFERENCES branches (`id`)
);

CREATE TABLE employees_clients (
employee_id INT(11),
client_id INT(11),

CONSTRAINT fk_ec_e FOREIGN KEY (employee_id)
        REFERENCES employees (`id`),
CONSTRAINT fk_e_c FOREIGN KEY (client_id)
        REFERENCES clients (`id`)
);

#2.	Section 2: Data Manipulation Language (DML) 
#2. Insert
INSERT INTO cards (card_number, card_status, bank_account_id) 
SELECT REVERSE(c.full_name), 'Active', c.id FROM clients c
WHERE c.id BETWEEN 191 AND 200;

#03. Update 
UPDATE employees_clients as ec
JOIN
(SELECT ec1.employee_id, COUNT(ec1.client_id) AS 'count'
		FROM employees_clients as ec1 
		GROUP BY ec1.employee_id
		ORDER BY `count`, ec1.employee_id) AS s
SET ec.employee_id = s.employee_id
WHERE ec.employee_id = ec.client_id;

#04.Delete
DELETE e FROM employees e
        LEFT JOIN
    employees_clients ec ON e.id = ec.employee_id 
WHERE
    ec.client_id IS NULL;

#3.	Section 3: Querying – 50 pts
#05.Clients
SELECT id, full_name FROM clients
ORDER BY id;

#06.Newbies
SELECT 
    id,
    CONCAT(first_name, ' ', last_name),
    CONCAT('$', salary),
    started_on
FROM
    employees
WHERE
    salary >= 100000
        AND started_on >= '2018-01-01'
ORDER BY salary DESC , id;

#07.Cards against Humanity
SELECT 
    ca.id,
    CONCAT_WS(' ', ca.card_number, ':', c.full_name) AS card_token
FROM
    cards ca
        LEFT JOIN
    bank_accounts ba ON ca.bank_account_id = ba.id
        LEFT JOIN
    clients c ON c.id = ba.client_id
ORDER BY ca.id DESC;

#08. Top 5 Employees 
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS `name`,
    e.started_on,
    COUNT(ec.client_id) AS count_of_clients
FROM
    employees e
        JOIN
    employees_clients ec ON ec.employee_id = e.id
GROUP BY e.id
ORDER BY count_of_clients DESC , e.id
LIMIT 5;

#09.Branch cards
SELECT 
    b.name, COUNT(ca.card_number) AS count_of_cards
FROM
    branches b
        LEFT JOIN
    employees e ON e.branch_id = b.id
        LEFT JOIN
    employees_clients ec ON ec.employee_id = e.id
        LEFT JOIN
    bank_accounts ba ON ba.client_id = ec.client_id
        LEFT JOIN
    cards ca ON ca.bank_account_id = ba.id
GROUP BY b.name
ORDER BY count_of_cards DESC , b.name;

#4.	Section 4: Programmability – 30 pts
#10.Extract client cards count
DELIMITER %%
CREATE FUNCTION udf_client_cards_count(name VARCHAR(30)) 
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(ca.id) AS `cards` FROM clients c
LEFT JOIN bank_accounts ba ON c.id = ba.client_id
LEFT JOIN cards ca ON ca.bank_account_id = ba.id
WHERE c.full_name = name
);
END %%
SELECT c.full_name, udf_client_cards_count('Baxy David') as `cards` FROM clients c
WHERE c.full_name = 'Baxy David';

#11.Extract Client Info
DELIMITER %%
CREATE PROCEDURE udp_clientinfo(full_name VARCHAR(100))
BEGIN 
	SELECT c.full_name, c.age, ba.account_number, CONCAT('$', ba.balance) AS balance FROM clients c
    JOIN bank_accounts ba ON ba.client_id = c.id
    WHERE c.full_name = full_name;
    END %%
CALL udp_clientinfo ('Hunter Wesgate');





