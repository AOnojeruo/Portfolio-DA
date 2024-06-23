
/*
complete
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT location,date,total_cases,new_cases,total_deaths,population
  FROM [Project].[dbo].[CovidDeaths]
  WHERE continent is not null 
  order by 1,2

-- mortality rate
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Project].[dbo].[CovidDeaths]
Where continent is not null 
	 
order by 1,2

 

-- TOP 10 countries for motality rate
Select top 10 location, (max(total_deaths)/max(total_cases))*1000  as mortality_rate_per_1000
From [Project].[dbo].[CovidDeaths]
 where continent is not null 
 group by continent,location
 order by mortality_rate_per_1000 desc

 -- total cases vs population
 --the percentage fo the population infected with covid 

 -- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Project].[dbo].[CovidDeaths]
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Project].[dbo].[CovidDeaths]
Where continent is not null 
Group by Location,continent
order by TotalDeathCount desc



--analysis on continental level
-- contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Project].[dbo].[CovidDeaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Project].[dbo].[CovidDeaths]
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows rolling sum of people  that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Project].[dbo].[CovidDeaths] dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	--and vac.new_vaccinations is not null
order by 2,3

-- alternatively we can Use a CTE to perform Calculation on Partition By 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [Project].[dbo].[CovidDeaths] dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [Project].[dbo].[CovidDeaths]dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--views

-- View to store data for later visualizations
go
Create View ProportionPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Project].[dbo].[CovidDeaths] dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
go

-- view to see what infected poulation for any country 
create view InfectionPercentage as 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Project].[dbo].[CovidDeaths]
Group by Location, Population

