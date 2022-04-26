
select *
from PortfolioProject..CovidDeathsInfo
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinationsInfo
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeathsInfo
order by 1,2


-- Looking at total cases versus total deaths
-- Shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeathsInfo
where Location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population have gotten cases

select Location, date, population, total_cases, (total_cases/population)*100 as Pop_Percentage
from PortfolioProject..CovidDeathsInfo
where Location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeathsInfo
--where location like'%states%'
Group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with the highest death count per population

select Location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeathsInfo
--where location like'%states%'
where continent is not null
Group by Location
order by total_death_count desc

-- Breaking down by continent

--select location, MAX(cast(total_deaths as int)) as total_death_count
--from PortfolioProject..CovidDeathsInfo
----where location like'%states%'
--where continent is null
--Group by location
--order by total_death_count desc

-- Showing continent with the highest death count

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeathsInfo
--where location like'%states%'
where continent is null
Group by location
order by total_death_count desc


-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeathsInfo
--where Location like '%states%'
where continent is not null
group by date
order by 1,2

--Total cases vs Total deaths (World)

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from PortfolioProject..CovidDeathsInfo
--where Location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at Total population vs Vaccinations

--Use CTE

with PopvsVac (continent, Loacrion, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeathsInfo dea
join PortfolioProject..CovidVaccinationsInfo vac
    on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeathsInfo dea
join PortfolioProject..CovidVaccinationsInfo vac
    on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeathsInfo dea
join PortfolioProject..CovidVaccinationsInfo vac
    on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated