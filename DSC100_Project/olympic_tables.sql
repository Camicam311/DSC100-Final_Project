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

COPY athlete_events FROM '/Users/jacobamoul/Desktop/DSC100/Project/athlete_events.csv' CSV HEADER;
COPY dictionary FROM '/Users/jacobamoul/Desktop/DSC100/Project/dictionary.csv' CSV HEADER;
COPY noc_regions FROM '/Users/jacobamoul/Desktop/DSC100/Project/noc_regions.csv' CSV HEADER;
COPY summer FROM '/Users/jacobamoul/Desktop/DSC100/Project/summer.csv' CSV HEADER;
COPY winter FROM '/Users/jacobamoul/Desktop/DSC100/Project/winter.csv' CSV HEADER;

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

UPDATE athlete_events SET event = regexp_replace(event, E'(\\d+)( metres)', '\1M');


-- FIND ATHLETE OVERLAP BETWEEN athlete_events and summer/winter

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

CREATE TABLE reformatted_athlete_events
(
    id         int,
    sport      text,
    discipline text,
    sex char,
    event      text
);

INSERT INTO reformatted_athlete_events(id, sport, discipline, sex, event)
SELECT id, sport, (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[1] as discipline, sex,
       (regexp_split_to_array(event, E'\\s(Wo)?[Mm]en\'s\\s'))[2] as event
FROM athlete_events
WHERE lower(event) NOT LIKE '%mixed%'

union

SELECT id, sport, (regexp_split_to_array(event, E'\\sMixed\\s'))[1], sex,
       CONCAT('Mixed ', (regexp_split_to_array(event, E'\\sMixed\\s'))[2])
FROM athlete_events
WHERE lower(event)  LIKE '%mixed%';

-- CREATE 3NF SCHEMA

CREATE TABLE athlete
(
    id         SERIAL PRIMARY KEY,
    name       text NOT NULL,
    sex        varchar(5)
);


CREATE TABLE athlete_measurements
(
    athlete_id int,
    year       int,
    season     varchar(6),
    age        int,
    weight     float,
    height     float,
    CONSTRAINT athlete_measure_pk PRIMARY KEY(athlete_id, year, season),
    CONSTRAINT athlete_fk FOREIGN KEY(athlete_id) REFERENCES
        athlete (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE competitor
(
    id         SERIAL PRIMARY KEY,
    athlete_id int     NULL,
    team_name  text    NULL,
    noc    char(3) NOT NULL,
    CONSTRAINT athlete_fk FOREIGN KEY (athlete_id) REFERENCES athlete (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT country_fk FOREIGN KEY (noc) REFERENCES country(noc)
);

CREATE TABLE country
(
    noc    char(3) PRIMARY KEY,
    country text
);


CREATE TABLE event
(
    id         SERIAL PRIMARY KEY,
    event_name text,
    sport      text
);

CREATE TABLE host
(
    id     SERIAL PRIMARY KEY,
    city   text,
    year   int,
    season varchar(6)
);

CREATE TABLE results
(
    competitor_id int,
    event_id      int,
    host_id       int,
    medal         varchar(6),
    CONSTRAINT results_pk PRIMARY KEY (event_id, competitor_id, medal, host_id),
    CONSTRAINT team_fk FOREIGN KEY (competitor_id) REFERENCES competitor (id),
    CONSTRAINT event_fk FOREIGN KEY (event_id) REFERENCES event (id),
    CONSTRAINT host_fk FOREIGN KEY (host_id) REFERENCES host (id)
);


INSERT INTO athlete(name, sex)
    (
--         SELECT id, name, sex
--         FROM athlete_events
--         GROUP BY id, name, sex
--         ORDER BY id
        SELECT name, sex
        FROM (
            SELECT id, name, sex
            FROM athlete_events
            WHERE id NOT IN (SELECT id FROM athlete_matches)
            GROUP BY id, name, sex
            ORDER BY id
                 ) temp

        UNION

        SELECT name, sex
        FROM (
            SELECT id, name, sex
            FROM athlete_events
            WHERE id IN (SELECT id FROM athlete_matches)
                 ) temp

        UNION

        SELECT athlete,
                CASE
                   WHEN gender='Men' THEN 'M'
                   WHEN gender='Women' THEN 'F'
                END AS gender
        FROM summer
        WHERE (athlete, country) NOT IN (SELECT (athlete, noc) FROM athlete_matches)
    );

INSERT INTO country(noc, country)
    (
        SELECT code, country
        FROM dictionary
        GROUP BY code, country
        ORDER BY code
    );

INSERT INTO competitor(athlete_id, team_name, noc)
    (
        SELECT id, team, noc
        FROM athlete_events
        GROUP BY id, team, noc
    );

INSERT INTO event(event_name, sport)
    (
        SELECT event, sport
        FROM athlete_events
        GROUP BY event, sport
    );

INSERT INTO host(city, year, season)
    (
        SELECT city, year, season
        FROM athlete_events
        GROUP BY city, year, season
        ORDER BY year, city
    );

INSERT INTO results(competitor_id, event_id, host_id, medal)
SELECT c.id, e.id, h.id, a.medal
FROM competitor c, event e, host h,
    (
        SELECT id, team, event, city, year, medal
        FROM athlete_events
        GROUP BY id, team, event, city, year, medal
    ) a
WHERE c.athlete_id = a.id AND c.team_name = a.team AND
      e.event_name = a.event AND h.city = a.city AND
      h.year = a.year;