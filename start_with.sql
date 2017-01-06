--!connect by prior !start with !sys_connect_by_path !level !tree

     SELECT customer_trx_line_id, line_type, level
       FROM RA_CUSTOMER_TRX_LINES_ALL
 CONNECT BY PRIOR customer_trx_line_id	= link_to_cust_trx_line_id
 START WITH customer_trx_line_id	= :NEW.interface_line_id;

funkcja sys_connect_by_path(name, '?') zwraca wszystkie nazwy z wczesniejszych poziomow i rozdziela znakiem '?'

uwagi:
- je¿eli konieczne jest u¿ycie warunku WHERE (np. wersja_hierarchii = 210), wówczas wpisz warunek po CONNECT BY
- pamiêtaj o zasadzie "CONNECT BY PRIOR DOK¥D <--- SK¥D". 
  Zapisy "CONNECT BY PRIOR A=B" i "CONNECT BY PRIOR B=A" oznaczaj¹ CO INNEGO 
- problemy z sortowaniem ? jest sk³adnia order sibilings by ...
- mozesz uzywac wielokrotnie slowka PRIOR, np. CONNECT BY PRIOR<--tutaj me.sub_menu_id =me.menu_id and prior<--i tutaj me.prompt IS NOT NULL and prior<-- i tutaj grant_flag = 'Y' 

struktura do testów:
===================================================================================================================

create table xxpriortest ( parent number, child number );

begin
delete from xxpriortest;
insert into xxpriortest (parent, child) values (1,2);
insert into xxpriortest (parent, child) values (1,3);
insert into xxpriortest (parent, child) values (3,4);
insert into xxpriortest (parent, child) values (3,5);
insert into xxpriortest (parent, child) values (3,6);
insert into xxpriortest (parent, child) values (6,7);
insert into xxpriortest (parent, child) values (1,8);
insert into xxpriortest (parent, child) values (8,9);
insert into xxpriortest (parent, child) values (8,10);
commit;
end;

 select sys_connect_by_path(parent, '-') , child , lpad('#',level*4,'#'),  level 
   from xxpriortest
 connect by prior child = parent
 start with parent = 1

/*
1 
+--2
+--3
|  +--4
|  +--5
|  +--6
|     +--7
+--8 
   +--9
   +--10
*/

-- jednostki podrzêdne dla jednostki 3
select * from
(
select level, parent, child , sys_connect_by_path(child, '-')
  from xxpriortest
  CONNECT BY PRIOR child = parent  
  start with parent = 3
)

LEVEL	PARENT	CHILD	SYS_CONNECT_BY_PATH(CHILD,'-')
1	3	4	-4
1	3	5	-5
1	3	6	-6
2	6	7	-6-7


-- jednostki narzêdne dla jednostki 7
select * from
(
select level l, parent, child , sys_connect_by_path(parent, '-')
  from xxpriortest
  CONNECT BY PRIOR parent = child   
  start with child = 7
)
-- where l = 3

LEVEL	PARENT	CHILD	SYS_CONNECT_BY_PATH(PARENT,'-')
1	6	7	-6
2	3	6	-6-3
3	1	3	-6-3-1


zaawansowany przyk³ad:
===================================================================================================================

pokazuje hierarchie jednostek organizacyjnych:

select /*+ ALL_ROWS*/ v.BUSINESS_GROUP_ID, v.org_id, 
       ost.ORGANIZATION_STRUCTURE_ID hier_id, 
       ost.NAME  hier_name, 
       decode(ost.PRIMARY_STRUCTURE_FLAG, 'Y', 'Yes', 'No') hierarchia_podstawowa, 
       v.ORG_STRUCTURE_VERSION_ID version_id, 
       osv.VERSION_NUMBER "VERSION", 
       v.poziom lev, 
       nvl (osv.DATE_FROM, TO_DATE('01-01-1899','dd-mm-yyyy')) version_start_date, 
       nvl (osv.date_to, TO_DATE('31-12-4712','dd-mm-yyyy')) version_end_date, 
       (case when poziom  = 0 then v.name else poprzednik0 end) poziom0, 
       (case when poziom <= 1 then v.name else poprzednik1 end) poziom1, 
       (case when poziom <= 2 then v.name else poprzednik2 end) poziom2, 
       (case when poziom <= 3 then v.name else poprzednik3 end) poziom3, 
       (case when poziom <= 4 then v.name else poprzednik4 end) poziom4, 
       (case when poziom <= 5 then v.name else poprzednik5 end) poziom5, 
       (case when poziom <= 6 then v.name else poprzednik6 end) poziom6, 
       (case when poziom <= 7 then v.name else poprzednik7 end) poziom7, 
       (case when poziom <= 8 then v.name else poprzednik8 end) poziom8, 
       (case when poziom <= 9 then v.name end) poziom9 
from ( 
   select os.BUSINESS_GROUP_ID, os.ORG_STRUCTURE_VERSION_ID, os.organization_id_child org_id 
         ,translate(sys_connect_by_path(decode(level,1, name), '@'),'.@','.') poprzednik0 
         ,translate(sys_connect_by_path(decode(level,2, name), '@'),'.@','.') poprzednik1 
         ,translate(sys_connect_by_path(decode(level,3, name), '@'),'.@','.') poprzednik2 
         ,translate(sys_connect_by_path(decode(level,4, name), '@'),'.@','.') poprzednik3 
         ,translate(sys_connect_by_path(decode(level,5, name), '@'),'.@','.') poprzednik4 
         ,translate(sys_connect_by_path(decode(level,6, name), '@'),'.@','.') poprzednik5 
         ,translate(sys_connect_by_path(decode(level,7, name), '@'),'.@','.') poprzednik6 
         ,translate(sys_connect_by_path(decode(level,8, name), '@'),'.@','.') poprzednik7 
         ,translate(sys_connect_by_path(decode(level,9, name), '@'),'.@','.') poprzednik8 
         ,translate(sys_connect_by_path(decode(level,10, name),'@'),'.@','.') poprzednik9 
         ,org.name, (level-1) poziom 
     from hr_organization_units org, 
         (select pose.business_group_id 
                ,pose.org_structure_version_id 
                ,pose.organization_id_child 
                ,pose.organization_id_parent 
            from per_org_structure_elements pose 
          union 
          (select os.business_group_id, os.org_structure_version_id, os.organization_id_parent, NULL from per_org_structure_elements os 
           minus 
           select os.business_group_id, os.org_structure_version_id, os.organization_id_child , NULL from per_org_structure_elements os ) 
         ) os 
     where org.organization_id = os.organization_id_child 
     start with os.organization_id_parent IS NULL 
     connect by prior os.organization_id_child = os.organization_id_parent 
        and prior os.org_structure_version_id = os.ORG_STRUCTURE_VERSION_ID 
    ) v 
     ,per_organization_structures ost 
     ,per_org_structure_versions  osv 
where ost.organization_structure_id = osv.organization_structure_id 
  and v.business_group_id = ost.business_group_id 
  and ost.business_group_id = osv.business_group_id 
  and v.org_structure_version_id = osv.org_structure_version_id 
  and hr_general.effective_date between osv.date_from and nvl(osv.date_to,hr_general.effective_date)
--  and org_id = 81
