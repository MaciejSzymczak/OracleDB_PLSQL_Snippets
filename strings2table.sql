DROP TYPE TABLE_OF_VARCHAR2_240;

CREATE OR REPLACE TYPE TABLE_OF_VARCHAR2_240 AS TABLE OF VARCHAR2(240)
                    
SELECT  * FROM TABLE(table_of_varchar2_240('CC','A','B','C','∆','D','E','F','G','H','I','J','K','L','£','M','N','—','O','P','Q','R','S','å','T','U','W','X','Y','Z','Ø','è') )
ORDER BY column_value

