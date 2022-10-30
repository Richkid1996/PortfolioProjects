SELECT *
FROM public.covid_deaths2
WHERE continent is not null
ORDER BY 3,4



--SELECT *
--FROM public.covid_vaccinations2
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM public.Covid_deaths2
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covind in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM public.Covid_deaths2
WHERE location like '%North%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population has gotten covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM public.Covid_deaths2
WHERE location like '%North%'
ORDER BY 1,2

-- looking at countries with highest infection Rate compared to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as InfectedPercentage
FROM public.Covid_deaths2
--WHERE location like '%North%'
GROUP BY LOCATION, POPULATION
ORDER BY infectedpercentage desc

-- Showing Contintents with Highest death Count per population
-- Create a View with this querry
SELECT location, MAX(cast(total_Deaths as int)) as Total_Death_Count
FROM public.Covid_deaths2
--WHERE location like '%North%'
WHERE continent is not null
GROUP BY LOCATION
ORDER BY Total_Death_Count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_Deaths as int)) as Total_Death_Count
FROM public.Covid_deaths2
--WHERE location like '%North%'
WHERE continent is  null
GROUP BY continent
ORDER BY Total_Death_Count desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_Deaths as int)) as Total_Death_Count
FROM public.Covid_deaths2
--WHERE location like '%North%'
WHERE continent is  null
GROUP BY continent
ORDER BY Total_Death_Count desc

-- GLOBAL NUMBERS
-- Put this querry into a view
SELECT  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM public.covid_deaths2
--WHERE location like '%North%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Global cases to deaths percentage

SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM public.covid_deaths2
--WHERE location like '%North%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)
FROM public.covid_deaths2 dea
JOIN public.covid_vaccinations2 vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM public.covid_deaths2 dea
JOIN public.covid_vaccinations2 vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp TABLE

Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent text,
Location text,
Date timestamp,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM public.covid_deaths2 dea
JOIN public.covid_vaccinations2 vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM public.covid_deaths2 dea
JOIN public.covid_vaccinations2 vac
    On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
