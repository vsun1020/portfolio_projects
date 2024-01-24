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



