#CREATE DATABASE `Triple S – SoftUni Stores System`;
#Section 1: Data Definition Language (DDL)
#1.	Table Design
CREATE TABLE pictures (
    id INT PRIMARY KEY AUTO_INCREMENT,
    url VARCHAR(100) NOT NULL,
    added_on DATETIME NOT NULL

);

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) UNIQUE NOT NULL,
    best_before DATE,
    price DECIMAL(10,2) NOT NULL,
    `description` TEXT,
    category_id INT NOT NULL,
    picture_id INT NOT NULL,
    CONSTRAINT fk_prod_categories FOREIGN KEY (category_id)
        REFERENCES categories (`id`),
	CONSTRAINT fk_prod_pictures FOREIGN KEY (picture_id)
        REFERENCES pictures (`id`)
);

CREATE TABLE towns (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    town_id INT NOT NULL,
    CONSTRAINT fk_add_towns FOREIGN KEY (town_id)
        REFERENCES towns (`id`)
);

CREATE TABLE stores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) UNIQUE NOT NULL,
    rating FLOAT NOT NULL,
    has_parking TINYINT(1),
    address_id INT NOT NULL,
    CONSTRAINT fk_stores_addresses FOREIGN KEY (address_id)
        REFERENCES addresses (`id`)
);

CREATE TABLE products_stores (
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    CONSTRAINT pk_ps_ps PRIMARY KEY (product_id , store_id),
    CONSTRAINT fk_ps_prod FOREIGN KEY (product_id)
        REFERENCES products (`id`),
    CONSTRAINT fk_ps_stores FOREIGN KEY (store_id)
        REFERENCES stores (`id`)
);

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(15) NOT NULL,
    middle_name CHAR(1),
    last_name VARCHAR(20) NOT NULL,
    salary DECIMAL(19, 2) NOT NULL,
    hire_date DATE NOT NULL,
    manager_id INT,
    store_id INT NOT NULL,
    CONSTRAINT fk_emp_stores FOREIGN KEY (store_id)
        REFERENCES stores (`id`),
	CONSTRAINT fk_emp_emp FOREIGN KEY (manager_id)
        REFERENCES employees (`id`)
);

#Section 2: Data Manipulation Language (DML)
#2.	Insert
INSERT INTO products_stores (product_id, store_id)
SELECT p.id, 1 FROM products p
LEFT JOIN products_stores ps ON ps.product_id = p.id
LEFT JOIN stores s ON s.id = ps.store_id
WHERE ps.product_id IS NULL;

#3.	Update
UPDATE employees 
SET 
    manager_id = 3,
    salary = salary - 500
WHERE
    YEAR(hire_date) > 2003
        AND store_id NOT IN (5 , 14);
        
#4.	Delete
DELETE e FROM employees e 
WHERE
    e.manager_id IS NOT NULL
    AND e.salary >= 6000;

#Section 3: Querying – 50 pts
#5.	Employees 
SELECT first_name, middle_name, last_name, salary, hire_date FROM employees
ORDER BY hire_date DESC;

#6.	Products with old pictures
SELECT 
    p.name,
    p.price,
    p.best_before,
    CONCAT(LEFT(`description`, 10), '...') AS short_description,
    pi.url
FROM
    products p
        JOIN
    pictures pi ON pi.id = p.picture_id
WHERE
    CHAR_LENGTH(p.`description`) > 100
        AND YEAR(pi.added_on) < 2019
        AND p.price > 20
ORDER BY p.price DESC;

#7.	Counts of products in stores and their average 
SELECT 
    s.name,
    COUNT(ps.product_id) AS product_count,
    ROUND(SUM(p.price) / COUNT(ps.product_id), 2) AS `avg`
FROM
    stores s
        LEFT JOIN
    products_stores ps ON ps.store_id = s.id
        LEFT JOIN
    products p ON p.id = ps.product_id
GROUP BY s.name
ORDER BY product_count DESC , `avg` DESC , s.id;

#8.	Specific employee
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS Full_name,
    s.name AS Store_name,
    a.name,
    e.salary
FROM
    employees e
        JOIN
    stores s ON e.store_id = s.id
        JOIN
    addresses a ON s.address_id = a.id
WHERE
    e.salary < 4000 AND a.name LIKE '%5%'
        AND CHAR_LENGTH(s.name) > 8
        AND e.last_name LIKE '%n';

#09. Find all information of stores 
SELECT 
    REVERSE(s.name) AS reversed_name,
    CONCAT(UPPER(t.name), '-', a.name) AS full_address,
    COUNT(e.store_id) AS employees_count
FROM
    stores s
        JOIN
    towns t
        JOIN
    addresses a ON a.town_id = t.id AND s.address_id = a.id
        JOIN
    employees e ON e.store_id = s.id
GROUP BY s.name
HAVING employees_count >= 1
ORDER BY full_address;

#Section 4: Programmability – 30 pts
#10. Find name of top paid employee by store name
DELIMITER %%
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS TEXT
DETERMINISTIC
BEGIN
RETURN (SELECT CONCAT(e.first_name,' ', e.middle_name,'.', ' ', e.last_name,' works in store for ', 
TIMESTAMPDIFF(YEAR, e.hire_date, '2020-10-18'), ' years') AS full_info FROM employees AS e
JOIN stores s ON s.id = e.store_id 
WHERE s.name = store_name
ORDER BY e.salary DESC
LIMIT 1);
END %%
SELECT udf_top_paid_employee_by_store('Keylex');

#11.	Update product price by address
DELIMITER %%
CREATE PROCEDURE udp_update_product_price(address_name VARCHAR (50))
BEGIN 
UPDATE products p 
JOIN products_stores ps ON ps.product_id = p.id
JOIN stores s ON ps.store_id = s.id
JOIN addresses a ON s.address_id = a.id
SET p.price = CASE
        WHEN a.name LIKE '0%'
        THEN p.price + 100
        ELSE p.price + 200
    END
WHERE a.name = address_name;
END %%
CALL udp_update_product_price('1 Cody Pass');
SELECT name, price FROM products WHERE id = 17;











