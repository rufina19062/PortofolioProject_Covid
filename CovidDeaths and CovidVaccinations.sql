SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4


-- Select data that we are going to use
SELECT Location, continent, date, total_cases, new_cases, total_deaths, new_death, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Percentage of dying if you got covid in Indonesia, USA, and China
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location = 'Indonesia'
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location like '%state%'
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location = 'China'
ORDER BY 1, 2

-- Total Cases vs Population
-- Shows what percentage of population got Covid in Indonesia, USA, and China
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Infected_Percentage
FROM CovidDeaths
WHERE Location = 'Indonesia'
ORDER BY 1, 2

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Infected_Percentage
FROM CovidDeaths
WHERE Location like '%state%'
ORDER BY 1, 2

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Infected_Percentage
FROM CovidDeaths
WHERE Location = 'China'
ORDER BY 1, 2

-- Looking at Countries with higest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 AS Infected_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_Percentage DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count, MAX(total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC


-- Shows everything by Continent

-- Showing Continent with Highest Death Count per Population and Death Percentage
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count, MAX(total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC

SELECT location, MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count, MAX(total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC



-- Showing GLOBAL NUMBERS of Cases Count, Death Count, and Death Percentage
SELECT date, 
	SUM(New_cases) AS New_Cases, 
	SUM(CAST(New_deaths AS INT)) AS New_Death, 
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2  

SELECT SUM(New_cases) AS Total_Cases, 
	SUM(CAST(New_deaths AS INT)) AS Total_Death, 
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2 




-- Looking at Total Population vs Vacciations
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
		SUM(CONVERT(INT, vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinated_Percentage
		-- (Rolling_Vaccinations/death.population) * 100 
FROM CovidDeaths death
JOIN CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE
With Pop_vs_Vacc (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
		SUM(CONVERT(INT, vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinated --,
		--(Rolling_Vaccinations/death.population) * 100 
FROM CovidDeaths death
JOIN CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (Rolling_Vaccinated/Population) * 100 
FROM Pop_vs_Vacc


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopVacc

CREATE TABLE #PercentPopVacc
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
Rolling_Vaccinated NUMERIC
)


INSERT INTO #PercentPopVacc 
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
		SUM(CONVERT(int, vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL 


SELECT *, (Rolling_Vaccinated/Population) * 100 
FROM #PercentPopVacc



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopVacc AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
		SUM(CONVERT(int, vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_Vaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL 


SELECT *
FROM PercentPopVacc