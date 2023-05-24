select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4

select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4

----select data 
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--total cases vs total deaths
--shows the liklihood of dying if contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the total cases vs. pop
shows what pop has covid
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as MaxTotalCase, max((total_cases/population))*100 as InfectedPercentage
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by InfectedPercentage desc

--countries with the highest death count per pop
select location, population, max(total_deaths) as TotalDeathCount, max(total_deaths/population)*100 as DeathPercentage
from dbo.CovidDeaths
group by location, population
order by DeathPercentage desc

--countries with the highest death count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--broken down by continent
select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not NULL
--group by DATE
order by 1,2

-- total pop vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use a CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVac)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVac/population)*100 as VacPercentage
from PopvsVac

-- TEMP table
Drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
    Continent nvarchar(50),
    Location nvarchar(50),
    Date date,
    Population FLOAT,
    New_vaccinations float,
    RollingPeopleVac NUMERIC
)
Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVac/population)*100 as VacPercentage
from #PercentPeopleVaccinated

--View to store data for later visualizations
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT*
FROM PercentPopulationVaccinated