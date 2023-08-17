Select *
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 3, 4

--Select *
--from PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4

-- Selecting Data that we are using
SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at Total cases vs Total deaths
-- Looking at precentage deaths compared to cases
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like 'India'
ORDER BY 1, 2

-- Looking at total cases vs the population
-- Percentage of population that is affected
SELECT Location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject.dbo.CovidDeaths
-- Where location like 'India'
ORDER BY 1, 2

 --  Checking countries with highest infection rate comapred to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
-- Where location like 'India'
Group by population, location
ORDER BY PercentPopulationInfected desc

-- Countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
-- Where location like 'India'
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc


-- USING CONTINENT TO UNDERSTAND DATA
-- Continents with highest death count

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
-- Where location like 'India'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- Global Data

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths,  (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
ORDER BY 1, 2

-- Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2, 3

-- USING CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
-- ,(RollingPeopleVaccinated / population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVAccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
-- ,(RollingPeopleVaccinated / population)*100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
 -- ORDER BY 2, 3
 Select *
 From PercentPopulationVAccinated