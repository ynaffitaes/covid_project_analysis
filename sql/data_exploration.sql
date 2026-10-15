
-- PBI visualisatinon queries 

/* Displaying the dataset
SELECT *
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
ORDER BY 3, 4;*/


-- 1.  Total cases compared to the total deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT
  total_cases,
  total_deaths,
  (total_deaths / total_cases) * 100 AS death_percentage
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
-- WHERE location LIKE '%France%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2;


-- 2. The countries with the highest death count per population

SELECT location, MAX(total_deaths) AS total_death_count
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;


--3.The countries with highest infection rate


SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX((total_cases / population)) * 100 AS infection_rate
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
-- WHERE location like "% France%" 
GROUP BY location, population
ORDER BY infection_rate DESC;


-- 4. daily infection rate 

SELECT
  location,
  population,
  date,
  MAX(total_cases) AS highest_infection_count,
  MAX(total_cases / population) * 100 AS infection_rate
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
-- WHERE location like "% France%" 
GROUP BY location, population, date 
ORDER BY infection_rate desc;

-- 5. Rolling Vaccination Count by Country and Date

SELECT
      dea.continent,
      dea.location,
      dea.date,
      dea.population,
      SUM(vac.total_vaccinations) AS rolling_people_vaccinated
    FROM `portfolio-covid-analysis.covid_data.covid_deaths` AS dea
    JOIN `portfolio-covid-analysis.covid_data.covid_vaccinations` AS vac
      ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    GROUP BY dea.continent, dea.location, dea.date, dea.population
    ORDER BY 2, 3;

---6.Rolling Vaccination Count and Percentage of Population Vaccinated

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




-- 7. Total COVID Deaths by Continent

SELECT location, MAX(total_deaths) AS total_death_count
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- 8 . Global Daily COVID Cases, Deaths and Death Rate

CREATE OR REPLACE VIEW `portfolio-covid-analysis.covid_data.global_number_daily` AS
SELECT
  date,
  sum(new_cases) AS total_new_cases,
  sum(new_deaths) AS total_new_deaths,
  sum(new_deaths) / sum(new_cases) * 100 AS death_percentage
FROM `portfolio-covid-analysis.covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;




