select distinct country, city, event, athlete, medal
from winter
where lower(sport) like '%curling%' and year=2010 and lower(city) like '%vancouver%';

select distinct noc, games, city, event, name, medal
from athlete_events
where games='2010 Winter' and sport like 'Curl%';

(select distinct noc, 1 from athlete_events where games='2010 Winter' and sport='Curling'

except

(select distinct country, 1 from winter where year=2010 and sport='Curling'))

union

select country, 2 from winter where year=2010 and sport='Curling';

(select distinct country from winter where year=2010 and sport='Curling')

except

(select distinct noc from athlete_events where games='2010 Winter' and sport='Curling');

WITH in_games(noc) as
    (select distinct noc from athlete_events where lower(city) like '%barcelona%' and year = 1992),
    not_in_games(noc, num_competitors) as
    (select distinct noc, 0 from athlete_events where noc NOT IN (select noc from in_games))

select noc, count(distinct id) as num_competitors
from athlete_events
where lower(city) like '%barcelona%' and year = 1992
group by noc

union

select noc, num_competitors
from not_in_games

order by noc DESC;
