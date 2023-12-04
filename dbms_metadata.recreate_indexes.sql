begin
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',false);
end;
/

select to_char('Drop index '||index_name||';') ddl_statement from all_indexes where table_name = 'DM_ACCOUNT_PA' and table_owner ='LFPROD'
union all
select to_char(dbms_metadata.get_ddl('INDEX',index_name,table_owner)) from all_indexes where table_name = 'DM_ACCOUNT_PA' and table_owner ='LFPROD'

---
select dbms_metadata.get_ddl('PACKAGE','XXEX_GAP3_PKG', 'APPS') FROM dual
select DBMS_METADATA.GET_DDL('REF_CONSTRAINT', 'TT_PLA_FK2') from dual
