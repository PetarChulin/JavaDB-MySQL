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









