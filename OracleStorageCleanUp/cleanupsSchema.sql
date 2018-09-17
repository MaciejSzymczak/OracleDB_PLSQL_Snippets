*** this script cleanups storage of schema ***
*** it may take a few days ***
*** Maciej Szymczak, 2017.06.03 ***


set serveroutput on;
      
BEGIN
 DBMS_OUTPUT.ENABLE(1000000);
end;
/


begin
  DBMS_OUTPUT.PUT_LINE('*** gather_schema_stats');
  dbms_stats.gather_schema_stats
    (OWNNAME => 'LFPROD',
     ESTIMATE_PERCENT => 10, /* you can place here null(=100%) or 10 (means 10%) to speed up the process*/
     DEGREE => 1, /*number of processors*/
     CASCADE => TRUE,
     OPTIONS => 'GATHER',
     GRANULARITY => 'ALL', 
     No_Invalidate => FALSE);
end;
/ 
