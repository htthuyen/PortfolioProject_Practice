SELECT *
From PortfolioProject..CovidDeaths
order by 3,4

SELECT *
From PortfolioProject..CovidVacciantion
order by 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases,  total_deaths, (total_deaths*1.0/total_cases*1.0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where [location] like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage population got covid
SELECT Location, date, population,total_cases,   (total_cases*1.0/population*1.0)*100 as CovidPopPercentage
From PortfolioProject..CovidDeaths
where [location] like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location,  population,MAX(total_cases) as HighesInfectionCount, Max(total_cases*1.0/population*1.0)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
order by PercentPopulationInfected DESC

--Showing Countries with Highes Death Count per Population
SELECT [location], MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By [location] 
order by TotalDeathCount DESC

--SHowing the continent with the highest death count per population
SELECT [continent], MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By [continent] 
order by TotalDeathCount DESC

--Global Number
SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as float)) / SUM(New_Cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL
--Group BY [date] 
order by 1,2

/* LOOking at total population vs vaccination*/
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciantion vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(   
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciantion vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
SELECT *
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciantion vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciantion vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
