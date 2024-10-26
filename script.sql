-- Final Project

CREATE DATABASE IF NOT EXISTS pandemic;

USE pandemic;

-- 3 NF

CREATE TABLE countries (
    CountryID SERIAL PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL,
    Code CHAR(3)
);


ALTER TABLE countries MODIFY COLUMN Code VARCHAR(10);
INSERT INTO countries (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    CaseID SERIAL PRIMARY KEY,
    CountryID INTEGER REFERENCES countries(CountryID),
    Year INT NOT NULL,
    Disease VARCHAR(255) NOT NULL,
    Cases DECIMAL(10, 2)
);

ALTER TABLE infectious_cases_normalized MODIFY COLUMN Cases DECIMAL(15, 2);

INSERT INTO infectious_cases_normalized (CountryID, Year, Disease, Cases)
SELECT c.CountryID, ic.Year, 'Number_yaws' AS Disease, 
    NULLIF(ic.Number_yaws, '') AS Cases 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_yaws IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'polio_cases', 
    NULLIF(ic.polio_cases, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.polio_cases IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'cases_guinea_worm', 
    NULLIF(ic.cases_guinea_worm, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.cases_guinea_worm IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'Number_rabies', 
    NULLIF(ic.Number_rabies, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_rabies IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'Number_malaria', 
    NULLIF(ic.Number_malaria, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_malaria IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'Number_hiv', 
    NULLIF(ic.Number_hiv, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_hiv IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'Number_tuberculosis', 
    NULLIF(ic.Number_tuberculosis, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_tuberculosis IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'Number_smallpox', 
    NULLIF(ic.Number_smallpox, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_smallpox IS NOT NULL

UNION ALL

SELECT c.CountryID, ic.Year, 'Number_cholera_cases', 
    NULLIF(ic.Number_cholera_cases, '') 
FROM infectious_cases ic 
JOIN countries c ON ic.Entity = c.Entity 
WHERE ic.Number_cholera_cases IS NOT NULL;

-- Analyze the data

SELECT 
    c.Entity,
    c.Code,
    AVG(NULLIF(ic.Number_rabies, '')) AS Average_Rabies,
    MIN(NULLIF(ic.Number_rabies, '')) AS Min_Rabies,
    MAX(NULLIF(ic.Number_rabies, '')) AS Max_Rabies,
    SUM(NULLIF(ic.Number_rabies, '')) AS Sum_Rabies
FROM 
    infectious_cases ic
JOIN 
    countries c ON ic.Entity = c.Entity
WHERE 
    ic.Number_rabies IS NOT NULL AND ic.Number_rabies <> ''
GROUP BY 
    c.Entity, c.Code
ORDER BY 
    Average_Rabies DESC
LIMIT 10;

-- 4

SELECT 
    Year,
    DATE(CONCAT(Year, '-01-01')) AS First_January,
    CURDATE() AS CurrentDate,
    TIMESTAMPDIFF(YEAR, DATE(CONCAT(Year, '-01-01')), CURDATE()) AS Year_Difference
FROM 
    infectious_cases_normalized;

-- 5

DROP FUNCTION IF EXISTS YearDifference;
DELIMITER //

CREATE FUNCTION YearDifference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE start_date DATE;
    DECLARE currentDate DATE;

    SET start_date = DATE(CONCAT(input_year, '-01-01'));
	SET currentDate = CURDATE();

    RETURN TIMESTAMPDIFF(YEAR, start_date, currentDate);
END

//
DELIMITER ;

SELECT Year, YearDifference(Year) AS Year_Difference
FROM infectious_cases_normalized;
