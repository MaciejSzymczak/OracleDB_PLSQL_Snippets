--!row security level !vpd ( virtual private datbase )

select object_owner, object_name, policy_name, enable from DBA_POLICIES where object_name = 'PO_HEADERS_ALL'

--off policy
BEGIN dbms_rls.enable_policy('PO','PO_HEADERS_ALL','XX_PO_POLICY', false); END;

--on policy
BEGIN dbms_rls.enable_policy('PO','PO_HEADERS_ALL','XX_PO_POLICY', true); END;

===========================================================================================

adds where caluse on database level or hides values in selected columns
It works with delete/update. It DOES not work with TRUNCATE TABLE.

grant exempt access policy to ...

Suppose you have a table called ACCOUNTS as shown below:

SQL> desc accounts
 Name                                      Null?    Type
 ----------------------------------------- -------- -------------------
 ACCNO                                     NOT NULL NUMBER(5)
 ACCNAME                                            VARCHAR2(20)
 BAL                                                NUMBER(10,2)
The table has 4 rows:
     ACCNO ACCNAME                     BAL
---------- -------------------- ----------
         1 Alex                      10000
         2 Bill                      15000
         3 Charlie                   20000
         4 David                     25000
You would like to have a facility that restricts how much a user can see in the table. For instance a user, ANNA, should be allowed to see only those records where the BAL columns is less than 21,000. One way of accomplishing this is a view on the table, say VW_ACCOUNTS as:

create or replace view vw_accounts
as
select * from accounts
where bal < 21000
Then grant SELECT on this view, not on the table to ANNA. When ANNA selects from this view, she will see only 3 records where the BAL column is less than 21,000. There are issues with this approach. For instance, what if you add a column to the table? You would have to remember to add that to the view too. The management of privileges will be complicated. This is where you can establish row level security to automatically restrict the rows.

The feature works on the principle of a "policy". It will act as a sort of a sieve through which records from tables are allowed or not allowed to pass based on the conditions that you define. The condition is enforced by a WHERE condition, known as a "predicate". In this example the predicate is "BAL < 21000". As a first step in the establishment of RLS, you will have to develop a function that creates and returns a string with the predicate.

  1  create or replace function max_acc_bal
  2  (
  3     p_schema        in varchar2,
  4     p_obj           in varchar2
  5  )
  6  return varchar2
  7  as
  8     l_ret   varchar2(2000);
  9  begin
 10     if p_schema = USER then
 11             l_ret := null;
 12     else
 13             l_ret := 'BAL < 21000';
 14     end if;
 15     return l_ret;
 16 end;
This function must follow a specific pattern.

It should have exactly two parameters.
The first one should be the schema owner of the table.
The other one is the table on which the RLS policy is placed.
It should return a varchar2 value.
The return value should be a valid WHERE condition, without the WHERE keyword.
Next, you will define a policy on the table using the supplied PL/SQL package DBMS_RLS.

  1  begin
  2     dbms_rls.add_policy (
  3            object_name          => 'ACCOUNTS',
  4            policy_name          => 'ACC_MAXBAL_POL',
  5            policy_function      => 'MAX_ACC_BAL',
  6            statement_types      => 'INSERT, UPDATE, DELETE, SELECT'
  7            );
  8  end;
In line 4, you have provided the name of the policy that will be created on the table. Note, here you have given the name of the table (ACCOUNTS) and the policy function that will create the predicate. In line 6, you have provided the statements this policy will be applied to, i.e. insert/update/delete/select. That means if any of these statements will be issued against the table BALANCE, the VPD (Virtual Private Database - another name for Row Level Security) policy will be applied.

After this is executed, the policy on the table will be active. When a user called APPUSER selects from the table, he gets:

APPUSER@prolin1>select * from ACCMAN.accounts;
     ACCNO ACCNAME                     BAL
---------- -------------------- ----------
         1 Alex                      10000
         2 Bill                      15000
         3 Charlie                   20000
Only 3 rows were selected. If ACCMAN issues the same statement, he gets four rows. The predicate NULL was applied, as coded in the policy function.

APPUSER@prolin1>select * from ACCMAN.accounts;
     ACCNO ACCNAME                     BAL
---------- -------------------- ----------
         1 Alex                      10000
         2 Bill                      15000
         3 Charlie                   20000
         4 David                     25000
If APPUSER updates the table, or deletes some rows from it, only 3 rows will be affected.

SQL> update ACCMAN.accounts set accname = 'A';
3 rows updated.
SQL> delete ACCMAN.accounts;
3 rows deleted.
In all cases, only 3 rows are affected. It is as if there are only 3 rows in this table. Considering another analogy where its as if the user APPUSER has a private virtual copy of the table ACCOUNTS that has only 3 rows. When a user issues a statement against the table, VPD functionality intercepts it and adds the additional WHERE clause to it, automatically. There is no way for the user to bypass that additional predicate.

In line 10 of the policy function you have used a return string as NULL, which effectively means no restrictions are applied to the rows. Alternatively you can use any string that evaluates to TRUE, e.g. "1=1". If you use a string that always evaluates to FALSE, e.g. "1=2", then all rows will be blocked.













management
=====================

You can drop policies on tables using the procedure drop_policy as shown below:

begin
   dbms_rls.drop_policy (
       object_name          => 'ACCOUNTS',
       policy_name          => 'ACC_MAXBAL_POL'
   );
end;
Sometimes it makes sense to disable the application of the policy predicates. An example of this is when you are doing a Direct Path operation. You can do that by calling a procedure enable_policy:

begin
   dbms_rls.enable_policy (
      object_schema => 'ACCMAN',
      object_name   => 'ACCOUNTS',
      policy_name   => 'ACC_MAXBAL_POL',
      enable        => TRUE
   );
end;
Using the same procedure, but a different parameter,

enable => false
it will disable the policy. Disabling the policy is better than dropping it since the structure of the policy such as the table, owner, policy name, etc. are preserved for future analysis.

When you create a policy for the first time, it may be wise to create it initially disabled. Later, during a convenient time, you will enable it. To create the policy but in disabled state, you can use this parameter in add_policy procedure.

enable => false
Later you can use the enable_policy procedure to enable that procedure.

The policies are all visible in the data dictionary view DBA_POLICIES. Here is a brief description of the view:

Column Name
Description
OBJECT_OWNER
Owner of the table on which the policy is defined.
OBJECT_NAME
Name of the table on which the policy is defined.
POLICY_GROUP
If this is part of a group, the name of the policy group.
POLICY_NAME
Name of the policy.
PF_OWNER
Owner of the policy function, which creates and returns the predicate.
PACKAGE
If the policy function is a packaged one, this is the name of the package.
FUNCTION
Name of the policy function.
SEL
Indicates that this is a policy for SELECT statements on this table.
INS
Indicates that this is a policy for INSERT statements on this table.
UPD
Indicates that this is a policy for UPDATE statements on this table.
DEL
Indicates that this is a policy for DELETE statements on this table.
IDX
Indicates that this is a policy for CREATE INDEX statements on this table. (Oracle 10g only)
CHK_OPTION
Indicates whether the update check option was enabled when the policy was created.
ENABLE
Indicates whether the policy is enabled.
STATIC_POLICY
Indicates whether this is a static policy.
POLICY_TYPE
Dynamism of the policy (e.g., STATIC). (Oracle 10g only)
LONG_PREDICATE
Indicates whether this policy function returns a predicate longer than 4000 bytes. (Oracle 10g only)
Usage Notes

Always test the output of the policy function before adding to the policy. For instance, in the above case, you will issue as the user ACCMAN (the owner of the table):


 select max_acc_bal('ACCMAN','ACCOUNTS') from dual;
MAX_ACC_BAL('ACCMAN','ACCOUNTS')
------------------------------
*
Null is shown as "*". If you replace ACCMAN by any other value, the policy predicate should be returned.

SQL> select max_acc_bal('X','ACCOUNTS') from dual;
MAX_ACC_BAL('X','ACCOUNTS')
---------------------------
BAL < 21000
This confirms that the policy function is generating accurate policy predicates. If you see a different policy predicate; or a syntactically wrong one, you have a chance to fix it now.

Identify how you will apply the policies to child tables. If needed, add columns to the child tables that the policies predicate will work on.
 
Identify how the policy predicates apply to the parent tables. For instance if you are applying the policy to the table EMP based on the column SALARY, how can you apply the policy to the table DEPT when it does not have a SALARY column? Identify how you want to proceed in this case. Do you want to have the users unrestricted access to DEPT or restrict by a predicate as:

deptno in (select deptno from emp)

Always create policies initially disabled by setting enable => false in the add_policy procedure. Enable it later when you can watch it very carefully. It saves you from making a mistake while running the add_policy procedure and holding up something else in the production database.
 

Always check for rewritten queries when a VPD policy is set on a table. This can be done by setting the event as shown above. This allows you to catch the syntax and logical errors in the queries and catch them before they become real issues.
 
Create additional indexes when needed. The input for additional indexes comes from the query rewrite where you can identify how the columns are accessed.


sprawdzenie jakie policy s¹ w bazie danych
===============================================

SELECT * FROM all_policies




























policy mo¿na u¿yæ nie tylko w stosunku do polecenie SELECT, ale tak¿e do sterowania poleceniami INSERT, UPDATE, DELETE.
¯eby policy zadzia³a³o dla poleceñ insert i update parametr update_check musi byæ ustawiony na true.
Wyjaœnienie i przyk³ady (mam nadziejê, ¿e czytelne) poni¿ej.

create table xxext.XXRLS_TEST ( n number, c varchar2(100), d date );

create synonym xxrls_test for xxext.xxrls_test;

CREATE OR REPLACE PACKAGE XXRLS_TEST_PKG
IS
  FUNCTION build_predicate_i (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2;
  FUNCTION build_predicate_u (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2;
  FUNCTION build_predicate_d (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2;
  FUNCTION build_predicate_s (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY XXRLS_TEST_PKG
AS
 debugEnabled boolean := to_char(sysdate,'yyyy') in ('2008','2009') or fnd_profile.value('XXDEBUGENABLED')='Y';
 debugLevel number  := nvl( fnd_profile.value('XXDEBUGLEVEL') , 5);
               -- 1 = standard
               -- ..
               -- 5 = detailed
  
  -- how to access debug: select * from xxmsztools_eventlog here module_name ='XXRLS_TEST_PKG' order by id desc
  procedure debug ( message varchar2, pdebugLevel number default 1) is
  begin
   if pdebugLevel <= debugLevel then
     if debugEnabled then
       xxmsz_tools.insertintoeventlog(message,'I','XXRLS_TEST_PKG');
     end if;
   end if;
  end;

  FUNCTION build_predicate_i (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2 is 
  begin
   debug('i');
   return 'n in (1,2,3,4,5)';
  end;
  
  FUNCTION build_predicate_u (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2 is
  begin
    debug('u');
    return 'n in (2,3,4)';
  end;
  
  FUNCTION build_predicate_d (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2 is
  begin
   debug('d');
   return 'n in (6)';
  end;
  
  FUNCTION build_predicate_s (obj_schema VARCHAR2, obj_name VARCHAR2) RETURN VARCHAR2 is
  begin
   debug('s');
   return 'n in (1,2,3,4,6)';
  end;  

END;
/

begin
dbms_rls.add_policy (
    object_schema   		=> 'XXEXT',
    object_name     		=> 'XXRLS_TEST',
    policy_name      	    => 'XXRLS_TEST_I',
    function_schema 		=> 'APPS',
    policy_function  	    => 'XXRLS_TEST_PKG.BUILD_PREDICATE_I',
    statement_types  	    => 'INSERT',
    update_check     	    => true -- <--- !
 );
dbms_rls.add_policy (
    object_schema   		=> 'XXEXT',
    object_name     		=> 'XXRLS_TEST',
    policy_name      	    => 'XXRLS_TEST_U',
    function_schema 		=> 'APPS',
    policy_function  	    => 'XXRLS_TEST_PKG.BUILD_PREDICATE_U',
    statement_types  	    => 'UPDATE',
    update_check     	    => true -- <--- !
 );
dbms_rls.add_policy (
    object_schema   		=> 'XXEXT',
    object_name     		=> 'XXRLS_TEST',
    policy_name      	    => 'XXRLS_TEST_D',
    function_schema 		=> 'APPS',
    policy_function  	    => 'XXRLS_TEST_PKG.BUILD_PREDICATE_D',
    statement_types  	    => 'DELETE',
    update_check     	    => false
 );
dbms_rls.add_policy (
    object_schema   		=> 'XXEXT',
    object_name     		=> 'XXRLS_TEST',
    policy_name      	    => 'XXRLS_TEST_S',
    function_schema 		=> 'APPS',
    policy_function  	    => 'XXRLS_TEST_PKG.BUILD_PREDICATE_S',
    statement_types  	    => 'SELECT',
    update_check     	    => false
 );
end;

/*
object_name
  Name of table or view to which the policy is added.  
policy_name
  Name of policy to be added. It must be unique for the same table or view.  
function_schema
  Schema of the policy function (logon user, if NULL).  
policy_function
  Name of a function which generates a predicate for the policy. If the function is defined within a package, then the name of the package must be present.  
statement_types
  Statement types that the policy will apply. It can be any combination of SELECT, INSERT, UPDATE, and DELETE. The default is to apply to all of these types.  
update_check
  Optional argument for INSERT or UPDATE statement types. The default is FALSE. Setting update_check to TRUE causes the server to also check the policy against the value after insert or update.  
enable
  Indicates if the policy is enabled when it is added. The default is TRUE  
*/ 


-- sprz¹tanie
begin
execute immediate 'truncate table xxext.XXRLS_TEST';
delete from xxmsztools_eventlog where module_name = 'XXRLS_TEST_PKG';
commit;
end;

insert into XXRLS_TEST (n) values ( 1 );

insert into XXRLS_TEST (n) values ( 2 );

insert into XXRLS_TEST (n) values ( 6 );
-- ORA-28115: za³o¿enie systemowe z naruszeniwm opcji sprawdzania
-- Uwagi:
--   gdyby parametr update_check by³ ustawiony na false ( wartoœæ domyœlna ) to polecenie insert powiod³oby siê

insert into XXRLS_TEST (n) values ( 100 );
-- ORA-28115: za³o¿enie systemowe z naruszeniwm opcji sprawdzania

select * from XXRLS_TEST
--N	C	D
--1		
--2		
-- Uwagi:		
--  Rekord 6 i 100 nie zosta³ dodany, bo policy build_predicate_i [n in (1,2,3,4,5)] nie pozwala na to

update XXRLS_TEST set c = 'xxx', n = 101
-- ORA-28115: za³o¿enie systemowe z naruszeniwm opcji sprawdzania
-- Uwagi: mo¿emy zmieniæ n tylko w zakresie okreœlonym przez policy build_predicate_u [n in (2,3,4)] 
--        gdyby parametr update_check by³ ustawiony na false ( wartoœæ domyœlna ) to polecenie insert powiod³oby siê, n zosta³oby zmienione, ale tylko dla rokordów where n in (2,3,4)

update XXRLS_TEST set c = 'xxx'
-- ORA-28115: za³o¿enie systemowe z naruszeniwm opcji sprawdzania
-- Uwagi: mo¿emy zmieniæ n tylko w zakresie okreœlonym przez policy build_predicate_u [n in (2,3,4)] 

select * from XXRLS_TEST
--N	C	D
--1		
--2	xxx	
--Uwagi:
--  Tylko rekord 2 zosta³ zaktualizowany - policy build_predicate_u [n in (2,3,4)]

delete from  XXRLS_TEST

select * from XXRLS_TEST
--N	C	D
--1		
--2	xxx	
--Uwagi:
-- ¯aden rekord nie zosta³ usuniêty - policy build_predicate_d [n in (6)]

--
porz¹dki

begin
dbms_rls.drop_policy('XXEXT','XXRLS_TEST','XXRLS_TEST_I');
dbms_rls.drop_policy('XXEXT','XXRLS_TEST','XXRLS_TEST_U');
dbms_rls.drop_policy('XXEXT','XXRLS_TEST','XXRLS_TEST_D');
dbms_rls.drop_policy('XXEXT','XXRLS_TEST','XXRLS_TEST_S');
end;

drop package XXRLS_TEST_PKG; 

drop table xxext.XXRLS_TEST;

drop synonym xxrls_test;
