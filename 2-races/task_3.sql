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
        c.class AS car_class,
        AVG(r.position) AS class_average_position,
        COUNT(r.race) AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
best_classes AS (
    SELECT
        car_class
    FROM class_stats
    WHERE class_average_position = (
        SELECT MIN(class_average_position)
        FROM class_stats
    )
)
SELECT
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country,
    cls.total_races
FROM car_stats cs
JOIN class_stats cls ON cs.car_class = cls.car_class
JOIN best_classes bc ON cs.car_class = bc.car_class
ORDER BY cs.average_position, cs.car_name;