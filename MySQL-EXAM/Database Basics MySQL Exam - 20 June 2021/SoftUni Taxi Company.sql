#CREATE DATABASE `SoftUni Taxi Company`;
#Section 1: Data Definition Language (DDL)
#1.	Table Design
CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL
);

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(30) NOT NULL,
    `last_name` VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    rating FLOAT
);

CREATE TABLE cars (
    id INT PRIMARY KEY AUTO_INCREMENT,
	make VARCHAR(20) NOT NULL,
    model VARCHAR(20),
    year INT NOT NULL,
    mileage INT,	
    `condition` CHAR NOT NULL,
    category_id INT NOT NULL,
    
    CONSTRAINT fk_cars_cat FOREIGN KEY (category_id)
        REFERENCES categories (`id`)
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    from_address_id INT NOT NULL,
    `start` DATETIME NOT NULL,
    bill DECIMAL(10 , 2 ),
    car_id INT NOT NULL,
    client_id INT NOT NULL,
    CONSTRAINT fk_cou_addresses FOREIGN KEY (from_address_id)
        REFERENCES addresses (`id`),
    CONSTRAINT fk_cou_cars FOREIGN KEY (car_id)
        REFERENCES cars (`id`),
    CONSTRAINT fk_cou_clients FOREIGN KEY (client_id)
        REFERENCES clients (`id`)
);

CREATE TABLE cars_drivers (
    car_id INT NOT NULL,
    driver_id INT NOT NULL,
    CONSTRAINT pk_car_cars PRIMARY KEY (car_id , driver_id),
    CONSTRAINT fk_c_cars FOREIGN KEY (car_id)
        REFERENCES cars (`id`),
    CONSTRAINT fk_c_drivers FOREIGN KEY (driver_id)
        REFERENCES drivers (`id`)
);

#Section 2: Data Manipulation Language (DML)
#2.	Insert
INSERT INTO clients (full_name, phone_number)
SELECT CONCAT(d.first_name, ' ',d.last_name) , CONCAT('(088) 9999', (d.id * 2)) FROM drivers AS d
WHERE d.id BETWEEN 10 AND 20;

#3.	Update
UPDATE cars 
SET 
    `condition` = 'C'
WHERE
    mileage >= 800000
        OR mileage IS NULL AND year <= 2010
        AND make != 'Mercedes-Benz';
        
#4.	Delete
DELETE c FROM clients c
        LEFT JOIN
    courses cs ON c.id = cs.client_id 
WHERE
    cs.client_id IS NULL
    AND CHAR_LENGTH(c.full_name) > 3;

#Section 3: Querying – 50 pts
#5.	Cars
SELECT 
    make, model, `condition`
FROM
    cars
ORDER BY id;

#6.	Drivers and Cars
SELECT 
    d.first_name, d.last_name, c.make, c.model, c.mileage
FROM
    drivers d
        JOIN
    cars_drivers cd ON cd.driver_id = d.id
        JOIN
    cars c ON c.id = cd.car_id
WHERE
    c.mileage IS NOT NULL
ORDER BY c.mileage DESC , d.first_name;

#7.	Number of courses for each car
SELECT c.id, c.make, c.mileage, COUNT(cs.car_id) AS count_of_courses, 
ROUND(SUM(cs.bill) / COUNT(cs.car_id), 2) AS avg_bill
FROM cars c
LEFT JOIN courses cs ON cs.car_id = c.id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, c.id;

#8.	Regular clients
SELECT 
    cl.full_name,
    COUNT(cs.client_id) AS count_of_cars,
    SUM(cs.bill) AS total_sum
FROM
    clients AS cl
        JOIN
    courses cs ON cl.id = cs.client_id
        JOIN
    cars c ON cs.car_id = c.id
GROUP BY client_id
HAVING cl.full_name LIKE '_a%'
    AND count_of_cars > 1
ORDER BY full_name;

#9.	Full information of courses
SELECT 
    a.name,
    (CASE
        WHEN HOUR(cs.start) BETWEEN 6 AND 20 THEN 'Day'
        ELSE 'Night'
    END) AS day_time,
    cs.bill,
    cl.full_name,
    c.make,
    c.model,
    cat.name AS category_name
FROM
    addresses a
        JOIN
    categories cat
        JOIN
    cars c ON c.category_id = cat.id
        JOIN
    courses cs ON cs.car_id = c.id
        AND cs.from_address_id = a.id
        JOIN
    clients cl ON cs.client_id = cl.id
ORDER BY cs.id;

#Section 4: Programmability – 30 pts
#10.Find all courses by client’s phone number
DELIMITER %%
CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(cs.client_id) AS count FROM courses cs
JOIN clients cl ON cs.client_id = cl.id
WHERE cl.phone_number = phone_num
);
END %%
SELECT udf_courses_by_client ('(803) 6386812') AS count;

#11.Full info for address
DELIMITER %%
CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN 
SELECT a.name, cl.full_name, 
(CASE
        WHEN cs.bill <= 20 THEN 'Low'
        WHEN cs.bill <= 30 THEN 'Medium'
        WHEN cs.bill > 30 THEN 'High'
        
    END) AS level_of_bill , c.make, c.`condition`, cat.name
    FROM addresses a
    JOIN courses cs ON cs.from_address_id = a.id
    JOIN clients cl ON cs.client_id = cl.id
    JOIN cars c ON cs.car_id = c.id
    JOIN categories cat ON c.category_id = cat.id
	WHERE a.name = address_name
    ORDER BY c.make, cl.full_name;
END %%
CALL udp_courses_by_address('700 Monterey Avenue');



























