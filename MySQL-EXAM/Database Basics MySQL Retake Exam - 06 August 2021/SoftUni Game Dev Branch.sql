#Section 1: Data Definition Language (DDL)
#1.	Table Design
#CREATE DATABASE `SoftUni Game Dev Branch`;
CREATE TABLE addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10)  NOT NULL
);


CREATE TABLE offices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    workspace_capacity INT NOT NULL,
    website VARCHAR(50),
    address_id INT NOT NULL,
    CONSTRAINT fk_off_addresses FOREIGN KEY (address_id)
        REFERENCES addresses (`id`)
);

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT NOT NULL,
    salary DECIMAL(10,2)  NOT NULL,
    job_title VARCHAR(20) NOT NULL,
    happiness_level CHAR(1) NOT NULL
);

CREATE TABLE teams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL,
    office_id INT NOT NULL,
    leader_id INT UNIQUE NOT NULL,
    CONSTRAINT fk_off_offices FOREIGN KEY (office_id)
        REFERENCES offices (`id`),
    CONSTRAINT fk_off_employees FOREIGN KEY (leader_id)
        REFERENCES employees (`id`)
);

CREATE TABLE games (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    rating FLOAT NOT NULL,
    budget DECIMAL(10 , 2 ) NOT NULL,
    release_date DATE,
    team_id INT NOT NULL,
    CONSTRAINT fk_games_teams FOREIGN KEY (team_id)
        REFERENCES teams (`id`)
);

CREATE TABLE games_categories (
    game_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT pk_games_games PRIMARY KEY (game_id , category_id),
    CONSTRAINT fk_g_games FOREIGN KEY (game_id)
        REFERENCES games (`id`),
    CONSTRAINT fk_g_category FOREIGN KEY (category_id)
        REFERENCES categories (`id`)
);

#Section 2: Data Manipulation Language (DML)
#2.	Insert

INSERT INTO games (name, rating, budget, team_id)
SELECT LOWER(REVERSE(SUBSTR(name, 2))) , t.id, (t.leader_id * 1000), t.id FROM teams AS t 
WHERE t.id BETWEEN 1 AND 9;

#3.	Update
UPDATE employees 
SET 
    salary = salary + 1000
WHERE
    age < 40 AND salary <= 5000;

#4.	Delete
DELETE g FROM games AS g
        LEFT JOIN
    games_categories AS gc ON gc.game_id = g.id 
WHERE
    g.release_date IS NULL
    AND gc.category_id IS NULL;

#Section 3: Querying – 50 pts
#5.	Employees
SELECT 
    first_name, last_name, age, salary, happiness_level
FROM
    employees
ORDER BY salary , id;

#6.	Addresses of the teams
SELECT 
    t.name AS team_name,
    a.name AS address_name,
    CHAR_LENGTH(a.name) AS count
FROM
    teams AS t
         JOIN
    offices AS o ON t.office_id = o.id
          JOIN
    addresses AS a ON o.address_id = a.id
WHERE
    o.website IS NOT NULL
   ORDER BY team_name , address_name;

#7.	Categories Info
SELECT 
    c.name,
    COUNT(gc.game_id) AS count,
    ROUND(AVG(g.budget), 2) AS avg_budget,
    MAX(g.rating) AS max_r
FROM
    games_categories AS gc
        JOIN
    categories AS c ON c.id = gc.category_id
        JOIN
    games AS g ON g.id = gc.game_id
GROUP BY c.name
HAVING MAX(g.rating) >= 9.5
ORDER BY count DESC , c.name;

#8.	Games of 2022
SELECT 
    g.name,
    g.release_date,
    CONCAT(LEFT(g.description, 10), '...') AS summary,
    (CASE
        WHEN MONTH(release_date) IN (1 , 2, 3) THEN 'Q1'
        WHEN MONTH(release_date) IN (4 , 5, 6) THEN 'Q2'
        WHEN MONTH(release_date) IN (7 , 8, 9) THEN 'Q3'
        WHEN MONTH(release_date) IN (10 , 11, 12) THEN 'Q4'
    END) AS quarter,
    t.name AS team_name
FROM
    games AS g
        JOIN
    teams AS t ON t.id = g.team_id
WHERE
    YEAR(release_date) = 2022
        AND MONTH(release_date) % 2 = 0
        AND g.name LIKE '%2'
ORDER BY quarter;

#9.	Full info for games
SELECT 
    g.name,
    IF(g.budget < 50000,
        'Normal budget',
        'Insufficient budget') AS budget_level,
    t.name AS team_name,
    a.name AS address_name
FROM
    games AS g
        JOIN
    teams AS t ON t.id = g.team_id
        JOIN
    offices AS o ON o.id = t.office_id
        LEFT JOIN
    addresses AS a ON a.id = o.address_id
        LEFT JOIN
    games_categories AS gc ON gc.game_id = g.id
        LEFT JOIN
    categories AS c ON gc.category_id = c.id
WHERE
    g.release_date IS NULL
        AND gc.category_id IS NULL
ORDER BY g.name;

#Section 4: Programmability – 30 pts
#10.	Find all basic information for a game
DELIMITER %%
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20))
RETURNS TEXT
DETERMINISTIC
BEGIN
RETURN (SELECT CONCAT_WS(' ', 'The', g.name, 'is developed by a', t.name, 'in an office with an address', a.name)
AS info FROM games AS g
LEFT JOIN teams AS t ON g.team_id = t.id
LEFT JOIN offices AS o ON t.office_id = o.id
LEFT JOIN addresses AS a ON a.id = o.address_id
WHERE g.name = game_name);
END %%
SELECT udf_game_info_by_name('Fix San') AS info;

#11.	Update budget of the games 
DELIMITER %%
CREATE PROCEDURE udp_update_budget(min_game_rating FLOAT)
BEGIN 
UPDATE games AS g
LEFT JOIN games_categories AS gc ON g.id = gc.game_id
LEFT JOIN categories AS cat ON gc.category_id = cat.id
SET g.budget = (g.budget + 100000), g.release_date = DATE_ADD(g.release_date, INTERVAL 1 YEAR)
WHERE gc.game_id IS NULL AND g.rating > min_game_rating AND min_game_rating IS NOT NULL AND g.release_date IS NOT NULL;
END %%
CALL udp_update_budget (8);






