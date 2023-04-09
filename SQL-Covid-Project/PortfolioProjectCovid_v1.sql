-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Total cases vs Total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'Brazil' and continent is not null
Order by 1,2

-- Total cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'Brazil' and continent is not null
Order by 1,2

-- Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'Brazil'
Where continent is not null
Group By location, population
Order by PercentagePopulationInfected desc

-- Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'Brazil'
Where continent is not null
Group By location
Order by TotalDeathCount desc

-- Analyzing by continent

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'Brazil'
--Where continent is null
--Group By location
--Order by TotalDeathCount desc

-- Continents with the highest death count per continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'Brazil'
Where continent is not null
Group By continent
Order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'Brazil' 
Where continent is not null
--Group by date
Order by 1,2

-- Total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Use temp table

--DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated