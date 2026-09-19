-- =====================================================
-- COVID-19 MYSQL PROJECT — 15 SQL PRACTICE QUESTIONS
-- =====================================================
# COVID-19 Data Analysis — MySQL Project

-- =====================================================
-- PROJECT INFORMATION
-- =====================================================
-- Name: Gariman Mishra
-- Project: COVID-19 Data Analysis Using MySQL
-- Role: Data Analyst
-- Tool: MySQL
-- Database: covid_project
-- Datasets: CovidDeaths.csv, CovidVaccinations.csv
-- SQL Questions: 15
-- Difficulty Levels: Basic, Intermediate, Advanced
--
-- Project Objective:
-- To analyze COVID-19 data using SQL and demonstrate
-- practical skills in data querying, aggregation,
-- JOINs, CTEs, window functions, and data analysis.
-- =====================================================


## Project Overview

/*This project analyzes **real-world COVID-19 data** using **MySQL** to extract meaningful insights about the global impact and progression of the pandemic.

The analysis uses two datasets — **CovidDeaths** and **CovidVaccinations** — containing country-wise and date-wise information on COVID-19 cases, deaths, population, and vaccination progress.

The project is structured into **15 SQL questions** across three difficulty levels: **Basic, Intermediate, and Advanced**. The analysis progresses from fundamental data retrieval and aggregation to more advanced analytical techniques such as **CTEs, JOINs, window functions, `LAG()`, `ROW_NUMBER()`, `DENSE_RANK()`, rolling calculations, and population-adjusted metrics**.

### Key Analysis Areas

* Country-wise COVID-19 cases and deaths
* Maximum cumulative cases and deaths
* Population-based death percentages
* Average daily new cases
* Time taken to reach major case thresholds
* Vaccination coverage
* 7-day rolling case trends
* Day-over-day case changes
* Continental ranking of countries by deaths
* Peak daily case dates
* Comparison of vaccination progress and COVID-19 deaths

### SQL Concepts Used

```text
SELECT & WHERE
GROUP BY & HAVING
ORDER BY & LIMIT
Aggregate Functions
CASE / NULL Handling
INNER JOIN
CTEs
Window Functions
LAG()
ROW_NUMBER()
DENSE_RANK()
RANK()
Rolling Calculations
Percentage Calculations
Date-based Analysis
```

### Project Objective

The primary objective is to demonstrate how **SQL can be used to transform raw COVID-19 data into structured analysis and actionable data insights**, while developing practical skills in querying, aggregation, data comparison, and advanced analytical SQL.

**Tools:** MySQL | SQL
**Datasets:** CovidDeaths.csv | CovidVaccinations.csv*/

 -- =========================
-- CATEGORY 1 — BASICS
-- =========================
use covid_project;

-- Q1. From CovidDeaths.csv, display the location, date, total_cases, and total_deaths for all country records where continent IS NOT NULL. 
-- Sort the result by location and date.

select location,date,total_deaths ,total_cases 
from covid_deaths
where continent is not null 
order by location , date ;

-- INSIGHT:
-- The result provides a date-wise view of COVID-19 cases and deaths
-- for each country, allowing us to track how the pandemic progressed
-- over time and compare case and death trends across countries.


-- Q2. Find the maximum total_cases recorded for each country. Display the country name and its maximum total_cases, excluding aggregate locations.

SELECT
    location,
    MAX(total_cases) AS maximum_total_cases
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
GROUP BY location
ORDER BY maximum_total_cases DESC;

-- INSIGHT:
-- The results show that the United States recorded the highest
-- maximum total_cases in the dataset, followed by India and Brazil , ETC.
-- This highlights the difference in cumulative COVID-19 case totals
-- among countries.

-- Q3. Find the maximum total_deaths recorded for each country. Display the country name and its maximum total_deaths, excluding aggregate locations
SELECT
    location,
    MAX(total_deaths) AS maximum_total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
GROUP BY location
ORDER BY maximum_total_deaths DESC;

-- INSIGHT:
-- The results show the highest cumulative COVID-19 deaths recorded
-- for each country during the dataset period. The United States
-- recorded the highest maximum total_deaths, followed by Brazil
-- and India.

-- 4. Calculate the total number of new_cases recorded for each continent across the entire dataset. Exclude rows where continent IS NULL and sort continents from highest to lowest total new cases.

select*from covid_deaths;
select continent , sum(new_cases) as total_number_of_new_cases
from covid_deaths
where continent is not null and trim( continent) <> ""
group by continent
order by total_number_of_new_cases desc;

-- INSIGHT:
-- Europe recorded the highest total number of new COVID-19 cases
-- in the dataset, followed by Asia and North America. Oceania
-- recorded the lowest total number of new cases among the continents.

-- Q5. Find the 10 countries with the highest population in CovidDeaths.csv. Display location and population, excluding aggregate locations.

select max(population) as highest_population ,location
from covid_deaths
where continent is not null and trim(continent) <>"" 
group by location
order by highest_population desc
limit 10;

-- INSIGHT:
-- China has the highest population in the dataset, followed by India
-- and the United States. The results show a substantial population
-- difference between the most populous countries and the remaining
-- countries in the top 10.

-- =========================
-- CATEGORY 2 — INTERMEDIATE
-- =========================

-- Q6. For each country, calculate the case fatality percentage using its maximum total_cases and maximum total_deaths:
    -- (maximum total_deaths / maximum total_cases) × 100
-- Display the country, maximum total_cases, maximum total_deaths, and fatality percentage. Exclude countries where either value is NULL or maximum total_cases is 0.

SELECT
    location,
    MAX(total_cases) AS maximum_total_cases,
    MAX(total_deaths) AS maximum_total_deaths,
    ROUND(
        MAX(total_deaths) / NULLIF(MAX(total_cases), 0) * 100,
        2
    ) AS case_fatality_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
GROUP BY location
HAVING MAX(total_cases) IS NOT NULL
   AND MAX(total_deaths) IS NOT NULL
   AND MAX(total_cases) > 0
ORDER BY case_fatality_percentage DESC;

-- INSIGHT:
-- The results show significant variation in case fatality percentages
-- across countries. Countries with very low total case counts can show
-- unusually high fatality percentages, so the percentage should be
-- interpreted together with the total number of cases and deaths.


-- Q7. Find the 10 countries with the highest total_deaths as a percentage of population, 
-- using each country's maximum total_deaths and population. Display the country, 
-- population, maximum total_deaths, and death percentage.

SELECT
    location,
    MAX(population) AS population,
    MAX(total_deaths) AS maximum_total_deaths,
    ROUND(
        MAX(total_deaths) / NULLIF(MAX(population), 0) * 100,
        2
    ) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
GROUP BY location
HAVING MAX(population) IS NOT NULL
   AND MAX(total_deaths) IS NOT NULL
   AND MAX(population) > 0
ORDER BY death_percentage DESC
LIMIT 10;

-- INSIGHT:
-- The results show that Hungary has the highest recorded total_deaths
-- as a percentage of its population in this dataset, followed by
-- Czechia and San Marino. The results demonstrate that population-
-- adjusted death rates can differ substantially from rankings based
-- only on the absolute number of deaths.


-- Q8. For each country, calculate its average daily new_cases
-- during the dataset period. Display the country and average
-- daily new_cases, and show the 10 countries with the highest averages.

SELECT
    location,
    ROUND(AVG(new_cases), 2) AS average_daily_new_cases
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
GROUP BY location
HAVING AVG(new_cases) IS NOT NULL
ORDER BY average_daily_new_cases DESC
LIMIT 10;

-- INSIGHT:
-- The United States recorded the highest average daily new_cases
-- in the dataset, followed by India and Brazil. The results show
-- that these countries had substantially higher average daily
-- case counts than the other countries in the top 10.



-- Q9 Find the date on which each country first reached or exceeded 100,000 total_cases. 
-- Display the country and the first date it crossed this threshold.
--  Include only countries that reached 100,000 cases.

SELECT
    location,
    MIN(date) AS first_date_reached_100k
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
  AND total_cases >= 100000
GROUP BY location
ORDER BY first_date_reached_100k;

-- INSIGHT:
-- A total of 92 countries in the dataset reached or exceeded
-- 100,000 total_cases. The United States was the earliest country
-- to reach this threshold, on March 27, 2020, followed by Italy
-- and Spain.



-- Q10.  Join CovidDeaths.csv and CovidVaccinations.csv using location and date. For each country, 
-- calculate the percentage of its population that had received at least one vaccine dose on its latest available vaccination date:
-- people_vaccinated / population) × 100
-- Display the country, date, people_vaccinated, population, and vaccination percentage. Exclude records where the required values are NULL or population is 0.

WITH latest_vaccination AS (
    SELECT
        iso_code,
        location,
        MAX(date) AS latest_date
    FROM covid_vaccinations
    WHERE continent IS NOT NULL
      AND TRIM(continent) <> ''
      AND people_vaccinated IS NOT NULL
    GROUP BY iso_code, location
)

SELECT
    v.location,
    v.date,
    v.people_vaccinated,
    d.population,
    ROUND(
        v.people_vaccinated / NULLIF(d.population, 0) * 100,
        2
    ) AS vaccination_percentage
FROM covid_vaccinations AS v
INNER JOIN latest_vaccination AS lv
    ON v.iso_code = lv.iso_code
   AND v.location = lv.location
   AND v.date = lv.latest_date
INNER JOIN covid_deaths AS d
    ON v.iso_code = d.iso_code
   AND v.location = d.location
   AND v.date = d.date
WHERE v.continent IS NOT NULL
  AND TRIM(v.continent) <> ''
  AND v.people_vaccinated IS NOT NULL
  AND d.population IS NOT NULL
  AND d.population > 0
ORDER BY vaccination_percentage DESC;


-- INSIGHT:
-- The results show substantial variation in the percentage of the
-- population that had received at least one vaccine dose across
-- countries and territories. Gibraltar records the highest percentage
-- in this dataset, while some locations have vaccination percentages
-- above 100%, highlighting the need to interpret vaccination counts
-- alongside the population estimates used in the dataset.


-- ======================
-- CATEGORY 3 — ADVANCED
-- ======================

-- Q11. Using a window function, calculate a 7-day rolling sum of new_cases for each country based on date. 
-- Display location, date, new_cases, and the rolling 7-day total. Exclude aggregate locations.


SELECT
    location,
    date,
    new_cases,
    SUM(new_cases) OVER (
        PARTITION BY location
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7_day_cases
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
ORDER BY location, date;

-- INSIGHT:
-- The 7-day rolling calculation smooths daily fluctuations in new
-- COVID-19 cases and provides a clearer view of short-term case trends.
-- This helps reduce the effect of unusually high or low single-day
-- case counts when analyzing the progression of cases over time.

-- Q12. Using the LAG() window function, calculate the day-over-day change in total_cases for each country.
-- Display location, date, total_cases, and the change from the previous available date.

SELECT
    location,
    date,
    total_cases,
    total_cases - LAG(total_cases) OVER (
        PARTITION BY location
        ORDER BY date
    ) AS daily_case_change
FROM covid_deaths
WHERE continent IS NOT NULL
  AND TRIM(continent) <> ''
ORDER BY location, date;

-- INSIGHT:
-- The day-over-day calculation shows how much cumulative COVID-19
-- cases changed between consecutive recorded dates for each country.
-- Using LAG() makes it possible to identify periods of faster or
-- slower growth in reported cumulative cases.

-- Q13. Using a CTE and a window function, rank countries within each continent by their maximum total_deaths.
-- Display continent, country, maximum total_deaths, and rank, and return only the top 3 countries from each continent.


WITH country_deaths AS (
    SELECT
        continent,
        location,
        MAX(total_deaths) AS maximum_total_deaths
    FROM covid_deaths
    WHERE continent IS NOT NULL
      AND TRIM(continent) <> ''
    GROUP BY continent, location
),

ranked_countries AS (
    SELECT
        continent,
        location,
        maximum_total_deaths,
        DENSE_RANK() OVER (
            PARTITION BY continent
            ORDER BY maximum_total_deaths DESC
        ) AS death_rank
    FROM country_deaths
)

SELECT
    continent,
    location,
    maximum_total_deaths,
    death_rank
FROM ranked_countries
WHERE death_rank <= 3
ORDER BY continent, death_rank, location;

-- INSIGHT:
-- The results identify the three countries with the highest recorded
-- cumulative COVID-19 deaths within each continent. The countries
-- appearing in the top three vary across continents, showing that
-- the distribution of cumulative deaths differs considerably by region.


-- Q14. Using a CTE and ROW_NUMBER(), identify the date on which each country recorded its highest daily new_cases. 
-- If a country has the same highest new_cases on multiple dates, return only the earliest date.


WITH ranked_cases AS (
    SELECT
        location,
        date,
        new_cases,
        ROW_NUMBER() OVER (
            PARTITION BY location
            ORDER BY new_cases DESC, date ASC
        ) AS case_rank
    FROM covid_deaths
    WHERE continent IS NOT NULL
      AND TRIM(continent) <> ''
      AND new_cases IS NOT NULL
)

SELECT
    location,
    date,
    new_cases AS highest_daily_new_cases
FROM ranked_cases
WHERE case_rank = 1
ORDER BY highest_daily_new_cases DESC, location;

-- INSIGHT:
-- The results identify the peak reported daily new_cases date for
-- each country. The timing of these peak days differs across countries,
-- indicating that countries experienced their highest reported daily
-- case counts at different stages of the pandemic.

-- Q15. Using both datasets, compare countries' vaccination progress and COVID-19 deaths at their latest available dates. For each country, calculate:
    -- fully vaccinated people as a percentage of population
    -- total deaths as a percentage of population.

WITH latest_deaths AS (
    SELECT
        iso_code,
        location,
        MAX(date) AS latest_death_date
    FROM covid_deaths
    WHERE continent IS NOT NULL
      AND TRIM(continent) <> ''
    GROUP BY iso_code, location
),

latest_vaccinations AS (
    SELECT
        iso_code,
        location,
        MAX(date) AS latest_vaccination_date
    FROM covid_vaccinations
    WHERE continent IS NOT NULL
      AND TRIM(continent) <> ''
      AND people_fully_vaccinated IS NOT NULL
    GROUP BY iso_code, location
),

death_values AS (
    SELECT
        d.iso_code,
        d.location,
        d.population,
        d.total_deaths
    FROM covid_deaths AS d
    INNER JOIN latest_deaths AS ld
        ON d.iso_code = ld.iso_code
       AND d.location = ld.location
       AND d.date = ld.latest_death_date
    WHERE d.population IS NOT NULL
      AND d.population > 0
      AND d.total_deaths IS NOT NULL
),

vaccination_values AS (
    SELECT
        v.iso_code,
        v.location,
        v.people_fully_vaccinated
    FROM covid_vaccinations AS v
    INNER JOIN latest_vaccinations AS lv
        ON v.iso_code = lv.iso_code
       AND v.location = lv.location
       AND v.date = lv.latest_vaccination_date
    WHERE v.people_fully_vaccinated IS NOT NULL
)

SELECT
    d.location,
    d.population,
    v.people_fully_vaccinated,
    d.total_deaths,

    ROUND(
        v.people_fully_vaccinated
        / NULLIF(d.population, 0) * 100,
        2
    ) AS fully_vaccinated_percentage,

    ROUND(
        d.total_deaths
        / NULLIF(d.population, 0) * 100,
        2
    ) AS deaths_percentage_of_population,

    RANK() OVER (
        ORDER BY
            v.people_fully_vaccinated
            / NULLIF(d.population, 0) DESC
    ) AS vaccination_rank

FROM death_values AS d

INNER JOIN vaccination_values AS v
    ON d.iso_code = v.iso_code
   AND d.location = v.location

ORDER BY vaccination_rank, d.location
LIMIT 10;


# Overall Project Insights

/*The analysis of the COVID-19 datasets reveals substantial differences in the **scale, timing, and progression of the pandemic across countries and continents**.
 Countries varied considerably in their maximum recorded cases, deaths, average daily new cases, and the dates at which major case thresholds were reached.

Population-adjusted analysis also shows that rankings can change significantly when comparing 
**deaths relative to population** rather than absolute death counts. 
This demonstrates why both absolute and normalized metrics are important when interpreting large-scale public-health data.

The vaccination analysis shows considerable variation in **vaccination coverage across countries and territories**.
 The project also highlights an important data-quality consideration: 
 some vaccination percentages can exceed 100% because recorded vaccination counts and
 population estimates may come from different sources or reflect different reporting characteristics.

The advanced SQL analysis using **CTEs and window functions** provided additional insight into how cases changed over time, 
including 7-day rolling case totals, day-over-day changes, country rankings within continents, and peak daily case dates.

### Overall Conclusion

> **The project demonstrates how SQL can transform large, time-series COVID-19 datasets into meaningful country-, 
continent-, and population-level analysis. It also shows the importance of data cleaning, appropriate aggregation, 
population normalization, and careful interpretation when working with real-world datasets.**

### Skills Demonstrated

**Data querying → Data cleaning → Aggregation → JOINs → CTEs → Window Functions → Time-series analysis → Population-adjusted metrics → Data interpretation**

This is a strong way to finish the project because it focuses on **what the analysis revealed and what you learned from the data**, 
rather than simply repeating the 15 individual query results.*/
























