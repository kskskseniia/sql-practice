WITH hotel_categories AS (
    SELECT
        h.ID_hotel,
        h.name AS hotel_name,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
customer_hotels AS (
    SELECT DISTINCT
        c.ID_customer,
        c.name,
        hc.hotel_name,
        hc.hotel_category,
        CASE
            WHEN hc.hotel_category = 'Дешевый' THEN 1
            WHEN hc.hotel_category = 'Средний' THEN 2
            WHEN hc.hotel_category = 'Дорогой' THEN 3
        END AS category_priority
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN hotel_categories hc ON r.ID_hotel = hc.ID_hotel
),
customer_preferences AS (
    SELECT
        ID_customer,
        name,
        MAX(category_priority) AS preferred_priority,
        STRING_AGG(DISTINCT hotel_name, ',' ORDER BY hotel_name) AS visited_hotels
    FROM customer_hotels
    GROUP BY ID_customer, name
)
SELECT
    ID_customer,
    name,
    CASE
        WHEN preferred_priority = 1 THEN 'Дешевый'
        WHEN preferred_priority = 2 THEN 'Средний'
        WHEN preferred_priority = 3 THEN 'Дорогой'
    END AS preferred_hotel_type,
    visited_hotels
FROM customer_preferences
ORDER BY preferred_priority, ID_customer;