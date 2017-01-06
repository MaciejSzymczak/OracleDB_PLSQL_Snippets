--!audit
--œledzenie sesji
======================

w³¹czenie œledzenia:

begin
  sys.dbms_system.set_sql_trace_in_session(11,19415,TRUE );
  -- 11 - SID
  -- 19415 - serial#
  -- TRUE/FALSE - wlaczenie wylaczenie
  -- zostanie utworzony plik c:\oracle\admin\sf\udump\ora*.trc 
end;

trace off:
begin
  sys.dbms_system.set_sql_trace_in_session(11,19415,false);
end;



AUDIT SELECT ON employees;

AUDIT DELETE ANY TABLE BY userName WHENEVER NOT SUCCESSFUL;

AUDIT UPDATE ANY TABLE;

AUDIT SESSION BY UserName;

AUDIT SELECT,INSERT,UPDATE,DELETE
ON employees BY ACCESS WHENEVER SUCCESSFUL;



---


NOAUDIT SESSION;

NOAUDIT DELETE ANY TABLE BY userName WHENEVER NOT SUCCESSFUL;

NOAUDIT DELETE ANY TABLE BY userName;



