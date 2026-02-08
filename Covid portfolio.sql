Select *
From project..CovidDeaths
Where continent is not null
Order by 3,4

 --check table
Select *
From project..CovidVaccinations
Order by 3,4

--Select Data that will be used

Select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	new_deaths, 
	population
From project..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths (likelihood of dying)
Select location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
From project..CovidDeaths
Where location like '%phili%'
order by 1,2


-- total cases vs population
Select 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as InfectionRate
From project..CovidDeaths
--Where location like '%france%'
order by 1,2

-- looking at countries with highest infection rates
Select 
	location, 
	population, 
	Max(total_cases) as HighestInfectionRate, 
	Max((total_cases/population))*100 as InfectionRate
From project..CovidDeaths
Group by location, population
Order by InfectionRate desc

--looking at highest death
Select location, 
	Max(cast(total_deaths as int)) as TotalDeathCount
From project..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--looking things at continent level
--showing continents with highest death count
Select 
	continent, 
	Max(cast(total_deaths as int)) as TotalDeathCount
From project..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers
Select 
	Sum(new_cases) as TotalCases, 
	Sum(cast(new_deaths as int)) as totalDeaths, 
	(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From project..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- total vax
Select 
	dea.continent, 
	dea.location, dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVax
From project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--CTE 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPplVax)
as
(
Select 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVax 
From project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPplVax/population)*100 as Ratio
From PopvsVac

-- temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPplVax numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVax 
From project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPplVax/population)*100 as Ratio
From #PercentPopulationVaccinated


-- create view to store data for later visualization
Create view PercentPopulationVaccinated as 
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPplVax 
From project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

