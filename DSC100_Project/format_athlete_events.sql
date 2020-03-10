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


--