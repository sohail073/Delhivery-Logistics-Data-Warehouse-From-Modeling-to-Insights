## Creating trip table

``` 
CREATE TABLE trips (
	trip_uuid TEXT,
	route_schedule_uuid TEXT,
	route_type TEXT,
	source_center TEXT,
	destination_center TEXT,
);
```

## Creating location table

```
CREATE TABLE location (
	location_id TEXT,
	location_name TEXT,
);
```

## Creating route_metrics table

```
CREATE TABLE route_metrics (
	actual_time INT,
	osrm_time INT,
	actual_distance INT,
	segment_actual_time INT,
    segment_osrm_time INT,
    segment_osrm_distance NUMERIC,
);
```

## Creating cut_off_info table

```
CREATE TABLE cut_off_info (
	is_cutoff BOOLEAN, 
	cutoff_factor INT, 
	cutoff_timestamp TIMESTAMP,
);
```
## Creating time_info table

```
CREATE TABLE time_info (
	trip_creation_time TEXT, 
	od_start_time TEXT, 
	od_end_time TEXT, 
	start_scan_to_end_scan INT,
);
```


