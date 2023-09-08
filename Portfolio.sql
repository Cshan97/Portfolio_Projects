SELECT *
FROM [Portfolio Project]..['covid deaths']
order by 3,4


--Select the data we will be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['covid deaths']
order by 1,2


--Shows the chances of dying from covid in the Japan
Select Location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM [Portfolio Project]..['covid deaths']
WHERE Location like '%Japan%'
order by 1,2

--Shows the percentage of the population of japan that caught covid
Select Location, date, population, total_cases,  
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM [Portfolio Project]..['covid deaths']
WHERE Location like '%Japan%'
order by 1,2


--Looking at countries with the highest infection rate compared to the population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..['covid deaths']
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Shows countries with the highest death count compared to population
Select Location, MAX(cast(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolio Project]..['covid deaths']
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
Select location, MAX(cast(total_deaths AS INT)) as TotalDeathCount
FROM [Portfolio Project]..['covid deaths']
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..['covid deaths']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Looking at total amount of vaccinations vs population with rolling vaccination counts
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['covid deaths'] dea
Join [Portfolio Project]..['covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3



--USE CTE
--Shows the population that is vaccinated
WITH PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['covid deaths'] dea
Join [Portfolio Project]..['covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['covid deaths'] dea
Join [Portfolio Project]..['covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['covid deaths'] dea
Join [Portfolio Project]..['covid vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


-- a view of the percent of the population of japan that caught covid
CREATE VIEW PercentJapanPopCovid as
Select Location, date, population, total_cases,  
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Covidpercentage
FROM [Portfolio Project]..['covid deaths']
WHERE Location like '%Japan%'
--order by 1,2
