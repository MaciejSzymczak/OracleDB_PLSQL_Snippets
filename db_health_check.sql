--long ops

 select s.inst_id,
       s.sid,
       s.serial#,
       s.username,
       s.module,
       round(sl.elapsed_seconds/60) || ':' || mod(sl.elapsed_seconds,60) elapsed,
       round(sl.time_remaining/60) || ':' || mod(sl.time_remaining,60) remaining,
       round(sl.sofar/sl.totalwork*100, 2) progress_pct
from   gv$session s,
       gv$session_longops sl
where  s.sid     = sl.sid
and    s.inst_id = sl.inst_id
and    s.serial# = sl.serial#;

-- CPU BY SESSION

SELECT
   s.username,
   t.sid,
   s.serial#,
   SUM(VALUE/100) as "cpu usage (seconds)"
FROM
   v$session s,
   v$sesstat t,
   v$statname n
WHERE
   t.STATISTIC# = n.STATISTIC#
AND
   NAME like '%CPU used by this session%'
AND
   t.SID = s.SID
AND
   s.status='ACTIVE'
AND
   s.username is not null
GROUP BY username,t.sid,s.serial#


-- CPU by SQL

SELECT *
    FROM
      (SELECT a.sid session_id ,
              a.sql_id ,
              a.status ,
              a.cpu_time/1000000 cpu_sec ,
              a.buffer_gets ,
              a.disk_reads ,
              b.sql_text sql_text
       FROM v$sql_monitor a ,
                          v$sql b
       WHERE a.sql_id = b.sql_id
       ORDER BY a.cpu_time DESC)
    WHERE rownum <=20;

when to run the defragmentation?
-------------------------------------
--reclaimable space % < 0 says defragmentation is required
select owner,table_name,round((blocks*8),2)||'kb' "Fragmented size"
, round((num_rows*avg_row_len/1024),2)||'kb' "Actual size"
, round((blocks*8),2)-round((num_rows*avg_row_len/1024),2)||'kb'
,((round((blocks*8),2)-round((num_rows*avg_row_len/1024),2))/round(((blocks+0.01)*8),2))*100 -10 "reclaimable space % " 
from dba_tables where OWNER LIKE 'LFPROD' order by 2

-- (optionally) checking if defragmentation is needed (times larger means there is a free space in storage to be fragmented)
 select a.owner
      ,a.table_name
      ,round(a.num_rows*a.avg_row_len/1024/1024,2) calculated_size_mb
      ,round(b.bytes/1024/1024,2) allocated_size_mb
      ,round(b.bytes/(a.num_rows*a.avg_row_len),2) times_larger
 from dba_tables a
     ,dba_segments b
where (a.num_rows > 0 and a.avg_row_len > 0 and b.bytes > 0)
  and a.partitioned = 'NO'
  and a.iot_type is null
  and a.iot_name is null
  and a.table_name = b.segment_name
  and round(b.bytes/1024/1024,2) > 1024
  and round(b.bytes/1024/1024,2) > (round(a.num_rows*a.avg_row_len/1024/1024,2)* 2) 
order by 4 desc;

how to defragment
=====================
 
1. Export / import table or
2. Create a new table, drop the old one (remember about indexes and triggers) or
3. alter table "LFPROD"."DM_ACCOUNT" enable row movement
   alter table "LFPROD"."DM_ACCOUNT" shrink space;
   (or alter table .. tablespace )
   drop and created indexes (or alter index rebuild) 

-- full scan queries

select disk_reads diskreads, executions, sql_id, sql_text
from(select disk_reads, executions, sql_id, ltrim(sql_text) sql_text, 
      sql_fulltext, operation, options, row_number() over (partition by sql_text order by disk_reads * executions desc) keephighsql
   from(select avg(disk_reads) over (partition by sql_text) disk_reads, 
          max(executions) over (partition by sql_text) executions, 
          t.sql_id, sql_text, sql_fulltext, p.operation,p.options
        from v$sql t, v$sql_plan p
        where t.hash_value=p.hash_value and p.operation='TABLE ACCESS' 
        and p.options='FULL' and p.object_owner not in ('SYS','SYSTEM')
        and t.executions > 1) 
   order by disk_reads * executions desc)
where keephighsql = 1
and rownum <=10;


-- files in use

Select segment_name, partition_name, segment_type, tablespace_name
from   dba_extents a, v$session_wait b
where  b.p2 between a.block_id and (a.block_id + a.blocks - 1)
and    a.file_id  = b.p1
and    b.event    = 'db file sequential read'; 


set serveroutput on;
      
BEGIN
 DBMS_OUTPUT.ENABLE(1000000);
end;
/

declare
 statement varchar2(1000);
begin
  for rec in (
    select 'alter index '||owner||'.'||index_name||' rebuild' statement from all_indexes where  substr(table_name,1,3) in ('DM_','TA_','CC_')
  ) loop
   begin
     statement := rec.statement;
     execute immediate rec.statement;
   exception when others then
     DBMS_OUTPUT.PUT_LINE('ERROR:'|| statement);
   end;
   end loop;
end;
/

begin
  for rec in (
    select 'alter table LFPROD.'||table_name||' enable row movement' statement from all_tables where substr(table_name,1,3) in ('DM_','TA_','CC_') 
    union all
    select 'alter table LFPROD.'||table_name||' shrink space' statement from all_tables where substr(table_name,1,3) in ('DM_','TA_','CC_')
  ) loop
   execute immediate rec.statement;
   end loop; 
end;
/

declare
 statement varchar2(1000);
begin
  for rec in (
    select 'alter index '||owner||'.'||index_name||' rebuild' statement from all_indexes where  substr(table_name,1,3) in ('DM_','TA_','CC_')
  ) loop
   begin
     statement := rec.statement;
     execute immediate rec.statement;
   exception when others then
     DBMS_OUTPUT.PUT_LINE('ERROR:'|| statement);
   end;
   end loop;
end;
/

begin
  dbms_stats.gather_schema_stats
    (OWNNAME => 'LFPROD',
     ESTIMATE_PERCENT => null,
     DEGREE => 1, /*number of processors*/
     CASCADE => TRUE,
     OPTIONS => 'GATHER',
     GRANULARITY => 'ALL', 
     No_Invalidate => FALSE);
end;
/ 

begin
  for rec in (
  select table_name from all_tables where substr(table_name,1,3) in ('DM_','TA_','CC_')
  ) loop
  dbms_stats.gather_table_stats
    ( OWNNAME => 'LFPROD'
    , TABNAME => rec.table_name
    , ESTIMATE_PERCENT => null
    , DEGREE => 1
    , CASCADE => TRUE
    , GRANULARITY => 'ALL'
    , No_Invalidate => FALSE);
   end loop; 
end;
/


-------- Displays several performance indicators and comments on the value.

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/tuning.sql
-- Author       : Tim Hall
-- Description  : Displays several performance indicators and comments on the value.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @tuning
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 1000
SET FEEDBACK OFF

SELECT *
FROM   v$database;
PROMPT

DECLARE
  v_value  NUMBER;

  FUNCTION Format(p_value  IN  NUMBER) 
    RETURN VARCHAR2 IS
  BEGIN
    RETURN LPad(To_Char(Round(p_value,2),'990.00') || '%',8,' ') || '  ';
  END;

BEGIN

  -- --------------------------
  -- Dictionary Cache Hit Ratio
  -- --------------------------
  SELECT (1 - (Sum(getmisses)/(Sum(gets) + Sum(getmisses)))) * 100
  INTO   v_value
  FROM   v$rowcache;

  DBMS_Output.Put('Dictionary Cache Hit Ratio       : ' || Format(v_value));
  IF v_value < 90 THEN
    DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 90%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;

  -- -----------------------
  -- Library Cache Hit Ratio
  -- -----------------------
  SELECT (1 -(Sum(reloads)/(Sum(pins) + Sum(reloads)))) * 100
  INTO   v_value
  FROM   v$librarycache;

  DBMS_Output.Put('Library Cache Hit Ratio          : ' || Format(v_value));
  IF v_value < 99 THEN
    DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 99%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;

  -- -------------------------------
  -- DB Block Buffer Cache Hit Ratio
  -- -------------------------------
  SELECT (1 - (phys.value / (db.value + cons.value))) * 100
  INTO   v_value
  FROM   v$sysstat phys,
         v$sysstat db,
         v$sysstat cons
  WHERE  phys.name  = 'physical reads'
  AND    db.name    = 'db block gets'
  AND    cons.name  = 'consistent gets';

  DBMS_Output.Put('DB Block Buffer Cache Hit Ratio  : ' || Format(v_value));
  IF v_value < 89 THEN
    DBMS_Output.Put_Line('Increase DB_BLOCK_BUFFERS parameter to bring value above 89%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;
  
  -- ---------------
  -- Latch Hit Ratio
  -- ---------------
  SELECT (1 - (Sum(misses) / Sum(gets))) * 100
  INTO   v_value
  FROM   v$latch;

  DBMS_Output.Put('Latch Hit Ratio                  : ' || Format(v_value));
  IF v_value < 98 THEN
    DBMS_Output.Put_Line('Increase number of latches to bring the value above 98%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;

  -- -----------------------
  -- Disk Sort Ratio
  -- -----------------------
  SELECT (disk.value/mem.value) * 100
  INTO   v_value
  FROM   v$sysstat disk,
         v$sysstat mem
  WHERE  disk.name = 'sorts (disk)'
  AND    mem.name  = 'sorts (memory)';

  DBMS_Output.Put('Disk Sort Ratio                  : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase SORT_AREA_SIZE parameter to bring value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;
  
  -- ----------------------
  -- Rollback Segment Waits
  -- ----------------------
  SELECT (Sum(waits) / Sum(gets)) * 100
  INTO   v_value
  FROM   v$rollstat;

  DBMS_Output.Put('Rollback Segment Waits           : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase number of Rollback Segments to bring the value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;

  -- -------------------
  -- Dispatcher Workload
  -- -------------------
  SELECT NVL((Sum(busy) / (Sum(busy) + Sum(idle))) * 100,0)
  INTO   v_value
  FROM   v$dispatcher;

  DBMS_Output.Put('Dispatcher Workload              : ' || Format(v_value));
  IF v_value > 50 THEN
    DBMS_Output.Put_Line('Increase MTS_DISPATCHERS to bring the value below 50%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;
  
END;
/

PROMPT
SET FEEDBACK ON


---------------------------------------

select * from user_resource_limits
select * from v$process order by PGA_USED_MEM desc     
select LOGON_TIME,  floor(last_call_et / 60) "Minutes since active", sql_id from v$session
select * from v$resource_limit



