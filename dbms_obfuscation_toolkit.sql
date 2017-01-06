create or replace function ENCRYPT_PASSWORD(PASSWORD VARCHAR2) return varchar2 is
   input_string        VARCHAR2(100);
   key_string          VARCHAR2(24);
   encrypted_string            VARCHAR2(2048);
   res varchar2(1000);
BEGIN 
   INPUT_STRING := SUBSTR(PASSWORD || '                                                     ',1,30);
   KEY_STRING := SUBSTR(PASSWORD || '                        ',1,24);
res := '';
      dbms_obfuscation_toolkit.DES3Encrypt(
               input_string => input_string, 
               key_string => key_string, 
               encrypted_string => encrypted_string,
               which => 1);
      res := rawtohex(UTL_RAW.CAST_TO_RAW(encrypted_string));
 return res;
END;
/


create or replace function encrypt_and_decrypt return varchar2 is
   input_string        VARCHAR2(16) := 'tigertigertigert';
   key_string          VARCHAR2(16)  := 'scottscottscotts';
   encrypted_string            VARCHAR2(2048);
   decrypted_string            VARCHAR2(2048); 
   res varchar2(1000);
BEGIN 
res := '';
      dbms_obfuscation_toolkit.DES3Encrypt(
               input_string => input_string, 
               key_string => key_string, 
               encrypted_string => encrypted_string );
      res := rawtohex(UTL_RAW.CAST_TO_RAW(encrypted_string));
      dbms_obfuscation_toolkit.DES3Decrypt(
               input_string => encrypted_string, 
               key_string => key_string, 
               decrypted_string => decrypted_string );
      res := res || decrypted_string;
      if input_string = decrypted_string THEN
         res := res || ' String DES3 Encyption and Decryption successful';
      END if;
 return res;
END;
/
