create or replace 
function xxcreate_control_file ( 
    p_owner       varchar2 
  , p_table_name  varchar2 
  ) return clob 
  is 
    v_buff          clob; 
    v_cnt           number; 
 
    cursor c_columns ( 
      p_table_name  varchar2 
    , p_owner       varchar2 
    ) 
    is 
      select   cols.column_id 
             , cols.column_name as name 
             , nullable 
             , data_type as type 
             , decode (data_type 
                     , 'CHAR', char_length 
                     , 'VARCHAR', char_length 
                     , 'VARCHAR2', char_length 
                     , 'NCHAR', char_length 
                     , 'NVARCHAR', char_length 
                     , 'NVARCHAR2', char_length 
                     , null 
                      ) nchar_length 
             , decode (data_type, 'NUMBER', data_precision + data_scale, data_length) length 
             , data_precision precision 
             , data_scale scale 
             , data_length dlength 
             , data_default 
             , ' ' comments 
             , data_type_mod 
             , cols.char_used 
             , decode (cols.density, null, 'No', 'Yes') histogram 
      from     sys.all_tab_columns cols 
      where    cols.table_name = p_table_name and cols.owner = p_owner 
      order by column_id; 
 
    c_columns_rec   c_columns%rowtype; 
     
    Procedure NewClob  (clobloc       in out nocopy clob, 
                        msg_string    in varchar2) is 
     pos integer; 
     amt number; 
    begin 
    -- make clob temporary. this may impact the speed of the UI 
    -- such that user has to wait to see the notification. 
    -- To improve performance make sure buffer cache is well tuned. 
       dbms_lob.createtemporary(clobloc, TRUE, DBMS_LOB.session); 
       if msg_string is not null then 
          pos := 1; 
          amt := length(msg_string); 
          dbms_lob.write(clobloc,amt,pos,msg_string); 
       end if; 
    end NewClob;     
     
    procedure WriteToClob  ( clob_loc      in out nocopy clob,msg_string    in  varchar2) is 
     pos integer; 
     amt number; 
    begin     
       pos :=   dbms_lob.getlength(clob_loc) +1; 
       amt := length(msg_string); 
       dbms_lob.write(clob_loc,amt,pos,msg_string);     
    end WriteToClob; 
 
    procedure add (s varchar2) is begin 
      WriteToClob (v_buff, s); 
    end; 
 
  begin 
    --v_file_name := lower (p_owner || '_' || p_table_name || '.ctl'); 
 
    select count (*) 
    into   v_cnt 
    from   all_tables 
    where  table_name = p_table_name and owner = p_owner; 
 
    newClob(v_buff, ''); 
     
    if v_cnt <> 1 
    then 
      raise_application_error (-20000, 'ERROR: nie istnieje tabela ' || p_owner || '.' || p_table_name); 
    end if; 
     
    add('LOAD DATA' || chr (10)); 
    add('CHARACTERSET EE8MSWIN1250' || chr (10)); 
    add('APPEND' || chr (10)); 
    add('INTO TABLE ' || p_owner || '.' || p_table_name || chr (10)); 
    add('FIELDS TERMINATED BY X''7C''' || chr (10)); 
    add('(' || chr (10)); 
 
    open c_columns (p_table_name => p_table_name, p_owner => p_owner); 
 
    v_cnt := 1; 
 
    loop 
      fetch c_columns 
      into  c_columns_rec; 
 
      exit when c_columns%notfound; 
 
      if v_cnt <> 1 
      then 
        add(', '); 
      else 
        add('  '); 
      end if; 
 
      v_cnt := v_cnt + 1; 
 
      if c_columns_rec.type = 'VARCHAR2' 
      then 
        add(rpad (c_columns_rec.name, 40) 
                      || rpad ('char ', 20) 
                      || '"trim (:' 
                      || c_columns_rec.name 
                      || ' )"' 
                      || chr (10) 
                     ); 
      elsif c_columns_rec.type = 'DATE' 
      then 
        add(rpad (c_columns_rec.name, 40) || rpad ('date ', 20) || '"YYYY/MM/DD"' || chr (10)); 
      elsif c_columns_rec.type = 'NUMBER' 
      then 
        add(rpad (c_columns_rec.name, 40) 
                      || rpad ('DECIMAL EXTERNAL ', 20) 
                      || '"TO_NUMBER (:' 
                      || c_columns_rec.name 
                      || ', ''99999999999999999999.99999999999999999999'')"' 
                      || chr (10) 
                     ); 
      else 
        raise_application_error (-20001 
                               ,    'Tabela ' 
                                 || p_owner 
                                 || '.' 
                                 || p_table_name 
                                 || ' zawiera nieobs3ugiwany typ ' 
                                 || c_columns_rec.type 
                                ); 
      end if; 
    end loop; 
 
    close c_columns; 
 
    add(', X_STATUS                                CONSTANT            "NEW"' || chr (10)); 
    add(')' || chr (10)); 
    return v_buff;  
  end; 
 
select xxcreate_control_file('SYSTEM','TASKORA') from dual
