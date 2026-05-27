WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
class_stats AS (
    SELECT
        car_class,
        COUNT(*) AS total_races
    FROM car_stats
    GROUP BY car_class
),
low_position_classes AS (
    SELECT
        car_class,
        COUNT(*) AS low_position_count
    FROM car_stats
    WHERE average_position > 3.0
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country,
    cls.total_races,
    lpc.low_position_count
FROM car_stats cs
JOIN class_stats cls ON cs.car_class = cls.car_class
JOIN low_position_classes lpc ON cs.car_class = lpc.car_class
WHERE cs.average_position > 3.0
ORDER BY
    cls.total_races DESC,
    lpc.low_position_count DESC,
    cs.car_class ASC,
    cs.average_position ASC;