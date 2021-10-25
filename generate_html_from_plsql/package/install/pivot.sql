set termout off
set verify off
set trimspool on
set linesize 1000
set longchunksize 200000
set long 200000
set pages 0
column txt format a120
set colsep ,
set headsep off
set pagesize 0
set numwidth 5
set  echo off
var  cb clob
begin
  :cb := pivot.getPivot();
end;
/
SPOOL pivot.html
print cb
SPOOL OFF
exit


