*** this script cleanups storage of table ***
*** replace table name DM_ACCOUNT with your own table name ***
*** Maciej Szymczak, 2017.06.03 ***

set serveroutput on;
      
BEGIN
 DBMS_OUTPUT.ENABLE(1000000);
end;
/

declare
 statement varchar2(1000);
begin
  --http://www.oracle.com/technetwork/issue-archive/2005/05-may/o35tuning-096075.html
  DBMS_OUTPUT.PUT_LINE('*** enable row movement');
  for rec in (
    --('DM_','TA_','CC_')
    select 'alter table '||owner||'.'||table_name||' enable row movement' statement from all_tables where owner='LFPROD'and ( table_name in ('DM_ACCOUNT'))
    union all
    select 'alter table '||owner||'.'||table_name||' shrink space compact' statement from all_tables where owner='LFPROD'and (table_name in ('DM_ACCOUNT'))
    union all
    select 'alter table '||owner||'.'||table_name||' shrink space' statement from all_tables where owner='LFPROD'and (table_name in ('DM_ACCOUNT'))
  ) loop
      begin
       statement := rec.statement;
       DBMS_OUTPUT.PUT_LINE('Running ' || statement || '...' );
       execute immediate rec.statement;
      exception when others then
       DBMS_OUTPUT.PUT_LINE('ERROR:'|| statement || '    ' || SQLERRM);
      end;
   end loop; 
end;
/

begin
 dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);
 dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
 dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false);
 dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',false);
 for rec in (
     select table_owner, index_name, to_char(dbms_metadata.get_ddl('INDEX',index_name,table_owner)) stmt from all_indexes where table_name in ('DM_ACCOUNT') and table_owner ='LFPROD'
 ) loop
    execute immediate 'drop index '||rec.table_owner||'.'||rec.index_name;
    execute immediate rec.stmt;
 end loop;
end;
/

begin
  DBMS_OUTPUT.PUT_LINE('*** gather_table_stats');
  for rec in (
  select table_name from all_tables where owner='LFPROD'and (table_name in ('DM_ACCOUNT'))
  ) loop
   begin
    DBMS_OUTPUT.PUT_LINE('Running ' || rec.table_name || '...' );
    dbms_stats.gather_table_stats
      ( OWNNAME => 'LFPROD'
      , TABNAME => rec.table_name
      , ESTIMATE_PERCENT => 10
      , DEGREE => 1
      , CASCADE => TRUE
      , GRANULARITY => 'ALL'
      , No_Invalidate => FALSE);
    exception when others then
       DBMS_OUTPUT.PUT_LINE('ERROR:'|| rec.table_name || '    ' || SQLERRM);
      end;
   end loop; 
end;
/

