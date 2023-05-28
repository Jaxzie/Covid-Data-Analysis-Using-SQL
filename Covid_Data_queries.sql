SELECT *
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM CovidData..CovidVaccinations
ORDER BY 3,4

-- Select the Data we are going to using

SELECT Location,Date,total_cases,new_cases,total_deaths,new_deaths,population
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


--Total Cases and Total_deaths

SELECT Location,Date
,CONVERT(DECIMAL(15, 3), total_deaths) AS 'total_deaths'
,CONVERT(DECIMAL(15, 3), total_cases) AS 'total_cases' ,
CONVERT(DECIMAL(15, 3), (CONVERT(DECIMAL(15, 3), total_deaths) / CONVERT(DECIMAL(15, 3), total_cases))* 100) AS 'Death_percentage'
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Arab%' OR location like '%India%'
ORDER BY 1,2;

--Total cases vs population

SELECT Location,Date
,CONVERT(DECIMAL(15, 3), total_cases) AS 'total_cases'
,CONVERT(DECIMAL(15, 3), population) AS 'population' ,
CONVERT(DECIMAL(15, 3), (CONVERT(DECIMAL(15, 3),total_cases) / CONVERT(DECIMAL(15, 3), population))* 100) AS 'case_percentage'
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Arab%' OR location like '%India%'
ORDER BY 1,2;

--Countries with highest infection rate by population

SELECT Location,population, MAX(cast(total_cases AS int)) AS 'Highest_infection_count', MAX(cast(total_cases AS int)/population) * 100 AS 'Percent_populated_infected'
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Arab%' OR location like '%India%'
GROUP BY Location,population
ORDER BY Percent_populated_infected DESC;


--Countries with highest Death rate by population

SELECT Location,population, MAX(cast(total_deaths AS int)) AS 'Highest_death_count', MAX(cast(total_deaths AS int)/population) * 100 AS 'Percent_populated_deaths'
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Arab%' OR location like '%India%'
GROUP BY Location,population
ORDER BY Percent_populated_deaths DESC;

--Breaking down by Continent

SELECT Continent,MAX(cast(total_deaths AS int)) AS 'Highest_death_count'
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Arab%' OR location like '%India%'
GROUP BY Continent
ORDER BY Highest_death_count DESC;

--New ongoing cases

SELECT SUM(new_cases) AS total_new_cases ,SUM(cast(new_deaths AS int)) AS 'total_new_deaths',(SUM(cast(new_deaths AS int))/SUM(new_cases)) * 100 AS 'death_percentage'
FROM CovidData..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Arab%' OR location like '%India%'
--GROUP BY Continent
ORDER BY 1,2;


--total_population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(CONVERT(bigint,new_vaccinations)) OVER ( Partition by dea.location ORDER BY dea.location, dea.date) AS'Rolling_people_vaccinated'
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--CTE
with pops_vac (continent, location,date,population,new_vaccinations,Rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(CONVERT(bigint,new_vaccinations)) OVER ( Partition by dea.location ORDER BY dea.location, dea.date) AS'Rolling_people_vaccinated'
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Rolling_people_vaccinated/ population) *100 AS 'total_population_vs_total_new_vaccination'
FROM pops_vac


--Views percentage_population_vaccinated

CREATE VIEW percentage_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER ( Partition by dea.location ORDER BY dea.location, dea.date) AS'Rolling_people_vaccinated'
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
