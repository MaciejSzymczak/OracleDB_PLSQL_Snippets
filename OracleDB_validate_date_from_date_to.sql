/*
GENERYCZNE ROZWI�ZANIE DO WERYFIKOWANIA PRAWID�OWO�CI P�L DATA OD - DATA DO

Opis
=====================================================================
Rozwi�zanie sk�ada si� z dw�ch wyzwalaczy oraz pakietu.
Wyzwalacz    T1 "for each row" buforuje rekordy do zwalidowania w tabeli plsql ( nie mo�na wykona� zwalidowania ze wzgl�du na ograniczenia wyzwalacza z klauzul� for each row - problem tabel mutujacych ).
Wywalacz bez T2 "for each row" pobiera zbuforowane rekordy i wykonuje w�asciw� walikacj�.

Instrukcja u�ycia:
=====================================================================

1. Zamien wszystkie wystapienia "xxdates" na nazw� twojej tabeli.
   Mo�esz dodawa� do tabeli nowe kolumy, ale pozostaw kolumny istniej�ce.
   id        to unikatowy identyfikator rekordu
   dimension to identyfikator w ramach kt�rego sprawdzana jest unikalnosc dat. Jezeli nie u�ywasz, wprowadz wartosc 'n/a'. Je�eli masz kilku wymiar�w - wpisz warto�� skonkatenowan� w tym polu - zob. przyk�adow� linijk� w wyzwlaczu xxdates_t0
2. Uruchom ten skrypt.
3. Wszystkie komunikaty o b��dach zosta�y zgromadzone w jednym miejscu. Mo�esz wy��czy� niekt�re / zmieni� tekst komunikatu.
   Je�eli chcesz wy��czy� komunikat to usu� podnoszenie wyj�tku
   Szukaj: xxdates_pkg.raise_exception

Test:
=====================================================================
SQL > 
begin
delete from xxdates;
delete from xxmsztools_eventlog where module_name = 'xxdates_pkg';
commit;
end;

SQL > insert into xxdates (id, dimension, date_from, date_to) values (xxext.xxdates_Seq.nextval,'n/a',to_date('2011-01-02','yyyy-mm-dd'),to_date('2010-01-01','yyyy-mm-dd') );
ERROR at line 1: ORA-20001: Data od nie mo�e by� wi�ksza od daty do 

SQL> insert into xxdates (id, dimension, date_from, date_to) values (xxext.xxdates_Seq.nextval,'n/a',to_date('2000-01-02','yyyy-mm-dd'),to_date('2001-01-01','yyyy-mm-dd') );
1 row created.

SQL> insert into xxdates (id, dimension, date_from, date_to) values (xxext.xxdates_Seq.nextval,'n/a',to_date('2000-01-02','yyyy-mm-dd'),to_date('2001-01-01','yyyy-mm-dd') );
ERROR at line 1: ORA-20001: Okresy dat nie mog� si� pokrywa� 

SQL> insert into xxdates (id, dimension, date_from, date_to) values (xxext.xxdates_Seq.nextval,'n/a',to_date('2001-01-02','yyyy-mm-dd'),to_date('2002-01-01','yyyy-mm-dd') );
1 row created.

SQL> select id, dimension, date_from, date_to from xxdates;
       ID  DIMENSION DATE_FROM   DATE_TO                                                                                           
        1        n/a 2000/01/02  2001/01/01                                                                                                                                                                                       
        3        n/a 2001/01/02  2002/01/01                                                                                   
                                                                                                    
SQL> update xxdates set date_from = to_date('2000-01-02','yyyy-mm-dd') where id = 3;
ERROR at line 1:ORA-20001: Okresy dat nie mog� si� pokrywa� 

To do:
=====================================================================
1. Dodanie sprawdzenia badaj�cego ciaglosc okresow  (dniowa, godzinowa)
2. API do dodawania nowych okresow:
   - doklejanie nowych okres�w na koncu z zamykaniem poprzedniego okresu
   - wstawianie nowego okresu pomiedzy istniejace w taki spos�b, �e istniej�ce s� obcicnane
*/
   
drop table xxext.xxdates;
drop synonym xxdates;
drop sequence xxext.xxdates_Seq; 
drop package xxdates_pkg;
 
create table xxext.xxdates 
(id number primary key
,dimension varchar2(100) default 'n/a' not null 
,date_from date not null
,date_to   date);

create sequence xxext.xxdates_Seq;
create synonym xxdates for xxext.xxdates;

create index xxext.xxdates_i2 on xxext.xxdates ( dimension );
create index xxext.xxdates_i3 on xxext.xxdates ( date_from );
create index xxext.xxdates_i4 on xxext.xxdates ( date_to );

CREATE OR REPLACE package xxdates_pkg as
  /**************************************************************************************************************************************************
  | purpose:    date from - date to generic solution
  | additional documentation file name:  date_from_date_to_template.sql
  |
  | revisions:
  | ver        date        author           description
  | ---------  ----------  ---------------  ------------------------------------
  | 1.A        2008-01-07  Maciej Szymczak  created this object
  \***************************************************************************************************************************************************/

  type titem is record (
         id        xxdates.id%type
        ,dimension xxdates.dimension%type
        ,date_from xxdates.date_from%type
        ,date_to   xxdates.date_to%type
  );
  type trows is table of titem index by binary_integer;
  vrows trows;
  item titem;
  
  procedure debug ( message varchar2);
  procedure raise_exception(m varchar2);
  procedure validDates (item titem);
end;
/

CREATE OR REPLACE package body xxdates_pkg as

  debugEnabled boolean := fnd_profile.value('xxdates_enabled')='Y'; -- or to_char(sysdate,'yyyy') = '2008';
  procedure debug ( message varchar2) is
  begin
    if debugEnabled then
      xxmsz_tools.insertintoeventlog(message,'I','xxdates_pkg');
    end if;
  end;

  procedure raise_exception(m varchar2) is begin
     xxdates_pkg.vrows.delete;
     --raise_application_error(-20000, m);
    fnd_message.set_name('FND','FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', m);
    app_exception.raise_exception;
  end;  

  procedure validDates (item titem) is
   c number;
   exc_range_error exception;
   exc_dup         exception;
   exc_past        exception;
  begin
    if item.date_from > nvl(item.date_to, to_date('4000-01-01','yyyy-mm-dd')) then
     raise exc_range_error;
    end if;
    
    -- Okres czasowy (A,B) pokrywa si� z okresem czasowym (C,D), gdy spe�niony jest nast�puj�cy warunek logiczny:  (A>=C lub B >= C) i (A <= D lub B <= D)  
    select count(*) into c
      from xxdates
      where dimension = item.dimension
       and xxmsz_tools.has_common_part (
               item.date_from
             , nvl(item.date_to,to_date('4000-01-01','yyyy-mm-dd')) 
             , date_from
             , nvl(date_to,to_date('4000-01-01','yyyy-mm-dd')) ) = 'Y'
       and id <> nvl(item.id, id);
    xxdates_pkg.debug('pkg#c=' || c || ' item.date_from=' || to_char(item.date_from,'yyyy-mm-dd') || ' item.date_to=' || to_char(item.date_to,'yyyy-mm-dd') || ' item.dimension=' || item.dimension);   
    if c > 0 then raise exc_dup; end if;
      
    select count(*) into c
      from xxdates
      where dimension = item.dimension 
        and item.date_from < date_from 
        and id <> nvl(item.id, id);
    if c > 0 then raise exc_past; end if;
  
  exception  
    when exc_range_error then us_obciazenia_pkg.raise_exception('Data od ('||to_char(item.date_from, 'yyyy-mm-dd')||') nie mo�e by� wi�ksza od daty do ('||to_char(item.date_to  , 'yyyy-mm-dd')||')');
    when exc_dup         then xxdates_pkg.raise_exception('Okresy nie mog� si� pokrywa�');
    when exc_past        then xxdates_pkg.raise_exception('Nie mo�na dodawa� okres�w przed okresami, kt�re zosta�y wprowadzone wcze�niej');
  end;

end;
/

CREATE OR REPLACE TRIGGER APPS.xxdates_t1
after insert or update on xxdates referencing new as new for each row
declare
      /**************************************************************************************************************************************************
      | purpose:    date from - date to generic solution
      | additional documentation file name:  date_from_date_to_template.sql
      |
      | revisions:
      | ver        date        author           description
      | ---------  ----------  ---------------  ------------------------------------
      | 1.A        2008-01-07  Maciej Szymczak  created this object.
      \***************************************************************************************************************************************************/
  i           number;
begin
  i := xxdates_pkg.vrows.count;
  xxdates_pkg.vrows( i+1 ).id        := :new.id;
  xxdates_pkg.vrows( i+1 ).dimension := :new.dimension;
  xxdates_pkg.vrows( i+1 ).date_from := :new.date_from;
  xxdates_pkg.vrows( i+1 ).date_to   := :new.date_to;
  xxdates_pkg.debug('t1#insert date_from=' || to_char(:new.date_from, 'yyyy-mm-dd') || ' id=' || xxdates_pkg.vrows( i+1 ).id );
end;
/

CREATE OR REPLACE TRIGGER APPS.xxdates_t2
after insert or update on xxdates
declare
      /**************************************************************************************************************************************************
      | purpose:    date from - date to generic solution
      | additional documentation file name:  date_from_date_to_template.sql
      |
      | revisions:
      | ver        date        author           description
      | ---------  ----------  ---------------  ------------------------------------
      | 1.A        2008-01-07  Maciej Szymczak  created this object.
      \***************************************************************************************************************************************************/
  j             number;
begin
  j := xxdates_pkg.vrows.first;
  xxdates_pkg.debug('t2#before loop');
  while j is not null loop
    xxdates_pkg.debug('t2#in loop j=' || j || ' date_from=' || to_char(xxdates_pkg.vrows (j).date_from, 'yyyy-mm-dd') || ' id=' || xxdates_pkg.vrows( j ).id);
    xxdates_pkg.item.id        := xxdates_pkg.vrows (j).id;
    xxdates_pkg.item.dimension := xxdates_pkg.vrows (j).dimension;
    xxdates_pkg.item.date_from := xxdates_pkg.vrows (j).date_from;
    xxdates_pkg.item.date_to   := xxdates_pkg.vrows (j).date_to;
    xxdates_pkg.validDates ( xxdates_pkg.item );
        
    j := xxdates_pkg.vrows.next(j);
  end loop;
  xxdates_pkg.debug('t2#after loop');
  xxdates_pkg.vrows.delete;
end;
/

/*
uncomment this if required
create or replace trigger apps.xxdates_t0
  before insert
  on XXEXT.xxdates
  for each row
declare
begin
  select xxext.xxdates_seq.nextval into :new.id from dual;
  :new.dimension := :new.umowa_id ||'.'|| :new.inventory_item_id ||'.'|| :new.product_uom_code ||'.'|| nvl(:new.location_id,-1); 
end;
/
*/
