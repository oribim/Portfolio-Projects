/*
Data Exploration on Worldwide Covid 19 Data
Period Covered by DataSet: 24-Feb-2020 to 08-Mar-2022
Data Source: https://ourworldindata.org/covid-deaths

Skills used: Data type conversion , Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

--SELECT *
--FROM COVID_Deaths
--ORDER BY 3,4
--SELECT *
--FROM COVID_Vaccinations
--ORDER BY 3,4

-- The first step is to select the data that we are going to be using for our analysis. This is useful if you need to refer back to your table.
SELECT	*
FROM
	Covid19_Database..COVID_Deaths
ORDER BY 3,4

-- Comparing the Total Cases against Total Deaths, we can deduce the percentage of Covid cases in Canada which resulted in death.
SELECT
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS '%Deaths'
FROM
	Covid19_Database..COVID_Deaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Comparing the Total Cases against the Total Popolation, we can deduce the percentage of the Canadian population that contracted the virus
SELECT
	location, date, total_cases, population, (total_cases/population)*100 AS '%infected'
FROM
	Covid19_Database..COVID_Deaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Comparing the Total Deaths against the Total Population, we can deduce the covid 19 mortality rate within Canada
SELECT
	location, date, total_deaths, population, (total_deaths/population)*100 AS 'Mortality rate'
FROM
	Covid19_Database..COVID_Deaths
WHERE location = 'Canada'
ORDER BY 1,2

-- To determine which countries had the highest infection rate over the period covered in the data
SELECT 
	location, MAX(total_cases) AS total_infection_count, population, MAX((total_cases/population)*100) AS infection_rate
FROM
	Covid19_Database..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY infection_rate desc

-- To determine which countries had the highest mortality rate over the period covered in the data
SELECT 
	location, MAX(cast(total_deaths as int)) AS total_death_count, population, MAX((total_deaths/population)*100) AS mortality_rate
FROM
	Covid19_Database..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY total_death_count desc

-- Global Covid 19 Facts
SELECT
	date, SUM(new_cases) AS global_cases, SUM(CAST(new_deaths as int)) AS global_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS global_mortality_rate
FROM
	Covid19_Database..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date
-- This gives the daily number of covid cases, covid deaths and the mortality rate worldwide.

-- We can also calculate what % of the global population contracted this virus.
SELECT 
	SUM(DISTINCT(population)) AS global_population, SUM(new_cases) AS global_cases, (SUM(new_cases)/SUM(DISTINCT(population)))*100 AS infection_rate
FROM
	Covid19_Database..COVID_Deaths
WHERE continent IS NOT NULL

-- We can implement a join query to work with data from both tables.

SELECT *
FROM Covid19_Database..COVID_Deaths dea
JOIN Covid19_Database..COVID_Vaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date

-- It is possible to know how much of the world population has been vaccinated by comparing total vaccinations against the total population.
-- The partition function tells SQL where to stop summing up the values. e.g partitioning by location tells SQL to stop when it encounters a
-- different country
SELECT
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS rolling_vaccination_count
	--rolling_vaccination_count
FROM Covid19_Database..COVID_Deaths dea
JOIN Covid19_Database..COVID_Vaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3
-- It is important to order by location and date in the partition query, else SQL returns the total of all new vaccinations for a location,
-- rather than a rolling sum

-- The above query would return an error if the column rolling_vaccination_count is included because it has just been created within the query.
-- This can be corrected using a Common Table Expression (CTE) or Temporary Table
-- Using a CTE,
WITH PopvsVac (continent,location,date,population,new_vaccinations,rolling_vaccination_count) 
AS (
SELECT
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS rolling_vaccination_count
	--(rolling_vaccination_count/dea.population)*100 AS percentage_vaccinated
FROM Covid19_Database..COVID_Deaths dea
JOIN Covid19_Database..COVID_Vaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null)
SELECT *, (rolling_vaccination_count/population)*100 AS percentage_vaccinated
FROM PopvsVac
ORDER BY 2,3
-- Note to Self: The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, 
-- unless TOP, OFFSET or FOR XML is also specified.

-- Using a Temporary Table

DROP TABLE IF EXISTS PercentagePeopleVaccinated
CREATE TABLE PercentagePeopleVaccinated
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric)

INSERT INTO PercentagePeopleVaccinated
SELECT
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS rolling_vaccination_count
	--(rolling_vaccination_count/dea.population)*100 AS percentage_vaccinated
FROM Covid19_Database..COVID_Deaths dea
JOIN Covid19_Database..COVID_Vaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null

SELECT *, (rolling_vaccination_count/population)*100 AS percentage_vaccinated
FROM PercentagePeopleVaccinated
ORDER BY 2,3


-- We can also view a summary of the total number of vaccinations in each country.
SELECT
	dea.location,SUM(CAST(vac.new_vaccinations as bigint)) AS total_vaccinations
FROM Covid19_Database..COVID_Deaths dea
JOIN Covid19_Database..COVID_Vaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
GROUP BY dea.location
ORDER BY 1

-- Creating views to be used in visualizations
CREATE VIEW Percentage_Vaccinated AS
SELECT
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) AS rolling_vaccination_count
	--(rolling_vaccination_count/dea.population)*100 AS percentage_vaccinated
FROM Covid19_Database..COVID_Deaths dea
JOIN Covid19_Database..COVID_Vaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null

CREATE VIEW PercentageMortality AS
SELECT 
	location, MAX(cast(total_deaths as int)) AS total_death_count, population, MAX((total_deaths/population)*100) AS mortality_rate
FROM
	Covid19_Database..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location,population
