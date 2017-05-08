When to run the statitics?
----------------------------
If number of records is different from these two queries:
  select count(1) from LFPROD.DM_ACCOUNT_PA
  select num_rows from dba_tables where table_name = 'DM_ACCOUNT_PA'

How to run the gathering?
-----------------------------

begin
  dbms_stats.gather_schema_stats
    (OWNNAME => 'MPI_COMMONS',
     ESTIMATE_PERCENT => null, /*you can place here 10 (10%) to speed up the process*/
     DEGREE => 1, /*number of processors*/
     CASCADE => TRUE,
     OPTIONS => 'GATHER',
     GRANULARITY => 'ALL', 
     No_Invalidate => FALSE);
end;
/ 

begin
  dbms_stats.gather_table_stats
    ( OWNNAME => 'LFPROD'
    , TABNAME => 'DM_CONTACT'
    , ESTIMATE_PERCENT => null
    , DEGREE => 1
    , CASCADE => TRUE
    , GRANULARITY => 'ALL'
    , No_Invalidate => FALSE);
end;
/



How to check is auto gathering is on?
---------------------------------------
SELECT * FROM dba_autotask_schedule;

SELECT job_name, log_date, status, error#, actual_start_date at time zone 'UTC' actual_start_date, run_duration, cpu_used FROM dba_scheduler_job_run_details
order by log_date desc

SELECT client_name, status FROM dba_autotask_operation;



select * from sys.ALL_TAB_COL_STATISTICS where  owner = 'LFPROD' and table_name like 'DM%' and table_name not like 'DM_TMP%' 
          order by density, table_name, column_name


see also
db_health_check.sql
