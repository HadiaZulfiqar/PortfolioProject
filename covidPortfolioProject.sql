select *
from portfolioProject.dbo.covidDeaths$
where date like '%2023%'
order by 3,4

select *
from portfolioProject.dbo.covidVaccinations$
order by 3,4

--select the data we'll use
select location, date, total_cases,new_cases,total_deaths,population
from portfolioProject.dbo.covidDeaths$
order by 1,2

ALTER TABLE portfolioProject.dbo.covidVaccinations$
ALTER COLUMN  new_vaccinations int
-- or cast(total_cases as int)
--CONVERT(bigint,v.new_vaccinations )

-- loking at total cases vs total deaths
-- shows  the likelihood of dying from covid  in your region
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject.dbo.covidDeaths$
where location like '%Pakistan%'
order by 5 desc


-- looking at total cases vs population
-- shows what population got covid
select location, date, total_cases,population, (total_cases/population)*100 as casesPerPopulation
from portfolioProject.dbo.covidDeaths$
where location like '%Pakistan%' 
order by 1,2


-- countries with highest infection rate
select location, population, MAX(total_cases) as HighestInfection , Max((total_cases/population))*100 as HighestInfectionRatePerPopulation
from portfolioProject.dbo.covidDeaths$
--where location like '%Pakistan%' 
group by location, population
order by HighestInfectionRatePerPopulation desc


-- shows countries with highst death rate
select location, total_deaths, MAX(total_cases) as HighestInfection , Max((total_deaths/total_cases))*100 as HighestDeathRatePerCases
from portfolioProject.dbo.covidDeaths$
--where location like '%Pakistan%' 
group by location, total_deaths
order by HighestDeathRatePerCases desc


-- max death count per countries
select location, MAX(total_deaths) as DeathCounts
from portfolioProject.dbo.covidDeaths$
where continent is not null
group by location
order by DeathCounts desc       -- gives continents as well hence where statemnnt


-- max death count per continents
select continent, MAX(total_deaths) as DeathCountsperCountry
from portfolioProject.dbo.covidDeaths$
where continent is not null
group by continent
order by DeathCountsperCountry desc    

--this seems correct
select location, MAX(total_deaths) as DeathCountsperContinent
from portfolioProject.dbo.covidDeaths$
where continent is null
group by location
order by DeathCountsperContinent desc       

-- showing TOTAL death count per COUNTRIES
SELECT location, SUM(total_deaths) AS total_deaths_2023,SUM(total_cases) AS total_cases_2023
FROM portfolioProject.dbo.covidDeaths$
WHERE YEAR(date) = 2023      ---or this one, both work
--where date between '2022-01-01 00:00:00.000' and '2022-12-31 00:00:00.000' 
GROUP BY location
order by 1;
-- NOTE THAT NO date IN SELECT STATEMENT



-- showing TOTAL death count per continents
SELECT continent,( SUM(total_deaths)/( SUM(total_cases)) )*100 AS death_percentage_2022
FROM portfolioProject.dbo.covidDeaths$
-->WHERE YEAR(date) = 2022      or this one, both work
where date between '2022-01-01 00:00:00.000' and '2022-12-31 00:00:00.000' and continent is not null
GROUP BY continent;

--     NOW, GLOBAL NUMBERS
select c.continent,c.location,c.date,c.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations )) OVER (Partition by c.location order by c.location,c.date)  as sum_of_vaccination
from portfolioProject.dbo.covidDeaths$ as c
join portfolioProject.dbo.covidVaccinations$ as v
	on c.location=v.location
	and c.date= v.date
where c.continent is not NULL



--create CTE, no of columns should be same
with popsVacc (Continent, Location, Date, Population, NewVacc, sum_of_vaccination) 
as
(
-- getting percentage of sum_of_vaccination, but we just created it so create a temp table
select c.continent,c.location,c.date,c.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations )) OVER (Partition by c.location order by c.location,c.date)  as sum_of_vaccination
--,(sum_of_vaccination/population)*100  -----------gives error
from portfolioProject.dbo.covidDeaths$ as c
join portfolioProject.dbo.covidVaccinations$ as v
	on c.location=v.location
	and c.date= v.date
where c.continent is not NULL
)
select *, (sum_of_vaccination/population)*100 
From popsVacc




-- TEMPTABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVacc  numeric,
sum_of_vaccination numeric,
)
insert into #PercentPopulationVaccinated
select c.continent,c.location,c.date,c.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations )) OVER (Partition by c.location order by c.location,c.date)  as sum_of_vaccination
--,(sum_of_vaccination/population)*100  -----------gives error
from portfolioProject.dbo.covidDeaths$ as c
join portfolioProject.dbo.covidVaccinations$ as v
	on c.location=v.location
	and c.date= v.date
where c.continent is not NULL

select *, (sum_of_vaccination/population)*100 
From #PercentPopulationVaccinated


--CREATING A VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
select c.continent,c.location,c.date,c.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations )) OVER (Partition by c.location order by c.location,c.date)  as sum_of_vaccination
--,(sum_of_vaccination/population)*100  -----------gives error
from portfolioProject.dbo.covidDeaths$ as c
join portfolioProject.dbo.covidVaccinations$ as v
	on c.location=v.location
	and c.date= v.date
where c.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated
