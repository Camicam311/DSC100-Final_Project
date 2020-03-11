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

-- BIATHLON
-- begin transaction block
BEGIN;
-- add savepoint if needed
SAVEPOINT pre_update;
-- change
UPDATE athlete_events
SET event = regexp_replace(event, E'( kilometres)+', 'KM', 'g')
WHERE sport ilike '%biathlon%';
-- ROLLBACK TO SAVEPOINT pre_update;
COMMIT;

--BOBSLEIGH
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

--