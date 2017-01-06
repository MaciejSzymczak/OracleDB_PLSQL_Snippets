-- session -< transaction -< step
select userenv('sessionid'), dbms_transaction.local_transaction_id, to_char(dbms_transaction.step_id)  from dual
--nulls? execute any DML statement before 

-------------------------------------------------

drop table xx

create table xx ( i number )

begin 
 dbms_transaction.read_only;
end;

insert into xx values ( 1)
--ORA-01456: may not perform insert/delete/update operation inside a READ ONLY transaction

commit

insert into xx values ( 1)

ok
