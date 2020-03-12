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
WHERE e.sport ilike 'Curling' and h.city ilike 'vancouver' and h.year = 2010;


-- Q3
SELECT a.name
FROM athlete a
JOIN competitor c ON a.id = c.athlete_id
JOIN results r ON c.id = r.competitor_id
JOIN host h ON h.id = r.host_id
WHERE h.year > 1940
GROUP BY a.name, host_id
having count(distinct event_id) > 4;


-- Q4
SELECT h.year, count(distinct a.athlete_id)
from results r
JOIN host h ON h.id = r.host_id
JOIN competitor c ON r.competitor_id = c.id
JOIN athlete a ON c.athlete_id = a.athlete_id
WHERE h.year > 1940
GROUP BY h.year
HAVING count(distinct event_id) > 3;

-- Q5
SELECT r.host_id, count(distinct a.athlete_id)
from results r
JOIN host h ON h.id = r.host_id
JOIN competitor c ON c.id = r.competitor_id
JOIN athlete a ON c.athlete_id = a.athlete_id
JOIN country ct ON c.alt_noc = ct.alt_noc
WHERE year > 1947 AND alt_noc ilike 'ind'
GROUP BY r.host_id;


-- Q6
SELECT a.gender e.event, a.name, r.medal
FROM results r
JOIN event e ON e.id = r.event_id
JOIN competitor c ON c.id = r.competitor_id
JOIN athlete a ON c.athlete_id = a.athlete_id
WHERE e.discipline ilike 'swimming' AND r.medal IS NOT NULL AND e.year = 2004
ORDER BY e.event, a.gender, r.medal, ;


-- Q7
SELECT h.year,
       sum(
           CASE WHEN r.medal = 'Gold' THEN 1
           ELSE 0
           ) AS gold,
       sum(
           CASE WHEN r.medal = 'Silver' THEN 1
           ELSE 0
           ) AS silver,
       sum(
           CASE WHEN r.medal = 'Bronze' THEN 1
           ELSE 0
           ) AS bronze
FROM results r
JOIN event e ON e.id = r.event_id
JOIN competitor c ON c.id = r.competitor_id
JOIN athlete a ON c.athlete_id = a.athlete_id
WHERE a.name ilike '%michael%phelps%' or a.name ilike '%phelps%michael%'
GROUP BY h.year;


-- Q8 WIP
select C.country, sum(CASE WHEN R.medal='Gold' THEN 1 ELSE 0 END) as gold_count
FROM country C, results R
JOIN competitor CP ON R.competitor_id=CP.id
JOIN athlete A ON CP.athlete_id = A.id
JOIN event E ON R.event_id = E.id
WHERE A.sex='M' AND E.event_name ILIKE '%marathon%' AND E.sport='Athletics'
GROUP BY C.country

ORDER BY gold_count DESC
LIMIT 1;
