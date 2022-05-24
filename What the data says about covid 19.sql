/*
WHAT THE DATA SAYS ABOUT COVID 19

Data Exploration on Worldwide Covid 19 Data
Period Covered by DataSet: 24-Feb-2020 to 17-May-2022
Data Source: https://ourworldindata.org/covid-deaths

Our aim in this project is to conduct exploratory data analysis on the covid dataset. We will in the end establish which countries had the highest 
covid 19 infection, and mortality.

Skills used: Data type conversion , subqueries, CTE's, Windows Functions, Aggregate Functions

*/

-- Inspecting the dataset.
SELECT *
FROM Covid_19_Figures..covid_figures
WHERE location = 'Angola'
ORDER BY date

/* The first aggregate function I ran returned an error because the datatype within the columns was not set to integer. I'll just change the 
datatypes for the columns I intend to use for my analysis so I don't have to encounter datatype errors.

Note: Always check datatype when adding 3rd party data to your database*/

-- From my experience, the ALTER TABLE function works better than CAST function in changing data type. So I'll use that.
ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN total_cases int 

ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN new_cases int

ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN total_deaths int

ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN new_deaths int

ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN total_vaccinations bigint

ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN new_vaccinations int

ALTER TABLE Covid_19_Figures..covid_figures
ALTER COLUMN [date] date

-- Total number of cases and deaths by countries

SELECT 
	location, population, MAX(total_cases) AS total_infections, MAX(total_deaths) AS total_deaths,
	MAX((total_cases/population)*100) AS infection_rate, 
	MAX((total_deaths/population)*100) AS mortality_rate
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 1

SELECT 
	location, population, population_density, MAX(total_cases) AS total_infections, MAX(total_deaths) AS total_deaths,
	MAX((total_cases/population)*100) AS infection_rate, 
	MAX((total_deaths/population)*100) AS mortality_rate
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
GROUP BY location,population, population_density
ORDER BY 1

-- Filtering out only countries with recorded cases
SELECT 
	location, population, SUM(new_cases) AS total_infections, SUM(new_deaths) AS total_deaths, 
	MAX((total_cases/population)*100) AS infection_rate, 
	MAX((total_deaths/population)*100) AS mortality_rate
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL 
GROUP BY location,population
HAVING SUM(new_cases) >0
ORDER BY 1

-- Top 10 countries with the highest number of infections

SELECT TOP 10 location, MAX(total_cases) AS no_of_infections
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Average number of infections
WITH CTE AS (
SELECT location, MAX(total_cases) AS no_of_infections
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
GROUP BY location)
SELECT AVG(no_of_infections) AS avg_total_infections
FROM CTE

-- Time series (Covid figures change over time)
SELECT 
	location, 
	date, 
	ISNULL(new_cases,0) AS new_cases, 
	ISNULL(new_deaths,0) AS new_deaths, 
	ISNULL(new_vaccinations,0) AS new_vaccinations
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT 
	location, 
	date, 
	ISNULL(SUM(new_cases),0) AS total_new_cases, 
	ISNULL(SUM(new_deaths),0) AS total_new_deaths, 
	ISNULL(SUM(new_vaccinations),0) AS total_new_vaccinations
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
GROUP BY location, date
ORDER BY 1,2


-- To crosscheck tableau time series. With this query I can calculate the total new cases for a month and compare with the tableau chart output.
WITH CTE2 AS (
SELECT 
	date, 
	SUM(new_cases) AS total_new_cases, 
	SUM(new_deaths) AS total_new_deaths, 
	SUM(new_vaccinations) AS total_new_vaccinations
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
GROUP BY date
)
SELECT SUM(total_new_cases)
FROM CTE2
WHERE date BETWEEN '2022-01-01' AND '2022-01-31'

-- Total Vaccinations per country
--SELECT 
--	*
--FROM Covid_19_Figures..covid_figures
--WHERE continent IS NOT NULL

SELECT 
	location, population, 
	MAX(CAST(people_vaccinated AS bigint)) AS people_vaccinated, 
	MAX(CAST(people_fully_vaccinated AS bigint)) AS people_fully_vaccinated,
	MAX(CAST(total_vaccinations AS bigint)) AS doses_administered,
	MAX((CAST(people_vaccinated AS bigint)/population)*100) AS vaccination_rate,
	MAX((CAST(people_fully_vaccinated AS bigint)/population)*100) AS vaccination_rate_full
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL 
GROUP BY location,population
HAVING MAX(CAST(people_vaccinated AS bigint)) >0
ORDER BY 1

-- Time series (Vaccine figures change over time)
SELECT 
	location, 
	date, 
	ISNULL(new_vaccinations,0) AS new_vaccinations, 
	ISNULL(new_deaths,0) AS new_deaths, 
	ISNULL(new_vaccinations,0) AS new_vaccinations
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL
ORDER BY 1,2

-- GDP against Vaccine administration
SELECT 
	location, gdp_per_capita, 
	MAX(CAST(people_vaccinated AS bigint)) AS people_vaccinated, 
	MAX(CAST(people_fully_vaccinated AS bigint)) AS people_fully_vaccinated,
	MAX(CAST(total_vaccinations AS bigint)) AS doses_administered
FROM Covid_19_Figures..covid_figures
WHERE continent IS NOT NULL 
GROUP BY location,gdp_per_capita
ORDER BY 1

-- Income bracket timeline
SELECT 
	location, 
	date, 
	ISNULL(total_vaccinations,0) AS total_vaccinations, 
	ISNULL(total_deaths,0) AS total_deaths
FROM Covid_19_Figures..covid_figures
WHERE location IN ('High income','Upper middle income','Lower middle income','low income')
ORDER BY 1,2