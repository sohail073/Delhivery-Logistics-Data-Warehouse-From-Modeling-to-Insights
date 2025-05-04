# ETL Pipeline Automation with PostgreSQL and pgAgent

This document outlines the process of creating a stored procedure for ETL operations and scheduling it to run automatically using pgAgent.

## Creating a Stored Procedure

First, we create a stored procedure that encapsulates our entire ETL pipeline. This allows us to execute the complete data transformation process with a single command.

```sql
CREATE OR REPLACE PROCEDURE run_etl_pipeline()
LANGUAGE plpgsql
AS $
BEGIN
    -- ETL process code here
    
    raise notice 'ETL Completed (Data''s has been updated)';
END;
$;
```

The procedure includes all our ETL steps which can be found in #3:

   ```

## Creating a Job Schedule

Use the pgAdmin interface to set up a job schedule for your ETL procedure:

1. Open pgAdmin and connect to your database
2. Right-click on "pgAgent Jobs" and select "Create > pgAgent Job"
3. In the General tab:
   - Name: `Daily_ETL_Pipeline_Run`
   - Enabled: Yes
   - Comment: "Daily ETL process that runs at 2AM"

4. In the Steps tab:
   - Click "Add" to create a new step
   - Name: `Run_ETL_Procedure`
   - Enabled: Yes
   - Kind: SQL
   - Connection type: Local
   - Database: Your database name
   - Code: `CALL run_etl_pipeline();`

5. In the Schedules tab:
   - Click "Add" to create a new schedule
   - Name: `Daily_Run_2AM`
   - Enabled: Yes
   - Start: Select current date
   - Repeat: Enabled
   - Days: 1 (to run daily)
   - In the Week Days, Month Days, and Months tabs, select "All" to run every day


## Benefits of Using pgAgent for ETL Automation

1. **Scheduled Execution**: Ensures the ETL process runs at the optimal time (2AM) when database usage is low
2. **Error Handling**: Provides logging and notification options when jobs fail
3. **Centralized Management**: All database maintenance processes can be managed in one place
4. **No External Dependencies**: Runs within PostgreSQL with no need for external scheduling tools
5. **Transaction Management**: Handles database transactions properly