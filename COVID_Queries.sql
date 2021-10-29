/*
COVID-19 Exploratory Data Analysis

Includes: Joins, Views, Aggregate Functions, Data Conversions

*/

Select *
From PortfolioProject.dbo.CovidDeaths1
ORDER BY 1,2


--Finding Total Cases vs. Total Deaths
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases) * 100 AS death_percentage
From PortfolioProject.dbo.CovidDeaths1
WHERE location like '%states%'
ORDER BY 1,2

--Looking at the total cases vs the population
--shows what % of population got Covid-19
SELECT 
	location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population) * 100 AS total_positive_cases_percentage
From PortfolioProject.dbo.CovidDeaths1
WHERE location like '%states%'
ORDER BY 1,2

--Looking at the countries with the Highest Infection Rate compared to the Population.
SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS MaxPercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths1
GROUP BY population, location
ORDER BY MaxPercentPopulationInfected DESC

--Showing the max deaths of each country
SELECT
	location,
	population,
	MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProject.dbo.CovidDeaths1
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS BY CONTINENT
SELECT
	location,
	MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProject.dbo.CovidDeaths1
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Global numbers per day
SELECT 
	date, 
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProject.dbo.CovidDeaths1
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs. Vaccinations
SELECT
	CD.continent,
	CD.location,
	CD.date,
	CV.population,
	CD.new_vaccinations,
	SUM(CAST(CD.new_vaccinations AS INT)) 
		OVER (PARTITION BY CV.location
		ORDER BY CD.Location, CD.date) AS Rolling_Vaccinations
FROM PortfolioProject.dbo.CovidVaccinations CD
JOIN PortfolioProject.dbo.CovidDeaths1 CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CV.continent IS NOT NULL
ORDER BY 2,3

--Using a CTE to reference alias col and find % vaxed

WITH CTE AS (
	SELECT
	CD.continent,
	CD.location,
	CD.date,
	CV.population,
	CD.new_vaccinations,
	SUM(CAST(CD.new_vaccinations AS INT)) 
		OVER (PARTITION BY CV.location
		ORDER BY CD.Location, CD.date) AS Rolling_Vaccinations
FROM PortfolioProject.dbo.CovidVaccinations CD
JOIN PortfolioProject.dbo.CovidDeaths1 CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CV.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_Vaccinations/Population)*100 AS PercentPopulationVaccinated
FROM CTE


---Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated1 AS
	SELECT
	CD.continent,
	CD.location,
	CD.date,
	CV.population,
	CD.new_vaccinations,
	SUM(CAST(CD.new_vaccinations AS INT)) 
		OVER (PARTITION BY CV.location
		ORDER BY CD.Location, CD.date) AS Rolling_Vaccinations
FROM PortfolioProject.dbo.CovidVaccinations CD
JOIN PortfolioProject.dbo.CovidDeaths1 CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CV.continent IS NOT NULL
--ORDER BY 2,3
