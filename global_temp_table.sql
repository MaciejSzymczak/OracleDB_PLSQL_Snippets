--!table
 CREATE GLOBAL TEMPORARY TABLE XXEXT.XX_KIP_PER_MEASUREMENTS_TMP
 ( EFFECTIVE_START_DATE  DATE,
   EFFECTIVE_END_DATE    DATE,
   MEASUREMENT           VARCHAR2(150 BYTE),
   ASSIGNMENT_ID         NUMBER)
 ON COMMIT DELETE ROWS;

/*
mo¿e te¿ byæ: ... ON COMMIT PRESERVE ROWS;
nie wiem co to znaczy 
*/

 INSERT INTO xx_kip_per_measurements_tmp VALUES (SYSDATE, SYSDATE, '001', 1)
 INSERT INTO xx_kip_per_measurements_tmp VALUES (SYSDATE, SYSDATE, '001', 1)

 SELECT * FROM xx_kip_per_measurements_tmp
 
 --zwroci rekordy
 
 COMMIT

 SELECT * FROM xx_kip_per_measurements_tmp
 
 --zwroci zero wierszy
