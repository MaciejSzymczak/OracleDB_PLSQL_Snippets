begin dbms_session.free_unused_user_memory; end;
begin dbms_session.reset_package; end; <-- clears session state

--!clearing shared pool
alter system flush shared pool;

spa - data buffer cache + shared pool + library cache + dictionary cache + java pool
pga - program global area


--------------------------------
W ramach kontekstu mo¿na przechowywaæ wartoœci zmiennych

kontekst trzeba utworzyc za pomoc¹ create context

ustawic zmienna w ramach kontekstu dbms_session.set_context('app_ctx',p_name,p_value,user,g_session_id); (dwa ostatnie parametry sa opcjonalne)

i odczytac kontekst za pomoca sys_context('app_ctx', 'var1')  

usunac za pomoca drop context ...

a tak mo¿na przejrzeæ istniej¹ce konteksty:

select * from dba_context

Kontekst mo¿e byc pomocny np. podczas generowania klauzyl where przez policy
   przy pierwszym wywolaniu budowany jest warunek where (kosztowne zadanie) i wstawiany do zmiennej w ramach kontekstu
   przy drugim wywolaniu warunek where jest pobierany z kontekstu (nie musimy wykonywac kosztownego zadania)     

 
uwaga:
=========
w PL/SQL zamiast kontekstu lepiej u¿yæ zmiennych pakietowych.
konteksty s¹ przydatne w SQL ( gdzie nie ma pakietów ) 
 
przyklad: 
         
CREATE OR REPLACE CONTEXT App_Ctx using My_pkg
ACCESSED GLOBALLY;

CREATE OR REPLACE PACKAGE my_pkg IS

PROCEDURE set_session_id(p_session_id NUMBER);
PROCEDURE set_ctx(p_name VARCHAR2, p_value VARCHAR2);
PROCEDURE close_session(p_session_id NUMBER);

END;
/

CREATE OR REPLACE PACKAGE BODY my_pkg IS

g_session_id NUMBER;

PROCEDURE set_session_id(p_session_id NUMBER) IS
BEGIN
  g_session_id := p_session_id;
  dbms_session.set_identifier(p_session_id);
end set_session_id;
--===============================================
PROCEDURE set_ctx(p_name VARCHAR2, p_value VARCHAR2) IS
BEGIN
  dbms_session.set_context('App_Ctx',p_name,p_value,USER,g_session_id);
END set_ctx;
--===============================================
PROCEDURE close_session(p_session_id NUMBER) IS
BEGIN
  dbms_session.set_identifier(p_session_id);
  dbms_session.clear_identifier;
END close_session;
--===============================================
END;
/

col var1 format a10
col var2 format a10

exec my_pkg.set_session_id(1234);
exec my_pkg.set_ctx('Var1', 'Val1');
exec my_pkg.set_ctx('Var2', 'Val2');

SELECT sys_context('app_ctx', 'var1') var1,
sys_context('app_ctx', 'var2') var2
FROM dual;

-- Now we'll log out/log in
-- At first, the context is empty-but we rejoin the session & there it is

disconnect
connect uwclass/uwclass

SELECT sys_context('app_ctx', 'var1') var1,
sys_context('app_ctx', 'var2') var2
FROM dual;

exec my_pkg.set_session_id(1234);

SELECT sys_context('app_ctx', 'var1') var1,
sys_context('app_ctx', 'var2') var2
FROM dual;

-- Now we'll show that this context is tied to our user (we specified
-- USER above, if we used null anyone can join this session).

grant execute on my_pkg to scott;

conn scott/tiger

exec uwclass.my_pkg.set_session_id(1234);

SELECT sys_context('app_ctx', 'var1') var1,
sys_context('app_ctx', 'var2') var2
FROM dual;

-- Return to the set context again and clear it

conn uwclass/uwclass

exec my_pkg.set_session_id(1234);

SELECT sys_context('app_ctx', 'var1') var1,
sys_context('app_ctx', 'var2') var2
FROM dual;

exec my_pkg.close_session(1234);

SELECT sys_context('app_ctx', 'var1') var1,
sys_context('app_ctx', 'var2') var2
FROM dual;

