/*
Covid 19 Data Exploration 2020-01-01 - 2022-08-14
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid per country
SELECT
  location, date, total_cases, total_deaths,(total_deaths / total_cases)*100 AS DeathPercentage
FROM 
  dataanalysttraining.CovidPortfolio.covid_deaths
ORDER BY 1,2


-- Looking at total cases vs population
-- Shows what percentage of the population got covid
SELECT
  location, date, total_cases, population,(total_cases / population)*100 AS ContractPercentage
FROM 
  dataanalysttraining.CovidPortfolio.covid_deaths
ORDER BY 1,2

-- Looking at total cases vs population in the United States
SELECT
  location, date, total_cases, population,(total_cases / population)*100 AS PercentInfected
FROM 
  dataanalysttraining.CovidPortfolio.covid_deaths
WHERE 
  location = "United States"
ORDER BY 
  date DESC

-- Looking at countries with the highest infection rate compared to Population
SELECT
  location, MAX(total_cases) AS HighestInfectionCount, population,MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM 
  dataanalysttraining.CovidPortfolio.covid_deaths
GROUP BY 
  location, population
ORDER BY 
  PercentPopulationInfected DESC

-- Looking at countries with the lowest infection rate compared to Population
SELECT
  location, MAX(total_cases) AS HighestInfectionCount, population,Max((total_cases / population))*100 AS PercentPopulationInfected
FROM 
  dataanalysttraining.CovidPortfolio.covid_deaths
GROUP BY 
  location, population
ORDER BY 
  PercentPopulationInfected

-- Showing countries with highest death count per population
SELECT
  location, MAX(total_deaths) AS TotalDeathCount
FROM
  dataanalysttraining.CovidPortfolio.covid_deaths
WHERE 
  continent is not null
and total_deaths is not null
GROUP BY 
  location
ORDER BY 
  TotalDeathCount DESC

-- Showing continents with the highest death count
SELECT
  continent, MAX(total_deaths) AS TotalDeathCount 
FROM
  `dataanalysttraining.CovidPortfolio.covid_deaths`
WHERE
  continent is not null
GROUP BY 
  continent
ORDER BY 
  TotalDeathCount DESC

-- Global Covid Data
SELECT
  date, total_cases, total_deaths,(total_deaths / total_cases)*100 AS DeathPercentage
FROM 
  dataanalysttraining.CovidPortfolio.covid_deaths
WHERE 
  continent is not null
GROUP BY 
  date
ORDER BY 
  1,2


-- For fun analysis
-- Weekly ICU admissions per country per year
SELECT
  EXTRACT(year FROM date) AS year, location, SUM(cast(weekly_icu_admissions as int64)) AS total_weekly_icu_patients
FROM
  `dataanalysttraining.CovidPortfolio.covid_deaths`
WHERE
  continent is not null
GROUP BY 
  location, year
ORDER BY 
  total_weekly_icu_patients DESC

-- Average reproduction rate by country descending
SELECT
  location, AVG(reproduction_rate) as average_reproduction_rate
FROM
  `dataanalysttraining.CovidPortfolio.covid_deaths`
WHERE 
  reproduction_rate is not null
GROUP BY 
  location
ORDER BY 
  average_reproduction_rate DESC

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From 
  dataanalysttraining.CovidPortfolio.covid_deaths dea
Join 
  dataanalysttraining.CovidPortfolio.covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where 
  dea.continent is not null 
order by 2,3
