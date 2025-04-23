CREATE TABLE trips (
	trip_uuid TEXT,
	route_schedule_uuid TEXT,
	route_type TEXT,
	source_center TEXT,
	destination_center TEXT,
);

CREATE TABLE locations (
	locations_id TEXT,
	locations_name TEXT,
);

CREATE TABLE route_metrics (
	actual_time INT,
	osrm_time INT,
	actual_distance numeric,
	segment_actual_time INT,
    segment_osrm_time INT,
    segment_osrm_distance NUMERIC,
);

CREATE TABLE cut_off_info (
	is_cutoff BOOLEAN, 
	cutoff_factor INT, 
	cutoff_timestamp TIMESTAMP,
);

CREATE TABLE time_info (
	trip_creation_time TEXT, 
	od_start_time TEXT, 
	od_end_time TEXT, 
	start_scan_to_end_scan INT,
);