select  location,date,total_cases,new_Cases,total_deaths,population from CovidDeaths order by 1,2;
--alter table CovidDeaths alter column location varchar(200);
---Look for Total cases vs total deaths for the country which is death percentage
---Likelihood of dying if covid contact country wise
select * from CovidDeaths where continent is not null;
select  location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths 
where location like '%ndia%'
order by 1,2;

select  location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths 
where location like '%states%'
order by 1,2;

-- Total Covid cases vs Population
-- calculates what percentage of population got Covid infected

select  location,date,Population,total_cases,(total_cases/population)*100 as InfectionRate 
from CovidDeaths 
where location like '%india%'
order by 1,2;


select  location,date,Population,total_cases,(total_cases/population)*100 as InfectionRate 
from CovidDeaths 
where location like '%states%'
order by 1,2;

-- Countries with Highest Covid InfectionRate compared to Population

select  location,Population,max(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as InfectionRate 
from CovidDeaths 
group by location,population
order by InfectionRate desc;

-- Country with Highest deadth count per population

select  location,population,max(total_deaths) as TotalDeadthCnt
from CovidDeaths
where continent is not null
group by location,population
order by TotalDeadthCnt desc;

---continent with highest deadth count per population


select  continent,max(total_deaths) as TotalDeadthCnt
from CovidDeaths
where continent is not null
group by continent
order by TotalDeadthCnt desc;

--global numbers

select  date,sum(cast(new_cases as float)) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(cast(new_cases as float)))*100 as DeadthPercentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2;

select sum(cast(new_cases as float)) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(cast(new_cases as float)))*100 as DeadthPercentage
from CovidDeaths 
where continent is not null
--group by date
order by 1,2;

--- Total population in world has been vaccinated
select * 
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date = vac.date;

-- This query gives sum/total vaccines over entire location because there is no order by in partition frame.
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from CovidDeaths dea join CovidVaccinations vac 
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null and dea.location ='India'
order by 2,3;

-- This query will start sum/total vaccines over location and date wise because of order by clause in partition frame.
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVacccinated
from CovidDeaths dea join CovidVaccinations vac 
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null and dea.location ='India'
order by 2,3; 

-- to check how many people in the respective country are vaccinated ,use CTE
with PopVsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVacccinated ) as
(select dea.continent,dea.location,dea.date,cast(dea.population as float),vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVacccinated
from CovidDeaths dea join CovidVaccinations vac 
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null and dea.location ='Albania'
) Select *, RollingPeopleVacccinated/population*100 from PopVsVac;


-- TEMP TABLE , same can be done as above using temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVacccinated
from CovidDeaths dea join CovidVaccinations vac 
on dea.location=vac.location and dea.date = vac.date
--where dea.continent is not null;-- and dea.location ='India'

select *, (RollingPeopleVacccinated/population)*100 
from #PercentPopulationVaccinated;

--- Create view for storing data which can be used later for visualisation in Tableau

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVacccinated
from CovidDeaths dea join CovidVaccinations vac 
on dea.location=vac.location and dea.date = vac.date
where dea.continent is not null --and dea.location ='India'
--order by 2,3; 

select * from PercentPopulationVaccinated















































