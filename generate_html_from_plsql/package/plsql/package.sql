  CREATE GLOBAL TEMPORARY TABLE HELPER_PIVOT 
   (	 
	DAY DATE 
	,NO_DSP VARCHAR2(100) 
	,NO NUMBER
	,LEC VARCHAR2(2000)
	,RES VARCHAR2(2000)
   ) ON COMMIT DELETE ROWS ;
   
   
create or replace package  pivot is  
    function getPivot (pDay Date := Sysdate) return clob;  
end;
/

create or replace package body pivot is  
     res clob;  
     
    ------------------------------------------------------------------------------------------------------------------------------------------------------- 
    function getPivot (pDay Date := Sysdate) return clob is 

            --------------------------------------------------------------  
            procedure NewClob  (clobloc       in out nocopy clob,  
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

            --------------------------------------------------------------  
            procedure WriteToClob  ( clob_loc      in out nocopy clob,msg_string    in  varchar2) is  
             pos integer;  
             amt number;  
            begin  
               pos :=   dbms_lob.getlength(clob_loc) +1;  
               amt := length(msg_string);  
               dbms_lob.write(clob_loc,amt,pos,msg_string);  
            end WriteToClob;  

    --------------------------------------------------------------   
    begin
      delete from HELPER_PIVOT;
      insert into HELPER_PIVOT (DAY, NO_DSP, NO, LEC, RES) 
            SELECT DAY
                , GRIDS.CAPTION 
                , GRIDS.NO 
                , trim(lecturers.full_name) LEC
                , trim(resources.res_name) RES
            FROM CLASSES
            ,GRIDS
            ,(select trim(';'  from max(v1)||';'||max(v2)||';'||max(v3)||';'||max(v4)||';'||max(v5)||';'||max(v6)||';'||max(v7)||';'||max(v8)||';'||max(v9)||';'||max(v10)) full_name
                 , cla_id Id
            from
            (
            select case when (row_number() over (partition by cla_id  order by lec_id))=1 then title ||' '||first_name||' '||last_name else null end v1
                 , case when (row_number() over (partition by cla_id  order by lec_id))=2 then title ||' '||first_name||' '||last_name else null end v2
                 , case when (row_number() over (partition by cla_id  order by lec_id))=3 then title ||' '||first_name||' '||last_name else null end v3
                 , case when (row_number() over (partition by cla_id  order by lec_id))=4 then title ||' '||first_name||' '||last_name else null end v4
                 , case when (row_number() over (partition by cla_id  order by lec_id))=5 then title ||' '||first_name||' '||last_name else null end v5
                 , case when (row_number() over (partition by cla_id  order by lec_id))=6 then title ||' '||first_name||' '||last_name else null end v6
                 , case when (row_number() over (partition by cla_id  order by lec_id))=7 then title ||' '||first_name||' '||last_name else null end v7
                 , case when (row_number() over (partition by cla_id  order by lec_id))=8 then title ||' '||first_name||' '||last_name else null end v8
                 , case when (row_number() over (partition by cla_id  order by lec_id))=9 then title ||' '||first_name||' '||last_name else null end v9
                 , case when (row_number() over (partition by cla_id  order by lec_id))=10 then title ||' '||first_name||' '||last_name else null end v10
                 , cla_id 
              from lec_cla
                  , lecturers 
              where lec_cla.lec_id = lecturers.id
               and lecturers.id >0
            )
            group by cla_id
            ) lecturers 
            ,(select cla_id Id
                 , gou.name  orguni
                 , g.attribs_01||' '||g.name res_name
             from rooms   g
                , rom_cla  c
                , org_units  gou
            where g.id = c.rom_id
              and g.orguni_id = gou.id(+)
              and g.id >0
            ) resources 
            WHERE lecturers.id = classes.id
             and resources.id = classes.id
             and CLASSES.HOUR = GRIDS.NO
             and day = pDay
             ;     
         
         
        NewClob(res, '');   
        WriteToClob(res,     
'<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title></title>
  <link href="pivot.css" rel="stylesheet">
</head>
  <body>
  <table>
');    
         
         WriteToClob(res, '<tr>');
         WriteToClob(res, '<th>Sala</th>');
         for cols in (select unique no, no_dsp from HELPER_PIVOT order by no) loop
         WriteToClob(res, '<th>'|| cols.no_dsp  ||'</th>');
         end loop;
         WriteToClob(res, '</tr>'||chr(13)||chr(10));
         
         
        for rows in (select unique res from HELPER_PIVOT order by res) loop
            WriteToClob(res, '<tr>');
            WriteToClob(res, '<td>'|| rows.res  ||'</td>');
            for cols in (select unique no, no_dsp from HELPER_PIVOT order by no) loop
              declare
               plec varchar2(2000) := '';
              begin
                  for lec in (select lec from HELPER_PIVOT where res = rows.res and no = cols.no) loop
                      plec := lec.lec;
                  end loop;
                  WriteToClob(res, '<td>'|| plec  ||'</td>');
              end;
            end loop;
            WriteToClob(res, '</tr>'||chr(13)||chr(10));
        end loop;

WriteToClob(res,'
  </table>
  </body>
</html>');  

       return res;  
      
   end getPivot;
  
end;
/
