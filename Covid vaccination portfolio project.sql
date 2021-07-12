
SELECT * 
FROM PortfolioProject..['Covid Death']+
WHERE continent IS NOT null
ORDER BY 3,4


-- Death percentile
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['Covid Death']
WHERE location like '%states%'
ORDER BY 1,2


--Infected population rate
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..['Covid Death']
--WHERE location like '%states%'
ORDER BY 1,2



-- Highest country infected rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..['Covid Death']
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc



-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['Covid Death']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount Desc


-- showing continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['Covid Death']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc


-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..['Covid Death']
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['Covid Death'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['Covid Death'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac




-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['Covid Death'] dea
JOIN PortfolioProject..['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

