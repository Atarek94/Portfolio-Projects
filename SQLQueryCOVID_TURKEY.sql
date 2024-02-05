SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location = 'Turkey'
ORDER BY 1,2




-- Looking at total cases vs total deaths
-- Shows the possibility percentage of dying if you contracted Covid in Türkiye

SELECT Location, date, total_cases, new_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as death_percentage
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location LIKE 'Turkey'
ORDER BY 1,2




-- Looking at total cases vs the population
-- Shows the percentage of the population infected by Covid in Türkiye

SELECT Location, date, population, total_cases, ROUND((total_cases/population)*100,2) as infected_percentage 
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location = 'Turkey'
ORDER BY 1,2




--Looking at the percent of the population infected in countries that shares borders with Türkiye

SELECT Location, population, Max(total_cases) Highest_infection_count, ROUND(MAX((total_cases/population)*100),2) as Percent_population_infected
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location LIKE 'Turkey' 
OR location LIKE 'Armenia' OR location LIKE 'Georgia' OR location LIKE 'Iran' OR location LIKE 'Azerbaijan'
OR location LIKE 'Bulgaria' OR location LIKE 'Greece' OR location LIKE 'Iraq' OR location LIKE 'Syria'
GROUP BY Location, population
ORDER BY Percent_population_infected DESC




--Showing countries that shares borders with Türkiye with Highest Death Count per population

SELECT location, MAX(CAST((total_deaths) AS INT)) as Total_Deaths_Count
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location LIKE 'Turkey' 
OR location LIKE 'Armenia' OR location LIKE 'Georgia' OR location LIKE 'Iran' OR location LIKE 'Azerbaijan'
OR location LIKE 'Bulgaria' OR location LIKE 'Greece' OR location LIKE 'Iraq' OR location LIKE 'Syria'
GROUP BY location
ORDER BY Total_Deaths_Count DESC




--Looking at global death percentage

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Turkey_Covid_Project..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2




--Looking at poplulation vs vaccinations in Türkiye

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
FROM Turkey_Covid_Project..CovidDeaths$ dea
JOIN Turkey_Covid_Project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'Turkey'
ORDER BY 2,3




--Using CTE to look at the percentage of poeple vaccinated in Türkiye

WITH PopvsVac (continent, location, Date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
FROM Turkey_Covid_Project..CovidDeaths$ dea
JOIN Turkey_Covid_Project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'Turkey'
--ORDER BY 2,3
)
SELECT *,( Rolling_people_vaccinated/(population)*100)
FROM PopvsVac




-- TEMP TABLE
DROP TABLE IF EXISTS #PERCENT_POPULATION_VACCINATED
CREATE TABLE #PERCENT_POPULATION_VACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #PERCENT_POPULATION_VACCINATED
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
FROM Turkey_Covid_Project..CovidDeaths$ dea
JOIN Turkey_Covid_Project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.location = 'Turkey'
--ORDER BY 2,3

SELECT *,( Rolling_people_vaccinated/(population)*100)
FROM #PERCENT_POPULATION_VACCINATED



-- Views for data visualization


-- View of PERCENT_POPULATION_VACCINATED

Create view PERCENT_POPULATION_VACCINATED AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_people_vaccinated
FROM Turkey_Covid_Project..CovidDeaths$ dea
JOIN Turkey_Covid_Project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.location = 'Turkey'
--ORDER BY 2,3



--View of percent of the population infected in countries that shares borders with Türkiye

CREATE VIEW Percent_population_infected
as
SELECT Location, population, Max(total_cases) Highest_infection_count, ROUND(MAX((total_cases/population)*100),2) as Percent_population_infected
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location LIKE 'Turkey' 
OR location LIKE 'Armenia' OR location LIKE 'Georgia' OR location LIKE 'Iran' OR location LIKE 'Azerbaijan'
OR location LIKE 'Bulgaria' OR location LIKE 'Greece' OR location LIKE 'Iraq' OR location LIKE 'Syria'
GROUP BY Location, population
--ORDER BY Percent_population_infected DESC




--View of the percentage of the population infected by Covid in Türkiye

CREATE VIEW infected_percentage
as
SELECT Location, date, population, total_cases, ROUND((total_cases/population)*100,2) as infected_percentage 
FROM Turkey_Covid_Project..CovidDeaths$
WHERE location = 'Turkey'
--ORDER BY 1,2