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

SELECT noc, num_competitors from in_barca

UNION

SELECT noc, num_competitors from not_in_barca
order by num_competitors DESC;


-- Q2
SELECT distinct noc
FROM competitor c
JOIN results r ON c.id = r.competitor_id
JOIN event e ON e.id = r.event_id
JOIN host h ON h.id = r.host_id
WHERE e.sport ilike 'Curling' and (h.main_city ilike 'vancouver' or
                                   h.alt_city ilike 'vancouver') and
      h.year = 2010;


-- Q3
SELECT distinct a.name
FROM athlete a
JOIN competitor c ON a.id = c.athlete_id
JOIN results r ON c.id = r.competitor_id
JOIN host h ON h.id = r.host_id
WHERE h.year > 1900
GROUP BY a.name, host_id
having count(distinct event_id) > 4;


-- Q4
WITH year_ath(year, athlete) as (
    SELECT distinct h.year, a.id
    from results r
    JOIN host h ON h.id = r.host_id
    JOIN competitor c ON r.competitor_id = c.id
    JOIN athlete a ON c.athlete_id = a.id
    WHERE h.year > 1940
    GROUP BY a.id, h.year
    HAVING count(distinct event_id) > 3
    ORDER BY h.year
)

SELECT year, count(athlete)
from year_ath
GROUP BY year;

-- Q5
SELECT h.season, h.year, count(distinct a.id)
from results r
JOIN host h ON h.id = r.host_id
JOIN competitor c ON c.id = r.competitor_id
JOIN athlete a ON c.athlete_id = a.id
JOIN country ct ON c.noc = ct.alt_noc
WHERE year > 1947 AND alt_noc ilike 'ind'
GROUP BY h.season, h.year
ORDER BY h.year, h.season;


-- Q6
SELECT e.discipline, e.event_name, a.sex, a.name, r.medal, c.noc
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
select C.country, sum(CASE WHEN R.medal='Gold' THEN 1 ELSE 0 END) as gold_count
FROM country C, results R
JOIN competitor CP ON R.competitor_id=CP.id
JOIN athlete A ON CP.athlete_id = A.id
JOIN event E ON R.event_id = E.id
WHERE A.sex='M' AND E.event_name ILIKE '%marathon%' AND E.sport='Athletics' AND C.alt_noc=CP.noc
GROUP BY C.country

ORDER BY gold_count DESC
LIMIT 10;
