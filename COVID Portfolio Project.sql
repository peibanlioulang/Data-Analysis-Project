-- use covidanalysis;
SELECT 
    *
FROM
    covid_death
-- group by continent
where continent =''
ORDER BY 3 , 4;

-- SELECT 
--     *
-- FROM
--     covid_vaccinations
-- ORDER BY 3 , 4;

SELECT 
    location,
    STR_TO_DATE(dates, '%m/%d/%Y') as dates,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_death
ORDER BY 1 , 2;

-- Looking at Total Cases vs Total Deaths
SELECT 
    location,
	STR_TO_DATE(dates, '%m/%d/%Y') as dates,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as death_ratio
FROM
    covid_death
ORDER BY 1 , 2;

-- Looking at Total Cases vs Total Deaths in the United States
SELECT 
    location,
    STR_TO_DATE(dates, '%m/%d/%Y') as dates,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as death_ratio
FROM
    covid_death
WHERE
	location like '%states%'
ORDER BY 2;

-- Looking at Total Cases vd Population in the United States
-- Shows what percentage of population got Covid
SELECT 
    location,
    STR_TO_DATE(dates, '%m/%d/%Y') as dates,
    population,
    total_cases,
    (total_cases/population)*100 as infection_rate
FROM
    covid_death
-- WHERE
-- 	location like '%states%'
ORDER BY 1, 4;


-- Looking at Coutries with Highest Infection Rate compared to Population
SELECT 
    location,
    population,
    max(total_cases) as HighestInfectionCount,
    max((total_cases/population)*100 )as HighestInfection_rate
FROM
    covid_death
-- WHERE
-- 	location like '%states%'
GROUP BY 1,2
ORDER BY HighestInfection_rate DESC;


-- Showing Countries with Higest Death Count
SELECT 
    location,
    max(cast(total_deaths  as unsigned)) as TotalDeath_count
FROM
    covid_death
-- WHERE
-- 	location like '%states%'
GROUP BY 1
ORDER BY TotalDeath_count DESC;

-- Total Death Count By Continent
SELECT 
    continent,
    max(cast(total_deaths  as unsigned)) as TotalDeath_count
FROM
    covid_death
-- WHERE
-- 	continent !=''
GROUP BY continent
ORDER BY TotalDeath_count DESC;


-- Global Death
SELECT 
    STR_TO_DATE(date, '%m/%d/%Y') AS dates,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED INTEGER)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED INTEGER)) / SUM(new_cases) * 100 AS death_rate
FROM
    covid_death
WHERE
    location NOT IN ('Asia' , 'Africa',
        'Europe',
        'North Amercia',
        'South America',
        'Oceania',
        'Europen')
GROUP BY dates
ORDER BY 1 , 2;


-- Join Two Tables
-- New_vaccine and Total Vaccine
SELECT 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as total_vac
FROM 
	covid_death dea  JOIN 
    covid_vaccinations vac
ON dea.location = vac.location AND
   dea.date = vac.date
ORDER BY 2 , 3;


-- Total Population vs Vaccinations
-- Use CTE
WITH pop_vac 
AS 
(
SELECT 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as total_vac
FROM 
	covid_death dea  JOIN 
    covid_vaccinations vac
ON dea.location = vac.location AND
   dea.date = vac.date)
SELECT * ,
	(total_vac/population)*100 AS vac_pop
FROM 
	pop_vac;
    
-- Use Temp Table
Drop TEMPORARY table if exists PopulationgVsVaccinated;
CREATE TEMPORARY Table PopulationgVsVaccinated (
SELECT 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as total_vac
FROM 
	covid_death dea  JOIN 
    covid_vaccinations vac
ON dea.location = vac.location AND
   dea.date = vac.date);
SELECT * ,
	(total_vac/population)*100 AS vac_pop
FROM 
	PopulationgVsVaccinated;
    
    
-- Create View to Store Data
CREATE VIEW PopulationgVsVaccinated AS
(
SELECT 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    convert(new_vaccinations,signed integer)AS new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as total_vac
FROM 
	covid_death dea  JOIN 
    covid_vaccinations vac
ON dea.location = vac.location AND
   dea.date = vac.date);

SELECT
	*
FROM
	PopulationgVsVaccinated;


