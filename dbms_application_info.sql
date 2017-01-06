begin 
  dbms_application_info.set_module('<MODULE>', '<ACTION>'); 
  dbms_application_info.set_client_info('<CLIENT_INFO>');
  --dbms_application_info.READ_CLIENT_INFO
  --dbms_application_info.READ_module
end;  

select machine, module, action, client_info from v$session where module = '<MODULE>'

FINE EXAMPLE (from http://psoug.org/reference/dbms_applic_info.html)
======================

CREATE TABLE test (
testcol NUMBER(10));

-- session 1
DECLARE
 mod_name VARCHAR2(48);
 act_name VARCHAR2(32); 
BEGIN
  mod_name := 'read mod';
  act_name := 'inserting';
  dbms_application_info.set_module(mod_name, act_name);

  FOR x IN 1..5
  LOOP
    FOR i IN 1 ..60
    LOOP
      INSERT INTO test VALUES (i);
      COMMIT;
      dbms_lock.sleep(1);
    END LOOP;

    act_name := 'deleting';
    dbms_application_info.set_action(act_name);
    FOR i IN 1 ..60
    LOOP
      DELETE FROM test WHERE testcol = i;
      COMMIT;
      dbms_lock.sleep(1);
    END LOOP;
  END LOOP;
END;
/

-- session 2
col module format a20
col action format a20

SELECT module, action
FROM gv$session;

SELECT module, action
FROM gv$sqlarea;

SELECT sql_text, disk_reads, module, action 
FROM gv$sqlarea
WHERE action = 'deleting';