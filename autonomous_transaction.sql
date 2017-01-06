--!autonomous_transaction

w triggerach nie mozna stosowac commit. 
czasem nie mozna uniknac wywolania commit (np. wywolanie procedur innych programistow)
wowczas nalezy uzyc odpowiedniej prgamy - ponizej.
---------------------------------------------------------------------------------------

wewn¹trz cia³a pakietu
.
.
.

PROCEDURE    NOWA_SEKWENCJA(P_SEKWENCJA VARCHAR2)    IS
pragma autonomous_transaction; <-- odpowiednia pragma
           L_NAZWA VARCHAR2(50) := 'CREATE SEQUENCE '||P_SEKWENCJA;
        BEGIN
        blady := null;
        EXECUTE   IMMEDIATE    L_NAZWA ;
        commit;  -- <--- musi byc commit
                 -- jesli nie zostanie wywo³any commit, to w specyficznych przypadkach mo¿e pojawiæ siê b³¹d: 
                 --           ORA-06519: wykryto i wycofano aktywn¹ autonomiczn¹ transakcjê
         exception
              when others then
          blady := 'AMOKLIB.LINIA.Aktywne - b³¹d w wywo³aniu procedury';
        END;

.
.
.

przyk³ad 2

CREATE OR REPLACE TRIGGER xxint.xxfisais_I2
   before UPDATE
   ON xxfisais_iface_invoices
   REFERENCING OLD AS OLD NEW AS NEW
   FOR EACH ROW
BEGIN
 DECLARE
  aAction varchar2(32);
  procedure ev (m varchar2) is
  pragma autonomous_transaction;
  begin
    insert into xxfisais_eventlog (message) values (m);
    commit;
  end;
 BEGIN
   select nvl(action,'-') into aAction from v$session where audsid =  userenv('sessionid');
   if aAction <> 'DISABLE TRIGGERS' then
    :new.import_status := 'R';
   end if;
 END;
END;
/
