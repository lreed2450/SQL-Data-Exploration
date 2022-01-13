/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From [Portfolio Project] .. [Covid Deaths]
Where continent is not null 
order by 3,4;

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[Covid Deaths]
Where continent is not null 
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
Where location like '%states%'
and continent is not null 
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (cast(total_cases as float)/population)*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((cast(total_cases as float)/population))*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.location, d.Date) as rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] d
Join [Portfolio Project]..[Covid Vaccinations] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.location, d.Date) as rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] d
Join [Portfolio Project]..[Covid Vaccinations] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (cast(rolling_people_vaccinated as float)/Population)*100 
From PopvsVac


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.location, d.Date) as rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] d
Join [Portfolio Project]..[Covid Vaccinations] v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 