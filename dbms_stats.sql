--!gathering statitistics 
dbms_stats.gather_index_stats
dbms_stats.gather_table_stats
dbms_stats.gather_schema_stats
dbms_stats.gather_database_stats

see also dbms_xplan
------------------------

create table test1
2 (A number
3 ,B varchar2(100));

-- In 10g table automatically has monitor option enabled.
-- For 9i you should execute the following:

alter table test1 monitoring;

select monitoring from user_tables where table_name = 'TEST1';

SQL> insert into test1 values (1,'a');
1 row inserted
SQL> insert into test1 values (2,'b');
1 row inserted
SQL> insert into test1 values (3,'c');
1 row inserted
SQL> commit;

SQL> exec dbms_stats.flush_database_monitoring_info;

SQL> select * from user_tab_modifications;

TABLE_NAME PARTITION_NAME SUBPARTITION_NAME INSERTS UPDATES DELETES TIMESTAMP TRUNCATED DROP_SEGMENTS
------------------------------ ------------------------------ ------------------------------ ---------- 
TEST1                                             3       0       0 7/29/2007         1   NO        0