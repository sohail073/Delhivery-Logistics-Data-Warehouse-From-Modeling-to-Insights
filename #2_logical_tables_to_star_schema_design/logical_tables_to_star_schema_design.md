# Database Schema

This schema organizes trip data using a star schema design with one fact table and multiple dimension tables.

## Fact Table: Trip Metrics

```sql
CREATE TABLE fact_trip_metrics (
    trip_uuid TEXT PRIMARY KEY,                -- FK to dim_trip(trip_uuid)
    source_location_id TEXT,                   -- FK to dim_location(location_id)
    destination_location_id TEXT,              -- FK to dim_location(location_id)
    time_id TEXT,                              -- FK to dim_time(time_id)
    cutoff_id TEXT,                            -- FK to dim_cutoff(cutoff_id)
    actual_time INT,
    osrm_time INT,
    actual_distance NUMERIC,
    segment_actual_time INT,
    segment_osrm_time INT,
    segment_osrm_distance NUMERIC,
    start_scan_to_end_scan INT,
    FOREIGN KEY (trip_uuid) REFERENCES dim_trip(trip_uuid),
    FOREIGN KEY (source_location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (cutoff_id) REFERENCES dim_cutoff(cutoff_id)
);
```

## Dimension Table: Location

```sql
CREATE TABLE dim_location (
    location_id TEXT PRIMARY KEY,
    location_name TEXT NOT NULL
);
```

## Dimension Table: Trip

```sql
CREATE TABLE dim_trip (
    trip_uuid TEXT PRIMARY KEY,
    route_schedule_uuid TEXT,
    route_type TEXT CHECK (route_type IN ('FTL', 'Carting'))
);
```

## Dimension Table: Time

```sql
CREATE TABLE dim_time (
    time_id TEXT PRIMARY KEY,
    trip_creation_time TIMESTAMP,
    od_start_time TIMESTAMP,
    od_end_time TIMESTAMP
);
```

## Dimension Table: Cutoff

```sql
CREATE TABLE dim_cutoff (
    cutoff_id TEXT PRIMARY KEY,
    is_cutoff BOOLEAN,
    cutoff_factor INT,
    cutoff_timestamp TIMESTAMP
);
```