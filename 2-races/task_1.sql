WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
ranked_cars AS (
    SELECT
        car_name,
        car_class,
        average_position,
        race_count,
        RANK() OVER (
            PARTITION BY car_class
            ORDER BY average_position
        ) AS position_rank
    FROM car_stats
)
SELECT
    car_name,
    car_class,
    ROUND(average_position, 4) AS average_position,
    race_count
FROM ranked_cars
WHERE position_rank = 1
ORDER BY average_position;