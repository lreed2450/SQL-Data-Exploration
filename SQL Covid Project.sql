/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM [Portfolio Project] .. [Covid Deaths]
WHERE continent IS NOT null 
ORDER BY 3,4;

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..[Covid Deaths]
WHERE continent IS NOT null 
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (cast(total_deaths AS float)/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..[Covid Deaths]
WHERE location LIKE '%states%'
AND continent IS NOT null 
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (cast(total_cases AS float)/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((cast(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
WHERE continent IS NOT null 
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
WHERE continent IS NOT null 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
WHERE continent IS NOT null 
--Group By date
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations AS bigint)) OVER (Partition BY d.Location ORDER BY d.location, d.Date) AS rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] d
JOIN [Portfolio Project]..[Covid Vaccinations] v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null 
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations AS bigint)) OVER (Partition BY d.Location ORDER BY d.location, d.Date) AS rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] d
JOIN [Portfolio Project]..[Covid Vaccinations] v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null 
--order by 2,3
)
SELECT *, (cast(rolling_people_vaccinated AS float)/Population)*100 
FROM PopvsVac


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations AS bigint)) OVER (Partition BY d.Location ORDER BY d.location, d.Date) AS rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..[Covid Deaths] d
JOIN [Portfolio Project]..[Covid Vaccinations] v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null 
