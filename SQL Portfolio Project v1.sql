SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 3,4

--SELECT *
--FROM PortfolioProject..CovidDeaths
--Order By 3,4

--Select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order By 1,2
 
 --Looking at Total Cases vs Total Deaths
 --Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order By 1,2

--Looking at the Total Cases vs Population
--Shows what percantage of population got covid

SELECT location, date,  population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location,  population, MAX (total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By location,  population
Order By PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population

SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By location
Order By TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT


SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group By location
Order By TotalDeathCount desc

--Showing continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By continent
Order By TotalDeathCount desc


--Global Number

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By date
Order By 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group By date
Order By 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order By 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3
