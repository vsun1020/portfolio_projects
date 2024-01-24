-- checking if import was successful
-- SELECT *
-- FROM covid_data.covid_vacc
-- ORDER BY 3,4

-- Select the data that I am going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_data.covid_deaths
ORDER BY 1,2



-- looking at total_cases vs total_deaths (percentage of people who died)
# shows the likelihood of dying if you get covid by April 2021
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_data.covid_deaths
WHERE location like '%states%'
ORDER BY 1, 2

-- looking at total_cases vs population
#what percentage of population got covid?
SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
FROM covid_data.covid_deaths
WHERE location like '%states%'
ORDER BY 1, 2

#looking at what countries have the highest infection rates compared to populations
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_pop_infected
FROM covid_data.covid_deaths
GROUP BY location, population
ORDER BY percent_pop_infected DESC


-- looking at countries with highest death count per population
#casted total_deaths from TEXT to INT
SELECT location, MAX(CAST(total_deaths AS SIGNED)) as total_death_count
FROM covid_data.covid_deaths
WHERE continent <> ''
GROUP BY location
ORDER BY total_death_count DESC;

-- break things down by continent

-- showing continents with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS SIGNED)) as total_death_count
FROM covid_data.covid_deaths
WHERE continent = ''
GROUP BY location
ORDER BY total_death_count DESC;


-- global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS SIGNED)) as total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 as death_percentage
FROM covid_data.covid_deaths
WHERE continent <> ' '
GROUP BY date
ORDER BY 1, 2

-- total across the world
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS SIGNED)) as total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 as death_percentage
FROM covid_data.covid_deaths
WHERE continent <> ' '
-- GROUP BY date
ORDER BY 2,3

-- joining the two tables based on date and location
SELECT * 
FROM covid_data.covid_deaths dea
JOIN covid_data.covid_vacc vacc
	ON dea.location = vacc.location
    AND dea.date = vacc.date
ORDER BY 2,3
 
-- total population vs vaccinations
-- shows percentage of population that has recieved at least one covid vaccine
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM 
    covid_data.covid_deaths dea
JOIN 
    covid_data.covid_vacc vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    2, 3;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM 
        covid_data.covid_deaths dea
    JOIN 
        covid_data.covid_vacc vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent <> ' '
)
SELECT *
, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM 
    PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in the previous query

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM 
    covid_data.covid_deaths dea
JOIN 
    covid_data.covid_vacc vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT 
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM 
    PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM 
    PortfolioProject.CovidDeaths dea
JOIN 
    covid_data.covid_vacc vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

