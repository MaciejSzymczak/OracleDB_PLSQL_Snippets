--!EXECUTE IMMEDIATE
         v_statement :=
               'select mtow from xxbref_mtow where '
            || v_where_statement_code
            || ' and registration_number = '''
            || p_registration_number
            || ''''
            || ' and :effective_date between start_date_active and nvl(end_date_active, :effective_date)';
--            || 'and reported_pl = ''Y''';
         BEGIN
            EXECUTE IMMEDIATE v_statement
                        [BULK COLLECT] INTO p_mtow
                        USING p_effective_date, p_effective_date;
                        -- zwróæ uwagê, ¿e trzeba napisaæ dwa razy p_effective_date
            RETURN;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_mtow := NULL;
         END;

BULK COLLECT INTO example
-----------------------------------------

  FUNCTION verify_table(p_table_owner IN VARCHAR2
                       ,p_table_name  IN VARCHAR2) RETURN NUMBER IS
    TYPE SourceTable IS TABLE OF VARCHAR2(200);
    TYPE RemoteTable IS TABLE OF VARCHAR2(200);
    v_source_list SourceTable;
    v_remote_list RemoteTable;
  BEGIN
    dbms_application_info.set_client_info('Verifing: '||p_table_owner||'.'||p_table_name||'...');
    SELECT t.COLUMN_NAME||t.DATA_TYPE
      BULK COLLECT
      INTO v_source_list
      FROM ALL_TAB_COLUMNS t
     WHERE t.TABLE_NAME = p_table_name
       AND t.OWNER = p_table_owner
     ORDER BY t.COLUMN_ID;
    --
    EXECUTE IMMEDIATE 'SELECT t.COLUMN_NAME||t.DATA_TYPE
                         FROM ALL_TAB_COLUMNS@'||C_REMOTE_DBNAME||' t
                        WHERE t.TABLE_NAME = :TABLE_NAME
                          AND t.OWNER = :TABLE_OWNER
                        ORDER BY t.COLUMN_ID'
       BULK COLLECT INTO v_remote_list
      USING p_table_name, p_table_owner;
    --
    IF v_source_list.COUNT = v_remote_list.COUNT THEN
      --
      FOR i IN 1..v_source_list.COUNT LOOP
        --
        IF v_source_list(i) != v_remote_list(i) THEN
          RETURN C_STATUS_FATAL;
        END IF;
      END LOOP;
    ELSE
      RETURN C_STATUS_FATAL;
    END IF;
    RETURN C_STATUS_SUCCESS;
  END verify_table;
