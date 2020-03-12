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
