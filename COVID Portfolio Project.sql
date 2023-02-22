
-- Select the Data that we will use

Select continent, location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null
Order by 1,2



-- This is not in the course but will delete all row entries where the total cases column doesn't have a value entered, this will get rid of repeat rows
--DELETE From CovidDeaths$
--Where total_cases IS NULL


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select continent, location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From CovidDeaths$
--where location like '%states%'
Where continent is not null
Order by 1,2


-- Looking at Countries with the Highest Infection Rate compared to Popuation

Select continent, location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent, location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Percentage

Select continent, location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent, location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS
	

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RealTimeVacPercentage
From PopvsVac


-- Creating Views to store data for later visualizations

-- Population vs Vaccination Percentage sorted by dates
Create View PopvsVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- Death percentage based on locations
Create View DeathPercentage as
Select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null


-- Percentage of Population with Covid by date
Create View CovidPercentage as
Select continent, location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From CovidDeaths$
Where continent is not null


-- Countries with the Highest Infection Rate
Create View InfectionRate as
Select continent, location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Where continent is not null
Group by continent, location, population


-- Total Deaths per Population by Country
Create View TotalDeaths as
Select continent, location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by continent, location


-- Total Deaths per Population by Continent
Create View TotalDeathsContinent as 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent


-- Death Percentage Global
Create View GlobalDeathPercentage as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Group by date



