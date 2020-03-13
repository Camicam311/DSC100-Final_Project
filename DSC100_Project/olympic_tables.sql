-- LOAD DATA

CREATE TEMPORARY TABLE athlete_events (
    id int,
    name text,
    sex char,
    age text,
    height text,
    weight text,
    team text,
    noc char(3),
    games text,
    year int,
    season varchar(6),
    city text,
    sport text,
    event text,
    medal text
);

CREATE TEMPORARY TABLE dictionary (
    country text,
    code char(3),
    population int,
    gdp_per_capita float
);

CREATE TEMPORARY TABLE noc_regions (
    noc char(3),
    region text,
    notes text
);

CREATE TEMPORARY TABLE summer (
    year    int,
    city    text,
    sport   text,
    discipline text,
    athlete text,
    country char(3),
    gender varchar(5),
    event text,
    medal text
);

CREATE TEMPORARY TABLE winter (
    year    int,
    city    text,
    sport   text,
    discipline text,
    athlete text,
    country char(3),
    gender varchar(5),
    event text,
    medal text
);

COPY athlete_events FROM '/Users/joshuacastro/Desktop/data_science/dsc100/project/athlete_events.csv' CSV HEADER;
COPY dictionary FROM '/Users/joshuacastro/Desktop/data_science/dsc100/project/dictionary.csv' CSV HEADER;
COPY noc_regions FROM '/Users/joshuacastro/Desktop/data_science/dsc100/project/noc_regions.csv' CSV HEADER;
COPY summer FROM '/Users/joshuacastro/Desktop/data_science/dsc100/project/summer.csv' CSV HEADER;
COPY winter FROM '/Users/joshuacastro/Desktop/data_science/dsc100/project/winter.csv' CSV HEADER;

UPDATE athlete_events
SET age = NULL
WHERE age = 'NA';

UPDATE athlete_events
SET weight = NULL
WHERE weight = 'NA';

UPDATE athlete_events
SET height = NULL
WHERE height = 'NA';

UPDATE athlete_events
SET medal = NULL
WHERE medal = 'NA';

ALTER TABLE athlete_events
    ALTER COLUMN age SET DATA TYPE int  USING age::integer,
    ALTER COLUMN weight SET DATA TYPE float USING weight::float,
    ALTER COLUMN height SET DATA TYPE float USING height::float;

UPDATE athlete_events SET team = (regexp_match(team, E'(^\\d{0,2}[^\\d]*(#\\d+)?( \\d{1,4})?)(-\\d{1,2})?$'))[1];

UPDATE athlete_events SET event = regexp_replace(event, E'(\\d+)( metres)', '\1M', 'g');
UPDATE athlete_events SET event = regexp_replace(event, E'(\\d+)( kilometres)', '\1KM', 'g');


-- FIND ATHLETE OVERLAP BETWEEN athlete_events and summer/winter

CREATE TEMPORARY TABLE athlete_matches(
    id int,
    name text,
    sex char,
    athlete text
);

CREATE TABLE country
(
    alt_noc char(3) PRIMARY KEY,
    main_noc char(3),
    country text,
    population int,
    gdp_per_capita float
);

UPDATE dictionary
SET country = CASE
      WHEN right(country,1) = '*' THEN
         substr(country, 1, length(country) - 1)
      ELSE
         country
      END;

INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(
    WITH country_sub(country, region) AS
    (SELECT D.country, N.region
    FROM dictionary D, noc_regions N
    WHERE D.country <> N.region and
          D.country = any(string_to_array(N.region,' '))
          and N.region <> 'South Sudan' and N.region <> 'Democratic Republic of the Congo' and
          N.region <> 'Papua New Guinea' and N.region <> 'American Samoa' and
          N.region <> 'Equatorial Guinea')

    SELECT distinct  N.noc, D.code, D.country, D.population, D.gdp_per_capita
    FROM dictionary D, noc_regions N, country_sub
    WHERE (D.country=N.region OR (D.country=country_sub.country AND N.region=country_sub.region) OR
          D.code=N.noc) AND (N.noc <> 'HKG')

    UNION
    select distinct N.noc, N.noc, N.region, NULL::int, NULL::float
    FROM noc_regions N
    WHERE N.region NOT IN (SELECT region from country_sub) AND
          N.region NOT IN (SELECT country from dictionary) AND
          N.noc NOT IN (SELECT code from dictionary)

    UNION
    SELECT 'SSD', 'SSD', 'South Sudan', NULL, NULL
    UNION
    SELECT 'COD', 'COD', 'Congo, Dem Rep', 77266814, 456.052740548027
    UNION
    SELECT 'PNG', 'PNG', 'Papua New Guinea', 7619321, NULL
    UNION
--     SELECT 'ASA', 'ASA', 'American Samoa', 55538, NULL
--     UNION
    SELECT 'GEQ', 'GEQ', 'Equatorial Guinea', 845060, 14439.5944478516
    UNION
    SELECT 'HKG', 'HKG', 'Hong Kong', 7305700, 42327.8399570345

    ORDER BY country
);

INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
VALUES('ZZX', 'ZZX', 'Mixed Team', NUll, NULL);
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(SELECT 'EUA', 'GER', c.country, c.population, c.gdp_per_capita
FROM country c
WHERE c.alt_noc='GER');
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(SELECT 'SGP', 'SIN', c.country, c.population, c.gdp_per_capita
FROM country c
WHERE c.alt_noc='SIN');
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(SELECT 'TRI', 'TTO', c.country, c.population, c.gdp_per_capita
FROM country c
WHERE c.alt_noc='TTO');
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(SELECT 'TRT', 'TTO', c.country, c.population, c.gdp_per_capita
FROM country c
WHERE c.alt_noc='TTO');
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
VALUES('IOP', 'IOP', 'Independent', NUll, NULL);
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(SELECT 'RU1', 'RUS', c.country, c.population, c.gdp_per_capita
FROM country c
WHERE c.alt_noc='RUS');
INSERT INTO country(alt_noc, main_noc, country, population, gdp_per_capita)
(SELECT 'BWI', 'ANT', c.country, c.population, c.gdp_per_capita
FROM country c
WHERE c.alt_noc='ANT');

INSERT INTO athlete_matches(id, name, sex, athlete)
(select id, name, sex, athlete
from athlete_events, summer, country
where summer.country=alt_noc and noc=alt_noc and athlete_events.year=summer.year and
      (regexp_split_to_array(lower(name), E' ') <@ regexp_split_to_array(lower(athlete), E'(, | )') or
      regexp_split_to_array(lower(name), E' ') @> regexp_split_to_array(lower(athlete), E'(, | )')) and athlete_events.medal is not NULL and
      ((sex='M' and gender='Men') OR (sex='W' and gender='Women'))

group by id, name, athlete, sex

union

select id, name, sex, athlete
from athlete_events, winter, country
where winter.country=alt_noc and noc=alt_noc and athlete_events.year=winter.year and (regexp_split_to_array(lower(name), E' ') <@ regexp_split_to_array(lower(athlete), E'(, | )') or
      regexp_split_to_array(lower(name), E' ') @> regexp_split_to_array(lower(athlete), E'(, | )')) and athlete_events.medal is not NULL and
      ((sex='M' and gender='Men') OR (sex='W' and gender='Women'))

group by id, name, athlete, sex

order by id);


DELETE FROM athlete_matches
WHERE (id = 674 and athlete='ACHIK, Abdelhak') OR
(id=4590 and athlete='ANTONSSON, Bertil') OR
(id=10296 and athlete='DUMITRU, Marian') OR
(id=11259 and athlete='BIANCHI, Pietro') OR
(id=11260 and athlete='BIANCHI, Pietro Ubaldo') OR
(id=14949 and athlete='BRENNAN, Michael') OR
(id=24730 and athlete='RAFAEL') OR
(id=33630 and athlete='FABIANA') OR
(id=33638 and athlete='FABIANA') OR
(id=45684 and athlete='HANSEN, Joseph') OR
(id=48256 and athlete='HESS') OR
(id=53556 and athlete='JAMVOLD, Petter') OR
(id=55319 and athlete='JOHNSON, Sydney B.') OR
(id=58558 and athlete='KELLY') OR
(id=59173 and athlete='SHAHID, Ali Khan') OR
(id=66798 and athlete='LARSEN, Ludvig') OR
(id=69434) OR
(id=74746 and athlete='MARCELO') OR
(id=88859 and athlete='OLSEN, Ole') OR
(id=93891 and athlete='PETERSEN, Erik') OR
(id=94221 and athlete= 'PETTERSSON, Erik') OR
(id=94226 and athlete= 'PETTERSSON, Albert') OR
(id=109492 and athlete= 'KELLY') OR
(id=111012 and athlete='SINGH, Balbir II') OR
(id=111012 and athlete= 'SINGH, Balbir III') OR
(id=111013 and athlete='SINGH, Balbir I') OR
(id=111013 and athlete='SINGH, Balbir III') OR
(id=111014 and athlete='SINGH, Balbir I') OR
(id=111014 and athlete= 'SINGH, Balbir II') OR
(id=111055 and athlete= 'SINGH, Singh') OR
(id=111257 and athlete= 'SINGH, Singh') OR
(id=128113 and athlete= 'WALKER, Samuel John') OR
(id=132560) OR
(id=132561 and athlete='YANG (A), Yang') OR
(id=132562 and athlete='YANG (S), Yang') OR
(id=132573 and athlete='YU, Yang') OR
(id=133185 and athlete='YOUNG') OR
(id=133380) OR
(id=133381 and athlete='YANG, Yu') OR
(id=1102 and athlete='MANNA, Muhammad Afzal') OR
(id=1366 and athlete='SINGH, Singh') OR
(id=2545 and athlete='OLIVEIRA, Alessandra') OR
(id=2751 and athlete='ALINE');


-- REFORMAT athlete_events.event

ALTER TABLE athlete_events
ADD COLUMN discipline text;

UPDATE athlete_events
SET discipline=CASE
    WHEN lower(event) NOT LIKE '%mixed%' THEN (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[1]
    WHEN lower(event) LIKE '%mixed%' THEN (regexp_split_to_array(event, E'\\sMixed\\s'))[1]
    END;
UPDATE athlete_events
SET event=
    CASE
        WHEN lower(event) NOT LIKE '%mixed%' THEN (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[2]
        WHEN lower(event) LIKE '%mixed%' THEN CONCAT('Mixed ', (regexp_split_to_array(event, E'\\sMixed\\s'))[2])
    END;

-- CALL format_athlete_events.sql HERE

-- ALPINE SKIING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change alpine skiing to skiing
UPDATE athlete_events
SET sport = 'Skiing'
WHERE lower(sport) like 'alpine skiing%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- BASQUE PELOTA
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update_bp;
-- change
UPDATE athlete_events
SET event = E'Cesta Punta'
WHERE lower(sport) like 'basque%';
-- ROLLBACK TO SAVEPOINT pre_update_bp;
COMMIT;

-- BEACH VOLLEYBALL
--- IN ATHLETE_EVENTS
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Volleyball'
WHERE sport ilike 'beach volleyball%';

UPDATE summer
SET discipline = 'Beach Volleyball'
where sport ilike 'volley%' and discipline ilike 'beach%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- BOBSLEIGH
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE winter
SET event = regexp_replace(event, E'\-[A-Za-z]{3,5}', '')
WHERE lower(sport) like '%bobsleigh%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- BOXING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer as s set event = c.col_a
FROM (values
            ('Super-Heavyweight', '+ 91KG', 'Men'),
            ('Light-Flyweight', '46 - 49KG', 'Men'),
            ('Featherweight','51 KG', 'Women'),
            ('Featherweight','51KG', 'Women'),
            ('Bantamweight', '52KG', 'Men'),
            ('Featherweight ','56KG', 'Men'),
            ('Lightweight','56 - 60KG', 'Men'),
            ('Lightweight','57 - 60KG', 'Men'),
            ('Light-Welterweight','60 - 64 KG', 'Men'),
            ('Lightweight', '60 KG', 'Women'),
            ('Lightweight', '60KG', 'Women'),
            ('Welterweight', '64 - 69 KG', 'Men'),
            ('Middleweight', '69 - 75 KG', 'Men'),
            ('Middleweight', '71-75KG', 'Men'),
            ('Light-Heavyweight', '75 - 81KG', 'Men'),
            ('Middleweight', '75 KG', 'Women'),
            ('Heavyweight', '81 - 91KG', 'Men')
        ) as c(col_a, col_b, col_c)
WHERE lower(sport) like '%boxing%' and event = col_b and gender = col_c;
--ROLLBACK TO SAVEPOINT pre_update;
UPDATE summer
SET event = (regexp_match(event, E'(\\()(\\w+\-*\\s*\\w*)(\\))'))[2]
WHERE lower(sport) like '%boxing%' and lower(event) like '%(%';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

--CANOEING
BEGIN;
--add savepoint
SAVEPOINT pre_update;
--make changes
UPDATE athlete_events
SET event = regexp_replace(event, E'\,', '')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = concat(event, 'Slalom')
WHERE discipline ilike '%slalom%';

UPDATE summer
SET event = regexp_replace(event, E'C', 'Canadian')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'K', 'Kayak')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'-1', ' Singles')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'-2', ' Doubles')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'-4', ' Fours')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'(\\d{1,2}),(\\d{3})', E'\1\2')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'10KM', '10000M')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'(\\()(\\w+\\s*\\w*)(\\))', '')
WHERE sport ilike '%canoe%';

UPDATE summer
SET discipline = 'Canoeing'
WHERE discipline ilike '%canoe%';

UPDATE summer
SET sport = 'Canoeing'
WHERE sport ilike '%canoe%';

COMMIT;


-- CROQUET
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event =  regexp_replace(event, 'Double', 'Doubles')
WHERE lower(sport) like '%croquet%';

-- change
UPDATE summer
SET event = regexp_replace(event, 'Individual 1', 'Singles, One')
WHERE lower(sport) like '%croquet%';

-- change
UPDATE summer
SET event =  regexp_replace(event, 'Individual 2', 'Singles, Two')
WHERE lower(sport) like '%croquet%';

UPDATE summer
SET event = concat('Mixed ', event)
WHERE sport ilike '%croquet%';

--ROLLBACK TO pre_update;
COMMIT;

-- CROSS COUNTRY SKIING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;

-- change
UPDATE athlete_events
SET event = regexp_replace(event, E'( km)+', 'KM'),
    sport = 'Skiing'
WHERE lower(sport) like '%cross country skiing%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- CYCLING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;

UPDATE summer
SET event = 'BMX'
WHERE lower(discipline) like '%cycling bmx%' and lower(event) like 'individual';

UPDATE summer
SET discipline = 'Cycling'
WHERE lower(discipline) like '%cycling%';

UPDATE summer
SET event = regexp_replace(event, E'(\\()(\\d+.\\d*(KM|M){1,2})(\\))', '')
WHERE discipline ilike '%cycling%';

UPDATE summer
SET event = regexp_replace(event, E'\,','')
WHERE discipline ilike '%cycling%';

UPDATE summer
SET event = regexp_replace(event, 'mile', 'Mile')
WHERE discipline ilike '%cycling%';

-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- DIVING
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Aquatic'
WHERE lower(sport) like '%diving%';

UPDATE summer
SET event = regexp_replace(event, E'\\s\\d{1,2}M', '')
WHERE lower(discipline) like '%diving%';

UPDATE summer
SET event = regexp_replace(event, E'\\d{1,2}M\\s', '')
WHERE lower(discipline) like '%diving%';

UPDATE summer
SET event = regexp_replace(event, E'\\s\\d{1,2}M\\s', ' ')
WHERE lower(discipline) like '%diving%';

--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- EQUESTRIANISM
BEGIN;

SAVEPOINT pre_update;

UPDATE athlete_events
SET sport = 'Equestrian',
    discipline = 'Equestrian'
WHERE sport ilike 'equestrianism';

UPDATE athlete_events
SET event = regexp_replace(event, E'Mixed ', '')
WHERE event ilike 'mixed%';

SAVEPOINT pre_fix;

UPDATE athlete_events
SET discipline = 'Dressage',
    event = regexp_replace(event, 'Dressage, ','')
WHERE event ilike '%dressage%';

UPDATE athlete_events
SET discipline = 'Vaulting',
    event = regexp_replace(event, E'Vaulting, ','')
WHERE event ilike '%vaulting%';

UPDATE athlete_events
SET discipline = 'Jumping',
    event = regexp_replace(event, E'Jumping, ','')
WHERE event ilike '%jump%';

--ROLLBACK TO pre_update;

COMMIT;


-- FENCING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET event = regexp_replace(event, E'epee', E'Épée')
WHERE lower(sport) like '%fencing%';

--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- FIGURE SKATING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE winter
SET event = 'Singles'
WHERE lower(sport) like '%skating%' and lower(discipline) like 'figure skating'
  and lower(event) like 'individual';

UPDATE athlete_events
SET sport = 'Skating'
WHERE sport ilike 'figure skating';

--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

--FREESTYLE SKIING
BEGIN;
SAVEPOINT pre_update;
UPDATE athlete_events
SET sport = 'Skiing'
WHERE sport ilike 'freestyle skiing';
COMMIT;

-- GYMNASTICS
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event = regexp_replace(event, E'\\s(All-(Ar|R)ound|Competition)', '')
WHERE lower(discipline) like '%gymnastics artistic%' or lower(discipline) like '%aristic g.'
  or lower(discipline) like '%gymnastics%';
UPDATE summer
SET discipline = 'Gymnastics'
WHERE lower(discipline) like '%artistic%';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- ICE HOCKEY
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET sport = 'Hockey'
WHERE lower(discipline) like '%ice hockey%';
UPDATE winter
SET sport = 'Hockey'
WHERE lower(discipline) like '%ice hockey%';
UPDATE athlete_events
SET sport = 'Hockey'
WHERE lower(sport) like '%ice hockey%';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- JEU DE PAUME
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event = 'Singles',
    sport = 'Jeu De Paume',
    discipline = 'Jeu De Paume'
WHERE lower(discipline) like '%jeu de paume%';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- JUDO
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer as s set event = c.col_a
FROM (values
            ('Heavyweight', '+ 100KG', 'Men'),
            ('Heavyweight', '+ 78KG', 'Women'),
            ('Extra-Lightweight','- 48 KG', 'Women'),
            ('Lightweight','- 60 KG', 'Men'),
            ('Half-Lightweight', '48 - 52KG', 'Women'),
            ('Lightweight ','52 - 57KG', 'Women'),
            ('Half-Middleweight','57 - 63KG', 'Women'),
            ('Half-Lightweight','60 - 65KG', 'Men'),
            ('Half-Lightweight','60 - 66KG', 'Men'),
            ('Half-Middleweight', '63 - 70KG', 'Women'),
            ('Lightweight', '66 - 73KG', 'Men'),
            ('Half-Heavyweight', '70 - 78KG', 'Women'),
            ('Half-Middleweight', '73 - 81KG', 'Men'),
            ('Middleweight', '81 - 90KG', 'Men'),
            ('Half-Heavyweight', '90 - 100KG', 'Men')
        ) as c(col_a, col_b, col_c)
WHERE lower(sport) like '%judo%' and event = col_b and gender = col_c;
UPDATE summer
SET event = (regexp_match(event, E'(\\()(\\w+\-*\\s*\\w*)(\\))'))[2]
WHERE lower(sport) like '%judo%' and lower(event) like '%(%';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- LUGE
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET event = regexp_replace(event, E'\\sTeam\\s', ' ')
WHERE lower(sport) like '%luge%';
UPDATE athlete_events
SET event = regexp_replace(event, E'\\s\\(Men\\)(\')s\\s', ' ')
WHERE lower(sport) like '%luge%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- MODERN PENTATHLON
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event = regexp_replace(event, E'\\sCompetition', '')
WHERE lower(sport) like '%modern pentathlon%';
UPDATE summer
SET discipline = 'Modern Pentathlon'
WHERE lower(sport) like '%modern pentathlon%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- NORDIC COMBINED
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Skiing',
    event = regexp_replace(event, E'\\skm,', 'KM')
WHERE discipline ilike '%nordic combined%';

ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- RHYTHMIC GYMNASTICS
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event = regexp_replace(event, E'\\s(All-(Ar|R)ound|Competition)', '')
WHERE lower(discipline) like '%rhythmic%';
UPDATE summer
SET discipline = 'Rhythmic Gymnastics'
WHERE lower(discipline) like '%rhythmic%';
UPDATE athlete_events
SET sport = 'Gymnastics'
WHERE sport ilike '%rhythmic%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

-- ROQUE
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET event = 'Individual'
WHERE lower(sport) like '%roque%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- ROWING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event = regexp_replace(event, E'(\\s\\d.*$|\\s\(.*\)$)', '')
WHERE lower(sport) like '%rowing%';
UPDATE summer
SET event = regexp_replace(event, E'Four\\s', 'Fours')
WHERE lower(sport) like '%rowing%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- RUGBY SEVENS
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Rugby'
WHERE lower(sport) like '%rugby sevens%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- SHORT SPEED TRACK SKATING
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Skating'
WHERE lower(sport) like '%short track speed skating%';
UPDATE athlete_events
SET event = regexp_replace(event, E'\,', '')
WHERE lower(sport) like '%short track speed skating%';
ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


--SKELETON
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET event = 'Individual'
WHERE lower(sport) like '%skeleton%';
UPDATE winter
SET sport = 'Skeleton'
WHERE sport ilike 'bobsleigh%' and discipline ilike 'skeleton';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- SKI JUMPING
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Skiing'
WHERE lower(sport) like '%ski jumping%';


UPDATE winter as w
SET event = c.col_a
FROM (values
            ('Large Hill, Individual', 'K120 Individual (90M)'),
            ('Large Hill, Team', 'K120 Team (90M)'),
            ('Normal Hill, Individual', 'K90 Individual (70M)'),
            ('Normal Hill, Individual', 'K90 Individual')
   ) as c(col_a, col_b)
WHERE lower(sport) like 'skiing%' and lower(discipline) like '%ski jumping%' and w.event = c.col_b;
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- SNOWBOARDING
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE winter
SET sport = 'Snowboarding'
WHERE lower(sport) like 'skiing' and lower(discipline) like 'snowboarding';


UPDATE winter
SET discipline = 'Snowboarding'
WHERE lower(discipline) like 'snowboard';


UPDATE winter as w
SET event = c.col_a
FROM (values
            ('Parallel Giant Slalom', 'Giant Parall.S.'),
            ('Parallel Giant Slalom', 'Giant Parallel Slalom'),
            ('Giant Slalom', 'Giant-Slalom'),
            ('Halfpipe', 'Half-Pipe'),
            ('Boardercross', 'Snowboard Cross')
   ) as c(col_a, col_b)
WHERE lower(sport) like 'snowboarding%' and w.event = c.col_b;
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- SPEED SKATING
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events as r
SET event = c.col_a
FROM (values
            ('Team Pursuit', 'Team Pursuit (6 laps)'),
            ('Team Pursuit', 'Team Pursuit (8 laps)')
   ) as c(col_a, col_b)
WHERE lower(sport) like 'speed skating%' and r.event = c.col_b;
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- SWIMMING
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Aquatics'
WHERE sport ilike 'swimming';


UPDATE athlete_events
SET event = regexp_replace(event, E'\\s(Y|y)ard', E'YD')
WHERE discipline ilike 'swimming';


UPDATE athlete_events
SET event = regexp_replace(event, E'\\s(M|m)ile', E'MI')
WHERE discipline ilike 'swimming';

UPDATE athlete_events
SET event = regexp_replace(event, E'One', '1')
WHERE discipline ilike 'swimming';


UPDATE summer
SET event = regexp_replace(event, E'0Y', E'0YD')
WHERE discipline ilike 'swimming';


UPDATE summer
SET event = regexp_replace(event, E'\\s\\(\\d{2,3}\\.\\d{2}M\\)', '')
WHERE discipline ilike 'swimming';


UPDATE athlete_events
SET event = regexp_replace(event, E'\,', '')
WHERE discipline ilike 'swimming';

-- ROLLBACK TO SAVEPOINT pre_update;

COMMIT;


-- SYNCHRONIZED SWIMMING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Aquatics'
WHERE discipline ilike 'synchronized swimming';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- TAEKWONDO
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer as s set event = c.col_a
FROM (values
           ('Flyweight', '- 58 KG', 'Men'),
           ('Featherweight', '58 - 68 KG', 'Men'),
           ('Welterweight', '68 - 80 KG', 'Men'),
           ('Heavyweight','+ 80 KG', 'Men'),
           ('Flyweight', '- 49 KG', 'Women'),
           ('Featherweight', '49 - 57 KG', 'Women'),
           ('Welterweight', '57 - 67 KG', 'Women'),
           ('Heavyweight','+ 67 KG', 'Women')
       ) as c(col_a, col_b, col_c)
WHERE sport ilike 'taekwondo' and event = col_b and gender = col_c;
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- TENNIS
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET event = regexp_replace(event, E'\\, Covered Courts', ' Indoor')
WHERE discipline ilike 'tennis';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- TRAMPOLINING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET sport = 'Gymnastics'
WHERE discipline ilike 'trampolining';
UPDATE summer
SET discipline = 'Trampolining'
WHERE discipline ilike 'trampoline';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- TUG-OF-WAR
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET sport = 'Tug-Of-War'
WHERE discipline ilike 'tug of war';
UPDATE summer
SET event = 'Tug-Of-War'
WHERE discipline ilike 'tug of war';
UPDATE summer
SET discipline = 'Tug-Of-War'
WHERE discipline ilike 'tug of war';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- WATER POLO
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET discipline = 'Water Polo'
WHERE discipline ilike 'water polo';
UPDATE athlete_events
SET sport = 'Aquatics'
WHERE discipline ilike 'water polo';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;


-- WRESTLING
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE summer
SET event = concat(event, ' Freestyle'),
   discipline = 'Wrestling'
WHERE discipline ilike 'wrestling free.' or discipline ilike 'wrestling freestyle';
UPDATE summer
SET event = concat(event, ' Greco-Roman'),
   discipline = 'Wrestling'
WHERE discipline ilike 'wrestling Gre-R';
--ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

BEGIN;

SAVEPOINT pre_up;

UPDATE summer
SET athlete = 'GIRARD, Christine', country='CAN'
WHERE (athlete ilike 'pending' and
       discipline ilike 'weightlifting' and
       event ilike '63KG' and
       medal ilike 'gold' and
       year = 2012 and
       gender='Women' and
       city ilike 'london');

UPDATE summer
SET athlete = 'MIN-JAE, Kim', country='KOR'
WHERE (athlete ilike 'pending' and
       discipline ilike 'weightlifting' and
       event ilike '94KG' and
       medal ilike 'silver' and
       year = 2012 and
       gender='Men' and
       city ilike 'london');

UPDATE summer
SET athlete = 'JAMAL, Maryam Yusuf', country='BRN'
WHERE (athlete ilike 'pending' and
       discipline ilike 'athletics' and
       event ilike '1500M' and
       medal ilike 'gold' and
       year = 2012 and
       gender='Women' and
       city ilike 'london');

-- ROLLBACK TO pre_up;
COMMIT;


-- CREATE 3NF SCHEMA

CREATE TABLE athlete
(
    id       SERIAL PRIMARY KEY,
    name     text NOT NULL,
    sex      varchar(5),
    old_id   int UNIQUE
);


CREATE TABLE athlete_measurements
(
    athlete_id int,
    year       int,
    season     varchar(6),
    age        int,
    weight     float,
    height     float,
    CONSTRAINT athlete_age_pk PRIMARY KEY(athlete_id, year, season),
    CONSTRAINT athlete_fk FOREIGN KEY(athlete_id) REFERENCES
        athlete (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE competitor
(
    id         SERIAL PRIMARY KEY,
    athlete_id int,
    team_name  text    NULL,
    noc    char(3) NOT NULL,
    CONSTRAINT athlete_fk FOREIGN KEY (athlete_id) REFERENCES athlete (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT country_fk FOREIGN KEY (noc) REFERENCES country(alt_noc)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE event
(
    id         SERIAL PRIMARY KEY,
    sport      text,
    discipline text,
    event_name text
);

CREATE TABLE host
(
    id     SERIAL PRIMARY KEY,
    main_city   text,
    alt_city text,
    year   int,
    season varchar(6)
);

CREATE TABLE results
(
    id            SERIAL PRIMARY KEY,
    competitor_id int,
    event_id      int,
    host_id       int,
    medal         varchar(6),
--     CONSTRAINT results_pk PRIMARY KEY (event_id, competitor_id, medal, host_id),
    CONSTRAINT team_fk FOREIGN KEY (competitor_id) REFERENCES competitor (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT event_fk FOREIGN KEY (event_id) REFERENCES event (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT host_fk FOREIGN KEY (host_id) REFERENCES host (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- POPULATE NEW SCHEMA

INSERT INTO athlete(name, sex, old_id)
    (
        (SELECT name, sex, id
        FROM athlete_events
        GROUP BY id, name, sex)

        UNION

        (SELECT s.athlete,
                 CASE
                     WHEN s.gender = 'Men' THEN 'M'
                     WHEN s.gender = 'Women' THEN 'F'
                     END, NULL::int
          from summer s
          where s.athlete not in (select athlete from athlete_matches)
          GROUP BY s.athlete,
                   CASE
                       WHEN s.gender = 'Men' THEN 'M'
                       WHEN s.gender = 'Women' THEN 'F'
                       END
         )

         UNION

         (SELECT distinct w.athlete,
                          CASE
                              WHEN w.gender = 'Men' THEN 'M'
                              WHEN w.gender = 'Women' THEN 'F'
                              END, NULL::int
          from winter w
          where w.athlete not in (select athlete from athlete_matches)
        )
    );

INSERT INTO athlete_measurements(athlete_id, year, season, age, weight, height)
(
    SELECT distinct a.id, ae.year, ae.season, ae.age, ae.weight, ae.height
    FROM athlete a, athlete_events ae
    WHERE a.name=ae.name AND a.sex=ae.sex AND a.old_id=ae.id
);


INSERT INTO competitor(athlete_id, team_name, noc)
    (
        SELECT distinct a.id, ae.team, ae.noc
        FROM athlete_events ae
        JOIN athlete a ON (a.old_id=ae.id)

        UNION
        (
            SELECT distinct a2.id, NULL, s.country
            FROM athlete a2
            JOIN summer s ON (a2.name=s.athlete AND
                              (a2.sex='M' AND s.gender='Men' OR
                               a2.sex='F' AND s.gender='Women'))

            UNION

            SELECT distinct a3.id, NULL, w.country
            FROM athlete a3
            JOIN winter w ON (a3.name=w.athlete AND
                              (a3.sex='M' AND w.gender='Men' OR
                               a3.sex='F' AND w.gender='Women'))
        )
    );

INSERT INTO event(sport, discipline, event_name)
    (
        SELECT distinct sport, discipline, event
        FROM athlete_events

        UNION

        (
            SELECT distinct sport, discipline, event
            FROM summer
            WHERE athlete NOT IN (SELECT athlete FROM athlete_matches)

            UNION

            SELECT distinct sport, discipline, event
            FROM winter
            WHERE athlete NOT IN (SELECT athlete FROM athlete_matches)
        )

    );

INSERT INTO host(main_city, alt_city, year, season)
    (
        with ae(city, year, season) as (select distinct city, year, season from athlete_events),
             summ(city, year) as (select distinct city, year from summer),
             wint(city, year) as (select distinct city, year from winter)
        
        select distinct ae.city as main_city, summ.city as alt_city, ae.year as year, ae.season as season
        from ae, summ
        where ae.year=summ.year and ae.season='Summer'
        
        union
        
        select distinct ae.city, wint.city, ae.year, ae.season
        from ae, wint
        where ae.year=wint.year and ae.season='Winter'
        
        order by year, season, main_city
    );

INSERT INTO results(competitor_id, event_id, host_id, medal)
(
    select distinct c.id, e.id, h.id, ae.medal
    from athlete_events ae
    join athlete a on ae.id = a.old_id
    join competitor c on a.id = c.athlete_id
    join event e on (ae.sport = e.sport and 
                     ae.discipline = e.discipline and 
                     ae.event = e.event_name)
    join host h on (ae.season = h.season and
                    ae.year = h.year and
                    ae.city = h.main_city)
    
    union
    
    select distinct c.id, e.id, h.id, s.medal
    from summer s
    join athlete a on (s.athlete = a.name and s.gender=a.sex)
    join competitor c on a.id = c.athlete_id
    join event e on (s.sport = e.sport and 
                     s.discipline = e.discipline and 
                     s.event = e.event_name)
    join host h on (h.season = 'Summer' and
                    s.year = h.year and
                    s.city = h.alt_city)
    
    union 
    
    select distinct c.id, e.id, h.id, w.medal
    from winter w
    join athlete a on (w.athlete = a.name and w.gender=a.sex)
    join competitor c on a.id = c.athlete_id
    join event e on (w.sport = e.sport and 
                     w.discipline = e.discipline and 
                     w.event = e.event_name)
    join host h on (h.season = 'Winter' and
                    w.year = h.year and
                    w.city = h.alt_city)
);

ALTER TABLE athlete
DROP COLUMN old_id;

UPDATE athlete
SET name = LTRIM(name);
