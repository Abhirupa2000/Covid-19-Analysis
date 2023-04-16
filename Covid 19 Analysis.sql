/* 
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.
*/


SELECT *
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
 ORDER BY 3,4;



-- Selecting the data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- Total cases vs Total deaths for India specifically.
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2;



-- Total Cases vs Population
-- Shows what percentage of population infected with covid

-- For India
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM Portfolioproject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

-- World
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2



-- Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxPercentagePopulationInfected
FROM Portfolioproject..CovidDeaths
-- WHERE location = 'India'
GROUP BY location, population
ORDER BY MaxPercentagePopulationInfected DESC;



-- Countries with highest death count per population

-- There is some issue with the dataset. It reads the total_deaths data as characters.
-- Hence not giving the max. So we cast the variable as Integers.

SELECT location, MAX(CAST(total_deaths AS INT)) as HighestDeathCount
FROM Portfolioproject..CovidDeaths
-- WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;



-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count.
-- North america is only including values of USA and not Canada. 

SELECT continent, MAX(CAST(total_deaths AS INT)) as HighestDeathCount
FROM Portfolioproject..CovidDeaths
-- WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;



-- GLOBAL NUMBERS

-- Grouping by date, if we sum the new cases for all the countries,
-- we get the total new cases in the world for that day.
-- If we sum this values across all the dates, we get the total cases of the world.

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT ))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
where continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;



-- Total number of cases in the world in this pandemic.
-- Total cases across the world = 250574977 with death percentage 2.11%

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT ))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
where continent IS NOT NULL
ORDER BY 1,2;


-------------------------------------------------------


-- Lets use the vaccination dataset now.

SELECT *
FROM Portfolioproject..CovidVaccinations



-- Joining the two datasets on location and date.

SELECT * 
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date



-- Total Population Vs. Vaccination
-- Shows Percentage of population that has received at least one Covid Vaccine.

-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccination, cum_peoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_peoplevaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3;
)
SELECT * , (cum_peoplevaccinated/population)*100
FROM PopvsVac 



-- Using Temp Table to perform calculation on partition by in previous query

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cum_peoplevaccinated numeric
)
 
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_peoplevaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * , (cum_peoplevaccinated/population)*100
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_peoplevaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
