DROP TYPE TABLE_OF_VARCHAR2_240;

CREATE OR REPLACE TYPE TABLE_OF_VARCHAR2_240 AS TABLE OF VARCHAR2(240)
                    
create or replace 
FUNCTION XXGENERATE_REPORT_ITEM RETURN clob AS 
    v_buff          clob; 
    p_column_name  varchar2(30);
    Cursor cols is
      SELECT * FROM TABLE(table_of_varchar2_240('Accompanied__c'
      ,'Activity_Weighting__c'
      ,'Appointment_or_Drop_In__c'
      --,'Call_Notes__c'
      ,'Coaching_AIM__c'
      ,'Coaching_topic_1__c'
      ,'Coaching_Topic_2__c'
      ,'Commercial_committed_partner'
      --,'Competitor_Intelligence__c'
      ,'Contact_Primary_Job_Title__c'
      ,'DSA_Checkin_Used__c'
      --,'Dunning_Outcome__c'
      ,'Event_Status__c'
      ,'Event_Type__c'
      ,'Expectations_T2B__c'
      --,'Follow_Up_Actions__c'
      ,'FR_POA_DX_AOFA__c'
      ,'FR_POA_DX_OASYS__c'
      ,'FR_POA3_2__c'
      ,'Manager_Comments__c'
      ,'Material_Apoyo__c'
      ,'Min_Target__c'
      ,'Objection__c'
      ,'Objection_Detail__c'
      ,'Objection_Other_Text__c'
      ,'Original_Assigned_To__c'
      ,'Outcome__c'
      ,'PAC_Name__c'
      ,'PAC_Objective__c'
      ,'PAC_Performance_Rating__c'
      ,'PAC_Support_objective__c'
      ,'PAC_VE_Intervention__c'
      ,'Packs_ordered__c'
      ,'Patient_1__c'
      ,'Planning_segmentation__c'
      ,'POA_1__c'
      ,'POA_1A__c'
      ,'POA_1Aa__c'
      ,'POA_B2B_a__c'
      ,'POA_B2B_b__c'
      ,'POA_B2B_d__c'
      ,'POA_Q1a__c'
      ,'POA_Q1b__c'
      ,'POA_Q1b_c__c'
      ,'POA_Q1c__c'
      ,'POA_Q1d__c'
      ,'POA_Q1g_c__c'
      ,'POA_Q2_Picklist__c'
      ,'POA_Q2a__c'
      ,'POA_Q2b__c'
      ,'POA_Q2c__c'
      ,'POA_Q2d__c'
      ,'POA_Q2e__c'
      ,'POA_Q3_3__c'
      ,'POA_Q3_a__c'
      ,'POA_Q3_b__c'
      ,'POA_Q3_c__c'
      ,'POA_Q3_j__c'
      ,'POA_Q3d__c'
      ,'POA_Q4a__c'
      ,'POA_Q4b__c'
      ,'POA_Q4c__c'
      ,'POA_Q4d__c'
      ,'POA_Q4e__c'
      ,'POA_Q4f__c'
      ,'POA_Q4g__c'
      ,'POA_Q4h__c'
      ,'POA_Q4h_c__c'
      ,'POA_Q4j__c'
      ,'Position_2__c'
      ,'Position_3__c'
      ,'Practice_1__c'
      ,'Product__c'
      ,'Product_clinical__c'
      ,'Products__c'
      ,'Professional_1__c'
      ,'Q4_POA_h__c'
      ,'Question__c'
      ,'Resolution__c'
      ,'Resultado_visita__c'
      ,'Sub_Type__c'
      ,'Text_2__c'
      ,'Ttl_Director__c'
      ,'Ttl_ECP__c'
      ,'Ttl_Feedback_Forms__c'
      ,'Ttl_People__c'
      ,'Ttl_StoreMgr__c'
      ,'Ttl_Support__c'
      ,'User_Country__c'))
      ORDER BY column_value;  
    ---------------------------------- 
    Procedure NewClob  (clobloc       in out nocopy clob, 
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
    ---------------------------------- 
    procedure WriteToClob  ( clob_loc      in out nocopy clob,msg_string    in  varchar2) is 
     pos integer; 
     amt number; 
    begin     
       pos :=   dbms_lob.getlength(clob_loc) +1; 
       amt := length(msg_string); 
       dbms_lob.write(clob_loc,amt,pos,msg_string);     
    end WriteToClob; 
    ---------------------------------- 
    procedure add (s varchar2) is begin 
      WriteToClob (v_buff, s || chr (10)); 
    end; 
    ----------------------------------
    
BEGIN
  newClob(v_buff, ''); 
    
  add('set arraysize 1'); 
  add('set heading off'); 
  add('set feedback off');   
  add('set verify off'); 
  add('SET CONCAT ON'); 
  add('SET CONCAT .');   
  add('set lines 80'); 
  add('set pages 9999'); 
  add('spool c:\sqlldr\SFDCActicitiesUtilization.html'); 
  
  add('prompt <HTML>'); 
  add('prompt <HEAD>'); 
  add('prompt <TITLE>SFDC Activity Custom Attributes Utilization </TITLE>');
  add('prompt <STYLE TYPE="text/css">'); 
  add('prompt <!-- TD {font-size: 8pt; font-family: arial; font-style: normal} -->');
  add('prompt </STYLE>'); 
  add('prompt </HEAD>'); 
  add('prompt <BODY>'); 
    
  add('prompt <BR>'); 
  add('prompt <TABLE BORDER=1>');
  add('prompt <TR><TD><B>Quick Links to Columns</B></TD><TD>Unique count task+event (ignore blanks and zeros)</TD><TD>Count task+event (ignore blanks and zeros)</TD><TD>Remarks</TD></TR>');
  for rec in cols
  loop
      add('prompt <TR>');
      add('prompt <TD><A HREF="#'||rec.column_value||'">'||rec.column_value);
      add('prompt </A></TD>');
      add('prompt <TD>');
      add('select eventcnt+taskcnt from (select count(distinct '||rec.column_value||') eventcnt from eventora_valid where '||rec.column_value||' is not null and '||rec.column_value||'<>''0'' and '||rec.column_value||'<>''0.0''),(select count(distinct '||rec.column_value||') taskcnt from taskora_valid where '||rec.column_value||' is not null and '||rec.column_value||'<>''0'' and '||rec.column_value||'<>''0.0'');');
      add('prompt </TD>');
      add('prompt <TD>');
      add('select eventcnt+taskcnt from (select count(*) eventcnt from eventora_valid where '||rec.column_value||' is not null and '||rec.column_value||'<>''0'' and '||rec.column_value||'<>''0.0''),(select count(*) taskcnt from taskora_valid where '||rec.column_value||' is not null and '||rec.column_value||'<>''0'' and '||rec.column_value||'<>''0.0'');');
      add('prompt </TD>');
      add('prompt <TD>');
      add('prompt Put comments here');
      add('prompt </TD>');
      add('prompt </TR>');
  end loop;    
  add('prompt </TABLE><P><P>');
  add('prompt <BR>');

  add('prompt <TABLE BORDER=1 style="Border: 0px dashed black">');
  add('prompt <TR>');
  add('prompt <TD>Task table');
  add('prompt </TD>');
  add('prompt <TD>Event table');
  add('prompt </TD>');
  add('prompt </TR>'); 
  
  add('REM ========================= MAIN ========================='); 
  
  for rec in cols
  loop
  
  p_column_name := rec.column_value;
  
  add('rem *** START '||p_column_name);
  add('prompt <TR>');
  add('prompt <TD>');
  add('prompt <TABLE BORDER=1 style="Border: 0px dashed black">');
  add('prompt <TR BGCOLOR=RED><TD COLSPAN=3 BGCOLOR=');
  add('select case when count(*)=1 then ''GREEN'' else ''RED'' end ');
  add('from');
  add('(');
  add('select distinct '||p_column_name);
  add('from taskora_valid');
  add('group by '||p_column_name);
  add(');');
  add('prompt><font color=white face=arial><B><A NAME="'||p_column_name||'">'||p_column_name||'</A></B></TD></TR>');
  add('prompt <TR><TD>Value</TD><TD>Count</TD><TD>%Total</TD></TR>');
  add('select ''<TR><TD>''||'||p_column_name||'||''</TD>''||chr(10)||');
  add('    ''<TD>''||count(*)||''</TD>''||chr(10)||');
  add('     ''<TD>''||round(count(*)*100/(select count(*) from taskora_valid))||''%''||''</TD></TR>''');
  add('from taskora_valid');
  add('group by '||p_column_name);
  add('order by count(*) desc;');
  add('prompt </TABLE>');
  add('prompt </TD>');
  -- the same for the 2nd table
  add('');
  add('prompt <TD>');
  add('prompt <TABLE BORDER=1 style="Border: 0px dashed black">');
  add('prompt <TR BGCOLOR=RED><TD COLSPAN=3 BGCOLOR=');
  add('select case when count(*)=1 then ''GREEN'' else ''RED'' end');
  add('from');
  add('(');
  add('select distinct '||p_column_name);
  add('from eventora_valid');
  add('group by '||p_column_name);
  add(');');
  add('prompt><font color=white face=arial><B>'||p_column_name||'</B></TD></TR>');
  add('prompt <TR><TD>Value</TD><TD>Count</TD><TD>%Total</TD></TR>');
  add('select ''<TR><TD>''||'||p_column_name||'||''</TD>''||chr(10)||');
  add('    ''<TD>''||count(*)||''</TD>''||chr(10)||');
  add('     ''<TD>''||round(count(*)*100/(select count(*) from eventora_valid))||''%''||''</TD></TR>''');
  add('from eventora_valid');
  add('group by '||p_column_name);
  add('order by count(*) desc;');
  add('prompt </TABLE>');
  add('prompt </TD>');
  add('prompt </TR>');
  add('rem *** END '||p_column_name);

  end loop;

  add('prompt <br>'); 
  add('prompt </BODY>'); 
  add('prompt </HTML>'); 
 
  add('undef book');
  add('undef asset');
  add('spool off');
  add('set heading on');
  add('set feedback on');
  add('set verify on');   

  return v_buff;  
END XXGENERATE_REPORT_ITEM;


select XXGENERATE_REPORT_ITEM from dual
