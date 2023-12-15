-- locks monitor
with lock_query as (
    select /*+ rule*/ s.sid, s.username, s.sid || ',' || s.serial# sid_serial, s.module
          ,p.spid, s.status, s.osuser, s.machine, s.program, s.sql_id, state, event
          ,blocking_session sid_b
     from v$session s
         ,v$process p
    where s.paddr = p.addr
      and blocking_session is not null
    union all
    select /*+ rule*/ s.sid, s.username, s.sid || ',' || s.serial# sid_serial, s.module
          ,p.spid, s.status, s.osuser, s.machine, s.program, s.sql_id, state, event
          ,blocking_session sid_b
     from v$session s
         ,v$process p
    where s.paddr = p.addr
      and s.sid in (select distinct blocking_session from gv$session)
  )
select /*+ rule */ lpad('  ',2*(level-1)) || sid lock_tree, /*sid,*/ username
      ,sid_serial, spid, status, osuser, machine
      ,program, module, sql_id, state, event
from lock_query
connect by  prior sid = sid_b
  start with sid_b is null; 
  
SELECT * FROM TABLE(dbms_xplan.display_awr('chcyn8wyuutyk'));

-- locks monitor
select 
   substr(decode (l.request, 0, 'Holder: ','Waiter: ')||''''||l.sid||','||s.serial#||'''',1,20) sess
   , (SELECT 'ALTER SYSTEM KILL SESSION '''|| SID ||',' ||SERIAL#||'''' FROM V$SESSION WHERE SID = L.SID) KILL_STATEMENT
   , l.id1                                                                                                               
   , l.id2                                                                                                               
   , l.lmode                                                                                                             
   , l.request                                                                                                           
   , l.type                                                                                                              
   , l.inst_id
   , terminal
   , program         
   , module                                                                                                  
from gv$lock l                                                                                                        
   , v$session s                                                                                                         
where l.sid = s.sid (+)                                                                                               
   and (l.id1, l.id2, l.type) in                                                                                         
   ( select id1                                                                                                          
     , id2                                                                                                               
     , type                                                                                                              
     from gv$lock                                                                                                        
     where request>0                                                                                                     
   )                                                                                                                     
order by l.id1, l.inst_id,  l.request                                                                               

--!locks

select * from dba_dml_locks
select * from dba_ddl_locks  x   where name = 'SWD2_UTIL'

-- wszystkie sesje
select (SELECT 'ALTER SYSTEM KILL SESSION '''|| s.SID ||',' ||s.SERIAL#||'''' FROM V$SESSION WHERE SID = s.SID) KILL_STATEMENT, 
   s.sid, s.serial#, p.spid, s.* 
from  v$session s, 
      v$process p 
where s.paddr = p.addr 
  and s.sid in (select SESSION_ID from v$locked_object);

-- wszystkie obiekty zablokowane przez sesje (wiêcej ni¿ lock)
select l.*
    ,  (select object_name from all_objects where object_id = l.object_id) object_name 
from v$locked_object l

-- pokazuje wszystkie obiekty zablokowane i u¿ywane (niezablokowane) przez sesje (wiêcej ni¿ locks)
select * from v$access where object = 'CWF_T_DECISION_EXCEPTIONS'

--Oracle has several views for showing lock status, some of which show the username:
DBA_BLOCKERS – Shows non-waiting sessions holding locks being waited-on 
DBA_DDL_LOCKS – Shows all DDL locks held or being requested 
DBA_DML_LOCKS  - Shows all DML locks held or being requested 
DBA_LOCK_INTERNAL – Displays 1 row for every lock or latch held or being requested with the username of who is holding the lock 
select * from DBA_LOCKS  -- Shows all locks or latches held or being requested 
select * from DBA_WAITERS  -- Shows all sessions waiting on, but not holding waited for locks
select * from DBA_LOCK_INTERNAL --view used to show locks for a specific user, and you can specify the query in the form:

SELECT
   NVL(b.username,'SYS') username,
   session_id,lock_type,mode_held,
   mode_requested,lock_id1,lock_id2
FROM
   sys.dba_lock_internal a, 
   sys.v_$session b
where  . . . 
 

You can also query v$access and v$locked_object to see specific locks:  

select * from v$access where OBJECT = 'CWF_T_REAL_ESTATES'

select s.sid, s.serial#, p.spid 
from 
   v$session s, 
   v$process p 
where 
   s.paddr = p.addr 
and 
   s.sid in (select SESSION_ID from v$locked_object)
 





-- FND_USER - który user które tabele 
SELECT 
       vs.sid
      ,vp.pid
      ,c.owner
      ,c.object_name
      ,c.object_type
      ,fu.user_name locking_fnd_user_name
      ,fl.start_time locking_fnd_user_login_time
      ,vs.module
      ,vs.machine
      ,vs.osuser
      ,vlocked.oracle_username
      ,vp.spid AS os_process
      ,vs.serial#
      ,vs.status
      ,vs.saddr
      ,vs.audsid
      ,vs.process
FROM fnd_logins      fl
    ,fnd_user        fu
    ,v$locked_object vlocked
    ,v$process       vp
    ,v$session       vs
    ,dba_objects     c
WHERE vs.sid = vlocked.session_id
AND vlocked.object_id = c.object_id
AND vs.paddr = vp.addr
AND vp.spid = fl.process_spid(+)
AND vp.pid = fl.pid(+)
AND fl.user_id = fu.user_id(+)
--AND c.object_name LIKE '%' || upper('&tab_name_leaveblank4all') || '%'
AND nvl(vs.status
      ,'XX') != 'KILLED'
order by sid

-- blokady szczegó³owo 
SELECT 
        (SELECT DECODE(COUNT(*),0,NULL,'WAITER') FROM V$LOCK WHERE SID = L.SID AND REQUEST > 0 ) 
     || (SELECT DECODE(COUNT(*),0,NULL,'HOLDER') FROM V$LOCK L2 WHERE SID = L.SID AND REQUEST = 0 AND (l2.id1, l2.id2, l2.type) in ( select id1, id2, type from gv$lock where request>0)) WAITER_HOLDER
     , (SELECT 'ALTER SYSTEM KILL SESSION '''|| SID ||',' ||SERIAL#||'''' FROM V$SESSION WHERE SID = L.SID) KILL_STATEMENT
     , (SELECT DISTINCT SUBSTR(SQL_TEXT,1,250) FROM V$SQL WHERE (HASH_VALUE, ADDRESS) = (SELECT SQL_HASH_VALUE, SQL_ADDRESS FROM V$SESSION WHERE SID = L.SID)) CURRENT_SQL 
     , (SELECT START_TIME FROM V$TRANSACTION WHERE ADDR = (SELECT TADDR FROM V$SESSION WHERE SID = L.SID) ) TRANSACTION_STARTED
     , (SELECT COUNT(*) FROM V$OPEN_CURSOR WHERE SID = L.SID ) OPEN_CURSORS
     , DECODE ( TYPE
       ,  'TM', 'DML:'      || (SELECT OBJECT_NAME FROM DBA_OBJECTS WHERE OBJECT_ID = L.ID1) 
       ,  'TX', 'ROLLBACK:' || (SELECT NAME FROM V$ROLLNAME WHERE USN =  TRUNC(L.ID1/65536))
       , 'S') OBJECT_NAME
       ,DECODE(l.lmode, 
         0, '-',  
         1, 'Null',  
         2, 'Row-S (SS)', 
         3, 'Row-X (SX)', 
         4, 'Share',   
         5, 'S/Row-X (SSX)', 
         6, 'Exclusive', 
         TO_CHAR(l.lmode)) mode_held 
       ,DECODE(L.request, 
         0, '-', 
         1, 'Null', 
         2, 'Row-S (SS)',  
         3, 'Row-X (SX)',  
         4, 'Share',   
         5, 'S/Row-X (SSX)', 
         6, 'Exclusive',  
         TO_CHAR(l.request)) mode_requested    
       , DECODE(l.TYPE, 
          'MR', 'Media Recovery', 
          'RT', 'Redo Thread', 
          'UN', 'User Name', 
          'TX', 'Transaction', 
          'TM', 'DML', 
          'UL', 'PL/SQL User Lock', 
          'DX', 'Distributed Xaction', 
          'CF', 'Control File', 
          'IS', 'Instance State', 
          'FS', 'File Set', 
          'IR', 'Instance Recovery', 
          'ST', 'Disk Space Transaction', 
          'TS', 'Temp Segment', 
          'IV', 'Library Cache Invalidation', 
          'LS', 'Log Start or Switch', 
          'RW', 'Row Wait', 
          'SQ', 'Sequence Number', 
          'TE', 'Extend Table', 
          'TT', 'Temp Table', 
          'BL','Buffer hash table instance', 
          'CI','Cross-instance function invocation instance', 
          'CU','Cursor bind', 
          'DF','Data file instance', 
          'DL','Direct loader parallel index create', 
          'DM','Mount/startup db primary/secondary instance', 
          'DR','Distributed recovery process', 
          'HW','Space management operations on a specific segment', 
          'IN','Instance number', 
          'JQ','Job queue', 
          'KK','Thread kick', 
          'LA','Library cache lock instance lock namespace A', 
          'LB','Library cache lock instance lock namespace B', 
          'LC','Library cache lock instance lock namespace C', 
          'LD','Library cache lock instance lock namespace D', 
          'LE','Library cache lock instance lock namespace E', 
          'LF','Library cache lock instance lock namespace F', 
          'LG','Library cache lock instance lock namespace G', 
          'LH','Library cache lock instance lock namespace H', 
          'LI','Library cache lock instance lock namespace I', 
          'LJ','Library cache lock instance lock namespace J', 
          'LK','Library cache lock instance lock namespace K', 
          'LL','Library cache lock instance lock namespace L', 
          'LM','Library cache lock instance lock namespace M', 
          'LN','Library cache lock instance lock namespace N', 
          'LO','Library cache lock instance lock namespace O', 
          'LP','Library cache lock instance lock namespace P', 
          'MM','Mount definition global enqueue', 
          'NA','Library cache pin instance A', 
          'NB','Library cache pin instance B', 
          'NC','Library cache pin instance C', 
          'ND','Library cache pin instance D', 
          'NE','Library cache pin instance E', 
          'NF','Library cache pin instance F', 
          'NG','Library cache pin instance G', 
          'NH','Library cache pin instance H', 
          'NI','Library cache pin instance I', 
          'NJ','Library cache pin instance J', 
          'NK','Library cache pin instance K', 
          'NL','Library cache pin instance L', 
          'NM','Library cache pin instance M', 
          'NN','Library cache pin instance N', 
          'NO','Library cache pin instance O', 
          'NP','Library cache pin instance P', 
          'NQ','Library cache pin instance Q', 
          'NR','Library cache pin instance R', 
          'NS','Library cache pin instance S', 
          'NT','Library cache pin instance T', 
          'NU','Library cache pin instance U', 
          'NV','Library cache pin instance V', 
          'NW','Library cache pin instance W', 
          'NX','Library cache pin instance X', 
          'NY','Library cache pin instance Y', 
          'NZ','Library cache pin instance Z', 
          'PF','Password File', 
          'PI',' PS Parallel operation', 
          'PR','Process startup', 
          'QA','Row cache instance A', 
          'QB','Row cache instance B', 
          'QC','Row cache instance C', 
          'QD','Row cache instance D', 
          'QE','Row cache instance E', 
          'QF','Row cache instance F', 
          'QG','Row cache instance G', 
          'QH','Row cache instance H', 
          'QI','Row cache instance I', 
          'QJ','Row cache instance J', 
          'QK','Row cache instance K', 
          'QL','Row cache instance L', 
          'QM','Row cache instance M', 
          'QN','Row cache instance N', 
          'QO','Row cache instance O', 
          'QP','Row cache instance P', 
          'QQ','Row cache instance Q', 
          'QR','Row cache instance R', 
          'QS','Row cache instance S', 
          'QT','Row cache instance T', 
          'QU','Row cache instance U', 
          'QV','Row cache instance V', 
          'QW','Row cache instance W', 
          'QX','Row cache instance X', 
          'QY','Row cache instance Y', 
          'QZ','Row cache instance Z', 
          'SC','System commit number instance', 
          'SM','SMON', 
          'SN','Sequence number instance', 
          'SS','Sort segment', 
          'SV','Sequence number value', 
          'TA','Generic enqueue', 
          'US','Undo segment DDL', 
          'WL','Being-written redo log instance', 
           l.TYPE) lock_type          
       , L.*
FROM V$LOCK L
ORDER BY SID

-- poprzednie nie zadzia³a³o - spróbuj tego
select a.sid, b.serial#, a.inst_id, substr (a.event, 1, 30) event_name, substr (b.username, 1, 15), a.p1, a.p2,       
round(a.seconds_in_wait/60,0) minutes, state                                                                          
from gv$session_wait a, gv$session b                                                                                  
where a.sid=b.sid and a.inst_id=b.inst_id and a.event not like '%SQL%' and a.event not like '%rdbms%'             
and a.event not like '%time%' and a.event not like '%message%' and event not like '%pipe%'                      
and seconds_in_wait > 600 -- 10 minut                                                                                 
order by seconds_in_wait desc 


Source: https://github.com/gwenshap
=======================================================================

-- Find all blocked sessions and who is blocking them
select sid,blocking_session,username,sql_id,event,machine,osuser,program,last_call_et from v$session where blocking_session > 0;

select * from dba_blockers
select * from dba_waiters

-- Find what the blocking session is doing
select sid,blocking_session,username,sql_id,event,state,machine,osuser,program,last_call_et from v$session where sid=746 ;

-- Find the blocked objects
select owner,object_name,object_type from dba_objects where object_id in (select object_id from v$locked_object where session_id=271 and locked_mode =3);


-- Friendly query for who is blocking who
-- Mostly for versions before v$session had blocking_session column
select s1.inst_id,s2.inst_id,s1.username || '@' || s1.machine
 || ' ( SID=' || s1.sid || ' )  is blocking '
 || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
  from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2
order by s1.inst_id;


-- find blocking sessions that were blocking for more than 15 minutes + objects and sql
select s.SID,p.SPID,s.machine,s.username,CTIME/60 as minutes_locking, do.object_name as locked_object, q.sql_text
from v$lock l
join v$session s on l.sid=s.sid
join v$process p on p.addr = s.paddr
join v$locked_object lo on l.SID = lo.SESSION_ID
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
join v$sqlarea q on  s.sql_hash_value = q.hash_value and s.sql_address = q.address
where block=1 and ctime/60>15

-- Check who is blocking who in RAC
SELECT DECODE(request,0,'Holder: ','Waiter: ') || sid sess, id1, id2, lmode, request, type
FROM gv$lock
WHERE (id1, id2, type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;

-- Check who is blocking who in RAC, including objects
SELECT DECODE(request,0,'Holder: ','Waiter: ') || gv$lock.sid sess, machine, do.object_name as locked_object,id1, id2, lmode, request, gv$lock.type
FROM gv$lock join gv$session on gv$lock.sid=gv$session.sid and gv$lock.inst_id=gv$session.inst_id
join gv$locked_object lo on gv$lock.SID = lo.SESSION_ID and gv$lock.inst_id=lo.inst_id
join dba_objects do on lo.OBJECT_ID = do.OBJECT_ID 
WHERE (id1, id2, gv$lock.type) IN (
  SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;




-- Who is blocking who, with some decoding
select	sn.USERNAME,
	m.SID,
	sn.SERIAL#,
	m.TYPE,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_type,
	decode(REQUEST,
		0, 'None', 
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)', 
		4, 'Share', 
		5, 'S/Row-X (SSX)',
		6, 'Exclusive') lock_requested,
	m.ID1,
	m.ID2,
	t.SQL_TEXT
from 	v$session sn, 
	v$lock m , 
	v$sqltext t
where 	t.ADDRESS = sn.SQL_ADDRESS 
and 	t.HASH_VALUE = sn.SQL_HASH_VALUE 
and 	((sn.SID = m.SID and m.REQUEST != 0) 
or 	(sn.SID = m.SID and m.REQUEST = 0 and LMODE != 4 and (ID1, ID2) in
        (select s.ID1, s.ID2 
         from 	v$lock S 
         where 	REQUEST != 0 
         and 	s.ID1 = m.ID1 
         and 	s.ID2 = m.ID2)))
order by sn.USERNAME, sn.SID, t.PIECE

-- Who is blocking who, with some decoding
select	OS_USER_NAME os_user,
	PROCESS os_pid,
	ORACLE_USERNAME oracle_user,
	l.SID oracle_id,
	decode(TYPE,
		'MR', 'Media Recovery',
		'RT', 'Redo Thread',
		'UN', 'User Name',
		'TX', 'Transaction',
		'TM', 'DML',
		'UL', 'PL/SQL User Lock',
		'DX', 'Distributed Xaction',
		'CF', 'Control File',
		'IS', 'Instance State',
		'FS', 'File Set',
		'IR', 'Instance Recovery',
		'ST', 'Disk Space Transaction',
		'TS', 'Temp Segment',
		'IV', 'Library Cache Invalidation',
		'LS', 'Log Start or Switch',
		'RW', 'Row Wait',
		'SQ', 'Sequence Number',
		'TE', 'Extend Table',
		'TT', 'Temp Table', type) lock_type,
	decode(LMODE,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', lmode) lock_held,
	decode(REQUEST,
		0, 'None',
		1, 'Null',
		2, 'Row-S (SS)',
		3, 'Row-X (SX)',
		4, 'Share',
		5, 'S/Row-X (SSX)',
		6, 'Exclusive', request) lock_requested,
	decode(BLOCK,
		0, 'Not Blocking',
		1, 'Blocking',
		2, 'Global', block) status,
	OWNER,
	OBJECT_NAME
from	v$locked_object lo,
	dba_objects do,
	v$lock l
where 	lo.OBJECT_ID = do.OBJECT_ID
AND     l.SID = lo.SESSION_ID
and block=1




Source: https://github.com/gwenshap
=======================================================================

-- Check what the sessions in our instance are waiting for
select event,count(*) from v$session group by event order by count(*);

-- Flexible query to check what's currently running in the system
-- Where statement and column lists can be modified by the case
-- Written for RAC DBs
select 
s.inst_id,
--      'alter system kill session '''|| s.SID||',' || s.serial# ||'''' ,
--'!kill -9 ' || p.spid, 
      p.SPID UnixProcess ,s.SID,s.serial#,s.USERNAME,s.COMMAND,s.MACHINE,s.blocking_session
      ,s.program, status,state,event,s.sql_id,sql_text,COMMAND_TYPE
--    ,sbc.name,to_char(sbc.last_captured,'yyyy-mm-dd hh24:mi:ss'),sbc.value_string
    from gv$session s
left outer join gv$process p on p.ADDR = s.PADDR and s.inst_id=p.inst_id 
left outer join gv$sqlarea sa on sa.ADDRESS = s.SQL_ADDRESS and s.inst_id=sa.inst_id
--left outer join gV$SQL_BIND_CAPTURE sbc on sbc.ADDRESS = s.SQL_ADDRESS and s.inst_id=p.inst_id
where 1=1 and sql_text like '...'

-- Check what a specific session is doing:
select 
      p.SPID UnixProcess ,s.SID,s.serial#,s.USERNAME,s.COMMAND,s.MACHINE,s.SQL_ADDRESS,s.SQL_HASH_VALUE
      ,s.program, status,sql_text,COMMAND_TYPE
    from gv$session s,gv$process p, gv$sqlarea sa
	where p.ADDR = s.PADDR and s.inst_id=p.inst_id 
	and sa.ADDRESS = s.SQL_ADDRESS and s.inst_id=sa.inst_id
	and s.sid=1722;

-- Find all sessions that are blocked and which session is blocking them
-- Then find what the blocking session is doing
select sid,blocking_session,username,sql_id,event,machine,osuser,program from v$session where blocking_session > 0;
select sid,blocking_session,username,sql_id,event,machine,osuser,program from v$session where sid=491;


-- generate commands to kill all sessions from a specific user on specific instance
select 'alter system kill session '''|| SID||',' || serial# ||''' immediate;' from gv$session where username='BAD_USER' and inst_id=1;


-- Kill all sessions waiting for specific events by a specific user
select       'alter system kill session '''|| s.SID||',' || s.serial# ||''';' 
from gv$session s
where 1=1 
and (event='latch: shared pool' or event='library cache lock') and s.USERNAME='DBSNMP';

-- kill all sessions executing a bad SQL
select 
     'alter system kill session '''|| s.SID||',' || s.serial# ||''';' 
    from v$session s
where s.sql_id='0vj44a7drw1rj';


-- Sessions taking most PGA memory
-- Can be used to find leaks
select addr,SPID,username,program,pga_alloc_mem/1024 mem_alloc_Kb from v$process order by pga_alloc_mem;

-- Check what is the top SQL executed by parallel slaves
select sql_id,count(*) from v$session where program like '%P0%' group by sql_id;



-- Find inactive sessions
-- This can be used to decide which sessions to kill if the DB is running out of processes
select sid, blocking_session,username,program,machine,osuser,  sql_id, prev_sql_id, event,LAST_CALL_ET from v$session where status != 'ACTIVE' and last_call_et>3600;


-- How many sessions openned by each app server
select machine,count(*) from gv$session s group by machine;

-- Find sql_id for a specific sql snippet
select sql_id,sql_text from v$sql where dbms_lob.instr(sql_text, 'create INDEX',1,1) > 0

-- Find SQL with too many child cursors:
select version_count,sql_text from v$sqlarea order by version_count desc



-- Get the longops status for a specific session
	select sid
	,      message, start_time,time_remaining 
	from   v$session_longops
	where  sid = 28
	order by start_time;

-- Check status for long ops executing right now
  select s.sid,s.serial#,opname, target, program,sofar, totalwork,units, elapsed_seconds, message,start_time,time_remaining   
from v$session_longops l
join v$session s on l.sid=s.sid and s.serial#=l.serial#
where time_remaining>0
order by start_time desc




-- Find out how much memory each session is using
COLUMN sid                     FORMAT 999            HEADING 'SID'
COLUMN oracle_username         FORMAT a12            HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username             FORMAT a9             HEADING 'O/S User'        JUSTIFY right
COLUMN session_program         FORMAT a18            HEADING 'Session Program' TRUNC
COLUMN session_module         FORMAT a18            HEADING 'Session module' TRUNC
COLUMN session_action         FORMAT a18            HEADING 'Session action' TRUNC
COLUMN session_machine         FORMAT a8             HEADING 'Machine'   JUSTIFY right TRUNC
COLUMN session_pga_memory      FORMAT 9,999,999,999  HEADING 'PGA Memory'
COLUMN session_pga_memory_max  FORMAT 9,999,999,999  HEADING 'PGA Memory Max'
COLUMN session_uga_memory      FORMAT 9,999,999,999  HEADING 'UGA Memory'
COLUMN session_uga_memory_max  FORMAT 9,999,999,999  HEADING 'UGA Memory MAX'
COLUMN session_total_memory  FORMAT 9,999,999,999  HEADING 'Total Memory'

select sid,oracle_username,os_username,session_program,session_module,session_action, 
session_pga_memory,session_pga_memory_max,session_uga_memory,session_uga_memory_max,session_pga_memory+session_uga_memory session_total_memory from (
SELECT
    s.sid                sid
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , s.program            session_program
  , s.module            session_module
  , s.action            session_action
  , lpad(s.machine,8)    session_machine
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory')        session_pga_memory
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory max')    session_pga_memory_max
  , (select ss.value  from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory')        session_uga_memory
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory max')   as session_uga_memory_max
FROM 
    v$session  s )
ORDER BY session_total_memory DESC;










