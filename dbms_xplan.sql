--!plan zapytania  --!explain plan

select * from v$sql

-- bind variables for v$sql
select * from gv$sql_bind_capture

select * from table(dbms_xplan.display_cursor('3kxkr01zyc00f'))   -- = v$sql.sql_id

see also
dbms_stats

