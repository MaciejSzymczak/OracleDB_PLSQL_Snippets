CREATE PUBLIC DATABASE LINK USOS 
CONNECT TO PLANER IDENTIFIED BY "password"
USING 'ip address';

Do you face the error on insert into like: ORA-22992: cannot use LOB locators selected from remote tables?
There is workaround on this: use merge syntax. will work for sure!