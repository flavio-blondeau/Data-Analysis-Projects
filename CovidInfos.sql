Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by location, date

-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%italy%'
order by location, date

-- Looking at total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
From PortfolioProject..CovidDeaths
Where location like '%italy%'
order by location, date


-- Looking at countries with highest infection rate
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as percent_population_infected
From PortfolioProject..CovidDeaths
group by location, population
order by percent_population_infected desc


-- Showing countries with highest death count
Select location, MAX(cast(total_deaths as int)) as total_deaths_count
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_deaths_count desc


-- divide by continent
Select location, MAX(cast(total_deaths as int)) as total_deaths_count
From PortfolioProject..CovidDeaths
where continent is null
group by location
order by total_deaths_count desc


-- Showing continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as total_deaths_count
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_deaths_count desc


-- Global numbers

select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by date


-- Join tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vax_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


--Use CTE
With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vax_people)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vax_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_vax_people/population)*100 as perncentage
from pop_vs_vac


-- Use temp table

drop table if exists #percentPopulationVaccined
create table #percentPopulationVaccined (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_vax_people numeric
)

insert into #percentPopulationVaccined
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vax_people
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rolling_vax_people/population)*100 as percentage
from #percentPopulationVaccined


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccined as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vax_people 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccined