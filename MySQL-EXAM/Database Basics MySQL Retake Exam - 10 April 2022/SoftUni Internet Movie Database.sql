#CREATE DATABASE `SoftUni Internet Movie Database`;
CREATE TABLE countries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    continent VARCHAR(30) NOT NULL,
    currency VARCHAR(5) NOT NULL
);



CREATE TABLE genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) UNIQUE NOT NULL
);



CREATE TABLE actors (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
birthdate DATE NOT NULL,
height INT,
awards INT,
country_id INT NOT NULL,

CONSTRAINT `fk_countries_actors`
  FOREIGN KEY (`country_id`)
  REFERENCES countries (`id`)
);



CREATE TABLE movies_additional_info (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rating DECIMAL(10 , 2 ) NOT NULL,
    runtime INT NOT NULL,
    picture_url VARCHAR(80) NOT NULL,
    budget DECIMAL(10 , 2 ),
    release_date DATE NOT NULL,
    has_subtitles TINYINT(1),
    `description` TEXT
);




CREATE TABLE movies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(70) UNIQUE NOT NULL,
    country_id INT NOT NULL,
    movie_info_id INT UNIQUE NOT NULL,
    CONSTRAINT `fk_countries_movies` FOREIGN KEY (`country_id`)
        REFERENCES countries (`id`),
    CONSTRAINT `fk_countries_movies_addinfo` FOREIGN KEY (`movie_info_id`)
        REFERENCES movies_additional_info (`id`)
);


CREATE TABLE movies_actors (
    movie_id INT,
    actor_id INT,
    KEY pk_mov_movies (`movie_id` , `actor_id`),
    CONSTRAINT fk_mov_movies FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`id`),
    CONSTRAINT fk_mov_actors FOREIGN KEY (`actor_id`)
        REFERENCES `actors` (`id`)
);


CREATE TABLE genres_movies (
    genre_id INT,
    movie_id INT,
    KEY pk_gen_genres (`genre_id` , `movie_id`),
    CONSTRAINT fk_gen_genres FOREIGN KEY (`genre_id`)
        REFERENCES `genres` (`id`),
    CONSTRAINT fk_gen_movies FOREIGN KEY (`movie_id`)
        REFERENCES `movies` (`id`)
);

#2. INSERT
INSERT INTO actors (first_name ,last_name ,birthdate, height ,awards  ,country_id)
SELECT REVERSE(first_name), REVERSE(last_name), DATE(birthdate - 2), height + 10, country_id, 3
from actors
where id <= 10;

#03. Update 
UPDATE `movies_additional_info` SET `runtime` = runtime - 10 WHERE id BETWEEN 15 AND 25;

#04. Delete 
DELETE c FROM countries AS c
        LEFT JOIN
    movies AS m ON c.id = m.country_id 
WHERE
    m.country_id IS NULL;
    
#05. Countries 
SELECT 
    id, name, continent, currency
FROM
    countries
ORDER BY 
	currency DESC, id;

#06. Old movies 
SELECT 
    i.id, m.title, i.runtime, i.budget, i.release_date
FROM
    movies_additional_info AS i
        JOIN
    movies AS m ON i.id = m.id
    WHERE YEAR(release_date) BETWEEN 1996 AND 1999
    ORDER BY i.runtime, i.id
    LIMIT 20;
    
#07. Movie casting 
SELECT CONCAT(a.first_name, ' ', a.last_name) AS full_name, 
CONCAT(REVERSE(a.last_name), CHAR_LENGTH(a.last_name), '@cast.com') AS email,
(2022 - YEAR(a.birthdate)) AS age, a.height
FROM actors AS a
LEFT JOIN movies_actors AS ma ON a.id = ma.actor_id
WHERE ma.actor_id IS NULL
ORDER BY height;

#08. International festival 
SELECT 
    c.name, COUNT(m.id) AS movies_count
FROM
    countries AS c
        JOIN
    movies AS m ON c.id = m.country_id
GROUP BY country_id
HAVING movies_count >= 7
ORDER BY c.name DESC;

#09. Rating system 
SELECT 
    m.title,
    (CASE
        WHEN rating BETWEEN 0 AND 4 THEN 'poor'
        WHEN rating BETWEEN 4 AND 7 THEN 'good'
        WHEN rating > 7 THEN 'excellent'
    END) AS rating,
    IF(has_subtitles = 1, 'english', '-') AS subtitles,
    i.budget
FROM
    movies_additional_info AS i
        JOIN
    movies AS m ON i.id = m.id
ORDER BY budget DESC;

#10. History movies 
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN(
SELECT COUNT(ma.movie_id) FROM movies_actors AS ma
JOIN actors AS a ON a.id = ma.actor_id
JOIN genres_movies as gm ON ma.movie_id = gm.movie_id
JOIN genres AS g ON g.id = gm.genre_id
WHERE CONCAT(a.first_name, ' ', last_name) = full_name AND g.name = 'History');
END

#11. Movie awards 
CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
UPDATE actors as a
JOIN movies_actors as ma ON a.id = ma.actor_id
JOIN movies as m ON m.id = ma.movie_id
SET a.awards = a.awards + 1
WHERE m.title LIKE movie_title;
END


























