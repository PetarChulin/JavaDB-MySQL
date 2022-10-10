#CREATE DATABASE `Football Scout Database`;
#Section 1: Data Definition Language (DDL)
#1.	Table Design

CREATE TABLE coaches (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) DEFAULT 0 NOT NULL,
coach_level INT(11) NOT NULL
);

CREATE TABLE players (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL,
position CHAR(1) NOT NULL,
salary DECIMAL(10,2) NOT NULL,
hire_date DATETIME,
skills_data_id INT(11),
team_id INT(11)
);

CREATE TABLE players_coaches (
player_id INT(11),
coach_id INT(11),

CONSTRAINT pk_pl_coach PRIMARY KEY (player_id , coach_id),
    CONSTRAINT fk_p_p FOREIGN KEY (player_id)
        REFERENCES players (`id`),
    CONSTRAINT fk_p_c FOREIGN KEY (coach_id)
        REFERENCES coaches (`id`)
);

CREATE TABLE skills_data (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
dribbling INT(11),
pace INT(11),
passing INT(11),
shooting INT(11),
speed INT(11),
strength INT(11)
);

CREATE TABLE countries (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) not null
);

CREATE TABLE towns (
id INT(11) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) not null,
country_id INT(11),

 CONSTRAINT fk_t_c FOREIGN KEY (country_id)
        REFERENCES countries (`id`)
);


CREATE TABLE stadiums (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    capacity INT(11) NOT NULL,
    town_id INT(11) NOT NULL,
    
    CONSTRAINT fk_s_t FOREIGN KEY (town_id)
        REFERENCES towns (`id`)
);

CREATE TABLE teams (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    established DATE NOT NULL,
    fan_base BIGINT NOT NULL,
    stadium_id INT(11),
    CONSTRAINT fk_p_s FOREIGN KEY (stadium_id)
        REFERENCES stadiums (`id`)
);


#Section 2: Data Manipulation Language (DML)
#2.	Insert

INSERT INTO coaches (first_name, last_name,salary,coach_level)
SELECT p.first_name, p.last_name, p.salary * 2, char_length(p.first_name) FROM players p
WHERE p.age >= 45;

#3. Update
UPDATE coaches c
JOIN players_coaches pc ON pc.coach_id = c.id
JOIN players p ON p.id = pc.player_id
SET coach_level = coach_level + 1
WHERE pc.coach_id IS NOT NULL AND c.first_name LIKE 'A%';

#4.	Delete
DELETE p FROM players p
WHERE p.age >= 45;

#Section 3: Querying – 50 pts
#5.	Players 
SELECT first_name,age,salary FROM players
ORDER BY salary DESC;

#6.	Young offense players without contract
SELECT p.id, CONCAT(p.first_name, ' ', p.last_name) AS full_name, p.age, p.position, p.hire_date FROM players p
JOIN skills_data sd ON sd.id = p.skills_data_id
WHERE p.age < 23 AND p.position LIKE 'A' AND p.hire_date IS NULL  AND sd.strength > 50
ORDER BY p.salary, p.age;

#07. Detail info for all teams 
SELECT t.name AS team_name, t.established, t.fan_base, COUNT(p.team_id) AS count_of_players FROM teams t
LEFT JOIN players p ON p.team_id = t.id
GROUP BY t.id
ORDER BY count_of_players DESC, t.fan_base DESC;

#8.	The fastest player by towns
SELECT MAX(sd.speed) AS max_speed, t.name FROM towns t
LEFT JOIN stadiums s ON s.town_id = t.id
LEFT JOIN teams ts ON ts.stadium_id = s.id
LEFT JOIN players p ON p.team_id = ts.id
LEFT JOIN skills_data sd ON p.skills_data_id = sd.id
WHERE ts.`name` NOT LIKE 'Devify'
GROUP BY t.id
ORDER BY max_speed DESC, t.name;

#9.	Total salaries and players by country
SELECT c.name , COUNT(p.team_id) AS total_count_of_players, SUM(p.salary) AS total_sum_of_salaries FROM countries c
LEFT JOIN towns t ON t.country_id = c.id
LEFT JOIN stadiums s ON t.id = s.town_id
LEFT JOIN teams ts ON s.id = ts.stadium_id
LEFT JOIN players p ON p.team_id = ts.id 
GROUP BY c.name
ORDER BY total_count_of_players DESC, c.name;

#Section 4: Programmability – 30 pts
#10. Find all players that play on stadium 
DELIMITER %%
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (
	SELECT 
    COUNT(ts.stadium_id) AS count
FROM
    teams ts
        JOIN
   stadiums s ON s.id = ts.stadium_id 
        JOIN
    players p  ON p.team_id = ts.id      
    WHERE s.`name` = stadium_name
);
END %%
SELECT udf_stadium_players_count ('Jaxworks') as `count`;

#11. Find good playmaker by teams
DELIMITER %%
CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name VARCHAR(45))
BEGIN 
SELECT CONCAT(p.first_name, ' ', p.last_name) AS full_name , p.age, p.salary, sd.dribbling, sd.speed, ts.`name` FROM  players p
JOIN skills_data sd ON p.skills_data_id = sd.id
JOIN teams ts ON p.team_id = ts.id
WHERE sd.dribbling > min_dribble_points #(SELECT MIN(dribbling) FROM skills_data) 
AND ts.name = team_name AND sd.speed > (SELECT AVG(speed) FROM skills_data)
ORDER BY sd.speed DESC
LIMIT 1;
END %%
CALL udp_find_playmaker (20, 'Skyble');















