--!locks

select * from dba_dml_locks

select * from dba_ddl_locks  x   where name = 'SWD2_UTIL'

-- tylko locki
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





