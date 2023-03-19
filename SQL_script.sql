
-- First Tables: Covid related figures (infections, deaths, total cases, country population etc.)

select *
from projects..CovidDeaths
where continent is not null
order by 3,4

-- Select Columns of interest

Select Location,date, total_cases, new_cases, total_deaths, population
from projects..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from projects..CovidDeaths
--where location like '%Italy%' 
order by 1,2


-- Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidInfected
from projects..CovidDeaths
--where location like '%Italy%' 
order by 1,2


-- Countries with the highest infection rates compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CovidInfected
from projects..CovidDeaths
--where location like '%Italy%' 
group by population, location
order by CovidInfected desc

-- Top 10 countries by infection rates (between 17 % and 10%): Andorra, Montenegro, Czech Rep., San Marino, 
-- Slovenia, Luxembourg, Bahrain, Serbia, USA, Israel.

-- Continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as HighestDeathCount
from projects..CovidDeaths
--where location like '%Italy%' 
where continent is not null
group by continent
order by HighestDeathCount desc

-- Global Numbers 

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentDeath
from projects..CovidDeaths
where continent is not null
order by 1,2 

-- Overall, a 2.11% death across the world

--------------------------------------------------------------
----------------------------------------------------------------

-- Inner Join on specific columns:

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from projects..CovidDeaths as dea
join projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated   -- the count of new vaccines will start over at each new country
from projects..CovidDeaths as dea
join projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated   -- the count of new vaccines will start over at each new country
from projects..CovidDeaths as dea
join projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulation
from PopvsVac

-- Temp Table
--drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated   -- the count of new vaccines will start over at each new country
from projects..CovidDeaths as dea
join projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select *
from #PercentPopulationVaccinated

-- Create View to store data for Tableau visualisation
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated   -- the count of new vaccines will start over at each new country
from projects..CovidDeaths as dea
join projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
