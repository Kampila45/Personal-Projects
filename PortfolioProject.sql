Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--TOTAL CASES VS TOTAL DEATHS 
--LIKELIHOOD OF DYING FROM INFECTION IF CONTRACTED
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Zambia%'
order by 1,2

--TOTAL CASES VS POPULATION
--PERCENTAGE OF PEOPLE WHO CONTRACTED COVID
Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Zambia%'
order by 1,2

--HIGHEST INFECTION RATE PER POPULATION
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Zambia%'
Group by Location, Population
order by InfectedPopulationPercentage desc

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Zambia%'
Group by Location, Population, date
order by InfectedPopulationPercentage desc
--HIGHEST DEATH COUNT PER POPULATION
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Zambia%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--BREAKING DOWN BY CONTINENT
--CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Zambia%'
Where continent is null
and location not in ('World' , 'European Union' , 'International')
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Zambia%'
Where continent is not null
--Group by date 
order by 1,2

--TOTAL POPULATION VS VACCINATIONS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
		
--TEMP TABLE

DROP Table if exists #VaccinatedPopulationPercentage
Create Table #VaccinatedPopulationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #VaccinatedPopulationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #VaccinatedPopulationPercentage


--CREATION OF VIEW

Create view VaccinatedPopulationPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From VaccinatedPopulationPercentage