/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select Location, date, total_cases,new_cases, total_deaths, population
from Practice..CovidDeaths

-- 1. Looking at total_cases vs total_deaths as DeathPercentage
-- Shows likeliness of dying if you contact covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Practice..CovidDeaths
where location = 'India' 

-- 2. Looking at total cases vs population
-- Shows what percentage of population has got covid

select Location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
from Practice..CovidDeaths
where location = 'India'

-- 3. Looking at countries with highest infection rates compared to population

select Location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from Practice..CovidDeaths
--where location = 'India'
group by location, population
order by PercentPopulationInfected desc;

-- 4. Looking at countries with highest death count per population

select Location, max(cast(total_deaths as int)) as DeathCount
from Practice..CovidDeaths
where continent is not null
group by location
order by DeathCount desc;

-- Looking at death count per continent 
-- 5. Showing continents with highest death counts per population

select continent, max(cast(total_deaths as int)) as DeathCount
from Practice..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc;

-- 6. Looking at global numbers in cases

select sum(new_cases) as newCases, sum(cast(new_deaths as int)) as newDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathPercentage
from Practice..CovidDeaths
where continent is not null
--group by date
order by 1,2;

-- 7. Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
from Practice..CovidDeaths dea
inner join Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3;


-- With CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
from Practice..CovidDeaths dea
inner join Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3;
)
select *, (RollingPeopleVaccinated/population)*100 
from PopVsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
from Practice..CovidDeaths dea
inner join Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3;

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating views to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (PARTITION BY dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
from Practice..CovidDeaths dea
inner join Practice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3;

select * 
from PercentPopulationVaccinated;

-- for tableau 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Practice..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Practice..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Practice..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Practice..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Practice..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Practice..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

