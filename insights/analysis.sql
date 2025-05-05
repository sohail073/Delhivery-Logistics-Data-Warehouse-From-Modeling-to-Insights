-- What is the total number of trips per state?
select location_state, SUM(total_trips) as total_trips
From(
select dl.location_state, count(*) as total_trips 
from dim_location dl
join fact_trip_metrics ft on dl.location_id = ft.source_location_id
GROUP BY dl.location_state

UNION ALL

select dl.location_state, count(*) as total_trips 
from dim_location dl
join fact_trip_metrics ft on dl.location_id = ft.destination_location_id
GROUP BY dl.location_state
) 
group by location_state
ORDER BY total_trips DESC;

-- Which source-destination pairs have the highest number of trips?
SELECT 
    src.location_state AS source_state, 
    dest.location_state AS destination_state, 
    COUNT(*) AS total_trips
FROM fact_trip_metrics ft
JOIN dim_location src ON ft.source_location_id = src.location_id
JOIN dim_location dest ON ft.destination_location_id = dest.location_id
GROUP BY source_state, destination_state
ORDER BY total_trips DESC
LIMIT 10;

-- 
select location_state, avg(avg_actual_time) as avg_actual_time
From(
select dl.location_state, avg(actual_time) as avg_actual_time
from dim_location dl
join fact_trip_metrics ft on dl.location_id = ft.source_location_id
GROUP BY dl.location_state

UNION ALL

select dl.location_state, avg(actual_time) as avg_actual_time
from dim_location dl
join fact_trip_metrics ft on dl.location_id = ft.destination_location_id
GROUP BY dl.location_state
) 
group by location_state
ORDER BY avg_actual_time DESC;

-- Which source-destination pairs have the highest number of trips according to ity?
SELECT location_state, AVG(avg_delay) AS avg_delay
FROM (
    SELECT dl.location_state, AVG(ft.actual_time - ft.osrm_time) AS avg_delay
    FROM dim_location dl
    JOIN fact_trip_metrics ft ON dl.location_id = ft.source_location_id
    GROUP BY dl.location_state

    UNION ALL

    SELECT dl.location_state, AVG(ft.actual_time - ft.osrm_time) AS avg_delay
    FROM dim_location dl
    JOIN fact_trip_metrics ft ON dl.location_id = ft.destination_location_id
    GROUP BY dl.location_state
) AS delays
GROUP BY location_state
ORDER BY avg_delay DESC;

-- 
SELECT 
    src.location_name AS source_location, 
    dest.location_name AS destination_location, 
    COUNT(*) AS total_trips
FROM fact_trip_metrics ft
JOIN dim_location src ON ft.source_location_id = src.location_id
JOIN dim_location dest ON ft.destination_location_id = dest.location_id
GROUP BY source_location, destination_location
ORDER BY total_trips DESC
LIMIT 10;


