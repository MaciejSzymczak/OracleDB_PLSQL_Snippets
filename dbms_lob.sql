--!clob

create or replace procedure NewClob  (clobloc       in out nocopy clob,
                        msg_string    in varchar2) is
     pos integer;
     amt number;
    begin
       dbms_lob.createtemporary(clobloc, TRUE, DBMS_LOB.session);
       if msg_string is not null then
          pos := 1;
          amt := length(msg_string);
          dbms_lob.write(clobloc,amt,pos,msg_string);
       end if;
    end NewClob;    
    
create or replace procedure WriteToClob  ( clob_loc      in out nocopy clob,msg_string    in  varchar2) is
     pos integer;
     amt number;
    begin    
       pos :=   dbms_lob.getlength(clob_loc) +1;
       amt := length(msg_string);
       dbms_lob.write(clob_loc,amt,pos,msg_string);    
    end WriteToClob;

set  echo on
set  long 32000
var  cb clob
declare
 c clob;
begin
  NewClob(c, '');
  WriteToClob(c, 'ala ma kota');
  :cb := c;
end;
/
print cb


dbms_lob.substr
dbms_lob.instr

to_clob('text')
