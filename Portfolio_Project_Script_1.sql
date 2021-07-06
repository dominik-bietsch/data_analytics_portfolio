-- Look into the tables

select *
from public.coviddeaths 
where continent not like ''
order by 3,4

select *
from public.vaccinations
where continent not like '' 
order by 3,4




select location, date, total_cases , new_cases , total_deaths , population 
from public.coviddeaths c
where continent not like '' 
order by 1,2


-- Looking at Total Cases vs Total Deaths
	-- Shows the ratio btw. deaths and registered cases per day in Germany
select location, date, total_cases , total_deaths, round((total_deaths/total_cases)::numeric *100,2)  as DeathsvsCases
from public.coviddeaths c 
where location like 'Germany' 
order by 1,2


-- Looking at the Total Cases vs Population
	-- What percentage of the German population had covid  
select location, date, total_cases, population, round((total_cases/population)::numeric *100,2) as CasesRelToPop
from public.coviddeaths c 
where location like 'Germany'
order by 1,2


-- Looking at the Total Deaths vs Population
	-- What percentage of the German population died because of Corona
select location, date, total_deaths, population, round((total_deaths/population)::numeric *100,2) as DeathsRelToPop
from public.coviddeaths c 
where location like 'Germany'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, round((max(total_cases)/population)::numeric *100, 2) as infection_rate
from public.coviddeaths c 
where total_cases is not null and population is not null and continent not like ''
group by 1, 2
order by 3 desc 



-- Showing Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from public.coviddeaths c 
where continent not like '' and total_deaths is not null
group by 1
order by 2 desc 


-- Let's Break Things Down by Continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from public.coviddeaths c 
where continent like '' and total_deaths is not null
group by 1
order by 2 desc 


-- Global Number
	-- Deaths Ratio to Total Worldwide Cases
select SUM(new_cases) as SumNewCases, sum(new_deaths) as SumDeaths, round((sum(new_deaths)/SUM(new_cases))::numeric,4) *100 as DeathsNewCasesRatio
from public.coviddeaths c 
where continent not like '' and new_cases is not null
--group by 1
order by 1







-- Take a Look at the Vaccination Table

select *
from public.vaccinations v 



-- Join the Two Tables

select *
from public.coviddeaths dea
join public.vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date



-- Looking at the Rolling Vac. Number by location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea."location" order by dea.location, dea.date) as RollingPeopleVaccinated 
from public.coviddeaths dea
join public.vaccinations vac
	on dea."location" = vac."location" 
	and dea.date = vac."date" 
where dea.continent not like ''
order by 2,3


-- Looking at Total Population vs. Vaccinations --> Percentage of population vaccinated 
-- shown per day
	-- Using CTE for this


with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea."location" order by dea.location, dea.date) as RollingPeopleVaccinated
from public.coviddeaths dea
join public.vaccinations vac
	on dea."location" = vac."location" 
	and dea.date = vac."date" 
where dea.continent not like ''
)
select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from PopVsVac



-- Looking at Total Population vs. Vaccinations in Total

with PopVsVac (continent, location, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,  dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea."location" order by dea.location) as RollingPeopleVaccinated
from public.coviddeaths dea
join public.vaccinations vac
	on dea."location" = vac."location" 
	and dea.date = vac."date" 
where dea.continent not like ''
)
select location, population, (max(RollingPeopleVaccinated)/population)*100 as PercentVaccinated
from PopVsVac
group by 1,2
order by 3 desc




-- Temp Table

drop table if exists temp_PercentPopulationVaccinated;
create temporary table temp_PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
insert into temp_PercentPopulationVaccinated
select dea.continent, dea.location, dea.date::date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea."location" order by dea.location, dea.date) as RollingPeopleVaccinated
from public.coviddeaths dea
join public.vaccinations vac
	on dea."location" = vac."location" 
	and dea.date = vac."date" 
where dea.continent not like '';


select * 
from temp_PercentPopulationVaccinated


-- Creating permanent View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date::date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over (partition by dea."location" order by dea.location, dea.date) as RollingPeopleVaccinated
from public.coviddeaths dea
join public.vaccinations vac
	on dea."location" = vac."location" 
	and dea.date = vac."date" 
where dea.continent not like '';





