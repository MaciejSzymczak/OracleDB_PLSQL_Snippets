--!plsql table !array !bulk !pl/sql table

create or replace procedure plsqltableexample is
  type titem is record (
   v1 varchar2(100),
   v2 varchar2(100)
  );
  type Ttest is table of titem index by binary_integer;
                               -- zwróæ uwagê, ¿e tabela mo¿e byæ równie¿ indeksowana za pomoc¹ VARCHAR2
  test Ttest;  
  k number;
  
  procedure showList is
   i number;
  begin
    dbms_output.put_line('length = ' || nvl(test.count,-100) || ' first=' || test.first || ' last='|| test.last );
    i := test.first;  -- get subscript of first element
    -- this loop jumps over empty elements
    -- tak skonstruowana pêtla przeskakuje równie¿ dziury powsta³e po usuniêciu elementów
    while i is not null loop
       dbms_output.put_line('item no '||i||' value :' || test ( i ).v1 );  
       i := test.next(i); 
    end loop;
	dbms_output.put_line('');
	
    --variant II: 
    --if  p_segments_arr.count <> 0 then 
    --  for i in p_segments_arr.first .. p_segments_arr.last	
  end;

  procedure addItem ( item varchar2) is
   c number;
  begin
    dbms_output.put_line('dodaje ' || item );
    c := test.count;
    test ( c ).v1 := item;
    showList;
  end;
  
  procedure deleteAll is
  begin
    dbms_output.put_line('usuwam liste');
    test.delete;
    showList;
  end;
  
  procedure deleteItems(a number, b number) is
  begin
    dbms_output.put_line('usuwam elementy od ' || a || ' do ' || b);
    test.delete(1,1);
    showList;
  end;

BEGIN 
  showList;
  addItem ('item1');
  addItem ('item2');
  deleteAll;
  addItem ('item1');
  addItem ('item2');
  addItem ('item3');

  deleteItems(1,1);
  dbms_session.free_unused_user_memory;  --required when pl/sql tables are large
  -- dbms_output.put_line('item no '|| 1 ||' value :' || test ( 1 ) ); <-- trying to refer to element that does not exists raises exception
  -- instead od this use if test.exists(1) then ...
  --all the functions are : EXISTS, COUNT, FIRST, LAST, LIMIT, NEXT, PRIOR
  -- to find out more look into Oracle8 Application Developer's Guide
END;
/


bulk collection
--------------------------------

type EXTRACT_LINE_ID_TBL is table of AR_TAX_EXTRACT_SUB_ITF.EXTRACT_LINE_ID%type index by binary_integer;
G_EXTRACT_LINE_ID_TBL                 EXTRACT_LINE_ID_TBL;
select X bulk collect into  G_EXTRACT_LINE_ID_TBL from dual;

FETCH c1 BULK COLLECT INTO req_line_id_tax_tbl.header_id, req_line_id_tax_tbl.dist_id LIMIT 1000;
FORALL l_tax_rounding_index in 1.. req_line_id_tax_tbl.COUNT
UPDATE table_name
   SET recoverable_tax = recoverable_tax+1
 WHERE distribution_id= min_dist_id_tax_tbl(l_tax_rounding_index);


pl/sql table ---> update       bulk collection
-----------------------------------
   TYPE r_dbi_key_value_arr IS TABLE OF NUMBER(15);
   l_dbi_key_value_list r_dbi_key_value_arr;

 update ap_invoice_distributions
   set awt_invoice_payment_id=l_new_invoice_payment_id,
       accounting_date=sysdate,
       posted_flag='N',
       accrual_posted_flag='N',
       cash_posted_flag='N',
       accounting_event_id=null
 where invoice_id=r_c_get_inv_payments.invoice_id
   and awt_invoice_payment_id=r_c_get_inv_payments.invoice_payment_id
   RETURNING invoice_distribution_id
   BULK COLLECT INTO l_dbi_key_value_list;
   
pl/sql table ---> table               
-----------------------------------------

 DECLARE
    l_array1     <array_type_declaration>;
    l_array2     <array_type_declaration>;
    l_array3     <array_type_declaration>;
 BEGIN
    FORALL indx IN l_array1.FIRST .. l_array1.LAST
       INSERT INTO 
          ( column list )
          VALUES
          (l_array2 (indx), l_array3 (indx) ...);
 END;

pl/sql table ---> select              
-----------------------------------------
 
create or replace type zsip."t_varchar_list" is table of varchar2(4000)  --cannot add  "index by binary_integer". Types embeded in database not supports it
/

grant execute on  zsip.t_varchar_list to ksipwww;

declare
  gt_spje_privs  T_VARCHAR_LIST := NEW T_VARCHAR_LIST();
  cnt  number;
begin
  cnt:=nvl(gt_spje_privs.last,0)+1;
  gt_spje_privs.extend; -- <-- required for type without "index by binary_integer" 
                        -- for types with "index by binary_integer"  this line can be ignored
  gt_spje_privs(cnt) := p_spje_kod;
  for rec in (
     select value(rp) from table(gt_spje_privs) rp  -- possible for types embeded in database only
  ) loop
    null;
  end loop;
  gt_spje_privs.delete;
end;

-----------------------------------------------
see also: varray

you can do MINUS, INTERSECT on PL/SQL tables


------------------------------------------------
source: crdk, package xx_arch

	 exc_bulk_err EXCEPTION;
	 PRAGMA EXCEPTION_INIT(exc_bulk_err,-24381);

		EXCEPTION


	   --Obs³uga b³edow bulk
		WHEN exc_bulk_err THEN
		    <<EXC_BULK_ERRORS_BLK>>
          DECLARE
             l_msg      VARCHAR2(400);
             l_sqlcode  NUMBER;
             l_sqlerrm  VARCHAR2(400);
             l_count    INTEGER;
          BEGIN
             l_count := SQL%BULK_EXCEPTIONS.COUNT;

             FOR indx IN 1 .. l_count
             LOOP
                l_sqlcode:=-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE;
                l_sqlerrm:= SQLERRM(l_sqlcode);
					 xx_log_pkg.LOG_INS( MESSAGE        => '',
                                  ENTRY_CODE     => 'BULK EXCEPTION',
  					              OBJECT_TYPE    => 'PACKAGE_BODY',
					              OBJECT_NAME    => 'XX_ARCH.POBIERZ_ID_DO_ARCH2',
					              LOG_ENTRY_TYPE => 'ERROR',
					              SQL_EERM 		  => l_sqlerrm,
					              SQL_CODE 		  => l_sqlcode,
					              KEY_VALUES 	  => per_id_tab(indx).ARCH_ID ||'|'||per_id_tab(indx).PERSON_ID );
             END LOOP;
          END EXC_BULK_ERRORS_BLK;
          
          

