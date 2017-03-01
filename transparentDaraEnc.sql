setup
=======================

First, the DBA has to choose a location outside the database for the wallet. By default the location is $ORACLE_BASE/admin/$ORACLE_SID/wallet. This directory "wallet" may not have been created automatically during the installation, so you may need to create it.

Next, assign a password for the wallet. You can do that by:

alter system set encryption key authenticated by "tiger";
Note: You must enclose the password within double quotes as shown. Its also case sensitive.

This command does the following:

creates the wallet.
sets the password of the wallet as "tiger".
opens the wallet.
Unless the wallet is opened, it is not available for use by TDE and encryption and decryption will not work. The above steps are done only once.

Ongoing Activity
The wallet is closed when the database shuts down. When the database comes back up the DBA needs to open the wallet using:

alter system set encryption wallet open authenticated by "tiger";
or

alter system set encryption wallet open identified by "tiger";
The DBA can also close the wallet at any time using:

alter system set encryption wallet close;
When a wallet is not open, the encrypted columns are not accessible; but all un-encrypted columns are.




syntax
===============================

You can create a column as encrypted while creating the table. For instance, while creating the table CC, you can specify the column CC_NO as encrypted by AES 128-bit algorithm.

SQL>create table cc
  2  (
  3     acc_no  number(10),
  4     cc_no   varchar2(16) encrypt using 'AES128'
  5  );
If you describe this table, you will see:

SQL>desc cc
 Name                         Null?    Type
 ---------------------------- -------- -------------------------
 ACC_NO                                NUMBER(10)
 CC_NO                                 VARCHAR2(16) ENCRYPT
The column CC_NO is shown as encrypted, as expected.

You can add a column as encrypted:

alter table cc add (SOCIAL_SEC_NO varchar2(9) encrypt using 'AES128');

fine