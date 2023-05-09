#Selected data that we want to use 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
ORDER BY 1,2;

#Total cases vs Total death 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Totaldeath_vs_Totalcases
FROM portfolioproject.coviddeaths
ORDER BY 1,2;

#gives a rough estimate of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Totaldeath_vs_Totalcases
FROM portfolioproject.coviddeaths
WHERE location LIKE '%india%'
ORDER BY 1,2;

#Percentage of population that got covid 

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Percentagepopulation
FROM portfolioproject.coviddeaths
WHERE location LIKE '%india%'
ORDER BY date DESC;

#Highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population)) * 100 AS PercentagepopulationINFECTED
FROM portfolioproject.coviddeaths
GROUP BY location, population
ORDER BY PercentagepopulationINFECTED DESC;

#Highest deathcount compared to the population (by countries)

SELECT location, MAX(cast( total_deaths AS unsigned)) AS Highestdeathcount
FROM portfolioproject.coviddeaths
WHERE location <> 'Europe' AND location <> 'North America' AND location <> 'European Union' AND location <> 'South America' AND location <> 'Africa'
GROUP BY location
ORDER BY Highestdeathcount DESC;

#Highest deathcount compared to the population (by continent)

SELECT location, MAX(cast( total_deaths AS unsigned)) AS Highestdeathcount
FROM portfolioproject.coviddeaths
where location IN ('Europe' , 'North America','European Union','South America','Asia','Africa','Oceania')
GROUP BY location
ORDER BY Highestdeathcount DESC;

#Global numbers for new cases

SELECT date , sum(new_cases) AS Totalcases , sum(cast(new_deaths AS unsigned)) AS TotalDeaths, sum(cast(new_deaths AS unsigned))/sum(new_cases) * 100 AS NewDeathPercentage
FROM portfolioproject.coviddeaths
GROUP BY date
ORDER BY 1,2;

SELECT sum(new_cases) AS Totalcases , sum(cast(new_deaths AS unsigned)) AS TotalDeaths, sum(cast(new_deaths AS unsigned))/sum(new_cases) * 100 AS NewDeathPercentage
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

#Total population vs Total vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(cast(vac.new_vaccinations AS unsigned)) OVER (partition by dea.location order by dea.location, dea.date) AS Rollingpeoplevaccinated
From portfolioproject.coviddeaths dea
Join portfolioProject.covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

#Using CTE to perform calculation on the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(cast(vac.new_vaccinations AS unsigned)) OVER (partition by dea.location order by dea.location, dea.date) AS Rollingpeoplevaccinated
From portfolioproject.coviddeaths dea
Join portfolioProject.covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

#Creating view for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolioproject.coviddeaths dea
Join portfolioproject.covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

SELECT * FROM portfolioproject.percentpopulationvaccinated;














