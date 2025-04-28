-- CREATING A CLEANED VERSION OF STAGING TABLE 
CREATE TEMP TABLE staging_cleaned AS
	SELECT 
    trip_creation_time,
    route_schedule_uuid,
    route_type,
    trip_uuid,
    source_center,
    source_name,
    destination_center,
    destination_name,
    od_start_time,
    od_end_time,
    start_scan_to_end_scan,
    is_cutoff,
    cutoff_factor,
    cutoff_timestamp,
    actual_distance_to_destination,
    actual_time,
    osrm_time,
    osrm_distance,
    factor,
    segment_actual_time,
    segment_osrm_time,
    segment_osrm_distance
FROM trip_data 
WHERE trip_uuid IS NOT NULL;

select * from staging_cleaned

-- First update: handle date format strings (like 9/20/2018 2:35)
UPDATE staging_cleaned 
SET 
    trip_creation_time = 
        CASE WHEN trip_creation_time ~ '^\d{1,2}/\d{1,2}/\d{4}' 
             THEN TO_TIMESTAMP(trip_creation_time, 'MM/DD/YYYY HH24:MI')::text
             ELSE trip_creation_time END;

UPDATE staging_cleaned 
SET 
    od_start_time = 
        CASE WHEN od_start_time ~ '^\d{1,2}/\d{1,2}/\d{4}' 
             THEN TO_TIMESTAMP(od_start_time, 'MM/DD/YYYY HH24:MI')::text
             ELSE od_start_time END;

UPDATE staging_cleaned 
SET 
    od_end_time = 
        CASE WHEN od_end_time ~ '^\d{1,2}/\d{1,2}/\d{4}' 
             THEN TO_TIMESTAMP(od_end_time, 'MM/DD/YYYY HH24:MI')::text
             ELSE od_end_time END;

UPDATE staging_cleaned 
SET 
    cutoff_timestamp = 
        CASE WHEN cutoff_timestamp ~ '^\d{1,2}/\d{1,2}/\d{4}' 
             THEN TO_TIMESTAMP(cutoff_timestamp, 'MM/DD/YYYY HH24:MI')::text
             ELSE cutoff_timestamp END;

-- Second update: handle time-only formats (like 19:24.2 or times >24 hours)
UPDATE staging_cleaned 
SET 
    trip_creation_time = 
        CASE WHEN trip_creation_time ~ '^\d{1,2}:\d{1,2}(.\d+)?$' 
             THEN (NOW()::date + (trip_creation_time::interval))::text
             ELSE trip_creation_time END;

UPDATE staging_cleaned 
SET 
    od_start_time = 
        CASE WHEN od_start_time ~ '^\d{1,2}:\d{1,2}(.\d+)?$' 
             THEN (NOW()::date + (od_start_time::interval))::text
             ELSE od_start_time END;

UPDATE staging_cleaned 
SET 
    od_end_time = 
        CASE WHEN od_end_time ~ '^\d{1,2}:\d{1,2}(.\d+)?$' 
             THEN (NOW()::date + (od_end_time::interval))::text
             ELSE od_end_time END;

UPDATE staging_cleaned 
SET 
    cutoff_timestamp = 
        CASE WHEN cutoff_timestamp ~ '^\d{1,2}:\d{1,2}(.\d+)?$' 
             THEN (NOW()::date + (cutoff_timestamp::interval))::text
             ELSE cutoff_timestamp END;

-- Finally, convert all columns to timestamp
ALTER TABLE staging_cleaned 
    ALTER COLUMN trip_creation_time TYPE timestamp USING trip_creation_time::timestamp,
    ALTER COLUMN od_start_time TYPE timestamp USING od_start_time::timestamp,
    ALTER COLUMN od_end_time TYPE timestamp USING od_end_time::timestamp,
    ALTER COLUMN cutoff_timestamp TYPE timestamp USING cutoff_timestamp::timestamp;

select * from staging_cleaned

-- HANDLING NULL VALUES
DELETE FROM staging_cleaned
WHERE 
    -- TIMESTAMP and INTEGER and NUMERIC fields: only IS NULL
    trip_creation_time IS NULL OR
    route_schedule_uuid IS NULL OR
    route_type IS NULL OR
    trip_uuid IS NULL OR
    source_center IS NULL OR
    source_name IS NULL OR
    destination_center IS NULL OR
    destination_name IS NULL OR
    od_start_time IS NULL OR
    od_end_time IS NULL OR
    start_scan_to_end_scan IS NULL OR
    is_cutoff IS NULL OR
    cutoff_factor IS NULL OR
    cutoff_timestamp IS NULL OR
    actual_distance_to_destination IS NULL OR
    actual_time IS NULL OR
    osrm_time IS NULL OR
    osrm_distance IS NULL OR
    factor IS NULL OR
    segment_actual_time IS NULL OR
    segment_osrm_time IS NULL OR
    segment_osrm_distance IS NULL

    -- TEXT columns: IS NULL + Bad strings
    OR route_schedule_uuid IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR route_type IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR trip_uuid IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR source_center IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR source_name IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR destination_center IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR destination_name IN ('NaN', 'nan', 'NULL', 'null', '');

-- Adding column state to dim_location
ALTER TABLE dim_location
ADD COLUMN location_state TEXT;

--inserting into dim_location
WITH all_locations AS (
    SELECT source_center AS location_id, source_name AS full_location
    FROM staging_cleaned
    UNION
    SELECT destination_center AS location_id, destination_name AS full_location
    FROM staging_cleaned
)
INSERT INTO dim_location (location_id, location_name, location_state)
SELECT
    location_id,
    -- Extract location_name (remove state info in brackets)
    TRIM(SPLIT_PART(full_location, '(', 1)) AS location_name,
    -- Extract state info from brackets
    TRIM(REPLACE(SPLIT_PART(full_location, '(', 2), ')', '')) AS location_state
FROM all_locations
ON CONFLICT (location_id) DO NOTHING;

select * from dim_location

-- inserting into dim_trip
INSERT INTO dim_trip (trip_uuid, route_schedule_uuid, route_type)
SELECT DISTINCT 
    trip_uuid, 
    route_schedule_uuid, 
    route_type
FROM trip_data
WHERE trip_uuid IS NOT NULL
  AND trip_uuid NOT IN (SELECT trip_uuid FROM dim_trip);

-- insering into dim_time 
INSERT INTO dim_time (time_id, trip_creation_time, od_start_time, od_end_time)
SELECT DISTINCT
    'TIME_' || gen_random_uuid() AS time_id,
    trip_creation_time,
    od_start_time,
    od_end_time
FROM staging_cleaned
WHERE trip_creation_time IS NOT NULL 
   OR od_start_time IS NOT NULL 
   OR od_end_time IS NOT NULL;

-- inserting into dim_cutoff
INSERT INTO dim_cutoff (cutoff_id, is_cutoff, cutoff_factor, cutoff_timestamp)
SELECT DISTINCT
    'CUTOFF_' || gen_random_uuid() AS cutoff_id,
    is_cutoff,
    cutoff_factor,
    cutoff_timestamp
FROM staging_cleaned
WHERE is_cutoff IS NOT NULL 
   OR cutoff_factor IS NOT NULL 
   OR cutoff_timestamp IS NOT NULL;

-- insert into fact_trip_metrics 

