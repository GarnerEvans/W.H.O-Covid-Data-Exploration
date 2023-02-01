select location, date, total_cases,new_cases, total_deaths, population
from covid_deaths
order by 1,2

-- total cases vs total deaths
 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
order by 1,2


--shows a running total of death percentage due to covid 19, likelihood of dying if contraction of virus.

select location, date, total_cases, total_deaths, (total_deaths::decimal/total_cases)*100 as death_percentage
from covid_deaths 
where location like '%Iceland%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of the population has been infected

select location, date, total_cases, population, (total_cases::decimal/population)*100 as contraction_percentage
from covid_deaths 
where location like '%Iceland'
order by 1,2


--Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases::decimal/population))*100 
as PercentPopulationInfected
from covid_deaths
group by location, Population
order by PercentPopulationInfected

--Showing countries with highest death percentage

select location, MAX(total_deaths::INT) as TotalDeathCount
from covid_deaths
group by location
order by TotalDeathCount desc

--Same, but by continent

select continent, MAX(total_deaths::INT) as TotalDeathCount
from covid_deaths
group by continent
order by TotalDeathCount desc

--Showing the continents with highest death count

select continent, MAX(total_deaths::INT) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

--Sum of new cases and new deaths across the world each day

select date, SUM(new_cases), SUM(new_deaths)
from covid_deaths 
where continent is not null
group by date
order by 1,2

--Death percentage per day

select date, SUM(new_cases), SUM(new_deaths),
SUM(total_deaths::decimal)/SUM(total_cases)*100 as DeathPercentage
from covid_deaths 
where continent is not null
group by date
order by 1,2

--Total global death percentage

select SUM(new_cases), SUM(new_deaths),
SUM(total_deaths::decimal)/SUM(total_cases)*100 as DeathPercentage
from covid_deaths 
where continent is not null
order by 1,2

--Vaccinations

select * 
from covid_deaths
join covid_vacc
on covid_deaths.location = covid_vacc.location and
covid_deaths.date::date = covid_vacc.date::date


--looking at total populations vs vaccinations

--Gives a rolling total of vaccinated people over time per country

select covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vacc.new_vaccinations,
SUM(nullif(trim(covid_vacc.new_vaccinations), '')::integer) over (partition by covid_deaths.location order by covid_deaths.location, 
covid_deaths.date) as RollingPeopleVaccinated
from covid_deaths
join covid_vacc
on covid_deaths.location = covid_vacc.location and
covid_deaths.date::date = covid_vacc.date::date


--Shows the percentage of the population vaccinated in each country over time

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as (
	select covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vacc.new_vaccinations,
	SUM(nullif(trim(covid_vacc.new_vaccinations), '')::integer) over (partition by covid_deaths.location order by covid_deaths.location, 
	covid_deaths.date) as RollingPeopleVaccinated
	from covid_deaths
	join covid_vacc
	on covid_deaths.location = covid_vacc.location and
	covid_deaths.date::date = covid_vacc.date::date
	where covid_deaths.continent is not null 
)
select *, (RollingPeopleVaccinated::decimal/Population)*100
from PopvsVac


--Temp Table with same information as the above query

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent varchar(255),
location varchar(255),
Date date,
Population int4,
New_vaccinations varchar(255),
RollingPeopleVaccinated numeric
)


insert into PercentPopulationVaccinated
	select covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vacc.new_vaccinations,
	SUM(nullif(trim(covid_vacc.new_vaccinations), '')::integer) over (partition by covid_deaths.location order by covid_deaths.location, 
	covid_deaths.date) as RollingPeopleVaccinated
	from covid_deaths
	join covid_vacc
	on covid_deaths.location = covid_vacc.location and
	covid_deaths.date::date = covid_vacc.date::date
	where covid_deaths.continent is not null 

select *, (RollingPeopleVaccinated::decimal/Population)*100
from PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view VaccPercentage as
	select covid_deaths.continent, covid_deaths.location, covid_deaths.date, covid_deaths.population, covid_vacc.new_vaccinations,
	SUM(nullif(trim(covid_vacc.new_vaccinations), '')::integer) over (partition by covid_deaths.location order by covid_deaths.location, 
	covid_deaths.date) as RollingPeopleVaccinated
	from covid_deaths
	join covid_vacc
	on covid_deaths.location = covid_vacc.location and
	covid_deaths.date::date = covid_vacc.date::date
	where covid_deaths.continent is not null 

	







