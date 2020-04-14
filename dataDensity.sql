create or replace package dataDensity AS

/* 2020.04.14 Maciej Szymczak. All Rights Reserved

    begin
    dataDensity.calculate('ALL_EXTERNAL_CONTACTS','createdDate > ''2019-02-04T14:00:00.000Z''');
    end;
    
select unique_values.all_distinct_values, 
           first_values.*,
           case when pct=100 then 'NOT USED: DELETE'
            when pct>99 then 'VERY RARELY USED: DELETE'
            when pct>90 then 'RARELY USED: CONSIDER DELETETION'
           end Recommendation  
           , mod( (DENSE_RANK () over (partition by null order by unique_values.field_name)), 2) even_row
           , (DENSE_RANK () over (partition by null order by unique_values.field_name)) field_no
    from    
        (
            select * from
            (
            select 
              field_name, field_value, cnt, pct
              ,(row_number() over (partition by field_name order by cnt desc))  as first_values
            from density_result order by field_name, pct desc
            )
            where first_values <= 10
        ) first_values,
        (select field_name, count(1) all_distinct_values 
           from density_result 
        group by field_name) unique_values
    where first_values.field_name = unique_values.field_name
      
*/
  procedure calculate(pTableName in varchar2, pWhereClause in varchar2);         
  function getStatement (pTableName in varchar2, pFieldsList in varchar2, pWhereClause in varchar2) return varchar2;
END;
/

create or replace package body dataDensity AS
  ----------------------------------------------------------------------------------------------------
  procedure calculate(pTableName in varchar2, pWhereClause in varchar2) is
  begin
    begin execute immediate 'drop table density_result'; exception when others then null; end;
    execute immediate 'create table density_result (field_name varchar2(100), field_value varchar2(2000), cnt number)';
    for rec in (select cname from col where tname = pTableName) loop
       begin  execute immediate 'drop table density_chunk'; exception when others then null; end;
       execute immediate 'create table density_chunk as '|| getStatement (pTableName, rec.cname, pWhereClause);
       execute immediate 'insert into density_result select * from density_chunk';  
    end loop;
    -- calculate cnt
    declare
      cntTotal number;
    begin
      execute immediate 'select count(1) from '||pTableName||' where '||nvl(pWhereClause,'0=0') into cntTotal;
      execute immediate 'alter table density_result add (pct number)';
      execute immediate 'update density_result set pct = round(cnt * 100 /'||cntTotal||',5)';
    end;
  end;
  ----------------------------------------------------------------------------------------------------
  function getStatement (pTableName in varchar2, pFieldsList in varchar2, pWhereClause in varchar2) return varchar2 is
      res varchar2(32000):='';
      union_all varchar2(100) := '';
      vFieldsList varchar2(32000):='';
  begin
    if pFieldsList is not null then
      vFieldsList := upper(pFieldsList);
    else
      --get all fields
      for rec in (select cname from col where tname = pTableName) loop
       vFieldsList := vFieldsList||','||rec.cname;
      end loop;
    end if;
    vFieldsList := ',' || vFieldsList || ',';
       --raise_application_error(-20000, 'TU BYLEM'||vFieldsList);
    for rec in (select cname from col where tname = pTableName and vFieldsList like '%,'||cname||',%') loop
      res := res || union_all || 'select '''||rec.cname||''' field_name, '||rec.cname||' field_value, count(1) cnt from '||pTableName||' where '||nvl(pWhereClause,'0=0')||' group by '||rec.cname||'';
      union_all := chr(10)||' union all ';
    end loop;
    res := res ||chr(10)|| 'order by field_name, cnt desc';
    return res;
  end;      
END;
/
