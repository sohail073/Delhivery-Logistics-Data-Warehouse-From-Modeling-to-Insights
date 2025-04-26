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

-- UPDATING CLEAN TIMESTAMPS AND TEXT FIELDS
UPDATE staging_cleaned
SET 
    trip_creation_time = CASE 
        WHEN trip_creation_time ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' 
        THEN trip_creation_time::timestamp 
        ELSE NULL 
    END,
    
    od_start_time = CASE 
        WHEN od_start_time ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' 
        THEN od_start_time::timestamp 
        ELSE NULL 
    END,
    
    od_end_time = CASE 
        WHEN od_end_time ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' 
        THEN od_end_time::timestamp 
        ELSE NULL 
    END,
    
    cutoff_timestamp = CASE 
        WHEN cutoff_timestamp ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' 
        THEN cutoff_timestamp::timestamp 
        ELSE NULL 
    END;

-- HANDLING NULL VALUES
DELETE FROM staging_cleaned
WHERE 
    -- Checking for actual NULLs
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

    -- Checking for 'NaN', 'nan', 'NULL', 'null', ''
    OR trip_creation_time IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR route_schedule_uuid IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR route_type IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR trip_uuid IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR source_center IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR source_name IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR destination_center IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR destination_name IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR od_start_time IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR od_end_time IN ('NaN', 'nan', 'NULL', 'null', '') 
    OR cutoff_timestamp IN ('NaN', 'nan', 'NULL', 'null', '');


