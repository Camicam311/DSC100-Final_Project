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
UPDATE summer
SET event = concat(event, 'Slalom')
WHERE discipline ilike 'canoe slalom';

UPDATE summer AS s SET event = c.col_a
FROM (values
    ) as c(col_a, col_b)

UPDATE summer
SET event = regexp_replace(event, E'(\\d{1,2}),(\\d{3})', E'\1\2')
WHERE sport ilike '%canoe%';

UPDATE summer
SET event = regexp_replace(event, E'10KM', '10000M')
WHERE sport ilike '%canoe%';

UPDATE summer
SET discipline = 'Canoeing'
WHERE discipline ilike '%canoe%';

UPDATE summer
SET sport = 'Canoeing'
WHERE sport ilike '%canoe%';




