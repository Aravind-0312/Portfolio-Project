-- select * from project..CovidDeaths
-- order by 3,4;

-- select * from project..CovidVaccinations
-- order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths
order by 1,2;

-- lets check total_cases vs total_death in India
-- It shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths
where location = 'India'
order by 1,2;

-- Now, looking at total deaths vs the population 
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from project..CovidDeaths
--where location = 'India'
order by 1,2;

---- Now, looking at countries with highest infection rate when compared to population
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as covid_infection_rate
from project..CovidDeaths
group by location, population
order by covid_infection_rate desc;


---- Now, looking at countries with highest death rate when compared to population
select location, max(cast(total_deaths as int)) as total_death_count
from project..CovidDeaths
where continent is not null
group by location
order by total_death_count desc;

-- Now, lets break it down by continent
-- Showing continents with highest death count
select continent, max(cast(total_deaths as int)) as total_death_count
from project..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;

---- Global numbers per day
select date, sum(new_cases) total_cases , sum(cast(new_deaths as int)) total_deaths,
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..CovidDeaths
where continent is not null
group by date
order by 1,2;

----Global cases
select sum(new_cases) total_cases , sum(cast(new_deaths as int)) total_deaths,
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..CovidDeaths
where continent is not null
order by 1,2;

-- looking at total population vs vaccination

select 
	dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
	sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location
							order by dea.location, dea.date) rolling_people_vaccinated
from project..CovidDeaths dea
left join project..CovidVaccinations vacc 
	on dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null
--and dea.location = 'Canada'
order by 2,3

with PopVsVacc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select 
	dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
	sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location
													order by dea.location, dea.date) rolling_people_vaccinated
from project..CovidDeaths dea
left join project..CovidVaccinations vacc 
	on dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null
)

select *, (rolling_people_vaccinated/population)*100 as PercentPopulationVacc from PopVsVacc;

-- Using temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
	sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location
							order by dea.location, dea.date) rolling_people_vaccinated
from project..CovidDeaths dea
left join project..CovidVaccinations vacc 
	on dea.location = vacc.location 
	and dea.date = vacc.date
-- where dea.continent is not null

select *, (rolling_people_vaccinated/population)*100 as PercentPopulationVacc from #PercentPopulationVaccinated;

-- Creating view to store data for future visualizations
use project;
Create view PercentPopulationVaccinated as
select 
	dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
	sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location
							order by dea.location, dea.date) rolling_people_vaccinated
from project..CovidDeaths dea
left join project..CovidVaccinations vacc 
	on dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null;

select *, (rolling_people_vaccinated/population)*100 as PercentPopulationVacc from #PercentPopulationVaccinated;
