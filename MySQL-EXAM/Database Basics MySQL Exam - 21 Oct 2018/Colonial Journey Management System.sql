CREATE DATABASE `Colonial Journey Management System`;
#1.	Section: Database Overview
#2.	Section: Data Definition Language (DDL) 
CREATE TABLE planets (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) NOT NULL

);

CREATE TABLE spaceports  (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
planet_id INT(11),

CONSTRAINT fk_sp_p FOREIGN KEY (planet_id)
        REFERENCES planets (`id`)
);

CREATE TABLE spaceships (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
manufacturer VARCHAR(30) NOT NULL,
light_speed_rate INT(11) DEFAULT 0
);

CREATE TABLE journeys (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    journey_start DATETIME NOT NULL,
    journey_end DATETIME NOT NULL,
    purpose ENUM('Medical', 'Technical', 'Educational', 'Military'),
    destination_spaceport_id INT(11),
    spaceship_id INT(11),
    CONSTRAINT fk_j_sp FOREIGN KEY (destination_spaceport_id)
        REFERENCES spaceports (`id`),
    CONSTRAINT fk_j_s FOREIGN KEY (spaceship_id)
        REFERENCES spaceships (`id`)
);

CREATE TABLE colonists (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
ucn CHAR(10) UNIQUE NOT NULL,
birth_date DATE NOT NULL
);

CREATE TABLE travel_cards (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    card_number CHAR(10) UNIQUE NOT NULL,
    job_during_journey ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
    colonist_id INT(11),
    journey_id INT(11),
    
    CONSTRAINT fk_tc_c FOREIGN KEY (colonist_id)
        REFERENCES colonists (`id`),
    CONSTRAINT fk_tc_j FOREIGN KEY (journey_id)
        REFERENCES journeys (`id`)
);

#3.	Section: Data Manipulation Language (DML)
#01.	Data Insertion
INSERT INTO travel_cards(card_number, job_during_journey, colonist_id,  journey_id) 
SELECT IF((birth_date > '1980-01-01') , (CONCAT(YEAR(birth_date), DAY(birth_date), LEFT(ucn, 4))), 
(CONCAT(YEAR(birth_date), MONTH(birth_date), RIGHT(ucn, 4)))) , 

(CASE 
WHEN id % 2 = 0 THEN 'Pilot'
WHEN id % 3 = 0 THEN 'Cook'
ELSE 'Engineer'
END) , id,
LEFT(ucn , 1) FROM colonists 
WHERE id BETWEEN 96 AND 100;

#02.Data Update
UPDATE journeys 
SET 
    purpose = (CASE
        WHEN id % 2 = 0 THEN 'Medical'
        WHEN id % 3 = 0 THEN 'Technical'
        WHEN id % 5 = 0 THEN 'Educational'
        WHEN id % 7 = 0 THEN 'Military'
        ELSE purpose
    END);
    
#03.Data Deletion
DELETE c FROM colonists c
        LEFT JOIN
    travel_cards tc ON tc.colonist_id = c.id
        LEFT JOIN
    journeys j ON tc.journey_id = j.id 
WHERE
    j.id IS NULL;

#4.	Section: Querying – 100 pts
#04.Extract all travel cards
SELECT 
    card_number, job_during_journey
FROM
    travel_cards
ORDER BY card_number;

#05. Extract all colonists
SELECT 
    id, CONCAT(first_name, ' ', last_name) AS full_name, ucn
FROM
    colonists
ORDER BY first_name , last_name , id;

#06.Extract all military journeys
SELECT id, journey_start, journey_end FROM journeys 
WHERE purpose LIKE 'Military'
ORDER BY journey_start;

#07.Extract all pilots
SELECT 
    c.id, CONCAT(c.first_name, ' ', c.last_name) AS full_name
FROM
    colonists c
        JOIN
    travel_cards tc ON tc.colonist_id = c.id
WHERE
    tc.job_during_journey LIKE 'Pilot'
ORDER BY c.id;

#08. Count all colonists 
SELECT 
    COUNT(c.id) AS count
FROM
    colonists c
        JOIN
    travel_cards tc ON tc.colonist_id = c.id
        JOIN
    journeys j ON tc.journey_id = j.id
WHERE
    j.purpose LIKE 'Technical';
    
#09.Extract the fastest spaceship 
SELECT 
    s.name AS spaceship_name, sp.name AS spaceport_name
FROM
    spaceships s
        JOIN
    journeys j ON j.spaceship_id = s.id
        JOIN
    spaceports sp ON sp.id = j.destination_spaceport_id
WHERE
    s.light_speed_rate = (SELECT 
            MAX(s.light_speed_rate)
        FROM
            spaceships)
ORDER BY s.light_speed_rate DESC
LIMIT 1;

#10.Extract spaceships with pilots younger than 30 years ??
SELECT DISTINCT
    s.name, s.manufacturer
FROM
    spaceships s
        LEFT JOIN
    journeys j ON j.spaceship_id = s.id
        LEFT JOIN
    travel_cards tc ON tc.journey_id = j.id
        LEFT JOIN
    colonists c ON tc.colonist_id = c.id
WHERE
    YEAR('2019-01-01') - YEAR(c.birth_date) < 30
        AND tc.job_during_journey LIKE 'Pilot'
ORDER BY s.name;

#11. Extract all educational mission planets and spaceports
SELECT DISTINCT
    p.name AS planet_name, sp.name AS spaceport_name
FROM
    planets p
        LEFT JOIN
    spaceports sp ON sp.planet_id = p.id
        LEFT JOIN
    journeys j ON sp.id = j.destination_spaceport_id
        LEFT JOIN
    travel_cards tc ON tc.journey_id = j.id
WHERE
    j.purpose LIKE 'Educational'
ORDER BY sp.name DESC;

#12. Extract all planets and their journey count 
SELECT 
    p.name AS planet_name, COUNT(sp.planet_id) AS journeys_count
FROM
    planets p
        JOIN
    spaceports sp ON sp.planet_id = p.id
        JOIN
    journeys j ON j.destination_spaceport_id = sp.id
GROUP BY p.name
ORDER BY journeys_count DESC , planet_name;

#13.Extract the shortest journey
SELECT 
    j.id, p.name, sp.name, j.purpose
FROM
    planets p
        JOIN
    spaceports sp ON p.id = sp.planet_id
        JOIN
    journeys j ON j.destination_spaceport_id = sp.id
ORDER BY DATEDIFF(j.journey_end, j.journey_start)
LIMIT 1;

#.14Extract the less popular job
SELECT 
    tc.job_during_journey
FROM
    travel_cards tc
WHERE
    tc.journey_id = (SELECT 
            j.id
        FROM
            journeys j
        ORDER BY DATEDIFF(j.journey_end, j.journey_start) DESC
        LIMIT 1)
GROUP BY tc.job_during_journey
ORDER BY COUNT(tc.colonist_id)
LIMIT 1;

#5.	Section: Programmability – 30 pts
#15. Get colonists count
DELIMITER %%
CREATE FUNCTION udf_count_colonists_by_destination_planet (planet_name VARCHAR (30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(tc.journey_id) AS count FROM travel_cards tc
		JOIN journeys j ON j.id = tc.journey_id
        JOIN spaceports sp ON sp.id = j.destination_spaceport_id
        JOIN planets p ON p.id = sp.planet_id
        WHERE p.name = planet_name);
        
END %%
SELECT p.name, udf_count_colonists_by_destination_planet('Otroyphus') AS count
FROM planets AS p
WHERE p.name = 'Otroyphus';

#16. Modify spaceship
DELIMITER %%
CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(spaceship_name VARCHAR(50), light_speed_rate_increase INT)
BEGIN 
START TRANSACTION;
IF(SELECT COUNT(`name`) FROM spaceships WHERE `name` = spaceship_name > 0) THEN
	UPDATE spaceships
    SET light_speed_rate = light_speed_rate + light_speed_rate_increase;
    ELSE
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
      END IF;
END %%
CALL udp_modify_spaceship_light_speed_rate ('USS Templar', 5);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'USS Templar';


        
        










