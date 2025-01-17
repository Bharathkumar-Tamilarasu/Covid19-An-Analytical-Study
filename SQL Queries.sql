/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM COVID_DEATHS
WHERE CONTINENT IS NOT NULL
ORDER BY 3,4 

-- Select Data that we are going to be starting with

SELECT LOCATION, DATE, TOTAL_CASES,
	NEW_CASES,
	TOTAL_DEATHS,
	POPULATION
FROM COVID_DEATHS
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2

-- BREAKING THINGS DOWN BY COUNTRY

-- Total Cases vs Total Deaths
-- Shows Liklihood of Dying if you contract covid (in India)

SELECT LOCATION,DATE,TOTAL_CASES,
	TOTAL_DEATHS,
	(TOTAL_DEATHS * 1.0 / TOTAL_CASES * 1.0) * 100 AS DEATH_PERCENTAGE
FROM COVID_DEATHS
WHERE LOCATION = 'India'
	AND CONTINENT IS NOT NULL
ORDER
	BY 1,2

-- Total Cases vs Population
-- Shows percentage of population infected with Covid (in India)

SELECT LOCATION,DATE,POPULATION,
	TOTAL_CASES,
	(TOTAL_CASES * 1.0 / POPULATION * 1.0) * 100 AS INFECTED_PERCENTAGE
FROM COVID_DEATHS
WHERE LOCATION = 'India'
	AND CONTINENT IS NOT NULL
ORDER
	BY 1,2
	

-- Countries with Highest Infection Rate compared to Population

SELECT LOCATION,
	POPULATION,
	MAX(TOTAL_CASES) AS HIGHEST_INFECTION_COUNT,
	MAX((TOTAL_CASES * 1.0 / POPULATION * 1.0) * 100) AS HIGHEST_INFECTED_PERCENTAGE
FROM COVID_DEATHS
WHERE CONTINENT IS NOT NULL
	AND TOTAL_DEATHS IS NOT NULL GROUP
	BY 1,2
ORDER
	BY 4 DESC

-- Highest Death Count per Country

SELECT LOCATION,
	MAX(TOTAL_DEATHS) AS HIGHEST_DEATH_COUNT
FROM COVID_DEATHS
WHERE CONTINENT IS NOT NULL
	AND TOTAL_DEATHS IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Total Death count per Continent

SELECT CONTINENT,
	SUM(TOTAL_DEATHS) AS TOTAL_DEATHS
FROM COVID_DEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC

-- GLOBAL NUMBERS

SELECT SUM(NEW_CASES) AS TOTAL_CASES,
	SUM(NEW_DEATHS) AS NEW_DEATHS,
	(SUM(NEW_DEATHS) * 1.0 / SUM(NEW_CASES) * 1.0) * 100 AS DEATH_PERCENTAGE
FROM COVID_DEATHS
WHERE CONTINENT IS NOT NULL

-- Population vs Vaccinations
-- Number of People that has recieved at least one Covid Vaccine

SELECT DE.LOCATION,
	DE.DATE,
	DE.POPULATION,
	VA.NEW_VACCINATIONS AS DAILY_NEW_VACCINATIONS,
	SUM(VA.NEW_VACCINATIONS) OVER(PARTITION BY DE.LOCATION
								  ORDER BY DE.LOCATION ASC,DE.DATE ASC) AS TOTAL_VACCINATIONS
FROM COVID_DEATHS DE
JOIN COVID_VACCINATIONS VA ON DE.LOCATION = VA.LOCATION
AND DE.DATE = VA.DATE
WHERE DE.CONTINENT IS NOT NULL

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using CTE to perform Calculation on Partition By in previous query

WITH POP_VAC_CTE (LOCATION,DATE,POPULATION, NEW_VACCINATIONS, TOTAL_VACCINATIONS) 
AS
	(SELECT DE.LOCATION,
			DE.DATE,
			DE.POPULATION,
			VA.NEW_VACCINATIONS AS DAILY_NEW_VACCINATIONS,
			SUM(VA.NEW_VACCINATIONS) OVER(PARTITION BY DE.LOCATION
										  ORDER BY DE.LOCATION ASC,DE.DATE ASC) AS TOTAL_VACCINATIONS
		FROM COVID_DEATHS DE
		JOIN COVID_VACCINATIONS VA ON DE.LOCATION = VA.LOCATION
		AND DE.DATE = VA.DATE
		WHERE DE.CONTINENT IS NOT NULL )
		
SELECT *,
		(TOTAL_VACCINATIONS * 1.0 / POPULATION * 1.0) * 100 AS TOTAL_VACCINATIONS_PERCENTAGE
FROM POP_VAC_CTE
ORDER BY 1,2