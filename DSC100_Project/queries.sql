--- Q1
WITH in_barca(noc, num_competitors) as
    (
        SELECT noc, count(distinct competitor_id)
        FROM competitor c
        JOIN results r ON c.id = r.competitor_id
        JOIN host h ON r.host_id = h.id
        WHERE (h.main_city ilike '%barcelona%' or h.alt_city ilike '%barcelona%') and h.year = 1992
        GROUP BY noc
    ),
    not_in_barca(noc, num_competitors) as
    (
        SELECT main_noc, 0
        FROM country ctry
        WHERE ctry.alt_noc NOT IN (SELECT noc from in_barca)
        GROUP BY main_noc
    )

SELECT country, num_competitors
FROM in_barca, country
WHERE noc=alt_noc

UNION

SELECT country, num_competitors
FROM not_in_barca, country
WHERE noc=alt_noc
order by num_competitors DESC;


-- Q2
SELECT distinct c2.country
FROM competitor c
JOIN results r ON c.id = r.competitor_id
JOIN event e ON e.id = r.event_id
JOIN host h ON h.id = r.host_id
JOIN country c2 on c.noc = c2.alt_noc
WHERE e.sport ilike 'Curling' and (h.main_city ilike 'vancouver' or
                                   h.alt_city ilike 'vancouver') and
      h.year = 2010;


-- Q3
SELECT a.name
FROM athlete a
WHERE a.id IN (SELECT a.id
                FROM athlete a
                JOIN competitor c ON a.id = c.athlete_id
                JOIN results r ON c.id = r.competitor_id
                JOIN host h ON h.id = r.host_id
                WHERE h.year > 1900
                GROUP BY a.id, host_id
                having count(distinct event_id) > 4)
ORDER BY name;


-- Q4
WITH id_ath(id, athlete) as (
    SELECT distinct h.id, a.id
    from results r
    JOIN host h ON h.id = r.host_id
    JOIN competitor c ON r.competitor_id = c.id
    JOIN athlete a ON c.athlete_id = a.id
    WHERE h.year > 1940
    GROUP BY a.id, h.id
    HAVING count(distinct event_id) > 3
    ORDER BY h.id
)

SELECT h.year, count(athlete)
FROM id_ath, host h
WHERE h.id=id_ath.id
GROUP BY h.year
ORDER BY h.year;

-- Q5
WITH india_at_games(season, year, num_comp) AS
        (
            SELECT h.season, h.year, count(distinct a.id)
            from results r
            JOIN host h ON h.id = r.host_id
            JOIN competitor c ON c.id = r.competitor_id
            JOIN athlete a ON c.athlete_id = a.id
            JOIN country ct ON c.noc = ct.alt_noc
            WHERE year > 1947 AND alt_noc ilike 'ind'
            GROUP BY h.season, h.year
--             ORDER BY h.year, h.season
        ),
    india_not_at_games(season, year, num_comp) AS
        (
            SELECT h.season, h.year, 0
            FROM host h, india_at_games i
            WHERE h.main_city NOT IN (
                SELECT main_city
                FROM host h1, india_at_games i1
                WHERE h1.season=i1.season AND
                      h1.year=i1.year) AND h.year>=1947
        )

SELECT *
FROM india_at_games
UNION
SELECT *
FROM india_not_at_games
ORDER BY year, season
;


-- Q6
SELECT e.discipline, e.event_name, a.sex, a.name, r.medal
FROM results r
JOIN event e on r.event_id = e.id
JOIN competitor c on r.competitor_id = c.id
JOIN athlete a on c.athlete_id = a.id
JOIN host h on r.host_id = h.id
WHERE e.discipline ILIKE '%swim%' AND
      h.year=2004 AND
      h.season='Summer' AND
      r.medal IS NOT NULL
GROUP BY e.discipline, e.event_name, a.sex, a.name, r.medal, c.noc
ORDER BY e.discipline,
         e.event_name,
         a.sex,
         (CASE r.medal
             WHEN 'Gold' THEN 1
             WHEN 'Silver' THEN 2
             WHEN 'Bronze' THEN 3
             END);


-- Q7
SELECT h.year,
       sum(
           CASE WHEN r.medal = 'Gold' THEN 1
           ELSE 0 END
           ) AS gold,
       sum(
           CASE WHEN r.medal = 'Silver' THEN 1
           ELSE 0 END
           ) AS silver,
       sum(
           CASE WHEN r.medal = 'Bronze' THEN 1
           ELSE 0 END
           ) AS bronze
FROM results r
JOIN event e ON e.id = r.event_id
JOIN competitor c ON c.id = r.competitor_id
JOIN athlete a ON c.athlete_id = a.id
JOIN host h ON r.host_id = h.id
WHERE a.name ilike '%michael%phelps%' or a.name ilike '%phelps%michael%'
GROUP BY h.year;


-- Q8
SELECT C.country, sum(CASE WHEN R.medal='Gold' THEN 1 ELSE 0 END) as gold_count
FROM country C, results R
JOIN competitor CP ON R.competitor_id=CP.id
JOIN athlete A ON CP.athlete_id = A.id
JOIN event E ON R.event_id = E.id
WHERE A.sex='M' AND E.event_name ILIKE '%marathon%' AND E.sport='Athletics' AND C.alt_noc=CP.noc
GROUP BY C.country

ORDER BY gold_count DESC
LIMIT 1;


-- Q9
WITH aey(aid, eid, year, diff_year, diff_med) AS
        (SELECT distinct a.id, e.id, h.year,
                         h.year - lag(h.year) over (PARTITION BY a.id, e.id ORDER BY a.id, e.id, h.year) as diff_year,
                         (CASE r.medal
                           WHEN 'Gold' THEN 3
                           WHEN 'Silver' THEN 2
                           WHEN 'Bronze' THEN 1
                          END) - lag((CASE r.medal
                           WHEN 'Gold' THEN 3
                           WHEN 'Silver' THEN 2
                           WHEN 'Bronze' THEN 1
                          END)) over (PARTITION BY a.id, e.id ORDER BY a.id, e.id, h.year) as diff_med
        FROM athlete a
        JOIN competitor c on a.id = c.athlete_id
        JOIN results r on c.id = r.competitor_id
        JOIN host h on r.host_id = h.id
        JOIN event e on r.event_id = e.id),
     gtr3(aid, eid) as
        (SELECT aid, eid
        FROM aey
        where diff_year<>0
        group by aid, eid
        having count(*)>=3 and max(diff_year)<=4 and min(diff_med)>=0),
     good_athletes(ath_id) as
        (select aey.aid from aey, gtr3 where aey.aid=gtr3.aid and aey.eid=gtr3.eid and diff_year<>0 and diff_med>=0)

select distinct name
from athlete, good_athletes
where id = ath_id
ORDER BY name;
