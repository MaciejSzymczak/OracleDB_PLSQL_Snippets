*******************************************************************

Example 8: Describe Columns
This can be used as a substitute to the SQL*Plus DESCRIBE call by using a SELECT
* query on the table that you want to describe.

declare
  c number;
  d number;
  col_cnt integer;
  f boolean;
  rec_tab dbms_sql.desc_tab;
  col_num number;

  procedure print_rec(rec in dbms_sql.desc_rec) is
  begin
    dbms_output.new_line;
    dbms_output.put_line('col_type = '|| rec.col_type);
    dbms_output.put_line('col_maxlen = '|| rec.col_max_len);
    dbms_output.put_line('col_name = '|| rec.col_name);
    dbms_output.put_line('col_name_len = '|| rec.col_name_len);
    dbms_output.put_line('col_schema_name = '|| rec.col_schema_name);
    dbms_output.put_line('col_schema_name_len = '|| rec.col_schema_name_len);
    dbms_output.put_line('col_precision = '|| rec.col_precision);
    dbms_output.put_line('col_scale = '|| rec.col_scale);
    dbms_output.put('col_null_ok = ');
    if (rec.col_null_ok) then
      dbms_output.put_line('true');
    else
      dbms_output.put_line('false');
    end if;
  end;

begin
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, 'select * from scott.bonus', dbms_sql);
  d := dbms_sql.execute(c);
  dbms_sql.describe_columns(c, col_cnt, rec_tab);
  /*
  * Following loop could simply be for j in 1..col_cnt loop.
  * Here we are simply illustrating some of the PL/SQL table
  * features.
  */
  col_num := rec_tab.first;
  if (col_num is not null) then
  loop
    print_rec(rec_tab(col_num));
    col_num := rec_tab.next(col_num);
    exit when (col_num is null);
  end loop;
  end if;
  dbms_sql.close_cursor(c);
end;
/


*******************************************************************
EXECUTE IMMEDIATE  with clob parameter : 

declare
   v_clobe_proc clob;
   v_table      dbms_sql.varchar2s;
   v_c          number;
   v_rc         number;
  ------------------------------------------------------------------------------------
  procedure clob_to_table (p_clob in clob, p_table in out nocopy dbms_sql.varchar2s) is
    c_length       constant number := 200; --not 256 : polish chars can be stored on 2 bytes
    v_licznik      binary_integer;
    v_rozmiar      number;
  begin
    v_rozmiar := dbms_lob.getlength(p_clob);
    v_licznik := ceil(v_rozmiar / c_length);
    if v_licznik > 0 then
      p_table.delete;
      for i in 1..v_licznik loop
        if i != v_licznik then
          p_table(i) := dbms_lob.substr(p_clob, c_length, (i - 1) * c_length + 1);
        else
          p_table(i) := dbms_lob.substr(p_clob, v_rozmiar - (i - 1) * c_length, (i - 1) * c_length + 1);
        end if;
      end loop;
    end if;
  end;
  ------------------------------------------------------------------------------------
  procedure writeappend (p_clob in out nocopy clob, p_text varchar2) is
   v_text varchar2(32000);
  begin
   v_text := p_text || chr(10);
   dbms_lob.writeappend(p_clob, length(v_text), v_text);
  end;
  ------------------------------------------------------------------------------------
begin
    dbms_lob.createtemporary(v_clobe_proc, true, dbms_lob.session);
    dbms_lob.open(v_clobe_proc, dbms_lob.lob_readwrite);
    writeappend(v_clobe_proc, 'create or replace procedure xxxtest is begin null; end;');
    --...    
    clob_to_table(v_clobe_proc, v_table);
    v_c := dbms_sql.open_cursor;
    dbms_sql.parse(v_c, v_table, v_table.first, v_table.last, false, 1);
    v_rc := dbms_sql.execute(v_c);
    dbms_sql.close_cursor(v_c);
    dbms_lob.close(v_clobe_proc);
    dbms_lob.freetemporary(v_clobe_proc);
end;
  
  
*******************************************************************
Dynamic update (updates only when required) - useful during producing webservices 

type tcolumn_names   is table of varchar2(30) index by binary_integer; 
type tcolumn_values  is table of sys.anydata index by binary_integer;         

Sample use
create table XXTEST3 (id number, d date, c varchar2(100), n number);
insert into xxtest3 (id, d, c, n) values (1,sysdate, '£¥KA', 1);

BEGIN
 SWD2_UTIL.UPDATE_TABLE ('XXTEST3'
          ,'ID=1'
          ,'d', anyData.convertDate    (date'2011-12-12')
          ,'n', anyData.convertNumber  (null)
          ,'c', anyData.convertVarchar2('ALA') 
           );
END;

select * from xxtest3

-- on errors use this sql to see detail
select * from swd2_log_messages order by id desc

  PROCEDURE UPDATE_TABLE (
      p_table_name    varchar2
     ,p_pk            varchar2
    ,p_column_name1  VARCHAR2             , p_column_value1 sys.anydata
   ,p_column_name2  VARCHAR2 DEFAULT NULL, p_column_value2 sys.anydata DEFAULT NULL
   ,p_column_name3  VARCHAR2 DEFAULT NULL, p_column_value3 sys.anydata DEFAULT NULL
   ,p_column_name4  VARCHAR2 DEFAULT NULL, p_column_value4 sys.anydata DEFAULT NULL
   ,p_column_name5  VARCHAR2 DEFAULT NULL, p_column_value5 sys.anydata DEFAULT NULL
   ,p_column_name6  VARCHAR2 DEFAULT NULL, p_column_value6 sys.anydata DEFAULT NULL
   ,p_column_name7  VARCHAR2 DEFAULT NULL, p_column_value7 sys.anydata DEFAULT NULL
   ,p_column_name8  VARCHAR2 DEFAULT NULL, p_column_value8 sys.anydata DEFAULT NULL
   ,p_column_name9  VARCHAR2 DEFAULT NULL, p_column_value9 sys.anydata DEFAULT NULL
   ,p_column_name10  VARCHAR2 DEFAULT NULL, p_column_value10 sys.anydata DEFAULT NULL
   ,p_column_name11  VARCHAR2 DEFAULT NULL, p_column_value11 sys.anydata DEFAULT NULL
   ,p_column_name12  VARCHAR2 DEFAULT NULL, p_column_value12 sys.anydata DEFAULT NULL
   ,p_column_name13  VARCHAR2 DEFAULT NULL, p_column_value13 sys.anydata DEFAULT NULL
   ,p_column_name14  VARCHAR2 DEFAULT NULL, p_column_value14 sys.anydata DEFAULT NULL
   ,p_column_name15  VARCHAR2 DEFAULT NULL, p_column_value15 sys.anydata DEFAULT NULL
   ,p_column_name16  VARCHAR2 DEFAULT NULL, p_column_value16 sys.anydata DEFAULT NULL
   ,p_column_name17  VARCHAR2 DEFAULT NULL, p_column_value17 sys.anydata DEFAULT NULL
   ,p_column_name18  VARCHAR2 DEFAULT NULL, p_column_value18 sys.anydata DEFAULT NULL
   ,p_column_name19  VARCHAR2 DEFAULT NULL, p_column_value19 sys.anydata DEFAULT NULL
   ,p_column_name20  VARCHAR2 DEFAULT NULL, p_column_value20 sys.anydata DEFAULT NULL
   ,p_column_name21  VARCHAR2 DEFAULT NULL, p_column_value21 sys.anydata DEFAULT NULL
   ,p_column_name22  VARCHAR2 DEFAULT NULL, p_column_value22 sys.anydata DEFAULT NULL
   ,p_column_name23  VARCHAR2 DEFAULT NULL, p_column_value23 sys.anydata DEFAULT NULL
   ,p_column_name24  VARCHAR2 DEFAULT NULL, p_column_value24 sys.anydata DEFAULT NULL
   ,p_column_name25  VARCHAR2 DEFAULT NULL, p_column_value25 sys.anydata DEFAULT NULL
   ,p_column_name26  VARCHAR2 DEFAULT NULL, p_column_value26 sys.anydata DEFAULT NULL
   ,p_column_name27  VARCHAR2 DEFAULT NULL, p_column_value27 sys.anydata DEFAULT NULL
   ,p_column_name28  VARCHAR2 DEFAULT NULL, p_column_value28 sys.anydata DEFAULT NULL
   ,p_column_name29  VARCHAR2 DEFAULT NULL, p_column_value29 sys.anydata DEFAULT NULL
   ,p_column_name30  VARCHAR2 DEFAULT NULL, p_column_value30 sys.anydata DEFAULT NULL

  ) IS
    l_column_names  tcolumn_names;
    l_column_values tcolumn_values; 
  ------------------------  
  begin
    l_column_names  ( 1) := p_column_name1;
    l_column_names  ( 2) := p_column_name2;
    l_column_names  ( 3) := p_column_name3;
    l_column_names  ( 4) := p_column_name4;
    l_column_names  ( 5) := p_column_name5;
    l_column_names  ( 6) := p_column_name6;
    l_column_names  ( 7) := p_column_name7;
    l_column_names  ( 8) := p_column_name8;
    l_column_names  ( 9) := p_column_name9;
    l_column_names  ( 10) := p_column_name10;
    l_column_names  ( 11) := p_column_name11;
    l_column_names  ( 12) := p_column_name12;
    l_column_names  ( 13) := p_column_name13;
    l_column_names  ( 14) := p_column_name14;
    l_column_names  ( 15) := p_column_name15;
    l_column_names  ( 16) := p_column_name16;
    l_column_names  ( 17) := p_column_name17;
    l_column_names  ( 18) := p_column_name18;
    l_column_names  ( 19) := p_column_name19;
    l_column_names  ( 20) := p_column_name20;
    l_column_names  ( 21) := p_column_name21;
    l_column_names  ( 22) := p_column_name22;
    l_column_names  ( 23) := p_column_name23;
    l_column_names  ( 24) := p_column_name24;
    l_column_names  ( 25) := p_column_name25;
    l_column_names  ( 26) := p_column_name26;
    l_column_names  ( 27) := p_column_name27;
    l_column_names  ( 28) := p_column_name28;
    l_column_names  ( 29) := p_column_name29;
    l_column_names  ( 30) := p_column_name30;

    l_column_values ( 1) := p_column_value1;
    l_column_values ( 2) := p_column_value2;
    l_column_values ( 3) := p_column_value3;
    l_column_values ( 4) := p_column_value4;
    l_column_values ( 5) := p_column_value5;
    l_column_values ( 6) := p_column_value6;
    l_column_values ( 7) := p_column_value7;
    l_column_values ( 8) := p_column_value8;
    l_column_values ( 9) := p_column_value9;
    l_column_values ( 10) := p_column_value10;
    l_column_values ( 11) := p_column_value11;
    l_column_values ( 12) := p_column_value12;
    l_column_values ( 13) := p_column_value13;
    l_column_values ( 14) := p_column_value14;
    l_column_values ( 15) := p_column_value15;
    l_column_values ( 16) := p_column_value16;
    l_column_values ( 17) := p_column_value17;
    l_column_values ( 18) := p_column_value18;
    l_column_values ( 19) := p_column_value19;
    l_column_values ( 20) := p_column_value20;
    l_column_values ( 21) := p_column_value21;
    l_column_values ( 22) := p_column_value22;
    l_column_values ( 23) := p_column_value23;
    l_column_values ( 24) := p_column_value24;
    l_column_values ( 25) := p_column_value25;
    l_column_values ( 26) := p_column_value26;
    l_column_values ( 27) := p_column_value27;
    l_column_values ( 28) := p_column_value28;
    l_column_values ( 29) := p_column_value29;
    l_column_values ( 30) := p_column_value30;
    
    UPDATE_TABLE (
      p_table_name    
     ,p_pk            
    ,l_column_names
    ,l_column_values 
    );
  
  END UPDATE_TABLE;
  
  -----------------------------------------------------------------------
  PROCEDURE UPDATE_TABLE (
      p_table_name    varchar2
     ,p_pk            varchar2
    ,l_column_names  tcolumn_names
    ,l_column_values tcolumn_values 
  ) IS
      l_update_sql       clob;
      l_select_sql       clob;
      l_changes          varchar2(1000);
      l_trace            clob;
      --
      FUNCTION GET_FORMATED_DATA(p_x IN sys.anyData)
      RETURN VARCHAR2 IS 
       l_num      NUMBER;
       l_date     DATE;
       l_varchar2 VARCHAR2(4000); 
      BEGIN
        if p_x is null then
         RETURN 'NULL'; 
        end if;
        CASE p_x.gettypeName
        WHEN 'SYS.NUMBER' THEN
          IF (p_x.getNumber(l_num) = dbms_types.success) THEN
            IF l_num IS NULL THEN
              l_varchar2 := 'NULL';
            ELSE 
              l_varchar2 := l_num;
            END IF;  
          END IF;
        WHEN 'SYS.DATE' THEN
          IF (p_x.getDate(l_date) = dbms_types.success) THEN
            IF l_date IS NULL THEN
              l_varchar2 := 'NULL';
            ELSE 
              l_varchar2 := 'to_date(''' || to_char(l_date,'yyyymmddhh24miss') || ''',''yyyymmddhh24miss'')';
            END IF;  
          END IF;
        WHEN 'SYS.VARCHAR2' THEN
          IF (p_x.getVarchar2(l_varchar2) = dbms_types.success) THEN
            IF l_varchar2 IS NULL THEN
              l_varchar2 := 'NULL';
            ELSE 
              l_varchar2 := ''''||replace(l_varchar2,'''','''''')||'''';
            END IF;  
          END IF;
        ELSE
          raise_application_error(-20000, 'GET_FORMATED_DATA: This anydata type is not supported');
        END CASE;    
        RETURN l_varchar2;
      END GET_FORMATED_DATA;
      --
      FUNCTION GET_VARCHAR2(p_x IN sys.anyData)
      RETURN VARCHAR2 IS 
       l_num      NUMBER;
       l_date     DATE;
       l_varchar2 VARCHAR2(4000); 
       l_tmp      VARCHAR2(4000);
      BEGIN
        if p_x is null then
         RETURN 'NULL'; 
        end if;
        CASE p_x.gettypeName
        WHEN 'SYS.NUMBER' THEN
          -- NULL --> NULL
          -- 1    --> '1'
          IF (p_x.getNumber(l_num) = dbms_types.success) THEN
            SELECT DECODE( l_num, NULL, 'NULL', '''' || TO_CHAR(l_num) || '''' ) INTO l_tmp FROM DUAL;
            RETURN l_tmp;
          END IF;
        WHEN 'SYS.DATE' THEN
          IF (p_x.getDate(l_date) = dbms_types.success) THEN
            SELECT DECODE( l_date, NULL, 'NULL', '''' || TO_CHAR(l_date,'yyyymmddhh24miss')  || '''' ) INTO l_tmp FROM DUAL;
            RETURN l_tmp;
          END IF;
        WHEN 'SYS.VARCHAR2' THEN
          IF (p_x.getVarchar2(l_varchar2) = dbms_types.success) THEN
            RETURN ''''||l_varchar2||'''';
          END IF;
        ELSE
          raise_application_error(-20000, 'GET_VARCHAR2: This anydata type is not supported');
        END CASE;
      
        RETURN l_varchar2;
      END GET_VARCHAR2;
      --
      FUNCTION GET_COLUMN_NAME (p_column_name    varchar2     
                               ,p_column_value sys.anydata ) 
      RETURN VARCHAR2 IS
       l_res VARCHAR2(100);
      BEGIN
        if p_column_value is null then
         RETURN 'NULL'; 
        end if;
        CASE p_column_value.gettypeName
        WHEN 'SYS.NUMBER' THEN
          RETURN 'TO_CHAR('|| p_column_name ||')';
        WHEN 'SYS.DATE' THEN
          RETURN 'TO_CHAR('|| p_column_name ||',''yyyymmddhh24miss'')';
        WHEN 'SYS.VARCHAR2' THEN
          RETURN p_column_name;
        ELSE
          raise_application_error(-20000, 'GET_COLUMN_NAME: This anydata type is not supported');
        END CASE;
      END;
      --
      FUNCTION EXECUTE_IMMEDIATE (P_CLOBE_PROC CLOB, p_return_value boolean) RETURN VARCHAR2 IS
         V_TABLE      DBMS_SQL.VARCHAR2S;
         v_c          NUMBER;
         v_rc         NUMBER;
         l_result     VARCHAR2(4000);
        ------------------------------------------------------------------------------------
        PROCEDURE CLOB_TO_TABLE (P_CLOB IN CLOB, P_TABLE IN OUT NOCOPY DBMS_SQL.VARCHAR2S) IS
          C_LENGTH       CONSTANT NUMBER := 200; --NOT 256 : POLISH CHARS CAN BE STORED ON 2 BYTES
          V_LICZNIK      BINARY_INTEGER;
          V_ROZMIAR      NUMBER;
        BEGIN
          V_ROZMIAR := DBMS_LOB.GETLENGTH(P_CLOB);
          V_LICZNIK := CEIL(V_ROZMIAR / C_LENGTH);
          IF V_LICZNIK > 0 THEN
            P_TABLE.DELETE;
            FOR I IN 1..V_LICZNIK LOOP
              IF I != V_LICZNIK THEN
                P_TABLE(I) := DBMS_LOB.SUBSTR(P_CLOB, C_LENGTH, (I - 1) * C_LENGTH + 1);
              ELSE
                P_TABLE(I) := DBMS_LOB.SUBSTR(P_CLOB, V_ROZMIAR - (I - 1) * C_LENGTH, (I - 1) * C_LENGTH + 1);
              END IF;
            END LOOP;
          END IF;
        END;
        ------------------------------------------------------------------------------------
        PROCEDURE WRITEAPPEND (P_CLOB IN OUT NOCOPY CLOB, P_TEXT VARCHAR2) IS
         V_TEXT VARCHAR2(32000);
        BEGIN
         V_TEXT := P_TEXT || CHR(10);
         DBMS_LOB.WRITEAPPEND(P_CLOB, LENGTH(V_TEXT), V_TEXT);
        END;
        ------------------------------------------------------------------------------------
      BEGIN
          --DBMS_LOB.CREATETEMPORARY(V_CLOBE_PROC, TRUE, DBMS_LOB.SESSION);
          --DBMS_LOB.OPEN(V_CLOBE_PROC, DBMS_LOB.LOB_READWRITE);
          --WRITEAPPEND(V_CLOBE_PROC, 'create or replace procedure xxxtest is begin null; end;');
          --...    
          CLOB_TO_TABLE(P_CLOBE_PROC, V_TABLE);
          v_c := DBMS_SQL.OPEN_CURSOR;
          DBMS_SQL.PARSE(v_c, V_TABLE, V_TABLE.FIRST, V_TABLE.LAST, FALSE, 1);
          IF p_return_value THEN        
            DBMS_SQL.DEFINE_COLUMN(V_C,1,L_RESULT,4000);
          END IF;
          v_rc := DBMS_SQL.EXECUTE(v_c);
          
          IF p_return_value THEN        
            IF DBMS_SQL.FETCH_ROWS(v_c) >0 THEN
              DBMS_SQL.COLUMN_VALUE(v_c, 1, l_result);
            END IF;        
          END IF;
          
          DBMS_SQL.CLOSE_CURSOR(v_c);
          RETURN l_result;
          --DBMS_LOB.CLOSE(P_CLOBE_PROC);
          --DBMS_LOB.FREETEMPORARY(V_CLOBE_PROC);
      END;
  ------------------------  
  begin
    --@@@to do: CLOB, BLOB types should be supported
  
   -- check changes between database values and delivered values
   -- l_changes is in format '==!===!!' where "=" means no changes (update not required), "!" means change (update required)
   DECLARE
     l_tokens varchar2(32000) := '-->';
   BEGIN
     FOR l_i IN l_column_names.FIRST .. l_column_names.LAST LOOP
       l_tokens := l_tokens || '||CASE WHEN ('||GET_COLUMN_NAME(l_column_names(l_i),  l_column_values (l_i)) || '=' || GET_VARCHAR2 (l_column_values (l_i) ) || ') OR ( '|| GET_COLUMN_NAME(l_column_names (l_i),  l_column_values (l_i)) ||' IS NULL AND '|| GET_VARCHAR2 (l_column_values (l_i )) ||' IS NULL) THEN ''='' else ''!'' end';
     END LOOP;
     -- trim ||
     l_tokens := REPLACE (l_tokens, '-->||','');
     l_select_sql := 
             'SELECT ' || l_tokens || ' CHANGES_STRING' ||
            ' FROM ' || p_table_name || 
            ' WHERE '|| p_pk;
   END;
   l_changes := EXECUTE_IMMEDIATE(l_select_sql, true);   
  
   -- are there any changes ?
   IF INSTR(l_changes,'!') <> 0 THEN
     -- generate update
     DECLARE
       l_tokens varchar2(32000) := '-->';
     BEGIN
       FOR l_i IN l_column_names.FIRST .. l_column_names.LAST LOOP
         -- is there sign "!" on i-th posotion => update required 
         IF SUBSTR( l_changes, l_i, 1 ) = '!' THEN
           l_tokens := l_tokens || ',' || l_column_names (l_i) || '=' || GET_FORMATED_DATA ( l_column_values (l_i) );
         END IF;
       END LOOP;
       -- trim ||
       l_tokens := REPLACE (l_tokens, '-->,','');
       l_update_sql := 
             'UPDATE ' || p_table_name || 
               ' SET ' || l_tokens   || 
            ' WHERE '|| p_pk;
       DECLARE 
         l_dummy varchar2(1);
       BEGIN 
         l_dummy := EXECUTE_IMMEDIATE ( l_update_sql, false );
       END;
     END;
   ELSE
     l_update_sql := 'Update no necessary';
   END IF;
   
   /*
   l_trace :=  
     'l_select_sql='       || l_select_sql       || chr(13)||chr(10)||
     'l_changes='          || l_changes          || chr(13)||chr(10)||
     'l_update_sql='       || l_update_sql       ;
    SWD2_LOG.LOG_MESSAGE(
        P_CODE_UNIT_TYPE    => SWD2_LOG.C_CUT_PACKAGE_BODY
      , P_CODE_UNIT_NAME    => 'SWD2_UTIL'
      , P_CODE_UNIT_ELEMENT => 'UPDATE_TABLE'
      , P_MESSAGE_TYPE      => SWD2_LOG.C_MT_DEBUG
      , P_MESSAGE_TEXT      => SQLERRM
      , p_code_unit_params  => l_trace
      , P_LOCAL_TRANSACTION_ID => DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(FALSE)
      );
   */   
  EXCEPTION
     WHEN OTHERS THEN 
     l_trace :=  
       'l_select_sql='       || l_select_sql       || chr(13)||chr(10)||
       'l_changes='          || l_changes        || chr(13)||chr(10)||
       'l_update_sql='       || l_update_sql       ;
        SWD2_LOG.LOG_MESSAGE(
            P_CODE_UNIT_TYPE    => SWD2_LOG.C_CUT_PACKAGE_BODY
          , P_CODE_UNIT_NAME    => 'SWD2_UTIL'
          , P_CODE_UNIT_ELEMENT => 'UPDATE_TABLE'
          , P_MESSAGE_TYPE      => SWD2_LOG.C_MT_DEBUG
          , P_MESSAGE_TEXT      => SQLERRM
          , p_code_unit_params  => l_trace
          , P_LOCAL_TRANSACTION_ID => DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(FALSE)
          );   
       RAISE_APPLICATION_ERROR (-20000, SQLERRM);
  END UPDATE_TABLE;


