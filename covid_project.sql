use porfolio_project_covid;
## there is a problem with the date on , we fixed with the next Query
UPDATE coviddeaths SET date =  str_to_date(  `date`, '%d/%m/%Y');
UPDATE covidvaccionations SET date =  str_to_date(  `date`, '%d/%m/%Y');

## extract the day just to know of the date is right
SELECT 
    extract(year from date) as day
FROM
    coviddeaths;
## let´s see both tables
SELECT 
    *
FROM
    coviddeaths
ORDER BY 3 , 4;

/*select *
from covidvaccionations
order by 3,4;*/

##select data that we are going to using
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
    ORDER BY 1 , 2;
    
##looking at total cases vs total deaths
##shows likelihood of dying if you contract covid in you country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS deadth_porcentage
FROM
    coviddeaths
WHERE
    location LIKE '%exic%'
ORDER BY 1 , 2;

##Lokking at total cases vs total popuilation
##shows what porcentage of population got covid
SELECT 
    location,
    date,
    population,
    total_cases,
    ROUND((total_cases / population) * 100, 4) AS infected_porcentage
FROM
    coviddeaths
##WHERE
    ##location LIKE '%exic%'
ORDER BY 1 , 2;

## looking at countries with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS highestInfectionCount,
    MAX(ROUND((total_cases / population) * 100, 4)) AS porcentagePopulationInfected
FROM
    coviddeaths
GROUP BY location , population
ORDER BY porcentagePopulationInfected desc;

## showing countries with highest death per population. Ojo usa  unsigned como tipo integer
## add where is not null to avoid errors
SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

##Let's break things down by continent
SELECT 
    continent,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

##Global numbers
SELECT 
   sum(new_cases) as total_cases,
   sum(cast(new_deaths as unsigned)) as total_deaths,
    ROUND((sum(new_deaths) / sum(new_cases)) * 100, 2) AS deadth_porcentage
FROM
    coviddeaths
where continent is not null
##group by date
ORDER BY 1 , 2;

##join to tables. Looking at total population vs vaccinations
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccionations vac ON dea.location = vac.location
        AND dea.date = vac.date
where continent is not null
order by 2,3;

## use CTE. EL CTE es como una tabla temporal
with PopvsVac(Continent,Location,Date,Population,New_vaccinations,Rolling_People_Vaccinated)
as
(SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccionations vac ON dea.location = vac.location
        AND dea.date = vac.date
 where dea.continent is not null       
order by 2,3)
SELECT 
    *,
    (Rolling_People_Vaccinated/Population)*100
FROM
    PopvsVac;
    
## temp Table
create table PercentPopulationVaccinated(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations varchar(255),
Rolling_People_Vaccinated numeric
);

##ojo aqui en la columna New_vaccinations cambie el tipo de dato a varchar ya que con integer marcaba error por tener valores null
insert into PercentPopulationVaccinated (
Continent,
Location,
Date,
Population,
New_vaccinations,
Rolling_People_Vaccinated)
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccionations vac ON dea.location = vac.location
        AND dea.date = vac.date;

## create a view to store data for later visualizations
create view PercentPopulation as
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccionations vac ON dea.location = vac.location
        AND dea.date = vac.date
where dea.continent is not null;
