CREATE DATABASE `Insta Influencers`;
#Section 1: Data Definition Language (DDL)
#01.Table Design
CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    password VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL,
    age INT NOT NULL,
    job_title VARCHAR(40) NOT NULL,
    ip VARCHAR(30) NOT NULL
);

CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(30) NOT NULL,
    town VARCHAR(30) NOT NULL,
    country VARCHAR(30) NOT NULL,
    user_id INT NOT NULL,
    
    CONSTRAINT fk_add_users FOREIGN KEY (user_id)
        REFERENCES users (`id`)
);

CREATE TABLE photos (
    id INT PRIMARY KEY,
    `description` TEXT NOT NULL,
    `date` DATETIME NOT NULL,
    views INT NOT NULL
);

CREATE TABLE comments (
    id INT PRIMARY KEY,
    `comment` VARCHAR(255) NOT NULL,
    `date` DATETIME NOT NULL,
    photo_id INT NOT NULL,
    CONSTRAINT fk_comm_photos FOREIGN KEY (photo_id)
        REFERENCES photos (`id`)
);

CREATE TABLE users_photos (
    user_id INT NOT NULL,
    photo_id INT NOT NULL,
    KEY pk (user_id , photo_id),
    CONSTRAINT fk_u_users FOREIGN KEY (user_id)
        REFERENCES users (`id`),
	CONSTRAINT fk_u_photos FOREIGN KEY (photo_id)
        REFERENCES photos (`id`)
);

CREATE TABLE likes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    photo_id INT NOT NULL,
    user_id INT NOT NULL,
    CONSTRAINT fk_users FOREIGN KEY (user_id)
        REFERENCES users (`id`),
    CONSTRAINT fk_photos FOREIGN KEY (photo_id)
        REFERENCES photos (`id`)
);

#Section 2: Data Manipulation Language (DML) 
#02.Insert
INSERT INTO addresses (address , town, country, user_id)
SELECT u.username, u.password, u.ip, u.age FROM users AS u
WHERE u.gender LIKE 'M';

#03.Update
UPDATE addresses AS a 
SET 
    a.country = IF(a.country LIKE 'B%',
        'Blocked',
        a.country),
    a.country = IF(a.country LIKE 'T%',
        'Test',
        a.country),
    a.country = IF(a.country LIKE 'P%',
        'In Progress',
        a.country);

#04.Delete
DELETE a FROM addresses a 
WHERE
    id % 3 = 0;
    
#Section 3: Querying – 50 Pts
#05.Users
SELECT 
    username, gender, age
FROM
    users
ORDER BY age DESC , username;

#06. Extract 5 most commented photos 
SELECT 
    p.id,
    p.date,
    p.`description`,
    COUNT(c.photo_id) AS commentsCount
FROM
    photos p
        JOIN
    comments c ON c.photo_id = p.id
GROUP BY c.photo_id
ORDER BY commentsCount DESC , id
LIMIT 5;

#07.Lucky Users
SELECT 
    CONCAT(u.id, ' ', u.username) AS id_username, u.email
FROM
    users u
        JOIN
    users_photos up ON u.id = up.user_id
WHERE
    up.user_id = up.photo_id
ORDER BY u.id;

#08. Count likes and comments
SELECT 
    p.id,
    IFNULL(l.count, 0) likes_count,
    IFNULL(c.count, 0) comments_count
FROM
    photos p
        LEFT JOIN
    (SELECT 
        photo_id, COUNT(*) count
    FROM
        comments
    GROUP BY photo_id) c ON p.id = c.photo_id
        LEFT JOIN
    (SELECT 
        photo_id, COUNT(*) count
    FROM
        likes
    GROUP BY photo_id) l ON p.id = l.photo_id
ORDER BY l.count DESC , c.count DESC , p.id;
           

#09.The Photo on the Tenth Day of the Month
SELECT CONCAT(LEFT(`description`, 30), '...') AS summary, date FROM photos
WHERE DAY(date) = 10
ORDER BY date DESC;


#Section 4: Programmability – 30 Pts
#10. Get user’s photos count
DELIMITER %%
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(up.user_id)  AS photosCount FROM users_photos up
JOIN users u ON u.id = up.user_id
WHERE u.username = username);
END %%
SELECT udf_users_photos_count('ssantryd');

#11.Increase User Age
DELIMITER %%
CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30))
BEGIN 
UPDATE users u
JOIN addresses a ON a.user_id = u.id
SET u.age = IF(u.id IS NOT NULL, u.age + 10, u.age)
WHERE a.address = address AND a.town = town;
END %%

CALL udp_modify_user ('97 Valley Edge Parkway', 'Divinópolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title FROM users AS u
WHERE u.username = 'eblagden21';



















   

