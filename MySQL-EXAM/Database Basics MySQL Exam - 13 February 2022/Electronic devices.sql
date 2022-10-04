#CREATE DATABASE `electronic devices`;
#Section 1: Data Definition Language (DDL)
#01.Table Design
CREATE TABLE brands (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    content TEXT,
    rating DECIMAL(10,2) NOT NULL,
    picture_url VARCHAR(80) NOT NULL,
    published_at DATETIME NOT NULL
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL,
    price DECIMAL(19 , 2 ) NOT NULL,
    quantity_in_stock INT,
    description TEXT,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    review_id INT NOT NULL,
    CONSTRAINT `fk_products_brands` FOREIGN KEY (`brand_id`)
        REFERENCES brands (`id`),
    CONSTRAINT `fk_products_categories` FOREIGN KEY (`category_id`)
        REFERENCES categories (`id`),
    CONSTRAINT `fk_products_reviews` FOREIGN KEY (`review_id`)
        REFERENCES reviews (`id`)
);

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    phone VARCHAR(30) UNIQUE NOT NULL,
    address VARCHAR(60) NOT NULL,
    discount_card BIT(1) NOT NULL
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_datetime DATETIME NOT NULL,
    customer_id INT NOT NULL,
    
    CONSTRAINT `fk_ordesr_customers` FOREIGN KEY (`customer_id`)
        REFERENCES customers (`id`)
);

CREATE TABLE orders_products (
    order_id INT,
    product_id INT,
    KEY pk_ord_orders (`order_id` , `product_id`),
    CONSTRAINT fk_op_orders FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`id`),
    CONSTRAINT fk_op_products FOREIGN KEY (`product_id`)
        REFERENCES `products` (`id`)
);

#Section 2: Data Manipulation Language (DML) 

#02.Insert
INSERT INTO reviews (content, picture_url, published_at, rating)
SELECT LEFT(p.description , 15) , REVERSE(p.name), DATE('2010-10-10'), p.price / 8 FROM products AS p
WHERE p.id >= 5;

#03.Update
UPDATE products 
SET 
    quantity_in_stock = quantity_in_stock - 5
WHERE
    quantity_in_stock BETWEEN 60 AND 70;
    
#04.Delete
DELETE c FROM customers AS c
        LEFT JOIN
    orders AS o ON c.id = o.customer_id 
WHERE
    o.customer_id IS NULL;
    
#Section 3: Querying – 50 pts

#05.Categories
SELECT id, `name` FROM categories
ORDER BY `name` DESC;

#06.Quantity
SELECT id, brand_id, name, quantity_in_stock FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

#07.Review
SELECT id, content, rating, picture_url, published_at FROM reviews
WHERE content LIKE 'My%' AND CHAR_LENGTH(content) > 61
ORDER BY rating DESC;

#08.First customers
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.address,
    o.order_datetime
FROM
    customers AS c
        JOIN
    orders AS o ON c.id = o.customer_id
WHERE
    YEAR(o.order_datetime) <= 2018
ORDER BY full_name DESC;

#09.Best categories
SELECT 
    COUNT(p.category_id) AS items_count,
    c.name,
    SUM(p.quantity_in_stock) AS total_quantity
FROM
    products AS p
        JOIN
    categories AS c ON p.category_id = c.id
    GROUP BY c.id
    ORDER BY items_count DESC, total_quantity
LIMIT 5;

#Section 4: Programmability – 30 pts

#10.Extract client cards count
DELIMITER %%
CREATE FUNCTION udf_customer_products_count(name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN(
SELECT COUNT(o.customer_id) FROM orders AS o
JOIN customers AS c ON c.id = o.customer_id
JOIN orders_products AS op ON op.order_id = o.id
WHERE c.first_name = name);

END %%
#SELECT udf_customer_products_count('Shirley');
SELECT c.first_name,c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';

#11.Reduce price
DELIMITER %%
CREATE PROCEDURE udp_reduce_price(category_name VARCHAR(50))
BEGIN 
UPDATE products AS p
JOIN reviews AS r ON p.review_id = r.id
JOIN categories AS c ON c.id = p.category_id
SET p.price = p.price * 0.7
WHERE r.rating < 4 AND c.name LIKE category_name;
END %%
DELIMITER ;
CALL udp_reduce_price ('Phones and tablets');










