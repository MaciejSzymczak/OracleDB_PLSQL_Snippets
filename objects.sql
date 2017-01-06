--!object 

create or replace type xxtest_t as object
(
  n     number,
  d     date,
  s     varchar2(240),
  static procedure initialize(new_obj in out xxtest_t),

  member procedure setn (pn in number),
  member function getn return varchar2
)
/

create or replace type body xxtest_t as
  static procedure initialize(new_obj in out xxtest_t) is
  begin
    new_obj := xxtest_t -- object initialization. number of arguments must respond to number of local variables
                (null    --n
               , sysdate --d
               , null    --s
               );
  end initialize;

  member procedure setn        (pn in number) is
  begin
   self.n := pn;
  end;
  
  member function getn return varchar2 is
  begin
   return self.n;
  end;

end;
/

declare
  xxtest xxtest_t;
begin 
  xxtest := xxtest_t(null, null, null);   
  --= xxtest_t.initialize( xxtest ); 
  xxtest.setn ( 10 );
  xxtest.s := 'ala ma kota'; --you can refer directly to object variables
  raise_Application_Error (-20000, 'Info: n=' || xxtest.getn || ' d='|| xxtest.d || ' s=' || xxtest.s  ); 
end;

create table xxeraseme (a xxtest_t);

begin
insert into xxeraseme values ( xxtest_t(1, sysdate, 'ala ma kota') );
insert into xxeraseme values ( xxtest_t(2, sysdate, 'bela ma kota') );
insert into xxeraseme values ( xxtest_t(3, sysdate, 'cela ma kota') );
commit;
end;
  
select a  from xxeraseme 

ograniczenia 
===================================================================
W funkcji nie mo¿na zmieniaæ wartoœci zmiennych lokalnych (w procedurach mo¿na). Komunikat o b³êdzie: PLS-00363: wyra¿enie 'SELF' nie mo¿e byæ u¿yte jako cel przypisania
Funkcje nie mog¹ wywo³ywaæ procedur ( czyli nie mo¿na obejœæ problemu z poprzedniej linii)

wewn¹trz typu nie mozna zastosowaæ np. sk³adni
  type titems is  table  of  varchar2(255) index  by  binary_integer,
  items titems,

"dziedziczenie"
====================================================================
CREATE TYPE Address_t AS OBJECT(...) NOT INSTANTIABLE NOT FINAL; <-- not final
CREATE TYPE USAddress_t UNDER Address_t (
  overriding member function get_xsd_type return varchar2 <-- wpisz tylko nadpisywane metody
)

CREATE TYPE IntlAddress_t UNDER Address_t(...);

java
=====================================================================
CREATE OR REPLACE TYPE long_address_t
UNDER address_t
EXTERNAL NAME ’Examples.LongAddress’ LANGUAGE JAVA
USING SQLData(
street2_attr VARCHAR(250)...