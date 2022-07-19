SELECT 
	*
FROM 
	CovidProject..CovidDeaths
WHERE
continent is null
ORDER BY 
	3,4

--SELECT *
--FROM CovidProject..CovidVaccinations
--ORDER BY 3,4

--Select Data we're going to use

SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	CovidProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 
	1,2

-- total cases vs total deaths

SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM 
	CovidProject..CovidDeaths
WHERE 
	location like '%Kingdom%' 
ORDER BY 
	1,2

-- total cases vs population

SELECT 
	Location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 AS pop_percentage
FROM 
	CovidProject..CovidDeaths
WHERE 
	location like '%Kingdom%'
ORDER BY 1,2

-- countries with highest infection rate compared to population

SELECT 
	Location, 
	population, 
	MAX(total_cases) AS highest_infection_count, 
	MAX((total_cases/population)*100) AS percent_pop_infected
FROM 
	CovidProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	Location, 
	population
ORDER BY 
	percent_pop_infected desc

-- countries with highest death count per population

SELECT
	Location, 
	MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	CovidProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	location
ORDER BY 
	total_death_count desc


-- continent with highest death count per population

SELECT
	location, 
	MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	CovidProject..CovidDeaths
WHERE 
	continent IS NULL 
	AND location <> 'World'
	AND location <> 'International'
	AND location <> 'European Union'
	
GROUP BY 
	location
ORDER BY 
	total_death_count desc



-- Global numbers by day

SELECT 
	date, 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM
	CovidProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	1,2

-- Global number death percentage


SELECT 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM
	CovidProject..CovidDeaths
WHERE
	continent IS NOT NULL

-- Total population vs vaccinations

WITH
	PopVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
	AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location
			ORDER BY 
				dea.location,
				dea.date) AS rolling_people_vaccinated
FROM
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE
	dea.continent IS NOT NULL

)

SELECT 
	*,
	(rolling_people_vaccinated/population)*100 AS rolling_percentage
FROM
	PopVac


-- Create views for data vis

-- Percentage of Population Vaccinated (rolling)

CREATE VIEW 
	PercentPopVac AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location
			ORDER BY 
				dea.location,
				dea.date) AS rolling_people_vaccinated
FROM
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE
	dea.continent IS NOT NULL

SELECT
	*
FROM
	PercentPopVac
	
-- Global death percentage

CREATE VIEW
	GlobalPercentage AS
SELECT 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM
	CovidProject..CovidDeaths
WHERE
	continent IS NOT NULL
	
-- Global daily new cases

CREATE VIEW
	GlobalDaily AS
SELECT 
	date, 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM
	CovidProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	date


-- Highest death count per country

CREATE VIEW 
	HighestDeaths AS
SELECT
	Location, 
	MAX(cast(total_deaths AS int)) AS total_death_count
FROM
	CovidProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	location


-- UK total cases vs total deaths

CREATE VIEW
	UKdeaths AS
SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM 
	CovidProject..CovidDeaths
WHERE 
	location like '%Kingdom%' 

-- Germany total cases vs total deaths

CREATE VIEW
	DEdeaths AS
SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM 
	CovidProject..CovidDeaths
WHERE 
	location = 'Germany' 
