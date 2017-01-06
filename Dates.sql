--!dates
--!konwersje !konwersja
--!conversions

-- dzien tygodnia, miesiaca
SELECT to_char(SYSDATE,'d') FROM dual
SELECT to_char(SYSDATE,'dd') FROM dual

-- numer tygodnia w roku
select to_char( sysdate , 'IW') from dual --Week of year (1-52 or 1-53) based on the ISO standard.  
select to_char( sysdate , 'WW') from dual --Week of year (1-53) where week 1 starts on the first day of the year and continues to the seventh day of the year.  

-- !pierwszy dzien tygodnia, miesiaca, kwarta³u, roku 
SELECT TRUNC(SYSDATE,'d') FROM dual
SELECT TRUNC(SYSDATE,'mm') FROM dual
SELECT TRUNC(SYSDATE,'Q') FROM dual
SELECT TRUNC(SYSDATE,'yyyy') FROM dual

-- !ostatni dzien tygodnia, miesiaca, roku, poprzedniego miesi¹ca, poprzedniego roku
SELECT TRUNC(SYSDATE,'d')+6 FROM dual
select trunc(last_day(sysdate)) from dual
SELECT to_date(to_char(SYSDATE,'yyyy')+1 || '-01-01','yyyy-mm-dd')-1  FROM dual
SELECT TRUNC(SYSDATE,'mm')-1 FROM dual --zob. te¿ poni¿ej
SELECT to_date(to_char(SYSDATE,'yyyy') || '-01-01','yyyy-mm-dd')-1 FROM dual

-- pierwszy i ostatni dzien poprzedniego miesiaca
select last_day(add_months(trunc(sysdate),-2))+1 from dual 
select last_day(add_months(trunc(sysdate),-1)) from dual

-- data w dowolnej wersji jêzykowej
select to_char(sysdate,'yyyy-mon-dd','NLS_DATE_LANGUAGE=''AMERICAN''') from dual
select to_char(sysdate,'yyyy-mon-dd','NLS_DATE_LANGUAGE=''POLISH''') from dual

-- zwiêkszenie daty-godziny o 2 godz
select sysdate + NumTodsInterval(2, 'hour')  from dual
-- zwiêkszenie daty-godziny o rok
select sysdate + +numtoyminterval(-1, 'YEAR')  from dual

EXTRACT(SECOND FROM(cr.actual_completion_date - cr.actual_start_date) DAY TO SECOND)

--dzieñ miesi¹c rok s³ownie
select to_char(sysdate, 'DAY') from dual
select to_char(sysdate, 'MONTH') from dual
select to_char(sysdate, 'YEAR') from dual          

-- kwota z wymuszaniem formatu, w tym kropek i przecinków
!TO_CHAR(NVL(p_num,0), 'FM999G999G999G999G999G999G999G999G999G999G990D00' , 'nls_numeric_characters = ''.,''')
zob. te¿ Fnd_Currency.get_format_mask('PLN', 50) = 'FM999G999G999G999G999G999G999G999G999G999G990D00'
alter session set NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS'; 
alter session set nls_numeric_characters = '.,' 

--zapis skrócony
select DATE'2009-01-01' from dual 

--!trick !trik
select trunc(sysdate+rownum) from dual connect by rownum  < 10

select cast('100' as number) from dual

--!varray
create or replace type swd2_test is varray(1000) of varchar2(100); 

select column_value
  from table ( swd2_test ('a','b','c','d','e', 'f') )

--same effect as prior  
select to_clob( extract( column_value , '/r/text()')) 
  from table (xmlsequence(
       ( 
       select extract(d, '//r') 
        from (
             select xmltype.createxml(
                 --'<rowset><r>1</r><r>2</r><r>3</r><r>4</r><r>5</r></rowset>'
                 ( select  '<rowset><r>'||replace(d,',','</r><r>')||'</r></rowset>' from (select 'A,B,C,D,E' d from dual)  )
               ) d
               from dual
             )
       )     
       )) d          

--same effect as prior

with 
  concatenated_elements as
   (select '001;2;33³ó¿koZ33#4' dd from dual),
  elements as
   ( select length(concatenated_elements.dd) len, regexp_substr(concatenated_elements.dd, '([0-9]|[-]|[a-Z]|[¹êæ³ñŸ¿])+', 1, rownum/*get n-th element*/) element
       from concatenated_elements 
    connect by rownum <= length(concatenated_elements.dd)) -- major, not exact limitation
select element from elements where element is not null

select regexp_substr('1,,2,3', '([0-9]|[-])+', 1, 2/*get n-th element*/) from dual

--!concat !||
select wm_concat(a) from (select 1 a from dual union all select 2 from dual)  
see also "StringAggregationTechn.pdf"
    

--!spell amount
SELECT  TO_CHAR(TO_DATE(999999, 'J'), 'JSP')  FROM DUAL

  --!trim
  select trim(',' FROM ',aaa,aaa,') from dual
  --> aaa,aaa

  !replace
  !substr
  !REGEXP_LIKE 
  !REGEXP_INSTR 
  !REGEXP_REPLACE 
  !REGEXP_SUBSTR 
  !REGEXP_COUNT 
  
  SELECT REGEXP_SUBSTR('http://www.oracle.com/products', 'http://([[:alnum:]]+\.?){1,10}/?') "REGEXP_SUBSTR" FROM DUAL;
  
  -- First name starts with J or j
   SELECT id, first_name, last_name FROM employee WHERE REGEXP_LIKE(first_name, '^j', 'i');
   SELECT id, first_name, last_name, start_date FROM employee WHERE REGEXP_LIKE(TO_CHAR(start_date, 'YYYY'), '^199[5-8]$');

--dzielenie na substringi o okreœlonej d³ugoœci
select * from  (
select substr('ci¹g znaków do podzia³u',1 + (rownum-1)*3 ,3) substrs from dual 
connect by rownum  < 100 )
where substrs is not null

--funkcja podaje d³ugoœæ okresu w latach, miesi¹cach i dniach
create or replace function xxyear_month_days_between(p_start_date IN DATE,
					  p_end_date IN DATE
                      ) return varchar2 
                              IS
  dStartdate Date;
  dEnddate Date;
  dDays number;
  dMonths number;
  nStartdate Date;
  nEnddate Date;
  dYear number:=0;
	p_days NUMBER;
	p_months NUMBER;
   	p_years NUMBER;
BEGIN
  dStartdate:=p_start_date;
  dEnddate:=p_end_date;

  if last_day(dStartdate -1) = (dStartdate - 1) and last_day(dEnddate) = dEnddate then
     dMonths:= months_between(dEnddate,dStartdate-1);
     dDays:=0;
  elsif last_day(dStartdate -1) = (dStartdate - 1) then
      nStartdate:=dStartdate -1;
      nEnddate:=trunc(dEnddate,'MM')-1;
      dMonths:= months_between(nEnddate,nStartdate);
      dDays:=to_number(to_char(dEnddate,'dd'));
  elsif last_day(dEnddate) = dEnddate then
      nStartdate:=last_day(dStartdate);
      nEnddate:=dEnddate;
      dMonths:= months_between(nEnddate,nStartdate);
      dDays:=to_number(to_char(last_day(dStartdate),'dd'))-to_number(to_char(dStartdate-1,'dd'));
  elsif to_char(dStartdate,'Mon') = to_char(dEnddate,'Mon') Then
      dMonths:= months_between(dEnddate,dStartdate);
      if to_char(dStartdate,'dd') <= to_char(dEnddate,'dd') Then
        dDays:= to_number(to_char(dEnddate,'dd')) - to_number(to_char(dStartdate,'dd'))+1;
      else
        dDays:=to_number(to_char(last_day(dStartdate),'dd'))-to_number(to_char(dStartdate-1,'dd'))
              +to_number(to_char(dEnddate,'dd'));
      end if;
  else
      nStartdate:=last_day(dStartdate);
      nEnddate:=trunc(dEnddate,'MM')-1;
      dMonths:= months_between(nEnddate,nStartdate);
      dDays:=to_number(to_char(last_day(dStartdate),'dd'))-to_number(to_char(dStartdate-1,'dd'))
         +to_number(to_char(dEnddate,'dd'));
  end if;
  dMonths:= trunc(dMonths);
  If dDays >= 30 then
    dMonths:=dMonths+trunc(dDays/30);
    dDays :=mod(dDays,30);
  End If;

  If dMonths >= 12 then
    dYear := trunc(dMonths/12);
    dMonths:= mod(dMonths,12);
  end if;
   p_years:= dYear;
   p_months := dMonths;
   p_days := dDays;

return p_years ||':'||     p_months      ||':'|| p_days; 	 
END;

--nested queries are not supported, example

select
 (
   select * 
   from 
   (
   select 1 from dual where r1=r1 
   )
  ) 
 from (select 'r1' r1 from dual) ala

-- NULL in "in"/"not in" causes no data found
select 1 from dual where 'a'  in ('1', null)


--!wrap !unwrap
http://codecrete.net/unwrapit


--!oracle passord !get encrypted passowd
-- using this you can change user password for w while and then restore it

select 'alter user "'||username||'" identified by values '''||extract(xmltype(dbms_metadata.get_xml('USER',username)),'//USER_T/PASSWORD/text()').getStringVal()||''';'  old_password 
from  dba_users
where username = 'APPS';

--see also: Cracking_Passwords_Guide.pdf
