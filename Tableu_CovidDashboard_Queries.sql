Tableau Queries

create table TableauTable1 (
TotalCases float,
TotalDeaths numeric,
DeadthPercentage float)
Insert into TableauTable1
select sum(cast(new_cases as float)) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(cast(new_cases as float)))*100 as DeadthPercentage
from CovidDeaths 
where continent is not null

select * from TableauTable1;



create table TableauTable2 (
location nvarchar(255),
TotalDeathCount numeric)
Insert into TableauTable2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

select * from TableauTable2


create table TableauTable3 (
location nvarchar(255),
Population numeric,
HighestInfectionCount float,
PercentPopulationInfected float)
Insert into TableauTable3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population


select * from TableauTable3 order by PercentPopulationInfected desc

create table TableauTable4 (
location nvarchar(255),
Population numeric,
date date,
HighestInfectionCount float,
PercentPopulationInfected float)
Insert into TableauTable4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date

select * from TableauTable4 order by PercentPopulationInfected desc;