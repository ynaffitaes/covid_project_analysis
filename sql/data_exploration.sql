-- Displaying the dataset
SELECT *
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
ORDER BY 3, 4;

-- Select the data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
ORDER BY 1, 2;

-- Total cases compared to the total deaths
-- Shows the likelihood of dying if you contrcat covid in your country

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths / total_cases) * 100 AS death_percentage
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE location LIKE '%France%'
ORDER BY 1, 2;

-- Total of cases compared to the population
-- shows the percentage of the population which contracted covid

SELECT
  location,
  date,
  population,
  total_cases,
  (total_cases / population) * 100 AS infection_rate
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE location LIKE '%France%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- The countries with highest infection rate

SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX((total_cases / population)) * 100 AS infection_rate
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

-- The countries with the highest death count per population

SELECT location, MAX(total_deaths) AS total_death_count
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- The continent with the highest death count

SELECT location, MAX(total_deaths) AS total_death_count
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- New global numbers  daily

SELECT
  date,
  sum(new_cases) AS total_new_cases,
  sum(new_deaths) AS total_new_deaths,
  sum(new_deaths) / sum(new_cases) * 100 AS death_percentage
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Percentage of population vaccinated

--with a CTE
WITH
  popvsvac AS (
    SELECT
      dea.continent,
      dea.location,
      dea.date,
      dea.population,
      vac.new_vaccinations,
      SUM(vac.new_vaccinations)
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
        AS rolling_people_vaccinated
    FROM `portfolio-covid-analysis.covid_data.covid_deaths` AS dea
    JOIN `portfolio-covid-analysis.covid_data.covid_vaccinations` AS vac
      ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2, 3
  )
SELECT *, (rolling_people_vaccinated / population) * 100 AS vac_rate
FROM popvsvac;



-- Creating a view to store date for visualization

CREATE OR REPLACE VIEW `portfolio-covid-analysis.covid_data.pop_vac_rate` AS

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS rolling_people_vaccinated
FROM `portfolio-covid-analysis.covid_data.covid_deaths` AS dea
JOIN `portfolio-covid-analysis.covid_data.covid_vaccinations` AS vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

