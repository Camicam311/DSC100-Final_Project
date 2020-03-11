-- id -> name, sex, weight, height, age

-- games -> year, season

-- id, event -> sport (event -> sport)

-- id, games -> noc
-- id, team -> noc

-- id, event, games -> city (id, games -> city)
-- id, event, year -> city

-- city, year -> games, season

select id, event
from athlete_events
group by id, event
having count(distinct city) > 1;

select games
from athlete_events
group by games
having count(distinct city) > 1;

select distinct city
from athlete_events
where games = '1956 Summer';

select year
from summer
group by year
having count(distinct city) > 1;

select id, event, games, team
from athlete_events
group by id, event, games, team
having count(distinct medal) > 1
order by team;

select id, medal
from athlete_events
where lower(event)='sailing mixed 0-0.5 ton' and lower(games)='1900 summer' and team='Baby';

select id, team
from athlete_events
group by id, team
having count(distinct sport) > 1;

select id, event, games, medal, team
from athlete_events
group by id, event, games, medal, team
having count(distinct id) > 1 or count(distinct event) > 1 or count(distinct games) > 1 or
       count(distinct medal) > 1 or count(distinct year) > 1 or count(distinct city) > 1 or
       count(distinct sport) > 1 or count(distinct season) > 1 or count(distinct noc) > 1 or
       count(distinct team) > 1;

select id, event from athlete_events where medal is null group by id, event;

select games
from athlete_events
group by games
having count(distinct year) > 1 or count(distinct season) > 1;

select country
from dictionary
group by country
having count(distinct code)>1 or count(distinct population) > 1 or count(distinct gdp_per_capita)>1;

select noc
from noc_regions
group by noc
having count(distinct region)>1;

select id, year, season
from athlete_events
group by id, year, season
having count(distinct city) > 1;

select id, team from athlete_events group by id, team having count(distinct noc) > 1;

select id, year, season, team
from athlete_events
group by id, year, season, team
having count(distinct event) > 1;

select event from athlete_events group by event having count(distinct sport) > 1;

select * from athlete_events where lower(event) like '%steeple%';

select distinct discipline
from summer
where lower(sport) like'%aquatic%';

select sport, event, regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s')
from athlete_events;

select event, regexp_replace(event, E'(\\d+)( metres)', '\1M')
from athlete_events;

select sport, event, (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[1],
       (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[2]
from athlete_events;

select distinct sport from athlete_events order by sport;

select distinct sport, discipline, event, gender
from summer
where lower(sport) like '%rowing%' or lower(discipline) like '%rowing%'
group by sport, discipline, event, gender;

select distinct sport, event
from athlete_events
where lower(sport) like '%rowing%'
group by sport, event;

select distinct sport from athlete_events
except (
    (select distinct discipline from summer)
    union
    (select distinct discipline from winter))
order by sport;

select distinct b.team, b.noc
from athlete_events b
where b.team in
(select a.team
from athlete_events a
group by a.team
having count(distinct a.noc) > 1)
order by b.team;

select name from athlete_events where sport='Racquets' order by name;
select athlete from winter where athlete like 'NOEL%' and lower(athlete) like '%evan%' order by athlete;

select distinct athlete from summer;
select distinct name from athlete_events;

select athlete from winter where athlete like 'SCMITT%';

select name from athlete_events where lower(name) like '%dunai%';

select distinct id from athlete_events order by id ASC;

SELECT id, name, year, sex, age, weight, height
        FROM athlete_events
        GROUP BY id, name, year, sex, age, weight, height
        ORDER BY id ASC;

SELECT id, year, season, age, sex, weight, height
        FROM athlete_events
        WHERE id=5605
        GROUP BY id, year, season, age, sex, weight, height
        ORDER BY id, year, season ASC;


select id, year, season, age
from athlete_events
where id=54
group by id, year, season, age;

select id
from athlete_events
group by id
having count(distinct name) > 1 or count(distinct sex) > 1;

select id, year
from athlete_events
group by id, year
having count(distinct age) > 1
order by id;

select id, year, season, age, height, weight
from athlete_events
where id = 127335;

select name from athlete_events where id=10991;

select distinct event, season
from athlete_events
where event IN
    (select event
        from athlete_events
        group by event
        having count(distinct season) > 1)
order by event;

select year, city
from athlete_events
group by year, city
having count(distinct season) > 1;

select id, year, event
from athlete_events
group by id, year, event
having count(distinct city) > 1;

select id, year, team, event, medal
from athlete_events
group by id, year, team, event, medal
having count(distinct name) > 1 or count(distinct sex) > 1 or count(distinct noc) > 1 or count(distinct sport) > 1
    or count(distinct season) > 1;

select team
from athlete_events
group by team
having count(distinct noc) > 1;

select name from athlete_events group by name having count(distinct sex) > 1;

select id from athlete_events group by id;

select id, name, sex from athlete_events group by id, name, sex;

select distinct name from athlete_events order by name ASC;

select regexp_split_to_array(lower(athlete), E', ')
from summer;

select distinct event
from athlete_events
where lower(event) NOT LIKE '%men%' and lower(event) not like '%women%' and lower(event) not like '%mixed%';





CREATE TEMPORARY TABLE athlete_matches(
    id int,
    name text,
    athlete text,
    noc text
);

INSERT INTO athlete_matches(id, name, athlete, noc)
(select id, name, athlete, noc
from athlete_events, summer
where country=noc and athlete_events.year=summer.year and (regexp_split_to_array(lower(name), E' ') <@ regexp_split_to_array(lower(athlete), E'(, | )') or
      regexp_split_to_array(lower(name), E' ') @> regexp_split_to_array(lower(athlete), E'(, | )'))

union

select id, name, athlete, noc
from athlete_events, winter
where country=noc and athlete_events.year=winter.year and (regexp_split_to_array(lower(name), E' ') <@ regexp_split_to_array(lower(athlete), E'(, | )') or
      regexp_split_to_array(lower(name), E' ') @> regexp_split_to_array(lower(athlete), E'(, | )'))

order by id);

select id, name, athlete
from athlete_matches
where id in (select id from athlete_matches group by id having count(*) > 1)
order by id;

select id, name, athlete, noc
from athlete_matches
where athlete IN (select athlete from(select athlete, noc from athlete_matches group by athlete, noc having count(*) > 1) a) and
      id not in (select id from athlete_matches group by id having count(*) > 1)
order by id;


--blocking: create blocks of potential matches
--create block anchor: attributes that need to match before you consider it a possible match

select name, noc, country, athlete, athlete_events.event, summer.event
from athlete_events, summer
where id=10920 and athlete='BERTRAND' and noc='FRA'
union

select name, noc, country, athlete, athlete_events.event, winter.event
from athlete_events, winter
where id=10920 and athlete='BERTRAND' and noc='FRA'

order by athlete;

select sport, event
from athlete_events
where lower(event) like '%mixed%';

SELECT athlete,
        CASE
           WHEN gender='Men' THEN 'M'
           WHEN gender='Women' THEN 'F'
        END AS gender
FROM summer
WHERE (athlete, country) NOT IN (SELECT athlete, country FROM athlete_matches);


SELECT (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[1] as discipline, sex,
       (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[2] as event
FROM athlete_events
WHERE lower(event) NOT LIKE '%mixed%'

union

SELECT (regexp_split_to_array(event, E'\\sMixed\\s'))[1], sex,
       CONCAT('Mixed ', (regexp_split_to_array(event, E'\\sMixed\\s'))[2])
FROM athlete_events
WHERE lower(event)  LIKE '%mixed%';
