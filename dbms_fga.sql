alternative for this is oracle audit - google "Oracle aud$"

!fga

simple example will help immensely to understand the concept of fine grained auditing quickly. Suppose you have a table called ACCOUNTS as follows:

 Name                                      Null?    Type
 ----------------------------------------- -------- -------------------
 ACCNO                                     NOT NULL NUMBER(5)
 ACCNAME                                            VARCHAR2(20)
 BAL                                                NUMBER(10,2)
The table has four rows:
     ACCNO ACCNAME                     BAL
---------- -------------------- ----------
         1 Alex                      10000
         2 Bill                      15000
         3 Charlie                   20000
         4 David                     25000
Here you want to record in the audit trail whenever someone selects from the table where the balance is 20000 or more. To do this, create an FGA policy on the table to record the trail. The FGA policy has the relevant information about the auditing, such as what condition should trigger the auditing, etc.

begin
  dbms_fga.add_policy (
    object_schema   => 'ACCMASTER',
    object_name     => 'ACCOUNTS',
    policy_name     => 'ACC_MAXBAL',
    audit_column    => 'BAL',
    audit_condition => 'BAL >= 20000'
    --handler_schema, handler_module ---> own pl/sql procedure 
    --audit_trial - debug level
 );
end;

All FGA related activities are performed by APIs defined in the package DBMS_FGA. To add a policy, call add_policy procedure.

Line 3 shows the name of the schema that owns the object; "ACCMASTER" in this case
Line 4 shows the name of the table, "ACCOUNTS"
Line 5 is the name of the policy "ACC_MAXBAL"
Line 6 is where the column that triggers auditing is specified. If the user selects any other column, then action will not be audited. If you want auditing turned on for any column, then leave this parameter out.
Line 7 specifies when the auditing should be triggered. In this case you have specified the condition as BAL more than or equal to 20,000. So, if the user selects the BAL column but the value is 10,000, then the action is not audited. If you want any access to the BAL column is audited, regardless of the value, then leave this parameter out or use NULL (in Oracle 10g) or place "'1=1'" in (Oracle 9i).
Once this is set up, when a user APPUSER issues:

select * from ACCMASTER.accounts;
it will trigger an auditing event which will be recorded in the table FGA_LOG$ in the SYS schema. You can examine it by selecting from the public DBA view on that: DBA_FGA_AUDIT_TRAIL.

select * from dba_fga_audit_trail
The output is shown below in vertical format to improve readability.
statements from trigger are audited as well.
rollbacks do not deletes records in dba_fga_audit_trail

SESSION_ID                    : 970
TIMESTAMP                     : 10-feb-2006 13:23:35
DB_USER                       : APPUSER
OS_USER                       : PRONYNT\stiger
USERHOST                      : PRONYNT\STSTIGERT42
CLIENT_ID                     :
ECONTEXT_ID                   :
EXT_NAME                      : PRONYNT\stiger
OBJECT_SCHEMA                 : ACCMASTER
OBJECT_NAME                   : ACCOUNTS
POLICY_NAME                   : ACC_MAXBAL
SCN                           : 1211944
SQL_TEXT                      : select * from ACCMASTER.accounts
SQL_BIND                      :
COMMENT$TEXT                  :
STATEMENT_TYPE                : SELECT
EXTENDED_TIMESTAMP            : 10-FEB-06 01.23.35.485000 PM -05:00
PROXY_SESSIONID               :
GLOBAL_UID                    :
INSTANCE_NUMBER               : 0
OS_PROCESS                    : 3064:304
TRANSACTIONID                 :
STATEMENTID                   : 6
ENTRYID                       : 1
This view and its columns are pretty much self explanatory. Some special columns:

SCN - Shows the system change number when the query was issued. This helps in reconstructing the query later to see what the user actually saw, using flashback query; not what's the value now. Later, you can execute this query:
 
SQL> select bal
  2  from accounts
  3  as of SCN 1211944
  4  where accno = 4
  5  /
       BAL
----------
     25000

SQL_TEXT - Shows the actual SQL text used by the user. It ties in closely with the next column SQL_BIND, which is described below.
 
In Oracle 10g, you can also specify other DML statements such as INSERT. In that case, just use the appropriate statement in a new parameter
 
statement_types   => 'SELECT,INSERT'
This enables FGA auditing for INSERT statements as well as SELECTs.