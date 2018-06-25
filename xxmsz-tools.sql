create or replace package Xxmsz_Tools as

/* A set of tools written in PL/SQL. 
 * @author Maciej Szymczak
 * @created 2003-2013
 */

  -- ***********************************************************************************************************************
  -- * data encryption
  -- ***********************************************************************************************************************
  -- SELECT Xxmsz_Tools.encrypt('PASSWORD1') FROM dual;
  -- SELECT Xxmsz_Tools.decrypt(app_password.encrypt('PASSWORD1')) FROM dual;
  -- SELECT Xxmsz_Tools.encrypt('PSW2') FROM dual;
  -- SELECT Xxmsz_Tools.decrypt(app_password.encrypt('PSW2')) FROM dual;

   function encrypt(i_password varchar2) return varchar2;
   function decrypt(i_password varchar2) return varchar2;

  -- ***********************************************************************************************************************
  -- * dates
  -- ***********************************************************************************************************************

  -- Purpose:    Checks if a year is a leap year
  -- Author:     Frank Naude, Oracle FAQ
  function isLeapYear(i_year number) return boolean;

  -- returns 'Y' if period between dates (A1,A2) has an overlap with (B1,B2)
  function has_common_part(
     pa1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pa2 date default to_date('4000-12-31','yyyy-mm-dd') 
   , pb1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pb2 date default to_date('4000-12-31','yyyy-mm-dd')
   ) return varchar2;

/*   
Porównuje okres A1-A2 z okresem B1-B2
                    A1      A2
                    |=========|  
                    |         |
                B1==|=========|==B2               INSIDES                  
                    |  =====  |                   IS_INSIDE
                    |    =====|                   IS_INSIDE_RJUSTIFY
                    |=====    |                   IS_INSIDE_LJUSTIFY
                    |         |
    ========        |         |                   IS_BEFORE_GAP
            ========|         |                   IS_BEFORE_NO_GAP
              ======|===      |                   IS_BEFORE_COMMON_PART
                    |=========|                   THE_SAME   
                    |      ===|======             IS_AFTER_COMMON_PART
                    |         |========           IS_AFTER_NO_GAP
                    |         |       ========    IS_AFTER_GAP
                                                  BAD_PERIOD_A
                                                  BAD_PERIOD_B
*/
  function compare_periods(
     pa1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pa2 date default to_date('4000-12-31','yyyy-mm-dd') 
   , pb1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pb2 date default to_date('4000-12-31','yyyy-mm-dd')
   ) return varchar2;

   
  -- ***********************************************************************************************************************
  -- * bin, dec, hex conversions
  -- ***********************************************************************************************************************
  --
  -- SELECT Xxmsz_Tools.dec2bin(22)      FROM dual;
  -- SELECT Xxmsz_Tools.bin2dec('10110') FROM dual;
  -- SELECT Xxmsz_Tools.dec2oct(44978)   FROM dual;
  -- SELECT Xxmsz_Tools.oct2dec(127662)  FROM dual;
  -- SELECT Xxmsz_Tools.dec2hex(44978)   FROM dual;
  -- SELECT Xxmsz_Tools.hex2dec('AFB2')  FROM dual;
  --
  /* Purpose:    Package with functions to convert numbers between the
                 Decimal, Binary, Octal and Hexidecimal numbering systems.
     Usage:      See sampels at the bottom of this file
     Author:     Frank Naude, 17 February 2003
  */

   function bin2dec (binval in char  ) return number;
   function dec2bin (N      in number) return varchar2;
   function oct2dec (octval in char  ) return number;
   function dec2oct (N      in number) return varchar2;
   function hex2dec (hexval in char  ) return number;
   function dec2hex (N      in number) return varchar2;

  -- ***********************************************************************************************************************
  -- * String operations
  -- ***********************************************************************************************************************

  left   integer := 0;
  right  integer := 1;
  middle integer := 2;

  fopMarkOn  varchar2(50) := '<fo:inline font-size="from-parent(font-size) + 2">';
  fopMarkOff varchar2(50) := '</fo:inline>';

  function Center (S varchar2, LEN number) return varchar2;
  -- otacza taka sama liczba spacji tekst z przodu i z tylu, dlugosc zwracanego lancucha = len

  function trimSpaces ( S varchar2 ) return varchar;
  -- usuwa skrajne spacje oraz usuwa wielokrotne spacje z ciagu i zastepuje je pojedynczymi

  function makeStr(s varchar2, len number) return varchar2;
  -- zwraca ciag utworzony z wielokrotnego skonkatenowania s o dlugosci len
  function extractWord  (poz number, words varchar, sep varchar := '|') return varchar;
  -- wyodrebnia poz-ty podciag z podciagów rozdzielonych znakiem Sep z ciagu Words
  --    np. ExtractFileName(2, 'Ala|Ma|Kota','|') -> Ma
  function wordCount(  words varchar2, separator  in     varchar2 := '|') return number;
  -- zlicza liczbe podciagów rozdzielonych znakiem Separator w ciagu Words
  function replaceWord(poz number, replaceWith varchar2, words varchar, sep varchar := '|') return varchar2;
  -- zamienia poz-ty podciag w ciagu na ciag replaceWith  
  function getTokenByName ( tokens varchar2, tokenName varchar2, tokenSeparator varchar2) return varchar2;
  -- wyodrednia z lancucha znaków w postaci param1=value1;param2=value2,.. odpowiednia wartosc
  -- np. select getTokenByName ('param1=value1;param2=value1;param1=value3;param4=value4','param1',';') from dual --> param1=value1
  --     select getTokenByName ('param1=value1;param2=value1;param1=value3;param4=value4','param4',';') from dual --> param4=value4
  --     select getTokenByName ('param1=value1;param2=value1;param1=value3;param1=value4','paramx',';') from dual --> null
  --     select getTokenByName ('param1=value1;param2=value1;param1=value3;param4=value4','param',';') from dual  --> !! param1=value1
  function pushLastWord(pushWord varchar2, words varchar2, sep varchar := '|') return varchar2;
  --kladzie slowo na koniec
  function popLastWord(words varchar2, sep varchar := '|') return varchar2;
  --zabiera slowo z konca
  function merge(S1 varchar2, S2 varchar2, SEP varchar2 default null) return varchar2;
  -- laczy ciagi S1 i S2 za pomoca separatora SEP
  -- uzyteczna podczas skladania warunków WHERE warunek1 AND warunek2 AND ... oraz podczas dodawania lancuchow (NULL || 'any' = NULL ...)
  --    np. Merge('A','B',',', -> 'A,B')
  --        Merge('A','' ,',', -> 'A')
  --       Merge('','B' ,',', -> 'B')
  function wordWrap( wrappedString varchar2, columnWidth number, getTokenNr number default 0, completeWithSpaces varchar2 default 'Y', TokenSeparator varchar2 default '|') return varchar2;
  -- dzieli ciag S na fragmenty o dlugosci columnWidth i zwraca token o numerze getTokenNr ( 0 oznacza, ze zostana zwrocone wszystkie tokeny, rozdzielone znakami |)
  -- jezeli w ciagu wejsciowym sa znaki |, to zostana one potraktowane jako znaki konca wiersza
  function pasteStr( Str varchar2, pastedStr varchar2, fromPos number, toPos number, align number ) return varchar2;
  -- wkleja pastedStr do Str od pozycji fromPos do pozycji toPos align = 1-od prawej 0-od lewej
  function erasePolishChars(S varchar2) return varchar2;
  -- zastepuje polskie znaki ich odpowiednikami bez ogonkow np. lózko -> lozko
  -- przyklad uzycia - zamiana ciagow znakow na nazwy kolumn w bazie danych Oracle
  --    select ', '||rpad(replace(replace(replace(replace(replace(substr(xxmsz_tools.erasePolishChars(text),1,30),'(','_'),')','_'),' ','_'),'.',''),'-',''),40) || ' VARCHAR2(500)' x from xxtmp where upper(text) like upper('%') order by num
  procedure addPercent ( V in out varchar2 );
  -- dodaje % na koncu stringa, chyba, ze juz jest % w stringu
  function isSubsetOf (Set1 varchar2, Set2 varchar2) return varchar2;
  -- zwraca TRUE jesli SET1 jest podzbiorem SET2. Elementy sa rozdzdzielone znakiem ;
  --   select substr(xxmsz_tools.issubsetof('third;first','first;second;third'),1,3) from dual -> Y
  --   select substr(xxmsz_tools.issubsetof('fourth;first','first;second;third'),1,3) from dual -> N

  function tolatin2 (tekst in varchar2) return varchar2;
  -- konwertuje ciag na standard Latin2
  function hasPolishSigns(S in out varchar2) return varchar2;
  -- sprawdza, czy string zawiera polskie znaki -> N,Y
  function strToNumber ( str varchar2, valueWhenEmpty varchar2 default '0' ) return number;
  -- konwertuje ciag do liczby. Czesci calkowita i ulamkowa moga byc rozdzielone przecinkiem lub kropka, separator tysiecy nie moze wystepowac
  function isNumber ( str varchar2 ) return varchar2;
  -- sprawdza, czy ciag znakow mozna skonwertwac do liczby. Zwraca wartosci Y/N

   /*****************************************************************************************************************************
   |* Wrapping texts
   |*****************************************************************************************************************************
   |  set serveroutput on;
   |  declare
   |    WordWrap xxmsz_tools.tWordWrap;
   |    procedure insertLines ( WordWrap in out xxmsz_tools.tWordWrap ) is
   |      i number;
   |    begin
   |      if WordWrap.errorMessage is not null then xxmsz_tools.dbms_outputPut_line (WordWrap.errorMessage); end if;
   |      for i in 1..xxmsz_tools.wordWrapGetNumberOfLines(WordWrap) loop
   |        xxmsz_tools.dbms_outputPut_line ( xxmsz_tools.wordWrapGetLine(WordWrap,i) );
   |      end loop;
   |    end;
   |  begin
   |    xxmsz_tools.wordWrapInit (WordWrap,'|aaaaaaaaaaaaa|bbbbbbbbbbbbb|ccccccccccccc|');
   |    xxmsz_tools.wordWrapPrepareColumn(WordWrap, 'Przykladowy tekst Przykladowy tekst Przykladowy tekst', 'aaaaaaaaaaaaa', xxmsz_tools.left);
   |    xxmsz_tools.wordWrapPrepareColumn(WordWrap, 'Przykladowy tekst Przykladowy tekst Przykladowy tekst', 'bbbbbbbbbbbbb', xxmsz_tools.right);
   |    xxmsz_tools.wordWrapPrepareColumn(WordWrap, 'Przykladowy tekst Przykladowy tekst Przykladowy tekst', 'ccccccccccccc', xxmsz_tools.middle);
   |    insertLines ( WordWrap );
   |  end;
   |  /
   |
   \*-----------------------------------------------------------------------------------------------------------------------------*/

  type tWordWraplinesPastedStr is  table  of varchar2(5000) index  by  binary_integer;
  type tWordWraplinesFromPos   is  table  of number         index  by  binary_integer;
  type tWordWraplinesToPos     is  table  of number         index  by  binary_integer;
  type tWordWraplinesAlign     is  table  of number         index  by  binary_integer;
  -- zamiast kilku tabel PL/SQL powinna byc jedna z typem rekordowym, ale skladnia jezyka na to nie pozwala ( PLS-00511: rekord nie moze zawierac tabeli PL/SQL rekordów )
  -- PL/SQL nie pozwala predefiniowac typu LongStr = VARCHAR2(5000), szkoda
  type tWordWrap is record (
          defaultStr varchar2(2000)
         ,linesPastedStr tWordWraplinesPastedStr
         ,linesFromPos tWordWraplinesFromPos
         ,linesToPos tWordWraplinesToPos
         ,linesAlign tWordWraplinesAlign
         ,resultLineNum number default -1-- numer zwracanej linii
   ,errorMessage varchar2(1000) default null
   ,tokenSeparator varchar2(1) default '|' --znak przejscia do nastepnej linii
       );

  procedure wordWrapInit (aWordWrap in out nocopy tWordWrap,adefaultStr varchar2, TokenSeparator varchar2 default '|'); -- defaultStr musi zawierac placeholdery
                                                                            -- moze on takze zawierac inne elementy jak ramki, znaki formatujace html itp.
  procedure wordWrapPrepareColumn(aWordWrap in out nocopy tWordWrap, pastedStr varchar2, placeHolder varchar2, align number );
  function  wordWrapGetNumberOfLines(aWordWrap in out nocopy tWordWrap) return number; -- zwraca liczbe linii
  function  wordWrapGetLine(aWordWrap in out nocopy tWordWrap,lineNum number) return varchar2; -- zwraca linie o podanym numerze
  
   /*****************************************************************************************************************************
   |* printing tables. this API allows you print tables in easy way 
   |*****************************************************************************************************************************
   |  declare
   |   ptableDef Xxmsz_Tools.tTableDef;
   |  begin
   |   Xxmsz_Tools.addHeader (ptableDef
   |      , 'username|account_status|default_tablespace|temporary_tablespace|created|profile' --column headers. use SQLTrick to get this string in fastest way 
   |      , '0|0|0|0|0|10' -- column widths. you can omit this parameter (= whole table autowidth).  0 means column autowidth.
   |      , 'right|right|right' -- column alligns. you can omit this parameter (= left)
   |   );
   |   for rec in (
   |     select username ||'|'|| account_status ||'|'|| default_tablespace ||'|'|| temporary_tablespace ||'|'|| created ||'|'|| profile data --use SQLTrick to get this string in fastest way
   |                                                                                                                                         --use format (to_char) statemets here  
   |       from dba_users
   |   ) loop
   |    Xxmsz_Tools.addLine   (ptableDef, rec.data);
   |   end loop;
   |   Xxmsz_Tools.showTable (ptableDef);
   |   Xxmsz_Tools.destroy   (ptableDef);  --purges plsql tables
   |  end;
   |  /
   |  
   |  result:
   |   
   |  +-------------------+----------------+------------------+--------------------+--------+----------+
   |  |           USERNAME|  ACCOUNT_STATUS|DEFAULT_TABLESPACE|TEMPORARY_TABLESPACE|CREATED |PROFILE   |
   |  +-------------------+----------------+------------------+--------------------+--------+----------+
   |  |                IZU|            OPEN|              IZUD|TEMP                |06/10/29|DEFAULT   |
   |  |                MON|            OPEN|               MON|TEMP                |06/07/17|DEFAULT   |
   |  |                XDO|            OPEN|              XDOD|TEMP                |06/06/15|DEFAULT   |
   |  |           PERFSTAT|            OPEN|         STATSPACK|TEMP                |07/05/30|DEFAULT   |
   |  |           LOFTWARE|            OPEN|          LOFTWARE|TEMP                |04/04/28|DEFAULT   |
   |  |                PRP|            OPEN|              PRPD|TEMP                |04/01/01|DEFAULT   |
   |  |         AD_MONITOR|EXPIRED ; LOCKED|            SYSTEM|TEMP                |06/06/15|AD_PATCH_M|
   |  |                   |                |                  |                    |        |ONITOR_PRO|
   |  |                   |                |                  |                    |        |FILE      |
   |  +-------------------+----------------+------------------+--------------------+--------+----------+   
   |    
   |  remarks : 
   |     1/ do not use this api to print big tables
   |     2/ you will probably want to change output for yours table. Then make a copy of showTable procedure in you package and modify procedure wout inside it.
   |        in this case remember to replace "Xxmsz_Tools" with your package name in line Xxmsz_Tools.showTable (ptableDef);   
   |
   \*-----------------------------------------------------------------------------------------------------------------------------*/
   
  type tcolumnDef is record (width number                   
                           , allign varchar2(30) --left/right/middle
                           , autowidth char(1) default 'Y' --N = noautowidth
                           ); 
  type tTableRows is  table  of varchar2(5000) index  by  binary_integer;
  type tTableWidths is  table  of tcolumnDef index  by  binary_integer;  
  type tTableDef is record (
          tableWidths      tTableWidths
         ,tableRows        tTableRows
         ,ColumnCount      number
   ,tokenSeparator   varchar2(1)
       );
 procedure addHeader (ptableDef in out nocopy tTableDef, ptableRow varchar2, pcolWidths varchar2 default null, palligns varchar2 default null, ptokenSeparator varchar2 default '|');
 procedure addLine   (ptableDef in out nocopy tTableDef, ptableRow varchar2);
 procedure showTable (ptableDef in out nocopy xxmsz_tools.tTableDef);
 procedure destroy   (ptableDef in out nocopy tTableDef);
 
  -- *********************************************************************************
  -- * String - business opnerations
  -- *********************************************************************************
  function amountInWords(aamount number, language_code varchar2 default 'PL', currency_code1 varchar2 default 'zl', acurrency_code2 varchar2 default 'gr') return varchar2;
  -- zwraca kwote slownie w jezyku okreslonym przez paramert language_code (PL/END)
  function strToDate( p_dat varchar2) return date;
  -- konwertuje string na date, dopasowujac odpowiednia maske formatu
  function peselIsOK ( PESEL  varchar2 ) return  varchar2;
  -- sprawdza PESEL i zwraca Y/N
  function nipIsOk ( NIP  varchar2 ) return  varchar2;
  -- sprawdza NIP i zwraca Y/N
  function regonIsOk ( REGON  varchar2 ) return  varchar2;
  -- sprawdza REGON (9- lub 14-znakowy )i zwraca Y/N
  function emailIsOk ( EMAIL  varchar2 ) return  varchar2;
  -- sprawdza poprawnosc EMAIL i zwraca Y/N
  function ynToBool ( S varchar2, resultIfEmpty boolean default false ) return boolean;
  -- konwertuje wartosc Str na bool
  function ynToYN ( S varchar2, resultIfEmpty varchar2 default 'N' ) return char;
  -- konwertuje wartosc Str na ('N','Y')
  -- np. select xxmsz_tools.ynToYN ('Tak') from dual -> Y
  function boolToYN ( bool boolean, trueValue varchar2 default 'Y', falseValue varchar2 default 'N' ) return varchar2;
  -- konwertuje wartosc bool na Str
  function getIBANcheckDigits (acc varchar2 ) return varchar2;
  -- zwraca cyfry kontrolne CC na konta w formacie IBAN CC88888888aaaabbbbddddeeee
  function formatIBAN ( inS varchar2, numberOfSignsInSection number default 4, formatOnlyWhenDivisible varchar2 default 'N' ) return varchar2;
  -- formatuje rachunek bankowy do postaci iban ( cc88888888aaaabbbbccccdddd -> cc 88888888 aaaa bbbb cccc dddd )
  function formatNIP  ( inS varchar2 ) return varchar2;
  -- formatuje ciag do postaci 999-999-99-99 jesli nie zawiera myslników w przyciwnym wypadku zwracany jest ciag oryginalny
  --  select xxmsz_tools.formatNIP('9441733423') from dual --> 944-173-34-23
  --  select xxmsz_tools.formatNIP('944-17-33-423') from dual --> 944-17-33-423
  --  select xxmsz_tools.formatNIP('9-4-4-1-7-3-3-4-2-3') from dual --> 9-4-4-1-7-3-3-4-2-3

  -- *********************************************************************************
  -- *  Log
  -- *********************************************************************************

  /*
  Aby korzystac z funkcji dziennia zdarzen, nalezy utworzyc nastepujace: tabele i sekwencje.
  Dziennik zdarzen jest wspolny dla wielu aplikacji - uzyj kwalifikatora hierarchicznego dla rozróznienia, które komunikaty dotycza której aplikacji - zob. pole moduleName

   drop sequence xxmsztools_eventlog_seq;
   drop table xxmsztools_eventlog;

   create sequence xxext.xxmsztools_eventlog_seq;

   create table xxext.xxmsztools_eventlog (
     id number(11)
 ,module_name   varchar2(200)
 ,message       varchar2(200)
 ,message_type  varchar2(10)
 ,created       date default sysdate
   );


   create synonym xxmsztools_eventlog_seq for xxext.xxmsztools_eventlog_seq;

   create synonym xxmsztools_eventlog for xxext.xxmsztools_eventlog;

   CREATE INDEX XXMSZTOOLS_EVENTLOG_I1 ON xxext.XXMSZTOOLS_EVENTLOG (ID);

   CREATE INDEX XXMSZTOOLS_EVENTLOG_I2  ON xxext.XXMSZTOOLS_EVENTLOG (module_name);

  */

  moduleNameForEventLog  varchar2(400);

  procedure setModuleName ( moduleName varchar2 );
  -- ustawia nazwe modulu ( zob. opis parametru moduleName w procedurze insertIntoEventLog )
  procedure pushModuleName ( moduleName varchar2 );
  -- dodaje nowy czlon do nazwy modulu - zwykle wywolywane na poczatku procedury
  procedure popModuleName;
  -- usuwa czlon z nazwy modulu - zwykle wywolywane przed wyjsciem z procedury
  procedure insertIntoEventLog ( message varchar2, messageType varchar2 default 'I', moduleName varchar2 default 'XXMSZTOOLS', writeMessage varchar2 default 'Yes', raiseExceptions varchar2 default 'No');
  /* dodaje wiersz do tabeli xxmsztools_eventlog
     message         komunikat do zapisania
     messageType     typ komunikatu : I=Info E=Error W=Warning
     moduleName      hierarchiczne okresenie miejsce wywolania. Czlony rozdzielone kropka np Package001.WYDRUK_FAKTURY.FETCH_INVOICES.FETCH_INVOICE
                     jezeli chcesz zapisac nazwe pakietu oraz numer linii, to w module name wpisz : Xxmsz_Tools.extractword( 4, dbms_utility.format_call_stack, CHR(10))
                      stos bledów: sqlerrm || dbms_utility.format_error_backtrace
     writeMessage    flaga okreslajaca, czy dodac rekord ( moze np. byc sterowana zmienna okreslajaca, czy prowadzic sledzenie )
     raiseExceptions wywolaj wyjatek w razie, gdy nie powiedzie sie wstawienie rekordu do dzienika zdarzen

     JEzELI KORZYSTASZ Z EBS, TO MOzESZ TAKzE UzYc NASTEPUJACEJ FUNKCJI:
     procedure fnd_transaction.debug_info(function_name in varchar2,
                       action_name   in varchar2,
                       message_text  in varchar2,
                       s_type        in varchar2 default 'C');
    Ta funkcja lepiej identyfikuje sesje, ale nie pozwala na tworzenie hierarchicznego logu
    select * from fnd_concurrent_debug_info order by time_in_number
    begin fnd_transaction.debug_info('test','test','t est'); end;
  */

 -- workflow version of previous procedure
 -- parameters: MESSAGE
 -- commented due to ensure platform-independent form of this package
 --procedure insertIntoEventLog ( itemtype  in     varchar2, itemkey   in     varchar2, actid     in     number, funcmode  in     varchar2, result    out    varchar2);

  -- do debugowania polecen select
  -- wartosci pobierz za pomoca zapytania select * from xxmsztools_eventlog where module_name like 'insertIntoEventLog%' order by id
  function insertIntoEventLog (pdate date, pvalue varchar) return varchar2;

  -- *********************************************************************************
  -- * Inne operacje
  -- *********************************************************************************
  function startOfTime return date;
  function endOfTime return date;
  
  function replaceXMLchars (buffer in varchar2) return varchar2;
  --zmienia niedozwolone znaki XML na kody
  --wiecej na ten temat w Wikipedii i http://www.kurshtml.boo.pl/generatory/unicode.html
  
  function strToAsc ( strString varchar2 ) return varchar2;
  -- konwertuje ciag znaków do ciagu znaków ascii
  -- np. select strToAsc('przykladowy tekst') from dual ->  112,114,122,121,107,179,97,100,111,119,121,32,116,101,107,115,116
  function AscToStr ( ascString varchar2 ) return varchar2;
  -- konwertuje ciag znaków ascii do ciagu znaków
  -- np. select asctostr('112,114,122,121,107,179,97,100,111,119,121,32,116,101,107,115,116') from dual -> przykladowy tekst
  function extractFileName(S  in varchar2)  return varchar2;
  -- wyodrebnia ze sciezki nazwe pliku
  --     np. ExtractFileName('c:\Program Files\Joasia.xls') -> Joasia.xls
  function extractPath (S  in varchar2)  return varchar2;
  -- wyodrebnia ze sciezki sciezke bez nazwy pliku
  --     np. ExtractFileName('c:\Program Files\Joasia.xls') -> c:\Program Files\
  function getBanknotes( wydaj varchar2 ) return varchar2;
  -- zwraca kwote w banknotach i bilonach
  function iif( cond boolean, val1 varchar2, val2 varchar2 ) return varchar2;
  function iif( cond boolean, val1 number, val2 number ) return number;
  function iif( cond boolean, val1 date, val2 date ) return date;
  -- zwraca str1 jesli cond, w przeciwnyym przypadku zwraca str2
  -- funkcja uzyteczna przy formatowaniu warunkowym
  procedure dbms_outputPut_line (
      str         in   varchar2,
      len         in   integer := 254,
      expand_in   in   boolean := true
   );
   -- wykonuje dbms_output.put_line dzielac ciag znakow na podlancuchy o dlugosci len
   -- w razie potrzeby rozszerza bufor za pomoca polecenia dbms_output.enable

  -- extension of nvl
  function extnvl (
   v1 varchar2,v2 varchar2,v3 varchar2 default null,v4 varchar2 default null,v5 varchar2 default null
  ,v6 varchar2 default null,v7 varchar2 default null,v8 varchar2 default null,v9 varchar2 default null,v10 varchar2 default null
  ,v11 varchar2 default null,v12 varchar2 default null,v13 varchar2 default null,v14 varchar2 default null,v15 varchar2 default null
  ,v16 varchar2 default null,v17 varchar2 default null,v18 varchar2 default null,v19 varchar2 default null,v20 varchar2 default null
  ) return varchar2;   
   
  function extnvl (
   v1 number,v2 number,v3 number default null,v4 number default null,v5 number default null
  ,v6 number default null,v7 number default null,v8 number default null,v9 number default null,v10 number default null
  ,v11 number default null,v12 number default null,v13 number default null,v14 number default null,v15 number default null
  ,v16 number default null,v17 number default null,v18 number default null,v19 number default null,v20 number default null
  ) return number;   

    function extnvl (
   v1 date,v2 date,v3 date default null,v4 date default null,v5 date default null
  ,v6 date default null,v7 date default null,v8 date default null,v9 date default null,v10 date default null
  ,v11 date default null,v12 date default null,v13 date default null,v14 date default null,v15 date default null
  ,v16 date default null,v17 date default null,v18 date default null,v19 date default null,v20 date default null
  ) return date;   


  -- *********************************************************************************
  -- * passing parameters between sessions
  -- *********************************************************************************

  -- przykladowe zastosowanie:przekazanie parametru do okna zlecen wspolbieznych
  -- Do okna zlecen wspolbieznych parametrow nie mozna przekazac wprost, ale mozna nadac im wartosci domyslne.
  /*
   przyklad uzycia procedur setParameter, getparameter

   BEGIN
     Xxmsz_Tools.setParameter (Fnd_Profile.value('user_id'), 'PARAM1', 'PARAM1_VALUE');
     Xxmsz_Tools.setParameter (Fnd_Profile.value('user_id'), 'PARAM2', 'PARAM2_VALUE');
     Xxmsz_Tools.setParameter (Fnd_Profile.value('user_id'), 'PARAM2', 'PARAM2_VALUE_NOWA');
   END;

   SELECT Xxmsz_Tools.getParameter (Fnd_Profile.value('user_id'), 'PARAM1') FROM dual
   -- wynik: PARAM1_VALUE

   SELECT Xxmsz_Tools.getParameter (Fnd_Profile.value('user_id'), 'PARAM1') FROM dual
   -- wynik: null

   SELECT Xxmsz_Tools.getParameter (Fnd_Profile.value('user_id'), 'PARAM2') FROM dual
   -- wynik: PARAM2_VALUE_NOWA

   SELECT Xxmsz_Tools.getParameter (Fnd_Profile.value('user_id'), 'PARAM2') FROM dual
   -- wynik: null
   */

  -- procedura skladuje wartosc value parametru o nazwie paramName w kontekscie okreslonego uzytkownika userId
  -- kolejne wywolanie procedury powoduje nadpisanie poprzedniej wartosci
  procedure setParameter ( userId varchar2, paramName varchar2, value varchar2 );
  -- procedura pobiera parametr
  -- kolejne wywolanie funkcji spowoduje zwrocenie wartosci pustej
  function getParameter (userId varchar2, paramName varchar2) return varchar2;


  -- *********************************************************************************
  -- * formatowanie skladni dla SQL
  -- *********************************************************************************
  valueWhenEmpty varchar2(100) := 'NULL';

  function getSQLValues(SQLText varchar2, valueWhenEmpty varchar2 default null,exceptifempty char default 'N', Sep varchar2 default ', ', maxsizeofres number default 30000) return varchar2;
  -- zwraca wynik zapytania z pierwszej kolumny rozdzielony znakami Sep (dla wygody stosuj znak ^ zamiast ')
  --     np. XXMSZ_TOOLS.GetSQLValues ( 'select column_name from sys.all_tab_columns where table_name = ^ALL_OBJECTS^ and owner = ^SYS^ order by column_name' ) -> OWNER|OBJECT_NAME| itd.
  function getSQLValue(SQLText varchar2, valueWhenEmpty varchar2 default null,exceptifempty char default 'Y') return varchar2;
  -- zwraca wartosc zapytania z pierszego wiersza z pierwszej kolumny
  FUNCTION getSQLV(SQLText VARCHAR2, exceptifempty CHAR, Sep VARCHAR2 DEFAULT '|', maxsizeofres NUMBER DEFAULT 30000, singlevaluemode BOOLEAN) RETURN VARCHAR2;

  -- ponizej funkcje przeksztalace dane do postaci akceptowanej przez polecenia DML
  function formatDate(Word varchar2, format varchar2 default 'YYYY-MM-DD') return varchar2;
  function formatDateTime(Word varchar2) return varchar2;
  function formatFloat(Word varchar2) return varchar2;
  function formatString(Word varchar2) return varchar2;
  function buildCondition ( FIELDTYPE varchar2, FIELD_NAME varchar2, VALUE1 varchar2, VALUE2 varchar2 default null  ) return varchar2;
  -- Buduje warunek WHERE np.:
  -- xxmsz_tools.buildCondition('NUMBER','NO','1')                      --> NO = 1
  -- xxmsz_tools.buildCondition('VARCHAR2','NO','1')                    --> NO = '1'
  -- xxmsz_tools.buildCondition('VARCHAR2','NO','1%')                   --> NO LIKE '1%'
  -- xxmsz_tools.buildCondition('VARCHAR2','NO','A', 'B')               --> NO BETWEEN 'A' AND 'B'
  -- xxmsz_tools.buildCondition('DATE','NO','2004.12.12', '2004.12.12') --> NO BETWEEN TO_DATE('2004.12.12','yyyy-mm-dd') AND TO_DATE('2004.12.12','yyyy-mm-dd')
  -- xxmsz_tools.buildCondition('DATE','NO', NULL)                      --> NULL ( w szczególnosci funkcja nie zwróci NO IS NULL )
  -- daty musza byc przekazane w formacie yyyy-mm-dd

  -- Implemantacja stosu - w trakcie opracowywania
  type tStrStack is record (
   Elements      varchar2(100),
   COUNT         number
  );

  -- Uruchamia dowolne polecenie SQL. W wyzwalaczach nie mozna uzyc wprost EXECUTE IMMEDIATE
  procedure executeImmediate (SQL_STATEMENT varchar2);


  -- ***********************************************************************************
  -- * Zastosowanie procedur przedstawionych ponizej:
  -- *  - Zliczanie kwot wg róznych stawek podatku vat, walut itd. (zob. wydruk fakury)
  -- *  - Wyznaczanie poczatkowego i koncowego numeru strony ( zob. pakiet wzorcowy plsqlrep)
  -- *
  -- *  przykladowy skrypt:
  -- *  declare
  -- *        SumTotal               xxmsz_tools.TAmounts;
  -- *  begin
  -- *    xxmsz_tools.AmountsInit ( SumTotal          , xxmsz_tools.giAdd );
  -- *    xxmsz_tools.AmountsAdd  ( SumTotal          ,  '7%', 10, 20, 30);
  -- *    xxmsz_tools.AmountsAdd  ( SumTotal          ,  '7%', 10, 20, 30);
  -- *    xxmsz_tools.AmountsAdd  ( SumTotal          ,  '7%', 10, 20, 30);
  -- *    xxmsz_tools.AmountsAdd  ( SumTotal          , '22%', 10, 20, 30);
  -- *    xxmsz_tools.AmountsAdd  ( SumTotal          , '22%', 10, 20, 30);
  -- *    amountsGetExample2      ( SumTotal );
  -- *  end;
  -- *
  -- *  wynik dzialania przykladowego skryptu:
  -- *
  -- *  7%    30  60  90
  -- *  22%   20  40  60
  -- *  ================
  -- *  TOTAL 50 100 150
  -- ***********************************************************************************

  -- poniewaz w PLSQL nie mozna programowac obiektowo, udostepniane sa ponizsze typy i procedury uzywajace tych typow
   giAdd integer := 0; -- gi = group function information
   giMax integer := 1;
   giMin integer := 2;

   type tTAmounts         is  table  of  number        index  by  binary_integer;
   type tTGroupIndicators is  table  of  varchar2(100) index  by  binary_integer;
   type tAmounts is record (
       amounts1        TTAmounts,         -- kolumna 1 do zsumowania np. wartosc netto
       amounts2        TTAmounts,         -- kolumna 2 do zsumowania np. kwota vat
       amounts3        TTAmounts,         -- kolumna 3 do zsumowania np. wartosc brutto
       amounts4        TTAmounts,         -- kolumna 4 do zsumowania np. wartosc brutto bez rabatu
       amounts5        TTAmounts,         -- kolumna 5 do zsumowania np. wartosc netto w przeliczeniu na EUR
       amounts6        TTAmounts,         -- kolumna 6 do zsumowania np. wartosc vat w przeliczeniu na EUR
       amounts7        TTAmounts,         -- kolumna 7 do zsumowania
       amounts8        TTAmounts,         -- kolumna 8 do zsumowania
    groupIndicators TTGroupIndicators, -- wskaznik grupowania, np. stawka vat albo waluta
       COUNT  integer,
    groupOperator integer -- giAdd   (default) : AmountsAdd dodaje wartosci
                          -- giMax             : AmountsAdd oznacza max
        -- giMin             : jw min
     );
   procedure amountsInit (Amounts in out nocopy tAmounts, agroupOperator integer default 0);
   procedure amountsAdd(Amounts in out nocopy tAmounts, aGroupIndicator varchar2, amount1 number, amount2 number default 0, amount3 number default 0, amount4 number default 0, amount5 number default 0, amount6 number default 0, amount7 number default 0, amount8 number default 0);
   -- W PLSQL nie ma typu proceduralnego... skopiuj zatem AmountsGet z dostosuj do wlasnych potrzeb
   procedure amountsGetExample1(Amounts in out nocopy tAmounts);
   -- wyswietla kwoty dla poszczegolnych wskaznikow grupowania, w tym total
   procedure amountsGetExample2(Amounts in out nocopy tAmounts);
   -- wyswietla kwoty dla poszczegolnych wskaznikow grupowania oraz - o ile liczba wskaznikow grupowania >1 , rowniez total
   function amountsGetByIndicator(amounts in out nocopy tAmounts, aGroupIndicator varchar2, amountIndex number) return number;

   /*****************************************************************************************************************************
   |* Konwersje
   \*****************************************************************************************************************************

    /*
    Funkcja konwertuje typ long do typu varchar2
    Uwaga: Jezeli zmienna typu long jest dluzsza niz 4000 znaków, to jest obcianana do 4000 znaków ( z powodu ograniczen sql )
    Przykladowe zapytanie ( zapewnia wyszykowanie widoków wg ich definicji ):

    select xxmsz_tools.long2varchar('select text from all_views where owner = :owner and view_name = :view_name', 'owner',v.owner,'view_name',v.view_name) text
          ,v.view_name, v.text_length, o.status, v.type_text, v.oid_text, v.view_type_owner, v.view_type, superview_name
    from all_views v, all_objects o
    where v.owner = o.owner
    and o.object_type = 'VIEW'
    and v.view_name = o.object_name
    and upper(o.owner) like 'APPS'
    and upper(v.view_name) like  'AP_INVOICES_V'
    and upper(xxmsz_tools.long2varchar('select text from ALL_VIEWS where owner = :owner and view_name = :view_name', 'owner',v.owner,'view_name',v.view_name)) like upper('%%')
    order by  xxmsz_tools.long2varchar('select text from ALL_VIEWS where owner = :owner and view_name = :view_name', 'owner',v.owner,'view_name',v.view_name)
    */
    function long2varchar( p_query  in varchar2,
                               p_name1   in varchar2 default null,
                               p_value1  in varchar2  default null,
                               p_name2   in varchar2 default null,
                               p_value2  in varchar2  default null,
                               p_name3   in varchar2 default null,
                               p_value3  in varchar2  default null,
                               p_name4   in varchar2 default null,
                               p_value4  in varchar2  default null
                              ) return varchar2;

  function getPeriodID(backlogInDays number, periodInterval number, maxBacklog number default -1000, maxBacklogText varchar2 default 'Pozostale', FutureText varchar2  default 'Biezace' ) return number;
  -- funkcja zwraca ID okresu, do którego wpada dzien zaleglosci
  -- na przyklad, gdy periodInterval = 5, to w zaleznosci od backlogInDays funkcja przyjmie nastepujace wartosci:
  -- backlogInDays : -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 ...
  -- getPeriodID   : <---- -2 -----> <----- -1 ---> <------- 0 ----------- ... -->
  function getPeriodName(backlogInDays number, periodInterval number, maxBacklog number default -1000, maxBacklogText varchar2 default 'Pozostale', FutureText varchar2  default 'Biezace' ) return varchar2;
  -- funkcja zwraca nazwe okresu, do którego wpada dzien zaleglosci
  -- na przyklad, gdy periodInterval = 5, to w zaleznosci od backlogInDays funkcja przyjmie nastepujace wartosci:
  -- backlogInDays : -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 ...
  -- getPeriodID   : <-- 10-6 -----> <---- 5-1 ---> <------- FutureText -- ... -->


  -- ***********************************************************************************************************************
  -- * funkcje przestarzale
  -- ***********************************************************************************************************************

  -- zob. funkcje greatest
  function maximum(
     number1  number   , number2  number   , number3  number default null   , number4  number default null   , number5  number default null
   , number6  number default null   , number7  number default null   , number8  number default null   , number9  number default null   , number10 number default null
   , number11 number default null   , number12 number default null   , number13 number default null   , number14 number default null   , number15 number default null
   , number16 number default null   , number17 number default null   , number18 number default null   , number19 number default null   , number20 number default null
   , number21 number default null   , number22 number default null   , number23 number default null   , number24 number default null   , number25 number default null
   , number26 number default null   , number27 number default null   , number28 number default null   , number29 number default null   , number30 number default null
  ) return number;

  -- zob. funkcje least
  function MINIMUM(
     number1  number   , number2  number   , number3  number default  null   , number4  number default  null   , number5  number default  null
   , number6  number default  null   , number7  number default  null   , number8  number default  null   , number9  number default  null   , number10 number default  null
   , number11 number default  null   , number12 number default  null   , number13 number default  null   , number14 number default  null   , number15 number default  null
   , number16 number default  null   , number17 number default  null   , number18 number default  null   , number19 number default  null   , number20 number default  null
   , number21 number default  null   , number22 number default  null   , number23 number default  null   , number24 number default  null   , number25 number default  null
   , number26 number default  null   , number27 number default  null   , number28 number default  null   , number29 number default  null   , number30 number default  null
  ) return number;

  -- zob. funkcja wordWrap
  function wordWrap( wrappedString varchar2, columnWidth number, getTokenNr number default 0, completeWithSpaces boolean default true, TokenSeparator varchar2 default '|') return varchar2;
  
  -- zob. erasePolishChars
  function withoutPolishSigns (S in varchar2) return varchar2;
  function erasePolishHooks(S varchar2) return varchar2;
  
  function get_primary_key( p_owner varchar2, p_table_name varchar2 ) return varchar2;
  
  -- Zwraca wszystkie przeszukiwalne kolumny podanej tabeli, w ten sposób mozna przeszukac zawartosc calej bazy danych np tak 
  --  select * from ( XXX) where upper(cols) like '%ANY TEXT%', gdzie XXX
  --  select 'select '||xxmsz_tools.allTableColumns (table_name)||' vals, '''||table_name||''' tname from '||table_name||' union all '  from all_tables where owner = 'CWDATA'      
  function allTableColumns (pTableName varchar2, pColumNameFilter varchar2 default '%') return varchar2;
  
  
  -- Function allows to delete record from master table even it has child records
  -- BE AWARE ! THIS FUNCTION WORKS FINE UDER CONDITION THERE ARE CONTRAINTS IN DATABASE
  -- example call: 
  --    begin xxmsz_tools.merge_records('CWDATA','CWF_D_SALES_STRUCTURES','116','1002837','ID'); commit; end;  
  --    this will perform      update child_table set <child_table_column> =  1002837 where <child_table_colulm> = 116   for all child records and then
  --                           delete from CWDATA.CWF_D_SALES_STRUCTURES where id = 116  
  procedure merge_records(pOwner  varchar2, pTable_Name varchar2, pOldId varchar2, pNewId varchar2, pkColumn varchar2);
  
  -- silimar to merge_records, updates record from oldId to NewId
  -- begin xxmsz_tools.update_record('CWDATA','CWF_D_CURRENCIES','PLN','XXX','CURRENCY_CODE'); commit; end;   
  procedure update_record(pOwner  varchar2, pTable_Name varchar2, pOldId varchar2, pNewId varchar2, pkColumn varchar2);
  procedure enable_constraints(pOwner varchar2, pTable_Name varchar2, pkColumn varchar2);
  procedure disable_constraints(pOwner varchar2, pTable_Name varchar2, pkColumn varchar2);
  
  
  -- clob faciliates  
  Procedure NewClob  (clobloc       in out nocopy clob, msg_string    in varchar2);
  procedure WriteToClob  ( clob_loc      in out nocopy clob,msg_string    in  varchar2);
  
  function getAbbreviation ( s varchar2 ) return varchar2;

end;
/

create or replace package body Xxmsz_Tools as

  -- key must be exactly 8 bytes long
  c_encrypt_key varchar2(8) := 'key45678';

  fopDocumentId          varchar2(100);
  fopCurrentBorderStyle  varchar2(20);
  fopTableBodyFirstEntry boolean;
  --fopFileHandler         utl_file.file_type;
  fopOutputType          varchar2(20); -- file, xxmsztools_eventlog
  fopCharsDelimiter      char;

  c_start_of_time constant date := to_date ('01/01/0001','DD/MM/YYYY');
  c_end_of_time   constant date := to_date ('31/12/4712','DD/MM/YYYY');

 ---------------------------------------------------------------------------------------------------------------------------------------------------------


 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function iif( cond boolean, val1 varchar2, val2 varchar2 ) return varchar2 is
  begin
    if cond then return val1;
    else return val2; end if;
  end;
  function iif( cond boolean, val1 number, val2 number ) return number is
  begin
    if cond then return val1;
    else return val2; end if;
  end;
  function iif( cond boolean, val1 date, val2 date ) return date is
  begin
    if cond then return val1;
    else return val2; end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function center (S varchar2, LEN number) return varchar2 is
    L number;
    SPACES varchar2(500);
  begin
    L := ROUND ( (LEN -  LENGTH(S))  / 2 );
    SPACES := SUBSTR('                                                                                                           ',1,L);
    return SUBSTR( SPACES || S || SPACES, 1, len );
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
   function extractWord  (poz number, words varchar, sep varchar := '|') return varchar is
     word varchar2(5000):='';
     word2 varchar2(5000);
     str2 varchar2(5000):= words || sep;
   begin
     for i in 1..poz loop
      if i = 1 then
       word:=SUBSTR(str2,1,INSTR(str2,sep,poz)-1);
       word2:=str2;
      else
       word2 := SUBSTR(word2,LENGTH(word2)+2-LENGTH(SUBSTR(word2,INSTR(word2,sep,1))));
       word  := SUBSTR(word2,1,INSTR(word2,sep,1)-1);
      end if;
     end loop;
     return Word;
   end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function wordCount(  Words      varchar2,
                       Separator  in     varchar2 := '|') return number is
    N       number(9);
    Counter number(9);
    temp   varchar2(30000);
  begin
   temp := words;
   counter := 0;
   for n in 1..LENGTH(temp) loop
     if SUBSTR(temp,n,1) = separator then
       counter := counter + 1;
     end if;
   end loop;

   return counter+1;
  exception
   when OTHERS then
    return 0;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function replaceWord(poz number, replaceWith varchar2, words varchar, sep varchar := '|') return varchar2 is
    res varchar2(32000) := null;
    numberOfWords number(10);
  begin
    numberOfWords := wordCount(Words, Sep);
    if numberOfWords < poz then
     raise_application_error(-20000,'invalid poz parameter: cant be greather than numerOfWords');
    end if;
   for i in 1..numberOfWords loop
     if i <> poz then  res := merge(res,extractWord(i,Words,sep),sep);
                 else  res := merge(res,replaceWith,sep); end if;
   end loop;
   return res;
  end;

  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getTokenByName ( tokens varchar2, tokenName varchar2, tokenSeparator varchar2) return varchar2 is
   res        varchar2(32000);
   vtokens    varchar2(32000);
   vtokenName  varchar2(32000);
  begin
    -- @ is an identifier of start of token
    -- 'BIK_CREATED_BY_LOGIN=12;CREATED_BY_LOGIN=11' ---> ';@BIK_CREATED_BY_LOGIN=12;@CREATED_BY_LOGIN=11;@'
    vtokens    := replace ( tokenSeparator || tokens || tokenSeparator, tokenSeparator, tokenSeparator||'@' );
    vtokenName := '@'||tokenName; 
    select to_char( substr (vtokens,
                            instr (vtokens, vtokenName),
                              instr (vtokens,
                                     tokenSeparator,
                                     instr (vtokens, vtokenName)
                                    )
                            - instr (vtokens, vtokenName)
                           ))
    into res
    from dual;
    return substr(res,2,65000);
  end;
  
  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function pushLastWord(pushWord varchar2, words varchar2, sep varchar := '|') return varchar2 is --polóz
  begin
    return Xxmsz_Tools.merge(words, pushWord, sep);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function popLastWord(words varchar2, sep varchar := '|') return varchar2 is --zabierz
    res varchar2(32000) := null;
 numberOfWords number(10);
  begin
    numberOfWords := wordCount(Words, Sep);
 if numberOfWords < 1 then
  RAISE_APPLICATION_ERROR(-20000,'words is empty - cannot pop word');
 end if;
    for i in 1..numberOfWords-1 loop
   res := merge(res,extractWord(i,Words,sep),sep);
 end loop;
 return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function amountInWords(aamount number, language_code varchar2 default 'PL', currency_code1 varchar2 default 'zl', acurrency_code2 varchar2 default 'gr') return varchar2 is
    Wart    varchar2(2000);
    currency_code2 varchar2(10);
    amount  number := ROUND ( aamount, 2); -- np. 11.115 -> 11.12 ( if you would like to receive 11.11 call trunc(., 2) function before using AmountInWord


      function engAmountInWordsA(amount number, language_code varchar2 default 'PL', currency_code1 varchar2 default 'zl', currency_code2 varchar2 default 'gr') return varchar2 is
        liczba  number(12,2);
        pom     number;
        sl      varchar(20);
        out     varchar(1000);
        nascie  number;
        tys     number;

        type titem is record (
         SLOWO1 varchar2(20)
        ,SLOWO2 varchar2(20)
        ,SLOWO3 varchar2(20)
        ,WORD1  varchar2(20)
        ,WORD2  varchar2(20)
        ,WORD3  varchar2(20)
        );
        type TT_LICZBY_SLOWA is table of titem index by binary_integer;
        T_LICZBY_SLOWA TT_LICZBY_SLOWA;

      begin
        T_LICZBY_SLOWA (0).SLOWO1 :='zero ';    T_LICZBY_SLOWA (0).SLOWO2 :=' ';                  T_LICZBY_SLOWA (0).SLOWO3 :=' ';             T_LICZBY_SLOWA (0).WORD1 :='zero ';  T_LICZBY_SLOWA (0).WORD2 :='';             T_LICZBY_SLOWA (0).WORD3 :='';
        T_LICZBY_SLOWA (1).SLOWO1 :='jeden ';   T_LICZBY_SLOWA (1).SLOWO2 :='';                   T_LICZBY_SLOWA (1).SLOWO3 :='sto ';          T_LICZBY_SLOWA (1).WORD1 :='one ';   T_LICZBY_SLOWA (1).WORD2 :='';             T_LICZBY_SLOWA (1).WORD3 :='one hundred ';
        T_LICZBY_SLOWA (2).SLOWO1 :='dwa ';     T_LICZBY_SLOWA (2).SLOWO2 :='dwadziescia ';       T_LICZBY_SLOWA (2).SLOWO3 :='dwiescie ';     T_LICZBY_SLOWA (2).WORD1 :='two ';   T_LICZBY_SLOWA (2).WORD2 :='twenty ';      T_LICZBY_SLOWA (2).WORD3 :='two hundred ';
        T_LICZBY_SLOWA (3).SLOWO1 :='trzy ';    T_LICZBY_SLOWA (3).SLOWO2 :='trzydziesci ';       T_LICZBY_SLOWA (3).SLOWO3 :='trzysta ';      T_LICZBY_SLOWA (3).WORD1 :='three '; T_LICZBY_SLOWA (3).WORD2 :='thirty ';      T_LICZBY_SLOWA (3).WORD3 :='three hundred ';
        T_LICZBY_SLOWA (4).SLOWO1 :='cztery ';  T_LICZBY_SLOWA (4).SLOWO2 :='czterdziesci ';      T_LICZBY_SLOWA (4).SLOWO3 :='czterysta ';    T_LICZBY_SLOWA (4).WORD1 :='four ';  T_LICZBY_SLOWA (4).WORD2 :='forty ';       T_LICZBY_SLOWA (4).WORD3 :='four hundred ';
        T_LICZBY_SLOWA (5).SLOWO1 :='piec ';    T_LICZBY_SLOWA (5).SLOWO2 :='piecdziesiat ';      T_LICZBY_SLOWA (5).SLOWO3 :='piecset ';      T_LICZBY_SLOWA (5).WORD1 :='five ';  T_LICZBY_SLOWA (5).WORD2 :='fifty ';       T_LICZBY_SLOWA (5).WORD3 :='five hundred ';
        T_LICZBY_SLOWA (6).SLOWO1 :='szesc ';   T_LICZBY_SLOWA (6).SLOWO2 :='szescdziesiat ';     T_LICZBY_SLOWA (6).SLOWO3 :='szesset ';      T_LICZBY_SLOWA (6).WORD1 :='six ';   T_LICZBY_SLOWA (6).WORD2 :='sixty ';       T_LICZBY_SLOWA (6).WORD3 :='six hundred ';
        T_LICZBY_SLOWA (7).SLOWO1 :='siedem ';  T_LICZBY_SLOWA (7).SLOWO2 :='siedemdziesiat ';    T_LICZBY_SLOWA (7).SLOWO3 :='siedemset ';    T_LICZBY_SLOWA (7).WORD1 :='seven '; T_LICZBY_SLOWA (7).WORD2 :='seventy ';     T_LICZBY_SLOWA (7).WORD3 :='seven hundred ';
        T_LICZBY_SLOWA (8).SLOWO1 :='osiem ';   T_LICZBY_SLOWA (8).SLOWO2 :='osiemdziesiat ';     T_LICZBY_SLOWA (8).SLOWO3 :='osiemset ';     T_LICZBY_SLOWA (8).WORD1 :='eight '; T_LICZBY_SLOWA (8).WORD2 :='eighty ';      T_LICZBY_SLOWA (8).WORD3 :='eight hundred ';
        T_LICZBY_SLOWA (9).SLOWO1 :='dziewiec ';T_LICZBY_SLOWA (9).SLOWO2 :='dziewiecdziesiat ';  T_LICZBY_SLOWA (9).SLOWO3 :='dziewiecset ';  T_LICZBY_SLOWA (9).WORD1 :='nine ';  T_LICZBY_SLOWA (9).WORD2 :='ninety ';      T_LICZBY_SLOWA (9).WORD3 :='nine hundred ';
        T_LICZBY_SLOWA (10).SLOWO1 :='';        T_LICZBY_SLOWA (10).SLOWO2 :='dziesiec ';         T_LICZBY_SLOWA (10).SLOWO3 :='';             T_LICZBY_SLOWA (10).WORD1 :='';      T_LICZBY_SLOWA (10).WORD2 :='ten ';        T_LICZBY_SLOWA (10).WORD3 :='';
        T_LICZBY_SLOWA (11).SLOWO1 :='';        T_LICZBY_SLOWA (11).SLOWO2 :='jedenascie ';       T_LICZBY_SLOWA (11).SLOWO3 :='';             T_LICZBY_SLOWA (11).WORD1 :='';      T_LICZBY_SLOWA (11).WORD2 :='eleven ';     T_LICZBY_SLOWA (11).WORD3 :='';
        T_LICZBY_SLOWA (12).SLOWO1 :='';        T_LICZBY_SLOWA (12).SLOWO2 :='dwanascie ';        T_LICZBY_SLOWA (12).SLOWO3 :='';             T_LICZBY_SLOWA (12).WORD1 :='';      T_LICZBY_SLOWA (12).WORD2 :='twelve ';     T_LICZBY_SLOWA (12).WORD3 :='';
        T_LICZBY_SLOWA (13).SLOWO1 :='';        T_LICZBY_SLOWA (13).SLOWO2 :='trzynascie ';       T_LICZBY_SLOWA (13).SLOWO3 :='';             T_LICZBY_SLOWA (13).WORD1 :='';      T_LICZBY_SLOWA (13).WORD2 :='thirteen ';   T_LICZBY_SLOWA (13).WORD3 :='';
        T_LICZBY_SLOWA (14).SLOWO1 :='';        T_LICZBY_SLOWA (14).SLOWO2 :='czternascie ';      T_LICZBY_SLOWA (14).SLOWO3 :='';             T_LICZBY_SLOWA (14).WORD1 :='';      T_LICZBY_SLOWA (14).WORD2 :='fourteen ';   T_LICZBY_SLOWA (14).WORD3 :='';
        T_LICZBY_SLOWA (15).SLOWO1 :='';        T_LICZBY_SLOWA (15).SLOWO2 :='pietnascie ';       T_LICZBY_SLOWA (15).SLOWO3 :='';             T_LICZBY_SLOWA (15).WORD1 :='';      T_LICZBY_SLOWA (15).WORD2 :='fifteen ';    T_LICZBY_SLOWA (15).WORD3 :='';
        T_LICZBY_SLOWA (16).SLOWO1 :='';        T_LICZBY_SLOWA (16).SLOWO2 :='szesnascie ';       T_LICZBY_SLOWA (16).SLOWO3 :='';             T_LICZBY_SLOWA (16).WORD1 :='';      T_LICZBY_SLOWA (16).WORD2 :='sixteen ';    T_LICZBY_SLOWA (16).WORD3 :='';
        T_LICZBY_SLOWA (17).SLOWO1 :='';        T_LICZBY_SLOWA (17).SLOWO2 :='siedemnascie ';     T_LICZBY_SLOWA (17).SLOWO3 :='';             T_LICZBY_SLOWA (17).WORD1 :='';      T_LICZBY_SLOWA (17).WORD2 :='seventeen ';  T_LICZBY_SLOWA (17).WORD3 :='';
        T_LICZBY_SLOWA (18).SLOWO1 :='';        T_LICZBY_SLOWA (18).SLOWO2 :='osiemnascie ';      T_LICZBY_SLOWA (18).SLOWO3 :='';             T_LICZBY_SLOWA (18).WORD1 :='';      T_LICZBY_SLOWA (18).WORD2 :='eighteen ';   T_LICZBY_SLOWA (18).WORD3 :='';
        T_LICZBY_SLOWA (19).SLOWO1 :='';        T_LICZBY_SLOWA (19).SLOWO2 :='dziewietnascie ';   T_LICZBY_SLOWA (19).SLOWO3 :='';             T_LICZBY_SLOWA (19).WORD1 :='';      T_LICZBY_SLOWA (19).WORD2 :='nineteen ';   T_LICZBY_SLOWA (19).WORD3 :='';

        /*Generacja slownego zapisu warosci*/
        nascie := 0;
        tys := 0;
        liczba := amount; --parametr wejsciowy

        if liczba >= 100000000 then
          tys := 1;
          pom := MOD (TRUNC (liczba / 100000000), 10);
          sl :=  T_LICZBY_SLOWA (pom).word3;
          out := CONCAT (out, sl);
          liczba := liczba - pom * 100000000;
        end if;

        if liczba >= 10000000 then
          tys := 1;
          pom := MOD (TRUNC (liczba / 10000000), 10);
          if pom > 1 then
            sl :=  T_LICZBY_SLOWA (pom).word2;
            out := CONCAT (out, sl);
          liczba := liczba - pom * 10000000;
          else
            pom := MOD (TRUNC (liczba / 1000000), 100);
            sl :=  T_LICZBY_SLOWA (pom).word2;
            nascie := 1;
            out := CONCAT (out, sl);
          liczba := liczba - pom * 1000000;
          end if;
        end if;

        if liczba >= 1000000 then
          tys := 1;
          pom := MOD (TRUNC (liczba / 1000000), 10);
          if pom = 1 then
            out := CONCAT (out, 'one million ');
            tys := 0;
          else
            sl :=  T_LICZBY_SLOWA (pom).word1;
            out := CONCAT (out, sl);
          end if;
          liczba := liczba - pom * 1000000;
        end if;

        if tys = 1 then
          out := CONCAT (out, 'millions ');
       tys := 0;
        end if;

        if liczba >= 100000 then
          tys := 1;
          pom := MOD (TRUNC (liczba / 100000), 10);
          sl :=  T_LICZBY_SLOWA (pom).word3;
          out := CONCAT (out, sl);
          liczba := liczba - pom * 100000;
        end if;

        if liczba >= 10000 then
          tys := 1;
          pom := MOD (TRUNC (liczba / 10000), 10);
          if pom > 1 then
              sl :=  T_LICZBY_SLOWA (pom).word2;
              out := CONCAT (out, sl);
            liczba := liczba - pom * 10000;
          else
            pom := MOD (TRUNC (liczba / 1000), 100);
            sl :=  T_LICZBY_SLOWA (pom).word2;
            nascie := 1;
            out := CONCAT (out, sl);
            liczba := liczba - pom * 1000;
          end if;
        end if;

        if liczba >= 1000 then
          tys := 1;
          pom := MOD (TRUNC (liczba / 1000), 10);
          if pom = 1 then
            out := CONCAT (out, 'one thousand ');
            tys := 0;
          else
            sl :=  T_LICZBY_SLOWA (pom).word1;
            out := CONCAT (out, sl);
          end if;
          liczba := liczba - pom * 1000;
        end if;

        if tys = 1 then
          out := CONCAT (out, 'thousands ');
       tys := 0;
        end if;

        if MOD (liczba, 1000) > 0 then
          pom := MOD (TRUNC (liczba / 100), 10);
          sl :=  T_LICZBY_SLOWA (pom).word3;
          out := CONCAT (out, sl);
          pom := MOD (TRUNC (liczba / 10), 10);
          nascie := 0;
          if pom <> 1 then
          sl :=  T_LICZBY_SLOWA (pom).word2;
          else
            nascie := 1;
            pom := MOD (TRUNC (liczba), 100);
            sl :=  T_LICZBY_SLOWA (pom).word2;
          end if;
          out := CONCAT (out, sl);
          if nascie = 0 and TRUNC (MOD (liczba, 10)) != 0 then
            pom := TRUNC (MOD (liczba, 10));
            sl :=  T_LICZBY_SLOWA (pom).word1;
            out := CONCAT (out, sl);
          end if;
        end if;
        out := out || currency_code1 || ' ';

        -- grosze
        out := out || MOD (liczba * 100, 100) || '/100 ';
        return out;
      end;

   --poprzednia wersja funkcji
   --Zalety tej wersji: obsluguje kwoty > 1000000000
   --Wady tej wersji:   nie odmienia wyrazow, tylko pisze w formacie one*two*three
      function engAmountInWordsB(amount number, language_code varchar2 default 'PL', currency_code1 varchar2 default 'zl', currency_code2 varchar2 default 'gr') return varchar2 is
        value  number;
        value1  number;
        value2  number;
        decimal number;
        i       number;
        S_SAY   varchar2(2000);
        ratunek number;
      begin
        ratunek := 1;
        S_SAY:='';
        i:=10;
        decimal:=NVL(ABS(amount-TRUNC(amount)),0);
        value:=NVL(ABS(amount),0);
        loop
          value1:= TRUNC(value/i,1);
          value2:=(value1 - TRUNC(value1))*10;

          if value1=0 and value2*10=0 then S_SAY:=S_SAY || TO_CHAR(ROUND(decimal,2)*100) || '/100* ' || currency_code1; exit; end if;
          if ratunek = 100            then S_SAY:=S_SAY || TO_CHAR(ROUND(decimal,2)*100) || '0 / 100* ' || currency_code1; exit; end if;--ratunek
          if value2=1 then S_SAY:='one*' || S_SAY; end if;
          if value2=2 then S_SAY:='two*' || S_SAY; end if;
          if value2=3 then S_SAY:='three*' || S_SAY; end if;
          if value2=4 then S_SAY:='four*' || S_SAY; end if;
          if value2=5 then S_SAY:='five*' || S_SAY; end if;
          if value2=6 then S_SAY:='six*' || S_SAY; end if;
          if value2=7 then S_SAY:='seven*' || S_SAY; end if;
          if value2=8 then S_SAY:='eight*' || S_SAY; end if;
          if value2=9 then S_SAY:='nine*' || S_SAY; end if;
          if value2=0 then S_SAY:='zero*' || S_SAY; end if;
          i:=i*10;
          ratunek := ratunek + 1;
        end loop;
      return S_SAY;
      end;

    function slownie( L varchar2 ) return varchar2 is
     V varchar2( 1000 ) := '';
     V1 varchar2( 100 ) := '';

     R varchar2( 1000 );
     AKT varchar2( 3 );
     K integer := 0;
     STOP boolean := false;


            function LICZEBNIK(
                K number,
                L1 varchar2,
                L2 varchar2,
                L5 varchar2 )  return varchar2 is
            begin
                if K = 0 then
             return L5;
                elsif K = 1 then
             return L1;
                else
             if K > 10 and K < 20 then
                 return L5;
             else
                 declare
              CH varchar2( 40 );
              L  number;
                 begin
              CH := TO_CHAR ( K );
              L := TO_NUMBER ( SUBSTR( CH, NVL(LENGTH( CH ), 0) ) );
              if L = 0 or L = 1 then
                   return L5;
              elsif L > 1 and L < 5 then
                   return L2;
              else
                  return L5;
              end if;
                 end;
             end if;
                end if;
            return null; end;



            function SLOWNIE3( L varchar2 ) return varchar2 is
             V varchar2( 1000 ) :='';
             NASCIE varchar2( 1 ) := 'N';
            begin
             if NVL(LENGTH( L ), 0) > 2 then
              if SUBSTR( L, 1, 1 )  = '1' then
               V := 'sto ';
              elsif SUBSTR( L, 1 , 1 ) = '2' then
               V := 'dwiescie ';
                elsif SUBSTR( L,( 1 ), 1 ) = '3' then
               V := 'trzysta ';
                elsif SUBSTR( L,( 1 ), 1 ) = '4' then
               V := 'czterysta ';
                elsif SUBSTR( L,( 1 ), 1 ) = '5' then
               V := 'piecset ';
                elsif SUBSTR( L,( 1 ), 1 ) = '6' then
               V := 'szescset ';
                elsif SUBSTR( L,( 1 ), 1 ) = '7' then
               V := 'siedemset ';
                elsif SUBSTR( L,( 1 ), 1 ) = '8' then
               V := 'osiemset ';
                elsif SUBSTR( L,( 1 ), 1 ) = '9' then
               V := 'dziewiecset ';
              end if;
             end if;
             if NVL(LENGTH( L ), 0) > 1 then
              if SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '1' then
               NASCIE := 'T';
               if SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '0' then
                V := V || 'dziesiec ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '1' then
                V := V || 'jedenascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '2' then
                V := V || 'dwanascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '3' then
                V := V || 'trzynascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '4' then
                V := V || 'czternascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '5' then
                V := V || 'pietnascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '6' then
                V := V || 'szesnascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '7' then
                V := V || 'siedemnascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '8' then
                V := V || 'osiemnascie ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '9' then
                V := V || 'dziewietnascie ';
               end if;
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '2' then
               V := V || 'dwadziescia ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '3' then
               V := V || 'trzydziesci ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '4' then
               V := V || 'czterdziesci ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '5' then
               V := V || 'piecdziesiat ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '6' then
               V := V || 'szescdziesiat ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '7' then
               V := V || 'siedemdziesiat ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '8' then
               V := V || 'osiemdziesiat ';
              elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) - 1 ), 1 ) = '9' then
               V := V || 'dziewiecdziesiat ';
              end if;
             end if;
             if NVL(LENGTH( L ), 0) > 0 then
              if NASCIE = 'N' then
               if SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '1' then
                V := V || 'jeden ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '2' then
                V := V || 'dwa ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '3' then
                V := V || 'trzy ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '4' then
                V := V || 'cztery ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '5' then
                V := V || 'piec ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '6' then
                V := V || 'szesc ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '7' then
                V := V || 'siedem ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '8' then
                V := V || 'osiem ';
               elsif SUBSTR( L, ( NVL(LENGTH( L ), 0) ), 1 ) = '9' then
                V := V || 'dziewiec ';
               end if;
              end if;
              if NVL(LENGTH( L ), 0) = 1 and SUBSTR ( L, 1, 1 ) = '0' then
               V := 'zero ';
              end if;
             end if;
             return V;
            end;



    begin

     loop
      k := k + 1;
      if k > NVL(LENGTH( L ), 0) then
       exit;
      end if;
      if SUBSTR( L, K, 1 ) <> '0' then
          R := SUBSTR( L, K, NVL(LENGTH( L ), 0) - K + 1 );
          exit;
      end if;
     end loop;
     K := 0;
     loop
      if NVL(LENGTH( R ), 0) > 3 then
       AKT := SUBSTR( R, NVL(LENGTH( R ), 0)- 2 , 3 );
       R := SUBSTR( R, 1, NVL(LENGTH( R ), 0) - 3 );
       V1 := SLOWNIE3( AKT );
       K := K + 1;
      else
       STOP := true;
       AKT := R;
       R := '';
       V1 := SLOWNIE3( AKT );
       K := K + 1;
      end if;
      if NVL(LENGTH( V1 ), 0) > 1 then
       if K = 2 then
        V1 := V1 ||
         LICZEBNIK(
          TO_NUMBER( AKT ),
          'tysiac ',
          'tysiace ',
          'tysiecy ' );
       elsif K = 3 then
        V1 := V1 ||
         LICZEBNIK(
          TO_NUMBER( AKT ),
          'milion ',
          'miliony ',
          'milionów ' );
       elsif K = 4 then
        V1 := V1 ||
         LICZEBNIK(
          TO_NUMBER( AKT ),
          'miliard ',
          'miliardy ',
          'miliardów ' );
       elsif K = 5 then
        V1 := V1 ||
         LICZEBNIK(
          TO_NUMBER( AKT ),
          'bilion ',
          'biliony ',
          'bilionów ' );
       elsif K = 6 then
        V1 := V1 ||
         LICZEBNIK(
          TO_NUMBER( AKT ),
          'trylion ',
          'tryliony ',
          'trylionów ' );
       end if;
       V := V1 || V;
      end if;
      exit when STOP;
     end loop;
     return V;

    end;


  begin
    currency_code2 := acurrency_code2;
    if currency_code1 <> 'zl' and currency_code2 = 'gr' then
      currency_code2 := null;
    end if;

    if language_code <> 'PL' then
  if amount >= 1000000000 then
    return EngAmountInWordsB(amount, language_code, currency_code1, currency_code2);
  else
     return EngAmountInWordsA(amount, language_code, currency_code1, currency_code2);
  end if;

    end if;

 declare
  MinusHolder varchar2(1);
 begin
   MinusHolder := '';
      if amount < 0 then
    MinusHolder := '-';
   end if;

       Wart := slownie (TRUNC(ABS(amount))) || currency_code1 || ' ';
       -- tutaj dodaj grosze
       if TRUNC( ABS(amount), 2) - TRUNC( ABS(amount), 2)  >= 0 then
           Wart := Wart ||SUBSTR( TO_CHAR( TRUNC( ABS(amount), 2), '99999999999999999999.00' ), -2 ) ||'/100 ' || currency_code2;
       end if;
      return Merge ( MinusHolder, Wart);
 end;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function merge(S1 varchar2, S2 varchar2, SEP varchar2 default null) return varchar2 is
  begin
   if S1 is null then
      return S2;
   else
      if S2 is null then
       return S1;
      else
        return S1 || Sep || S2;
      end if;
   end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure addPercent ( V in out varchar2 ) is
  begin
    if INSTR(V, '%') = 0 or V is null then
      V := MERGE ( V, '%');
    end if;
  end;

  function strToDate
  ( p_dat varchar2 ) return date as
    v_dat varchar2(1000);
    v_buf date := null;

       function conv_date (p_string in varchar2)
       return date
       is
         type fmtArray is table of varchar2(30);
         g_fmts fmtArray := fmtArray (
                                      'YYYY-MM-DD'
                                     ,'YYYYMMDD'
                                     ,'YYYYMMDDHH24MI'
                                     ,'DD-MM-YY'
                                     ,'MON-DD-YY'
                                     ,'DD-MON-YYYY'
                                     ,'YYYY/MM/DD HH24:MI:SS'
                                     ,'D-M-YY'
                                     ,'YY-M-D'
                                     ,'M-D-YYYY'
                                     ,'M-DM-YY'
                                     ,'YY-D-M'
                                     ,'YYYY-D-M'
                                     ,'DDMMYYYY'
                                     ,'DDMMYY'
                                     ,'MMDDYYYY'
                                     ,'MMDDYY'
                                     ,'YYYY-M-D'
                                    );
          RETURN_VALUE date;
       begin
          for i in 1 .. g_fmts.count
          loop
             begin
                return_value := TO_DATE(p_string,g_fmts(i));
                exit;
             exception
                when OTHERS then null;
             end;
          end loop;

          if (return_value is null) then
             raise_application_error(-20000, 'Invalid date format : ' || p_string);
          end if;
          return return_value;
      end;

  begin
    v_dat := UPPER(p_dat);
    if v_dat is not null then
      if INSTR(v_dat,'STY')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'STY')-1)||'01'||SUBSTR(v_dat,INSTR(v_dat,'STY')+3);
      end if;
      if INSTR(v_dat,'LUT')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'LUT')-1)||'02'||SUBSTR(v_dat,INSTR(v_dat,'LUT')+3);
      end if;
      if INSTR(v_dat,'MAR')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'MAR')-1)||'03'||SUBSTR(v_dat,INSTR(v_dat,'MAR')+3);
      end if;
      if INSTR(v_dat,'KWI')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'KWI')-1)||'04'||SUBSTR(v_dat,INSTR(v_dat,'KWI')+3);
      end if;
      if INSTR(v_dat,'MAJ')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'MAJ')-1)||'05'||SUBSTR(v_dat,INSTR(v_dat,'MAJ')+3);
      end if;
      if INSTR(v_dat,'CZE')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'CZE')-1)||'06'||SUBSTR(v_dat,INSTR(v_dat,'CZE')+3);
      end if;
      if INSTR(v_dat,'LIP')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'LIP')-1)||'07'||SUBSTR(v_dat,INSTR(v_dat,'LIP')+3);
      end if;
      if INSTR(v_dat,'SIE')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'SIE')-1)||'08'||SUBSTR(v_dat,INSTR(v_dat,'SIE')+3);
      end if;
      if INSTR(v_dat,'WRZ')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'WRZ')-1)||'09'||SUBSTR(v_dat,INSTR(v_dat,'WRZ')+3);
      end if;
      if INSTR(v_dat,'PA')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'PA')-1)||'10'||SUBSTR(v_dat,INSTR(v_dat,'PA')+3);
      end if;
      if INSTR(v_dat,'LIS')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'LIS')-1)||'11'||SUBSTR(v_dat,INSTR(v_dat,'LIS')+3);
      end if;
      if INSTR(v_dat,'GRU')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'GRU')-1)||'12'||SUBSTR(v_dat,INSTR(v_dat,'GRU')+3);
      end if;
      if INSTR(v_dat,'JAN')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'JAN')-1)||'01'||SUBSTR(v_dat,INSTR(v_dat,'JAN')+3);
      end if;
      if INSTR(v_dat,'FEB')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'FEB')-1)||'02'||SUBSTR(v_dat,INSTR(v_dat,'FEB')+3);
      end if;
      if INSTR(v_dat,'MAR')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'MAR')-1)||'03'||SUBSTR(v_dat,INSTR(v_dat,'MAR')+3);
      end if;
      if INSTR(v_dat,'APR')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'APR')-1)||'04'||SUBSTR(v_dat,INSTR(v_dat,'APR')+3);
      end if;
      if INSTR(v_dat,'MAY')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'MAY')-1)||'05'||SUBSTR(v_dat,INSTR(v_dat,'MAY')+3);
      end if;
      if INSTR(v_dat,'JUN')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'JUN')-1)||'06'||SUBSTR(v_dat,INSTR(v_dat,'JUN')+3);
      end if;
      if INSTR(v_dat,'JUL')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'JUL')-1)||'07'||SUBSTR(v_dat,INSTR(v_dat,'JUL')+3);
      end if;
      if INSTR(v_dat,'AUG')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'AUG')-1)||'08'||SUBSTR(v_dat,INSTR(v_dat,'AUG')+3);
      end if;
      if INSTR(v_dat,'SEP')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'SEP')-1)||'09'||SUBSTR(v_dat,INSTR(v_dat,'SEP')+3);
      end if;
      if INSTR(v_dat,'NOV')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'NOV')-1)||'10'||SUBSTR(v_dat,INSTR(v_dat,'NOV')+3);
      end if;
      if INSTR(v_dat,'OCT')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'OCT')-1)||'11'||SUBSTR(v_dat,INSTR(v_dat,'OCT')+3);
      end if;
      if INSTR(v_dat,'DEC')>0 then
        v_dat := SUBSTR(v_dat,1,INSTR(v_dat,'DEC')-1)||'12'||SUBSTR(v_dat,INSTR(v_dat,'DEC')+3);
      end if;
    end if;
    -- data nie moze zawierac liter i musi zawierac cyfry
    if  NVL(TRANSLATE(v_dat,'0ABCDEFGHIJKLMNOPQRSTUVWXYZACELNÓSZZacenólszz','0'),'0') = v_dat
    and not NVL(TRANSLATE(v_dat,' 0123456789', ' '),' ') = v_dat
      then

      v_buf := conv_date (v_dat);

    end if;
    return v_buf;
    --if v_buf is not null then
    --  return('D');
    --else
    --  return('V:'||v_dat);
    --end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function isSubsetOf (Set1 varchar2, Set2 varchar2) return varchar2 is
    T integer;
    NOT_FOUND boolean;
    ELEMENT varchar2(100);
 workSet2 varchar2(5000);
  begin
    workSet2 := ';' || set2 || ';';
    NOT_FOUND := false;
    T := 1;
    ELEMENT := EXTRACTWORD(1,SET1,';');
    while (NVL(ELEMENT,'<EMPTY>') <> '<EMPTY>') and (NOT_FOUND = false) loop
      if INSTR(workSet2, ';' || ELEMENT || ';') = 0 then
        NOT_FOUND := true;
      end if;
      T := T + 1;
      ELEMENT := EXTRACTWORD(T,SET1,';');
    end loop;
    if NOT_FOUND then
       return 'N';
    else
       return 'Y';
    end if;
  end;


 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function peselIsOK ( PESEL  varchar2 ) return  varchar2
    is
  type  TPesel  is  table  of  number  index  by  binary_integer;
  CPesel          TPESEL;
  TempPESEL       number;
  L               binary_integer;
  CyfraKontrolna  number;

  begin
  if LENGTH( PESEL ) <> 11 then
    return 'N';
  else
   TempPESEL := TO_NUMBER ( PESEL );
   for L in reverse 1..11 loop
    CPesel(L) := MOD(TempPESEL,10);
    TempPESEL := FLOOR(TempPesel/10);
   end loop;

   CyfraKontrolna := MOD(10 - MOD(
     MOD(CPesel( 1) * 1,10) +
     MOD(CPesel( 2) * 3,10) +
     MOD(CPesel( 3) * 7,10) +
     MOD(CPesel( 4) * 9,10) +
     MOD(CPesel( 5) * 1,10) +
     MOD(CPesel( 6) * 3,10) +
     MOD(CPesel( 7) * 7,10) +
     MOD(CPesel( 8) * 9,10) +
     MOD(CPesel( 9) * 1,10) +
     MOD(CPesel(10) * 3,10),10),10);

   if (CyfraKontrolna = CPesel(11)) then
    return 'Y';
   else
    return 'N';
   end if;

  end if;

  exception
   when OTHERS then
    return 'N';
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function nipIsOk ( NIP  varchar2 ) return  varchar2
    is
   /* ********************************************************************** */
  /* Funkcja sprawdza czy NIP jest dobry                                    */
  /* Zwraca Y/N
  /* ********************************************************************** */
    type  TNip  is  table  of  number  index  by  binary_integer;
    CNIP            TNip;
    TempNIP         number;
    L               binary_integer;
    CyfraKontrolna  number;
   begin
  if LENGTH( NIP ) <> 10 then
    return 'N';
  else
   TempNIP := TO_NUMBER ( NIP );
   if TempNIP = 0 then return 'N'; end if;
   for L in reverse 1..10 loop
    CNIP(L) := MOD(TempNIP,10);
    TempNIP := FLOOR(TempNIP/10);
   end loop;
   CyfraKontrolna :=
     MOD(
     CNIP( 1) * 6 +
     CNIP( 2) * 5 +
     CNIP( 3) * 7 +
     CNIP( 4) * 2 +
     CNIP( 5) * 3 +
     CNIP( 6) * 4 +
     CNIP( 7) * 5 +
     CNIP( 8) * 6 +
     CNIP( 9) * 7,11);
   if (CyfraKontrolna = CNIP(10)) then
     return 'Y';
   else
     return 'N';
   end if;
  end if;
  exception
   when OTHERS then
        return 'N';
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function regonIsOk ( REGON  varchar2 ) return  varchar2
    is
   CyfraKontrolna     number;
      c1                 number;
      c2                 number;
      c3                 number;
      c4                 number;
      c5                 number;
      c6                 number;
      c7                 number;
      c8                 number;
      c9                 number;
     begin
     if LENGTH(regon) <> 9 and  LENGTH(regon) <> 14 then return 'N'; end if;
     if TO_NUMBER(regon) = 0 then return 'N'; end if;

     c1 := TO_NUMBER(SUBSTR(regon,1,1));
     c2 := TO_NUMBER(SUBSTR(regon,2,1));
     c3 := TO_NUMBER(SUBSTR(regon,3,1));
     c4 := TO_NUMBER(SUBSTR(regon,4,1));
     c5 := TO_NUMBER(SUBSTR(regon,5,1));
     c6 := TO_NUMBER(SUBSTR(regon,6,1));
     c7 := TO_NUMBER(SUBSTR(regon,7,1));
     c8 := TO_NUMBER(SUBSTR(regon,8,1));
     c9 := TO_NUMBER(SUBSTR(regon,9,1));

     CyfraKontrolna := MOD(
    (c1 * 8 +
     C2 * 9 +
     C3 * 2 +
     C4 * 3 +
     C5 * 4 +
     C6 * 5 +
     C7 * 6 +
     C8 * 7),11);

     if CyfraKontrolna = c9 then return 'Y';
     else return 'N';
     end if;
  exception
   when OTHERS then
    return 'N';
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function formatDate(Word varchar2, format varchar2 default 'YYYY-MM-DD') return varchar2 is
  -- Nazwa          : FormatDate
  -- Opis           : Funkcja przekasztalaca date do postaci akceptowanej przez polecenie DML
  begin
    if LENGTH(Word) <> 0 then
     return 'TO_DATE('''||Word||''','''||format||''')';
    else
     return 'NULL';
    end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function formatDateTime(Word varchar2) return varchar2 is
  -- Nazwa          : FormatDateTime
  -- Opis           : Funkcja przekasztalaca sie do postaci akceptowanej przez
  begin
    if LENGTH(Word) <> 0 then
     return 'TO_DATE('''||Word||''',''dd.mm.yyyy HH24:MI'')';
    else
     return 'NULL';
    end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function formatFloat(Word varchar2) return varchar2 is
  -- Nazwa          : FormatFloat
  -- Opis           : Funkcja przekasztalaca sie do postaci akceptowanej przez
  --                  polecenie DML
  begin
    if LENGTH(Word) <> 0 then
     return Word;
    else
     return 'NULL';
    end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function formatString(Word varchar2) return varchar2 is
  -- Nazwa          : FormatString
  -- Opis           : Funkcja przekasztalaca sie do postaci akceptowanej przez
  --                  polecenie DML
  begin
    return ''''||replace(Word,'''','''''')||'''';
  end;


 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function buildCondition ( FIELDTYPE varchar2, FIELD_NAME varchar2, VALUE1 varchar2, VALUE2 varchar2 default null  ) return varchar2 is
   QUOTED_VALUE1 varchar2(4000);
   QUOTED_VALUE2 varchar2(4000);
  begin
      /*
   skladnia dostepna od wersji 9 bazy danych
   CASE
        WHEN FIELDTYPE = 'VARCHAR2' THEN
         QUOTED_VALUE1 := formatString( VALUE1 );
         QUOTED_VALUE2 := formatString( VALUE2 );
        WHEN FIELDTYPE = 'DATE'     THEN
         QUOTED_VALUE1 := formatDate(VALUE1, 'yyyy-mm-dd');
         QUOTED_VALUE2 := formatDate(VALUE2, 'yyyy-mm-dd');
        ELSE
         QUOTED_VALUE1 := VALUE1;
         QUOTED_VALUE2 := VALUE2;
      END CASE;
      */
   if FIELDTYPE = 'VARCHAR2' then
         QUOTED_VALUE1 := formatString( VALUE1 );
         QUOTED_VALUE2 := formatString( VALUE2 );
      elsif FIELDTYPE = 'DATE'     then
         QUOTED_VALUE1 := formatDate(VALUE1, 'yyyy-mm-dd');
         QUOTED_VALUE2 := formatDate(VALUE2, 'yyyy-mm-dd');
      elsif FIELDTYPE = 'NUMBER'     then
         QUOTED_VALUE1 := replace(VALUE1, ',', '.');
         QUOTED_VALUE2 := replace(VALUE2, ',', '.');
      else
         QUOTED_VALUE1 := VALUE1;
         QUOTED_VALUE2 := VALUE2;
      end if;

   if VALUE1 is null and VALUE2 is null then return null; end if;
   if VALUE2 is null then
    if FIELDTYPE = 'VARCHAR2' and (INSTR(QUOTED_VALUE1, '%') <> 0 or INSTR(QUOTED_VALUE1, '_') <> 0) then
      return FIELD_NAME || ' LIKE ' || QUOTED_VALUE1 ;
    else
      return FIELD_NAME || ' = ' || QUOTED_VALUE1 ;
    end if;
   end if;

   return FIELD_NAME || ' BETWEEN ' || QUOTED_VALUE1 || ' AND ' || QUOTED_VALUE2;
 end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure executeImmediate (SQL_STATEMENT varchar2) is
  pragma autonomous_transaction;
  begin
    EXECUTE immediate SQL_STATEMENT;
    commit;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function toLatin2 (tekst in varchar2) return varchar2 is
    STR_ROB varchar2(1024);
  begin
      str_rob := tekst;
      str_rob := replace(str_rob, 'A', CHR(164));
      str_rob := replace(str_rob, 'Z', CHR(141));
      str_rob := replace(str_rob, 'C', CHR(143));
      str_rob := replace(str_rob, 'E', CHR(168));
      str_rob := replace(str_rob, 'L', CHR(157));
      str_rob := replace(str_rob, 'N', CHR(227));
      str_rob := replace(str_rob, 'Ó', CHR(224));
      str_rob := replace(str_rob, 'S', CHR(151));
      str_rob := replace(str_rob, 'Z', CHR(189));
      str_rob := replace(str_rob, 'a', CHR(165));
      str_rob := replace(str_rob, 'c', CHR(134));
      str_rob := replace(str_rob, 'e', CHR(169));
      str_rob := replace(str_rob, 'l', CHR(136));
      str_rob := replace(str_rob, 'n', CHR(228));
      str_rob := replace(str_rob, 'ó', CHR(162));
      str_rob := replace(str_rob, 's', CHR(152));
      str_rob := replace(str_rob, 'z', CHR(171));
      str_rob := replace(str_rob, 'z', CHR(190));
      return(str_rob);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function hasPolishSigns(S in out varchar2) return varchar2 is
   S2 varchar2(500);
  begin
    S := UPPER(S);
    S2:= S;
    S := replace(S,'E','');
    S := replace(S,'Ó','');
    S := replace(S,'A','');
    S := replace(S,'S','');
    S := replace(S,'L','');
    S := replace(S,'Z','');
    S := replace(S,'Z','');
    S := replace(S,'C','');
    S := replace(S,'N','');

    if S <> S2 then return 'Y'; else return 'N'; end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function extractFileName(S  in varchar2)  return varchar2  is
  -- Opis           : Funkcja wyodrebnia ze sciezki nazwe pliku
  --                  np. ExtractFileName('c:\Program Files\Joasia.xls') -> Joasia.xls
    POS   number;
  begin
    POS := INSTR(S, '\', -1, 1);
    if POS = 0 then
        POS := INSTR(S, '/', -1, 1);
    end if;
    return SUBSTR(S, POS+1 );
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function extractPath (S  in varchar2)  return varchar2  is
  -- Opis           : Funkcja wyodrebnia ze sciezki sciezke bez nazwy pliku
  --                  np. ExtractFileName('c:\Program Files\Joasia.xls') -> c:\Program Files\
    POS   number;
  begin
    POS := INSTR(S, '\', -1, 1);
    if POS = 0 then
        POS := INSTR(S, '/', -1, 1);
    end if;
    return SUBSTR(S, 1, POS );
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getBanknotes( Wydaj varchar2 ) return varchar2 is
  -- Opis   : Kwota podana w banknotach i bilonach
  -- Autor : Adam Plandowski 2001.03.10
   W1000 varchar2(20);
   W200  varchar2(20);
   W100  varchar2(20);
   W50   varchar2(20);
   W20   varchar2(20);
   W10   varchar2(20);
   W5    varchar2(20);
   W2    varchar2(20);
    W1    varchar2(20);
    Wgr   varchar2(20);
   tekst varchar2(250);
   Wynik number(16,2);
  begin
  -- Sprawdz dlugosc kwoty dla setek 1000 zl
  if TRUNC(wydaj)<0 then
  return Tekst||' ???? ';
  else
     if NVL(LENGTH( TRUNC(Wydaj) ), 0)>3 then
      -- Dla 1000
     --  IF Trunc(Wydaj/200)>=5 THEN
         if TRUNC(Wydaj/200)>=5 then
          W200:=TRUNC(Wydaj/200)||'*200';
          Wynik:=Wydaj-TRUNC(Wydaj/200)*200;
      if Wynik>=100 then
       W100:=',100';
     end if;
     if SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=9 then
        W50:=',50';
        W20:=',20,20';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=8 then
        W50:=',50';
        W20:=',20';
        W10:=',10';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=7 then
        W50:=',50';
        W20:=',20';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=6 then
        W50:=',50';
        W10:=',10';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=5 then
        W50:=',50';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=4 then
        W20:=',20,20';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=3 then
        W20:=',20';
        W10:=',10';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=2 then
        W20:=',20';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-2,1)=1 then
        W20:=',10';
      end if;
    if SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=9 then
       W5:=',5';
       W2:=',2,2';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=8 then
        W5:=',5';
       W2:=',2';
       W1:=',1';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=7 then
        W5:=',5';
       W2:=',2';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=6 then
        W5:=',5';
       W1:=',1';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=5 then
        W5:=',5';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=4 then
        W2:=',2,2';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=3 then
        W2:=',2';
       W1:=',1';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=2 then
        W2:=',2';
      elsif SUBSTR(Wynik,INSTR(Wynik,',')-1,1)=1 then
        W1:=',1';
      end if;

    end if;
       --
  -- Sprawdz dlugosc kwoty dla setek do 999 zl
     elsif NVL(LENGTH( TRUNC(Wydaj) ), 0)=3 then
      if TRUNC(Wydaj/100) >=9 then
         W200:='4*200';
         W100:=',100';
         Wynik:=Wydaj-TRUNC(Wydaj/100)*100;
      -- Wartosci ponizej 100
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 800
     elsif TRUNC(Wydaj/100)=8 then
         W200:='4*200';
      Wynik:=Wydaj-800;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 700
     elsif TRUNC(Wydaj/100)=7 then
         W200:='3*200';
         W100:=',100';
      Wynik:=Wydaj-700;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 600
     elsif TRUNC(Wydaj/100)=6 then
         W200:='3*200';
      Wynik:=Wydaj-600;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 500
     elsif TRUNC(Wydaj/100)=5 then
         W200:='200,200';
         W100:=',100';
      Wynik:=Wydaj-500;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 400
     elsif TRUNC(Wydaj/100)=4 then
         W200:='200,200';
      Wynik:=Wydaj-400;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 300
     elsif TRUNC(Wydaj/100)=3 then
         W200:='200';
         W100:=',100';
      Wynik:=Wydaj-300;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
    -- Wydaj 200
     elsif TRUNC(Wydaj/100)=2 then
         W200:='200';
      Wynik:=Wydaj-200;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
     -- Wydaj 100
     elsif TRUNC(Wydaj/100)=1 then
         W100:='100';
         Wynik:=Wydaj-100;
        if TRUNC(Wynik/50)=1 then
           W50:=',50';
           Wynik:=Wynik-50;
        end if;
        if TRUNC(Wynik/20)=2  then
           W20:=',20,20';
           Wynik:=Wynik-40;
        end if;
        if TRUNC(Wynik/20)=1 then
           W20:=',20';
           Wynik:=Wynik-20;
        end if;
        if TRUNC(Wynik/10)=1 then
           W10:=',10';
        end if;
       end if;
      if SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=9 then
       W5:=',5';
       W2:=',2,2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=8 then
        W5:=',5';
       W2:=',2';
       W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=7 then
        W5:=',5';
       W2:=',2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=6 then
        W5:=',5';
       W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=5 then
        W5:=',5';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=4 then
        W2:=',2,2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=3 then
        W2:=',2';
       W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=2 then
        W2:=',2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=1 then
        W1:=',1';
      end if;
     -- Sprawdz dlugosc kwoty dla dziesiatek
    elsif NVL(LENGTH( TRUNC(Wydaj) ), 0)=2 then
     if SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=9 then
        W50:='50';
        W20:=',20,20';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=8 then
        W50:='50';
        W20:=',20';
        W10:=',10';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=7 then
        W50:='50';
        W20:=',20';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=6 then
        W50:='50';
        W10:=',10';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=5 then
        W50:='50';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=4 then
        W20:='20,20';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=3 then
        W20:='20';
        W10:=',10';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=2 then
        W20:='20';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-2,1)=1 then
        W20:='10';
      end if;
      if SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=9 then
       W5:=',5';
       W2:=',2,2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=8 then
        W5:=',5';
       W2:=',2';
       W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=7 then
        W5:=',5';
       W2:=',2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=6 then
        W5:=',5';
       W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=5 then
        W5:=',5';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=4 then
        W2:=',2,2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=3 then
        W2:=',2';
       W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=2 then
        W2:=',2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=1 then
        W1:=',1';
      end if;
    --Sprawdz zlotówki
    elsif NVL(LENGTH( TRUNC(Wydaj) ), 0)=1 then
    if replace((SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)),',','0')=0 then
      W1:='0';
    else
     if SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=9 then
        W50:='5';
        W20:=',2,2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=8 then
        W5:='5';
        W2:=',2';
        W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=7 then
        W5:='5';
        W2:=',2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=6 then
        W5:='5';
        W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=5 then
        W5:='5';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=4 then
        W2:='2,2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=3 then
        W2:='2';
        W1:=',1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=2 then
        W2:='2';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=1 then
        W1:='1';
      elsif SUBSTR(Wydaj,INSTR(Wydaj,',')-1,1)=',' then
        W1:='0';
      end if;
     end if;
    end if;
   -- Sprawdz doalacz grosze
    if SUBSTR( TO_CHAR( TRUNC( Wydaj, 2), '999999999.00' ), -2 )<>'XX' then
     Wgr:=','||SUBSTR( TO_CHAR( TRUNC( Wydaj, 2), '999999999.00' ), -2 )||'/100';
    end if;
    return Tekst||'('||W1000||W200||W100||W50||W20||W10||W5||W2||W1||' zl '||Wgr||' gr'||')';
    end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getsqlv(sqltext varchar2, valuewhenempty varchar2, exceptifempty char, sep varchar2 default '|', maxsizeofres number default 30000, singlevaluemode boolean) return varchar2 is
    select_cursor   number;
    n_buffer        varchar2(2000);
    counter         number;
    result          varchar2(32000);
  begin
    begin
   result:= '';
      select_cursor:=dbms_sql.open_cursor;
      dbms_sql.parse(select_cursor, sqltext, dbms_sql.v7);
      dbms_sql.define_column(select_cursor,1,n_buffer,2000);
      --dbms_sql.bind_variable(select_cursor,':TOKEN_NUMBER_FIELD',n_number_of_policy);
      counter:=dbms_sql.execute(select_cursor);

     loop
        if dbms_sql.fetch_rows(select_cursor)>0 then
          dbms_sql.column_value(select_cursor, 1, n_buffer);
          --dbms_output.put_line ( n_buffer );
    result := merge (result, n_buffer, sep);
    if singlevaluemode then exit; end if;
    if length( result ) > maxsizeofres then exit; end if;
        else
          exit;
        end if;
      end loop;
      dbms_sql.close_cursor(select_cursor);
   if exceptifempty = 'Y' and result is null then raise no_data_found; end if;
   return nvl(result,valuewhenempty);
    exception
      when others then
        if dbms_sql.is_open(select_cursor) then
          dbms_sql.close_cursor(select_cursor);
        end if;
        raise;
    end;
  end;

  /*
  FUNCTION remote_qry(p_sql IN VARCHAR2) RETURN NUMBER IS
    --
    v_cursor_name INTEGER;
    v_cursor_rows INTEGER;
    v_cursor_data NUMBER;
    --
  BEGIN
    --
 v_cursor_name := DBMS_SQL.OPEN_CURSOR@SA;
 --
 DBMS_SQL.PARSE@SA(v_cursor_name, p_sql, DBMS_SQL.native);
 DBMS_SQL.DEFINE_COLUMN@SA(v_cursor_name, 1, v_cursor_data);
 --
 v_cursor_rows := DBMS_SQL.EXECUTE_AND_FETCH@SA(v_cursor_name);
 --
 DBMS_SQL.COLUMN_VALUE@SA(v_cursor_name, 1, v_cursor_data);
 DBMS_SQL.CLOSE_CURSOR@SA(v_cursor_name);
    --
    RETURN v_cursor_data;
    --
  EXCEPTION
    WHEN OTHERS THEN
      log_message(p_src => 'swd_sa_extract.remote_qry'
                 ,p_msg => 'Wywolanie zdalne zakonczone bledem: '||SQLERRM
                 ,p_log => C_LOG_LEVEL_ERROR);
      --
   IF DBMS_SQL.IS_OPEN@SA(v_cursor_name) THEN
        DBMS_SQL.CLOSE_CURSOR@SA(v_cursor_name);
   END IF;
   --
      RAISE;
      --
  END remote_qry;
  --
  -----------------------------------------------------------------------------
  --
  FUNCTION remote_dml(p_sql IN VARCHAR2) RETURN NUMBER IS
    --
    v_cursor_name INTEGER;
    v_cursor_rows INTEGER;
    --
  BEGIN
    --
 v_cursor_name := DBMS_SQL.OPEN_CURSOR@SA;
 --
 DBMS_SQL.PARSE@SA(v_cursor_name, p_sql, DBMS_SQL.native);
 --
 v_cursor_rows := DBMS_SQL.EXECUTE@SA(v_cursor_name);
 --
 DBMS_SQL.CLOSE_CURSOR@SA(v_cursor_name);
    --
    RETURN v_cursor_rows;
    --
  EXCEPTION
    WHEN OTHERS THEN
      log_message(p_src => 'swd_sa_extract.remote_dml'
                 ,p_msg => 'Wywolanie zdalne zakonczone bledem: '||SQLERRM
                 ,p_log => C_LOG_LEVEL_ERROR);
      --
   IF DBMS_SQL.IS_OPEN@SA(v_cursor_name) THEN
        DBMS_SQL.CLOSE_CURSOR@SA(v_cursor_name);
   END IF;
   --
      RAISE;
      --
  END remote_dml;
  */
  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  FUNCTION getSQLV(SQLText VARCHAR2, exceptifempty CHAR, Sep VARCHAR2 DEFAULT '|', maxsizeofres NUMBER DEFAULT 30000, singlevaluemode BOOLEAN) RETURN VARCHAR2 IS
    select_cursor   NUMBER;
    n_buffer        VARCHAR2(2000);
    counter         NUMBER;
    result          VARCHAR2(32000);
  BEGIN
    BEGIN
   result:= '';
      select_cursor:=dbms_sql.open_cursor;
      dbms_sql.parse(select_cursor, SQLText, dbms_sql.v7);
      dbms_sql.define_column(select_cursor,1,n_buffer,2000);
      --dbms_sql.bind_variable(select_cursor,':TOKEN_NUMBER_FIELD',n_number_of_policy);
      counter:=dbms_sql.EXECUTE(select_cursor);

     LOOP
        IF DBMS_SQL.FETCH_ROWS(select_cursor)>0 THEN
          DBMS_SQL.COLUMN_VALUE(select_cursor, 1, n_buffer);
          --dbms_output.put_line ( n_buffer );
    result := Merge (result, n_buffer, Sep);
    IF singlevaluemode THEN EXIT; END IF;
    IF LENGTH( result ) > maxsizeofres THEN EXIT; END IF;
        ELSE
          EXIT;
        END IF;
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(select_cursor);
   IF exceptifempty = 'Y' AND result IS NULL THEN RAISE NO_DATA_FOUND; END IF;
   RETURN NVL(result,valueWhenempty);
    EXCEPTION
      WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(select_cursor) THEN
          DBMS_SQL.CLOSE_CURSOR(select_cursor);
        END IF;
        RAISE;
    END;
  END;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getSQLValues(SQLText varchar2, valueWhenEmpty varchar2 default null,exceptifempty char default 'N', Sep varchar2 default ', ', maxsizeofres number default 30000) return varchar2 is
  begin
   return getSQLV(replace(SQLText,'^',''''), valueWhenEmpty, exceptifempty, Sep, maxsizeofres, false);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getSQLValue(SQLText varchar2, valueWhenEmpty varchar2 default null, exceptifempty char default 'Y') return varchar2 is
  begin
   return getSQLV(replace(SQLText,'^',''''), valueWhenEmpty, exceptifempty, '|', 2000, true);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure wordWrapInit (aWordWrap in out nocopy tWordWrap,adefaultStr varchar2, tokenSeparator varchar2 default '|') is
  begin
   aWordWrap.defaultStr := adefaultStr;
   aWordWrap.linesPastedStr.delete;
   aWordWrap.linesFromPos.delete;
   aWordWrap.linesToPos.delete;
   aWordWrap.linesAlign.delete;
   awordWrap.resultLineNum := -1;
   aWordWrap.errorMessage  := null;
   aWordWrap.tokenSeparator  := tokenSeparator;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure wordWrapPrepareColumn(aWordWrap in out nocopy tWordWrap, pastedStr varchar2, placeHolder varchar2, align number) is
   fromPos number;
   toPos   number;

   tempStr varchar2(2000);
   tempfromPos number;
  begin
   if aWordWrap.errorMessage is not null then return; end if;
   fromPos := INSTR(aWordWrap.defaultStr,placeHolder);
   toPos   := fromPos + LENGTH(placeHolder)-1;
   if fromPos = 0 then
    aWordWrap.errorMessage := 'Error: Placeholder '||NVL(PlaceHolder,'<empty>')|| ' not found in defaultStr';
   return;
   end if;

   tempStr     := PasteStr(aWordWrap.defaultStr,'.',fromPos,toPos,0);
   tempfromPos := INSTR(tempStr,placeHolder);
   if tempfromPos <> 0 then
    aWordWrap.errorMessage := 'Error: Two or more occurences of placeholder '||NVL(PlaceHolder,'<empty>')|| ' in defaultStr';
     return;
   end if;

   -- takie dziwolagi, bo w plsql nie ma polecenia With
   aWordWrap.linesPastedStr ( aWordWrap.linesPastedStr.COUNT ) := pastedStr;
   aWordWrap.linesfromPos   ( aWordWrap.linesfromPos.COUNT   ) := fromPos;
   aWordWrap.linestoPos     ( aWordWrap.linestoPos.COUNT     ) := toPos;
   aWordWrap.linesalign     ( aWordWrap.linesalign.COUNT     ) := align;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function  wordWrapGetNumberOfLines(aWordWrap in out nocopy tWordWrap) return number is
  i number;
  MAXVALUE number;

      function SingleMax ( N1 number, N2 number) return number is
      begin
     if N1 >= N2 then return N1;
                 else return N2; end if;
      end;

  begin
    if aWordWrap.errorMessage is not null then return -1; end if;
    i := aWordWrap.linesPastedStr.FIRST;
    MAXVALUE := -99999999999999999999999999999999999;
    while i is not null loop
      MAXVALUE := SingleMax ( MAXVALUE, WordCount( WordWrap( aWordWrap.linesPastedStr (I), aWordWrap.linestoPos(I) - aWordWrap.linesFromPos(I) + 1, 0, false, aWordWrap.tokenSeparator),aWordWrap.tokenSeparator) );
      --FUNCTION WordWrap( S VARCHAR2, columnWidth NUMBER, getTokenNr NUMBER DEFAULT 0, completeWithSpaces BOOLEAN DEFAULT TRUE, TokenSeparator VARCHAR2 DEFAULT '|') RETURN VARCHAR2
      i := aWordWrap.linesPastedStr.NEXT(i);
    end loop;
    awordWrap.resultLineNum := MAXVALUE;
    return MAXVALUE;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function  wordWrapGetLine(aWordWrap in out nocopy tWordWrap,lineNum number) return varchar2 is
    returnedStr varchar2(2000);
    i number;
  begin
   if aWordWrap.errorMessage is not null then return aWordWrap.errorMessage; end if;
    if awordWrap.resultLineNum = -1 then -- obiekt nie zostal prawidlowo zainicjowany
   return 'funkcja wordWrapGetLine - obiekt nie zostal prawidlowo zainicjowany';
   end if;

   returnedStr := aWordWrap.defaultStr;
   i := aWordWrap.linesPastedStr.FIRST;
   while i is not null loop
   returnedStr:= PasteStr (
                   returnedStr
                  ,WordWrap( aWordWrap.linesPastedStr (i), aWordWrap.linestoPos(i) - aWordWrap.linesFromPos(i) + 1, lineNum, false, aWordWrap.tokenSeparator)
                     ,aWordWrap.linesFromPos(i)
                     ,aWordWrap.linesToPos(i)
                     ,aWordWrap.linesAlign(i) );
      i := aWordWrap.linesPastedStr.NEXT(i);
    end loop;
    return returnedStr;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure amountsInit (amounts in out nocopy tAmounts, agroupOperator integer default 0) is
  begin
   Amounts.COUNT := 0;
   Amounts.groupOperator := agroupOperator;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure amountsAdd(amounts in out nocopy tAmounts, aGroupIndicator varchar2, amount1 number, amount2 number default 0, amount3 number default 0, amount4 number default 0, amount5 number default 0, amount6 number default 0, amount7 number default 0, amount8 number default 0) is
    t      integer;
    c      integer;
    FOUND  boolean;
    groupIndicator  varchar2(100);
  begin
   groupIndicator := aGroupIndicator;
   if groupIndicator <> 'TOTAL' then
     amountsAdd(Amounts, 'TOTAL', amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8);
   end if;
   FOUND := false;
   if groupIndicator is null then groupIndicator := '-'; end if;
   for c in 1..amounts.COUNT loop
    if amounts.groupIndicators(c) = groupIndicator then FOUND := true; t:= c; exit; end if;
   end loop;

   if FOUND then
    if amounts.groupOperator = 0 then
     amounts.amounts1(t) := amounts.amounts1(t) + NVL(amount1,0);
     amounts.amounts2(t) := amounts.amounts2(t) + NVL(amount2,0);
     amounts.amounts3(t) := amounts.amounts3(t) + NVL(amount3,0);
     amounts.amounts4(t) := amounts.amounts4(t) + NVL(amount4,0);
     amounts.amounts5(t) := amounts.amounts5(t) + NVL(amount5,0);
     amounts.amounts6(t) := amounts.amounts6(t) + NVL(amount6,0);
     amounts.amounts7(t) := amounts.amounts7(t) + NVL(amount7,0);
     amounts.amounts8(t) := amounts.amounts8(t) + NVL(amount8,0);
    elsif amounts.groupOperator = 1 then
     amounts.amounts1(t) := maximum (amounts.amounts1(t) , NVL(amount1,0));
     amounts.amounts2(t) := maximum (amounts.amounts2(t) , NVL(amount2,0));
     amounts.amounts3(t) := maximum (amounts.amounts3(t) , NVL(amount3,0));
     amounts.amounts4(t) := maximum (amounts.amounts4(t) , NVL(amount4,0));
     amounts.amounts5(t) := maximum (amounts.amounts5(t) , NVL(amount5,0));
     amounts.amounts6(t) := maximum (amounts.amounts6(t) , NVL(amount6,0));
     amounts.amounts7(t) := maximum (amounts.amounts7(t) , NVL(amount7,0));
     amounts.amounts8(t) := maximum (amounts.amounts8(t) , NVL(amount8,0));
    elsif amounts.groupOperator = 2 then
     amounts.amounts1(t) := MINIMUM (amounts.amounts1(t) , NVL(amount1,0));
     amounts.amounts2(t) := MINIMUM (amounts.amounts2(t) , NVL(amount2,0));
     amounts.amounts3(t) := MINIMUM (amounts.amounts3(t) , NVL(amount3,0));
     amounts.amounts4(t) := MINIMUM (amounts.amounts4(t) , NVL(amount4,0));
     amounts.amounts5(t) := MINIMUM (amounts.amounts5(t) , NVL(amount5,0));
     amounts.amounts6(t) := MINIMUM (amounts.amounts6(t) , NVL(amount6,0));
     amounts.amounts7(t) := MINIMUM (amounts.amounts7(t) , NVL(amount7,0));
     amounts.amounts8(t) := MINIMUM (amounts.amounts8(t) , NVL(amount8,0));
    end if;
   else
    amounts.COUNT := amounts.COUNT + 1;
    amounts.amounts1(amounts.COUNT)         := NVL(amount1,0);
    amounts.amounts2(amounts.COUNT)         := NVL(amount2,0);
    amounts.amounts3(amounts.COUNT)         := NVL(amount3,0);
    amounts.amounts4(amounts.COUNT)         := NVL(amount4,0);
    amounts.amounts5(amounts.COUNT)         := NVL(amount5,0);
    amounts.amounts6(amounts.COUNT)         := NVL(amount6,0);
    amounts.amounts7(amounts.COUNT)         := NVL(amount7,0);
    amounts.amounts8(amounts.COUNT)         := NVL(amount8,0);
    amounts.groupIndicators(amounts.COUNT) := groupIndicator;
   end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure amountsGetExample1(Amounts in out nocopy TAmounts) is
    t integer;
    procedure wout ( s varchar2 ) is begin dbms_output.put_line ( s ); end;

  begin
   for t in 1..Amounts.COUNT loop
    wout ( Amounts.amounts1(t) || ' ' || Amounts.amounts2(t) || ' ' || Amounts.amounts3(t) || ' ' || Amounts.amounts4(t) || ' ' || Amounts.GroupIndicators(t));
   end loop;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
 procedure amountsGetExample2 (amounts in out nocopy TAmounts) is
     procedure wout ( s varchar2 ) is begin dbms_output.put_line ( s ); end;
 begin
   for L in 2..amounts.COUNT loop -- no 1 is "TOTAL"
     wout ( amounts.groupIndicators(L)
   || ' ' || amounts.amounts1(L)
   || ' ' || amounts.amounts2(L)
   || ' ' || amounts.amounts3(L) );
   end loop;

   if amounts.COUNT-1 > 1 then
     wout  ('========================================');
     wout ( amounts.groupIndicators(1)
   || ' ' || Xxmsz_Tools.AmountsGetByIndicator (amounts, 'TOTAL', 1)
   || ' ' || Xxmsz_Tools.AmountsGetByIndicator (amounts, 'TOTAL', 2)
   || ' ' || Xxmsz_Tools.AmountsGetByIndicator (amounts, 'TOTAL', 3) );
   end if;
 end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function amountsGetByIndicator(Amounts in out nocopy TAmounts, aGroupIndicator varchar2, AmountIndex number) return number is
    t      integer;
    c      integer;
    FOUND  boolean;
    GroupIndicator  varchar2(100);
  begin
   GroupIndicator := aGroupIndicator;
   FOUND := false;
   if GroupIndicator is null then GroupIndicator := '-'; end if;
   for c in 1..Amounts.COUNT loop
    if Amounts.GroupIndicators(c) = GroupIndicator then FOUND := true; t:= c; exit; end if;
   end loop;

   if FOUND then
     if amountIndex = 1 then return amounts.amounts1(t); end if;
     if amountIndex = 2 then return amounts.amounts2(t); end if;
     if amountIndex = 3 then return amounts.amounts3(t); end if;
     if amountIndex = 4 then return amounts.amounts4(t); end if;
     if amountIndex = 5 then return amounts.amounts5(t); end if;
     if amountIndex = 6 then return amounts.amounts6(t); end if;
     if amountIndex = 7 then return amounts.amounts7(t); end if;
     if amountIndex = 8 then return amounts.amounts8(t); end if;
   else
     return 0;
   end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function trimSpaces ( S varchar2 ) return varchar is
    lenBefore number;
    lenAfter  number;
    Res       varchar2(30000);
  begin
  if S is null then
   return null;
  end if;
  if LENGTH ( S ) > 30000 then
    RAISE_APPLICATION_ERROR(-20000,'sorry, string too long');
  end if;
  Res := Trim ( S );
  loop
   lenBefore := LENGTH ( Res );
   Res := replace ( Res, '  ', ' ');
   lenAfter := LENGTH ( Res );
   exit when lenBefore = lenAfter;
  end loop;
  return Res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function withoutPolishSigns (S in varchar2) return varchar2 is
    res varchar2(1024);
  begin
      res := S;
      res := replace(res, 'A', 'A');
      res := replace(res, 'Z', 'Z');
      res := replace(res, 'C', 'C');
      res := replace(res, 'E', 'E');
      res := replace(res, 'L', 'L');
      res := replace(res, 'N', 'N');
      res := replace(res, 'Ó', 'O');
      res := replace(res, 'S', 'S');
      res := replace(res, 'Z', 'Z');
      res := replace(res, 'a', 'a');
      res := replace(res, 'c', 'c');
      res := replace(res, 'e', 'e');
      res := replace(res, 'l', 'l');
      res := replace(res, 'n', 'n');
      res := replace(res, 'ó', 'o');
      res := replace(res, 's', 's');
      res := replace(res, 'z', 'z');
      res := replace(res, 'z', 'z');
      return(res);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function wordWrap( wrappedString varchar2, columnWidth number, getTokenNr number default 0, completeWithSpaces boolean default true, TokenSeparator varchar2 default '|') return varchar2 is
   Rest      varchar2(30000);
   Token     varchar2(1000);
   outString varchar2(30000);
   S         varchar2(30000);
   Sentry    number;
  begin
    Sentry := 0;
    S := replace ( wrappedString, CHR(10), TokenSeparator); -- ch(10) jest zawsze separatorem linii

    if LENGTH ( S ) > 30000 then
      return 'sorry, string too long';
    end if;
   outString := '';
   Rest := S;

   loop
     Sentry := Sentry + 1;
  if INSTR( rest, TokenSeparator ) <> 0                     --   jezeli znaleziono znak konca wiersza
    and INSTR( rest, TokenSeparator )-1 <= columnWidth then -- i jesli pierwszy wiersz bez znaku konca wiersza zmiesci sie w kolumnie, to go wez
       Token := SUBSTR( rest, 1, INSTR( rest, TokenSeparator )-1); -- to wez
       Rest  := SUBSTR( rest,    INSTR( rest, TokenSeparator )+1, 30000);
     else
       Token := SUBSTR( rest, 1, columnWidth); -- w przeciwnym wypadku wez to co zmiesci sie w pierwszej kolumnie
       Rest  := SUBSTR( rest,    columnWidth + 1, 30000);

       -- to jeszcze nie jest ostateczny podzial na token i rest.
    -- moze nastapic odciecie czesci tokena po spacji lub myslniku i doklejenie go z powrotem do rest
       -- dfdgdfgdf dfgdfgd|fgd-- jesli ostatni znak tokena i pierwszy znak reszty sa literami* to jesli w tokenie jest spacja/myslnik, to znajdz piersza od konca i przytnij token
    --    * - dokladnie: jest innym znakiem niz spacja, myslnik, kropka, znak konca wiersza
       if SUBSTR( token, LENGTH(token), 1) not in (' ','-','.',TokenSeparator) and SUBSTR(rest, 1, 1) not in ( ' ','-','.',TokenSeparator) then
      if replace(replace( replace(SUBSTR(token,2,30000),' ',''), '-', ''),'.', '')  <> SUBSTR(token,2,30000) then -- jest spacja/myslnik czyli mozna zawijac
        declare
      spacePos1 number;
      spacePos2 number;
      spacePos3 number;
      spacePos  number;
      newToken  varchar2(1000);
      restToken varchar2(1000);
     begin
       spacePos1  := INSTR(token,' ',-1);
       spacePos2  := INSTR(token,'-',-1);
       spacePos3  := INSTR(token,'.',-1);
       spacePos   := Maximum (spacePos1, spacePos2,spacePos3); -- pierwszy od konca myslnik lub spacja
          newToken   := SUBSTR(token, 1, spacePos);
       restToken  := SUBSTR(token, spacePos+1, 30000);
       --dbms_output.put_line('newToken='||newToken);
       --dbms_output.put_line('restToken='||restToken);
       Token := newToken;
       Rest := Merge( restToken, Rest, ''); --doklejenie z powrotem fragmentu tokenu to pozostalej czesci
     end;
      end if;
    end if;

  end if;

  if completeWithSpaces then
       outString := Merge ( outString, SUBSTR(merge(Token, MakeStr(' ',columnWidth)),1,columnWidth), TokenSeparator);
  else
       outString := Merge ( outString, SUBSTR(Token,1,columnWidth), TokenSeparator);
  end if;
     exit when (rest is null) or (Sentry = 1000);
   end loop;
   if Sentry = 1000 then
    return 'Error in WordWrap';
   else
     if getTokenNr = 0 then return outString;
                       else return ExtractWord(getTokenNr, outString, TokenSeparator); end if;
   end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function wordWrap( wrappedString varchar2, columnWidth number, getTokenNr number default 0, completeWithSpaces varchar2 default 'Y', TokenSeparator varchar2 default '|') return varchar2 is   
  begin
    return wordWrap( wrappedString, columnWidth, getTokenNr, completeWithSpaces = 'Y' , TokenSeparator);
  end;
  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function makeStr(s varchar2, len number) return varchar2 is
    res varchar2(30000);
  begin
   if s is null or len < 1 then
     return 'input data error';
   end if;
   res := s;
   loop
     res := merge(res,s);
     exit when LENGTH(res) >= len;
   end loop;
   return SUBSTR(res,1,len);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function pasteStr( Str varchar2, pastedStr varchar2, fromPos number, toPos number, align number ) return varchar2 is
   aPastedStr varchar2(30000);
  begin
   if align = 0 then aPastedStr := rpad(NVL(PastedStr,' '), toPos - fromPos + 1, ' '); end if;
   if align = 1 then aPastedStr := lpad(NVL(PastedStr,' '), toPos - fromPos + 1, ' '); end if;
   if align = 2 then aPastedStr := Center (pastedStr, toPos - fromPos + 1); end if;
   return SUBSTR(str,1,fromPos-1) || aPastedStr || SUBSTR(str,toPos+1, 30000);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function ynToBool ( S varchar2, resultIfEmpty boolean default false ) return boolean is
  begin
   if S is null then return resultIfEmpty; else
     return UPPER(substr(S,1,1)) in ('T','Y');
   end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function ynToYN ( S varchar2, resultIfEmpty varchar2 default 'N' ) return char is
  begin
   if S is null then return resultIfEmpty; else
     if UPPER(substr(S,1,1)) in ('T','Y') then return 'Y'; else return 'N'; end if;
   end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function erasePolishChars(S varchar2) return varchar2 is
   S2 varchar2(3000);
  begin
    S2 := S;
    S2 := replace(S2,'E','E');
    S2 := replace(S2,'Ó','O');
    S2 := replace(S2,'A','A');
    S2 := replace(S2,'S','S');
    S2 := replace(S2,'L','L');
    S2 := replace(S2,'Z','Z');
    S2 := replace(S2,'Z','Z');
    S2 := replace(S2,'C','C');
    S2 := replace(S2,'N','N');
    S2 := replace(S2,'e','e');
    S2 := replace(S2,'ó','o');
    S2 := replace(S2,'a','a');
    S2 := replace(S2,'s','s');
    S2 := replace(S2,'l','l');
    S2 := replace(S2,'z','z');
    S2 := replace(S2,'z','z');
    S2 := replace(S2,'c','c');
    S2 := replace(S2,'n','n');

    return S2;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function boolToYN ( bool boolean, trueValue varchar2 default 'Y', falseValue varchar2 default 'N' ) return varchar2 is
  begin
   if bool then return trueValue;
           else return falseValue; end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getIBANcheckDigits (acc varchar2 ) return varchar2 is 
  begin
    return lpad(TO_CHAR (98 - MOD (TO_NUMBER (acc || '2521' || '00'), 97)),2,'0');
  end;
  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function formatIBAN ( inS varchar2, numberOfSignsInSection number default 4, formatOnlyWhenDivisible varchar2 default 'N' ) return varchar2 is
  res varchar2(500);
  n integer;
  S varchar2(500);
      function toIBAN (acc varchar2) return varchar2 is 
      --cc 88888888 aaaa bbbb cccc dddd
      --                               
      --         11 1111 1111 2222 2222
      --12 34567890 1234 5678 9012 3456
      begin
        return substr(acc,1,2) 
         || ' ' || substr(acc,3,4) 
         || ' ' || substr(acc,7,4)
         || ' ' || substr(acc,11,4)
         || ' ' || substr(acc,15,4)
         || ' ' || substr(acc,19,4)
         || ' ' || substr(acc,23,4);
      end;                  
  begin
    s := replace(inS,' ','');    
    if length(s)=26 then
      return toIBAN(inS);
    end if;    
    
    --old version
    if YNToBool ( formatOnlyWhenDivisible ) then
      if LENGTH(s) MOD numberOfSignsInSection <> 0 then return s; end if;
    end if;

    n := 0;
    loop
      exit when NVL(LENGTH(SUBSTR(s,1 + n * numberOfSignsInSection ,numberOfSignsInSection)),0) = 0;
      res := Xxmsz_Tools.merge( res, SUBSTR(s,1 + n * numberOfSignsInSection ,numberOfSignsInSection), ' ');
      n := n + 1;
    end loop;
    return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function formatNIP  ( inS varchar2 ) return varchar2 is
  S varchar2(100);
  begin
    if inS is null then return null; end if;
    s := replace(inS,' ','');
    s := replace(inS,'-','');
    if inS <> s then return inS ;
                else return SUBSTR(s,1,3) || '-' || SUBSTR(s,4,3) || '-' || SUBSTR(s,7,2) || '-' || SUBSTR(s,9,2); end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function strToNumber ( str varchar2, valueWhenEmpty varchar2 default '0' ) return number is
   res number;
  begin
   begin
     res := TO_NUMBER (replace(str,' ','')); -- konwertuj na liczbe
   exception
    when OTHERS then
  begin
       res := TO_NUMBER (replace(replace(str,' ',''),',','.')); -- a jesli sie nie udalo, to zamien ,->. i konweruj na liczbe
  exception
    when OTHERS then
         res := TO_NUMBER (replace(replace(str,' ',''),'.',',')); -- a jesli sie nie udalo, to zamien .->, i konweruj na liczbe
                                                     -- a jesli sie nie udalo, to blad
  end;
   end;
   return nvl(res, valueWhenEmpty);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function isNumber ( str varchar2 ) return varchar2  is
   t number;
  begin
    t := strToNumber (str);
    return 'Y';
  exception
   when others then return 'N';
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure pushModuleName ( moduleName varchar2 ) is
  begin
    moduleNameForEventLog := pushLastWord(moduleName,moduleNameForEventLog, '.');
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure popModuleName is
  begin
    moduleNameForEventLog := popLastWord(moduleNameForEventLog,'.');
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure setModuleName ( moduleName varchar2 ) is
  begin
    moduleNameForEventLog := moduleName;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure insertIntoEventLog ( message varchar2, messageType varchar2 default 'I', moduleName varchar2 default 'XXMSZTOOLS', writeMessage varchar2 default 'Yes', raiseExceptions varchar2 default 'No') is
  pragma autonomous_transaction;
  maxLength number := 3900;
  
  cursor cur (pmessage varchar2, pmaxLength number) is 
               select * from  (
                 select substr(pmessage,1 + (rownum-1)*pmaxLength ,pmaxLength) submessage from dual 
                 connect by rownum  < 100 
               )
               where submessage is not null;  
  begin
   if not Xxmsz_Tools.ynToBool ( writeMessage , true) then return; end if;
   begin   
     --dzielenie na substringi o okreslonej dlugosci
     for rec in cur (message, maxLength)
     loop
       EXECUTE immediate
      'insert into xxmsztools_eventlog (id, module_name, message, message_type) values (xxmsztools_eventlog_seq.nextval, :module_name,:message,:messageType)'
      using  NVL(moduleName,moduleNameForEventLog)
           , rec.submessage
           , messageType;
     end loop;
     commit;
   exception
     when OTHERS then
       EXECUTE immediate
      'insert into xxmsztools_eventlog (id, module_name, message, message_type) values (xxmsztools_eventlog_seq.nextval, :module_name,:message,''E'')'
    using NVL(moduleName,moduleNameForEventLog)
        , replace('Unable to insert message : ' || TO_CHAR (sqlcode) || ' ' || sqlerrm ,'''','''''');
       commit;
       if Xxmsz_Tools.ynToBool ( raiseExceptions, false ) then raise; end if;
   end;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function insertIntoEventLog (pdate date, pvalue varchar) return varchar2 is
  begin
    if pdate = trunc(sysdate) then
      insertIntoEventLog(pvalue, 'I', 'insertIntoEventLog' || to_char(pdate, 'yyyy-mm-dd'));
 else
  raise_application_error(-20000, 'Wylacz debug- funkcja insertIntoEventLog');
 end if;
    return null;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure dbms_outputPut_line (
      str         in   varchar2,
      len         in   integer := 254,
      expand_in   in   boolean := true
   )
   is
      v_len   pls_integer     := LEAST (len, 255);
      v_str   varchar2 (2000);
   begin
      if LENGTH (str) > v_len
      then
         v_str := SUBSTR (str, 1, v_len);
         DBMS_OUTPUT.put_line (v_str);
         dbms_outputPut_line (SUBSTR (str, len   + 1), v_len,expand_in);
      else
         v_str := str;
         DBMS_OUTPUT.put_line (v_str);
      end if;
   exception
      when OTHERS
      then
         if expand_in
         then
            DBMS_OUTPUT.ENABLE (1000000);
            DBMS_OUTPUTput_line (v_str);
         else
            raise;
         end if;
   end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function strToAsc ( strString varchar2 ) return varchar2 is
   res varchar2(30000);
  begin
    res := null;
    for i in 1..LENGTH( strString ) loop
      res :=  Xxmsz_Tools.merge(res, ASCII( SUBSTR(strString,i,1) ),',');
    end loop;
    return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function ascToStr ( ascString varchar2 ) return varchar2 is
   res varchar2(30000);
  begin
    res := null;
    for i in 1..Xxmsz_Tools.wordCount (AscString, ',') loop
      res :=  res || CHR( Xxmsz_Tools.extractWord(i, AscString, ',') );
    end loop;
    return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure setParameter ( userId varchar2, paramName varchar2, value varchar2 ) is
    pragma autonomous_transaction;
  begin
    EXECUTE immediate 'DELETE FROM XXMSZTOOLS_EVENTLOG WHERE module_name = ''parametersBuffer.'||userId||'.'||paramName||'''';
    insertIntoEventLog ( value, 'I', 'parametersBuffer'||'.'||userId||'.'||paramName);
    commit;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getParameter (userId varchar2, paramName varchar2) return varchar2 is
    pragma AUTONOMOUS_TRANSACTION;
    res   varchar2 (100);
  begin
    begin
     res := getSQLValue('SELECT message FROM XXMSZTOOLS_EVENTLOG WHERE module_name = ''parametersBuffer.'||userId||'.'||paramName||'''');
     EXECUTE immediate 'DELETE FROM XXMSZTOOLS_EVENTLOG WHERE module_name = ''parametersBuffer.'||userId||'.'||paramName||'''';
     commit;
    exception
     when NO_DATA_FOUND
     then
       res := null;
    end;
    return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function maximum(
     number1  number   , number2  number   , number3  number default null   , number4  number default null   , number5  number default null
   , number6  number default null   , number7  number default null   , number8  number default null   , number9  number default null   , number10 number default null
   , number11 number default null   , number12 number default null   , number13 number default null   , number14 number default null   , number15 number default null
   , number16 number default null   , number17 number default null   , number18 number default null   , number19 number default null   , number20 number default null
   , number21 number default null   , number22 number default null   , number23 number default null   , number24 number default null   , number25 number default null
   , number26 number default null   , number27 number default null   , number28 number default null   , number29 number default null   , number30 number default null
  ) return number is
    type  tnumbers is  table  of  number  index  by  binary_integer;
 numbers tnumbers;
 res     number;
 i       number;
        function singlemax ( n1 in out number, n2 in out number) return number is
     begin
      n1 := NVL( n1, -99999999999999999999999999999999999);
      n2 := NVL( n2, -99999999999999999999999999999999999);
      if n1 >= n2 then return n1;
                  else return n2; end if;
     end;
  begin
     numbers ( 1) := number1;     numbers ( 2) := number2;     numbers ( 3) := number3;     numbers ( 4) := number4;     numbers ( 5) := number5;
     numbers ( 6) := number6;     numbers ( 7) := number7;     numbers ( 8) := number8;     numbers ( 9) := number9;     numbers (10) := number10;
     numbers (11) := number11;    numbers (12) := number12;    numbers (13) := number13;    numbers (14) := number14;    numbers (15) := number15;
     numbers (16) := number16;    numbers (17) := number17;    numbers (18) := number18;    numbers (19) := number19;    numbers (20) := number20;
     numbers (21) := number21;    numbers (22) := number22;    numbers (23) := number23;    numbers (24) := number24;    numbers (25) := number25;
     numbers (26) := number26;    numbers (27) := number27;    numbers (28) := number28;    numbers (29) := number29;    numbers (30) := number30;

  res := -99999999999999999999999999999999999;
  for i in 1..30 loop
          if numbers (i) is null then exit; end if;
   res := singlemax ( res, numbers (i) );
  end loop;
    return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function MINIMUM(
     number1  number   , number2  number   , number3  number default  null   , number4  number default  null   , number5  number default  null
   , number6  number default  null   , number7  number default  null   , number8  number default  null   , number9  number default  null   , number10 number default  null
   , number11 number default  null   , number12 number default  null   , number13 number default  null   , number14 number default  null   , number15 number default  null
   , number16 number default  null   , number17 number default  null   , number18 number default  null   , number19 number default  null   , number20 number default  null
   , number21 number default  null   , number22 number default  null   , number23 number default  null   , number24 number default  null   , number25 number default  null
   , number26 number default  null   , number27 number default  null   , number28 number default  null   , number29 number default  null   , number30 number default  null
  ) return number is
    type  tnumbers is  table  of  number  index  by  binary_integer;
 numbers tnumbers;
 res     number;
 i       number;

        function singlemin ( n1 in out number, n2 in out number) return number is
     begin
      n1 := NVL( n1, 99999999999999999999999999999999999);
      n2 := NVL( n2, 99999999999999999999999999999999999);
      if n1 <= n2 then return n1;
                  else return n2; end if;
     end;
  begin
     numbers ( 1) := number1;     numbers ( 2) := number2;     numbers ( 3) := number3;     numbers ( 4) := number4;     numbers ( 5) := number5;
     numbers ( 6) := number6;     numbers ( 7) := number7;     numbers ( 8) := number8;     numbers ( 9) := number9;     numbers (10) := number10;
     numbers (11) := number11;    numbers (12) := number12;    numbers (13) := number13;    numbers (14) := number14;    numbers (15) := number15;
     numbers (16) := number16;    numbers (17) := number17;    numbers (18) := number18;    numbers (19) := number19;    numbers (20) := number20;
     numbers (21) := number21;    numbers (22) := number22;    numbers (23) := number23;    numbers (24) := number24;    numbers (25) := number25;
     numbers (26) := number26;    numbers (27) := number27;    numbers (28) := number28;    numbers (29) := number29;    numbers (30) := number30;

  res := 99999999999999999999999999999999999;
  for i in 1..30 loop
          if numbers (i) is null then exit; end if;
   res := singlemin ( res, numbers (i) );
  end loop;
    return res;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function bin2dec (binval in char) return number is
    i                 number;
    digits            number;
    result            number := 0;
    current_digit     char(1);
    current_digit_dec number;
  begin
    digits := LENGTH(binval);
    for i in 1..digits loop
       current_digit := SUBSTR(binval, i, 1);
       current_digit_dec := TO_NUMBER(current_digit);
       result := (result * 2) + current_digit_dec;
    end loop;
    return result;
  end bin2dec;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function dec2bin (N in number) return varchar2 is
    binval varchar2(64);
    N2     number := N;
  begin
    while ( N2 > 0 ) loop
       binval := MOD(N2, 2) || binval;
       N2 := TRUNC( N2 / 2 );
    end loop;
    return binval;
  end dec2bin;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function oct2dec (octval in char) return number is
    i                 number;
    digits            number;
    result            number := 0;
    current_digit     char(1);
    current_digit_dec number;
  begin
    digits := LENGTH(octval);
    for i in 1..digits loop
       current_digit := SUBSTR(octval, i, 1);
       current_digit_dec := TO_NUMBER(current_digit);
       result := (result * 8) + current_digit_dec;
    end loop;
    return result;
  end oct2dec;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function dec2oct (N in number) return varchar2 is
    octval varchar2(64);
    N2     number := N;
  begin
    while ( N2 > 0 ) loop
       octval := MOD(N2, 8) || octval;
       N2 := TRUNC( N2 / 8 );
    end loop;
    return octval;
  end dec2oct;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function hex2dec (hexval in char) return number is
    i                 number;
    digits            number;
    result            number := 0;
    current_digit     char(1);
    current_digit_dec number;
  begin
    digits := LENGTH(hexval);
    for i in 1..digits loop
       current_digit := SUBSTR(hexval, i, 1);
       if current_digit in ('A','B','C','D','E','F') then
          current_digit_dec := ASCII(current_digit) - ASCII('A') + 10;
       else
          current_digit_dec := TO_NUMBER(current_digit);
       end if;
       result := (result * 16) + current_digit_dec;
    end loop;
    return result;
  end hex2dec;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function dec2hex (N in number) return varchar2 is
    hexval varchar2(64);
    N2     number := N;
    digit  number;
    hexdigit  char;
  begin
    while ( N2 > 0 ) loop
       digit := MOD(N2, 16);
       if digit > 9 then
          hexdigit := CHR(ASCII('A') + digit - 10);
       else
          hexdigit := TO_CHAR(digit);
       end if;
       hexval := hexdigit || hexval;
       N2 := TRUNC( N2 / 16 );
    end loop;
    return hexval;
end dec2hex;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function isLeapYear(i_year number) return boolean as
  begin
    -- A year is a leap year if it is evenly divisible by 4
    -- but not if it's evenly divisible by 100
    -- unless it's also evenly divisible by 400
  
     if MOD(i_year, 400) = 0 or ( MOD(i_year, 4) = 0 and MOD(i_year, 100) != 0) then
        return true;
     else
        return false;
     end if;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function has_common_part(
     pa1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pa2 date default to_date('4000-12-31','yyyy-mm-dd') 
   , pb1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pb2 date default to_date('4000-12-31','yyyy-mm-dd')
   ) return varchar2 is
       a1 date;
       a2 date;
       b1 date;
       b2 date;
  begin
    a1 := nvl(pa1, to_date('1000-01-01','yyyy-mm-dd')); 
    a2 := nvl(pa2, to_date('4000-12-31','yyyy-mm-dd')); 
    b1 := nvl(pb1, to_date('1000-01-01','yyyy-mm-dd')); 
    b2 := nvl(pb2, to_date('4000-12-31','yyyy-mm-dd'));     
    --insertintoeventlog('a1='||a1||' a2='|| a2 ||' b1='|| b1 ||' b2='|| b2, 'I', 'has_common_part');
  
    -- Okres czasowy (A1,A2) ma czesc wspólna z okresem czasowym (B1,B2), gdy spelniony jest nastepujacy warunek logiczny:  
    if  (A1 >= B1 or A2 >= B1) and (A1 <= B2 or A2 <= B2)  then
      return 'Y';
    else
      return 'N';
    end if; 
  end;


 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  /*   
  Porównuje okres A1-A2 z okresem B1-B2
                      A1      A2
                      |=========|  
                      |         |
                  B1==|=========|==B2               INSIDES                  
                      |  =====  |                   IS_INSIDE
                      |    =====|                   IS_INSIDE_RJUSTIFY
                      |=====    |                   IS_INSIDE_LJUSTIFY
                      |         |
      ========        |         |                   IS_BEFORE_GAP
              ========|         |                   IS_BEFORE_NO_GAP
                ======|===      |                   IS_BEFORE_COMMON_PART
                      |=========|                   THE_SAME   
                      |      ===|======             IS_AFTER_COMMON_PART
                      |         |========           IS_AFTER_NO_GAP
                      |         |       ========    IS_AFTER_GAP
                                                    BAD_PERIOD_A
                                                    BAD_PERIOD_B
  */
  function compare_periods(
     pa1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pa2 date default to_date('4000-12-31','yyyy-mm-dd') 
   , pb1 date default to_date('1000-01-01','yyyy-mm-dd') 
   , pb2 date default to_date('4000-12-31','yyyy-mm-dd')
   ) return varchar2 is
     a1 date;
     a2 date;
     b1 date;
     b2 date;
  begin
    a1 := nvl(pa1, to_date('1000-01-01','yyyy-mm-dd')); 
    a2 := nvl(pa2, to_date('4000-12-31','yyyy-mm-dd')); 
    b1 := nvl(pb1, to_date('1000-01-01','yyyy-mm-dd')); 
    b2 := nvl(pb2, to_date('4000-12-31','yyyy-mm-dd'));     
    --insertintoeventlog('a1='||a1||' a2='|| a2 ||' b1='|| b1 ||' b2='|| b2, 'I', 'compare_periods');
    
    if a1 > a2             then return 'BAD_PERIOD_A'           ; end if;
    if b1 > b2             then return 'BAD_PERIOD_B'           ; end if;

    if b1 < a1 and b2 > a2 then return 'INSIDES'                ; end if;
    if b1 > a1 and b2 < a2 then return 'IS_INSIDE'              ; end if;

    if b1 > a1 and b2 = a2 then return 'IS_INSIDE_RJUSTIFY'     ; end if;
    if b1 = a1 and b2 < a2 then return 'IS_INSIDE_LJUSTIFY'     ; end if;
    
    if b1 < a1 and b2 < a1 then return 'IS_BEFORE_GAP'          ; end if;
    if b1 < a1 and b2 = a1 then return 'IS_BEFORE_NO_GAP'       ; end if;
    if b1 < a1 and b2 > a1 then return 'IS_BEFORE_COMMON_PART'  ; end if;
    if b1 = a1 and b2 = a2 then return 'THE_SAME'               ; end if;
    if b1 < a2 and b2 > a2 then return 'IS_AFTER_COMMON_PART'   ; end if;
    if b1 = a2 and b2 > a2 then return 'IS_AFTER_NO_GAP'        ; end if;
    if b1 > a2 and b2 > a2 then return 'IS_AFTER_GAP'           ; end if;    
  end;

   

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function encrypt (i_password varchar2) return varchar2 is
    v_encrypted_val varchar2(38);
    v_data          varchar2(38);
  begin
     -- Input data must have a length divisible by eight
     v_data := RPAD(i_password,(TRUNC(LENGTH(i_password)/8)+1)*8,CHR(0));

     DBMS_OBFUSCATION_TOOLKIT.DESENCRYPT(
        input_string     => v_data,
        key_string       => c_encrypt_key,
        encrypted_string => v_encrypted_val);
     return v_encrypted_val;
  end encrypt;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function decrypt (i_password varchar2) return varchar2 is
    v_decrypted_val varchar2(38);
  begin
     DBMS_OBFUSCATION_TOOLKIT.DESDECRYPT(
        input_string     => i_password,
        key_string       => c_encrypt_key,
        decrypted_string => v_decrypted_val);
     return v_decrypted_val;
  end decrypt;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getPeriodID(backlogInDays number, periodInterval number, maxBacklog number default -1000, maxBacklogText varchar2 default 'Pozostale', FutureText varchar2  default 'Biezace' ) return number is
  begin
   if backlogInDays >= 0             then return           0; end if;
   if backlogInDays < maxBacklog then return -9999999999; end if;
   return trunc((backlogInDays+1) /periodInterval)  -1;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getPeriodName(backlogInDays number, periodInterval number, maxBacklog number default -1000, maxBacklogText varchar2 default 'Pozostale', FutureText varchar2  default 'Biezace' ) return varchar2 is
    absPeriodID number;
  begin
   if backlogInDays >= 0             then return FutureText; end if;
   if backlogInDays < maxBacklog then return maxBacklogText; end if;
   absPeriodID := abs ( getPeriodID(backlogInDays, periodInterval, maxBacklog, maxBacklogText, FutureText));

   return (absPeriodID * periodInterval) || '-' || (absPeriodID * periodInterval -  periodInterval + 1);
  end;


/*
n>=0 => biezace , 0
n<-1000 => zalegle, -9999

select trunc((-6+1) /5)  -1, abs(trunc((-6+1) /5)  -1)*5 || '-' || (abs(trunc((-6+1) /5)  -1)*5 -4)
  from dual
*/

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function long2varchar( p_query  in varchar2,
                             p_name1   in varchar2 default null,
                             p_value1  in varchar2  default null,
                             p_name2   in varchar2 default null,
                             p_value2  in varchar2  default null,
                             p_name3   in varchar2 default null,
                             p_value3  in varchar2  default null,
                             p_name4   in varchar2 default null,
                             p_value4  in varchar2  default null
                            ) return varchar2
  as
      l_cursor    integer default dbms_sql.open_cursor;
      l_n         number;
      l_long_val  varchar2(250);
      l_long_len  number;
      l_buflen    number := 250;
      l_curpos    number := 0;
      l_out       varchar2(32000) := '';
  begin
      dbms_sql.parse( l_cursor, p_query, dbms_sql.native );
      if p_name1 is not null then  dbms_sql.bind_variable( l_cursor, p_name1, p_value1 );   end if;
      if p_name2 is not null then  dbms_sql.bind_variable( l_cursor, p_name2, p_value2 );   end if;
      if p_name3 is not null then  dbms_sql.bind_variable( l_cursor, p_name3, p_value3 );   end if;
      if p_name4 is not null then  dbms_sql.bind_variable( l_cursor, p_name4, p_value4 );   end if;
      dbms_sql.define_column_long(l_cursor, 1);
      l_n := dbms_sql.execute(l_cursor);
      if (dbms_sql.fetch_rows(l_cursor) > 0)
      then
          loop
              dbms_sql.column_value_long(l_cursor, 1, l_buflen,
                                         l_curpos , l_long_val,
                                         l_long_len );
              l_curpos := l_curpos + l_long_len;
              --dbms_output.put_line( l_long_val );
              if length(l_out || l_long_val) < 4000 then
                l_out := l_out || l_long_val;
              else
                l_out := substr(l_out || l_long_val,1,4000);
                exit;
              end if;
              exit when l_long_len = 0;
        end loop;
     end if;
     --dbms_output.put_line( '====================' );
     --dbms_output.put_line( 'Long was ' || l_curpos || ' bytes in length' );
     dbms_sql.close_cursor(l_cursor);
     return substr(l_out,1,4000);
  exception
     when others then
        if dbms_sql.is_open(l_cursor) then
           dbms_sql.close_cursor(l_cursor);
        end if;
        raise;
  end;
  
   /*
   commented due to ensure platform-independent form of this package
   procedure insertIntoEventLog
    ( itemtype  in     varchar2
    , itemkey   in     varchar2
    , actid     in     number
    , funcmode  in     varchar2
    , result    out    varchar2) is
      messageText varchar2(100);
   begin
     messageText := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'MESSAGE');
     xxmsz_tools.insertIntoEventLog( messageText );
     result :=  'COMPLETE:';
  
   exception
     when others then
        wf_core.context('ITEM_TYPE_HERE', 'xxmsz_tools.insertIntoEventLog', itemtype, itemkey, 'sqlerrm=' || sqlerrm);
        raise;
   end;
   */

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure addHeader (ptableDef in out nocopy tTableDef, ptableRow varchar2, pcolWidths varchar2 default null, palligns varchar2 default null, ptokenSeparator varchar2 default '|') is
   colWidth number;
   colAllign varchar2(30);
   
  begin
   ptableDef.tokenSeparator := ptokenSeparator;
   ptableDef.ColumnCount := xxmsz_tools.wordCount(ptableRow, ptableDef.tokenSeparator);
   
   --if pcolWidths is not null then
     for t in 1..ptableDef.ColumnCount loop
       colWidth := nvl( to_number ( xxmsz_tools.extractWord(t, pcolWidths, ptableDef.tokenSeparator) ) , 0 );
       ptableDef.tableWidths (t).width := colWidth;
       if colWidth > 0 then
         ptableDef.tableWidths (t).autowidth := 'N';
       else
         ptableDef.tableWidths (t).autowidth := 'Y';        
       end if;      
     end loop;  
   --end if;
 
   for t in 1..ptableDef.ColumnCount loop
     if ptableDef.tableWidths(t).autowidth = 'Y' then
       ptableDef.tableWidths (t).width := greatest ( ptableDef.tableWidths(t).width , length ( xxmsz_tools.extractWord(t, ptableRow, ptableDef.tokenSeparator) ) );      
     end if;
     ptableDef.tableWidths (t).allign := 'left';
   end loop; 
   
   if palligns is not null then
     for t in 1..ptableDef.ColumnCount loop
       colAllign := xxmsz_tools.extractWord(t, palligns, ptableDef.tokenSeparator);
       if colAllign is not null then
         if lower(colAllign) not in ('left','right','middle') then raise_application_error (-20000, 'invalid value of colAllign'); end if;
         ptableDef.tableWidths (t).allign := colAllign;
       end if;
     end loop;  
   end if;
 
 
   ptableDef.tableRows( ptableDef.tableRows.count ) := ptableRow;
  end;
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
   procedure addLine   (pTableDef in out nocopy tTableDef, ptableRow varchar2) is
   begin
    ptableDef.ColumnCount := xxmsz_tools.wordCount(ptableRow, ptableDef.tokenSeparator);
    
    for t in 1..ptableDef.ColumnCount loop
      if ptableDef.tableWidths(t).autowidth = 'Y' then
        ptableDef.tableWidths (t).width := greatest ( ptableDef.tableWidths(t).width , nvl( length ( xxmsz_tools.extractWord(t, ptableRow, ptableDef.tokenSeparator) ), 0) );
      end if;
    end loop; 
    
    ptableDef.tableRows( ptableDef.tableRows.count ) := ptableRow;
   exception
    when no_Data_found then
      raise_application_error(-20000, 'Character | is not allowed as a value');
    when others then
      raise_application_error(-20000, 'AddLine. sqlerrm=' || sqlerrm);      
   end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
   procedure showTable (ptableDef in out nocopy xxmsz_tools.tTableDef) is
      WordWrap xxmsz_tools.tWordWrap;
      TableLine varchar2 (1000);
      tableRow  varchar2 (1000);
      --+----------------------+----------------------+-------------------+---------------+ tableLine
      --|                      |                      |                   |               | tableRow
      allign number;
      procedure wout (m varchar2) is
      begin
        xxmsz_tools.dbms_outputPut_line ( m );
      end;    
      procedure insertLines ( WordWrap in out xxmsz_tools.tWordWrap ) is
        i number;
      begin
        if WordWrap.errorMessage is not null then xxmsz_tools.dbms_outputPut_line (WordWrap.errorMessage); end if;
        for i in 1..xxmsz_tools.wordWrapGetNumberOfLines(WordWrap) loop
          wout ( xxmsz_tools.wordWrapGetLine(WordWrap,i) );
        end loop;
      end;
    begin
      TableLine := null;
      for t in 1..ptableDef.ColumnCount loop
        TableLine := TableLine || '+' || lpad('-', ptableDef.tableWidths (t).width , '-');
      end loop; 
      TableLine := TableLine || '+';
      
      tableRow := null;
      for t in 1..ptableDef.ColumnCount loop
        tableRow := tableRow || '|' || lpad( chr(t+65), ptableDef.tableWidths (t).width , chr(t+65));
      end loop; 
      tableRow := tableRow || '|';    
  
      wout(TableLine);      
      for c in 0..ptableDef.tableRows.count-1 loop
        xxmsz_tools.wordWrapInit (WordWrap,tableRow);
        for t in 1..ptableDef.ColumnCount loop
          select decode ( lower(ptableDef.tableWidths (t).allign), 'right', xxmsz_tools.right, 'left', xxmsz_tools.left, xxmsz_tools.middle) into allign from dual;              
          xxmsz_tools.wordWrapPrepareColumn(WordWrap
             , xxmsz_tools.extractWord(t, ptableDef.tableRows(c), ptableDef.tokenSeparator)
             , lpad( chr(t+65), ptableDef.tableWidths (t).width , chr(t+65)) 
             , allign );
        end loop; 
        insertLines ( WordWrap );
        if c = 0 then wout(TableLine); end if;
      end loop;        
      wout(TableLine);  
    end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
   procedure destroy (ptableDef in out nocopy tTableDef) is
   begin
    ptableDef.tableWidths.delete;
    ptableDef.tableRows.delete;
    ptableDef.ColumnCount := 0;
   end; 
  
   -- by http://oracle.anilpassi.com
   function emailIsOk ( EMAIL  varchar2 ) return  varchar2 is
    l_dot_pos    number;
    l_at_pos     number;
    l_str_length number;
   begin
    l_dot_pos    := instr(email
                         ,'.');
    l_at_pos     := instr(email
                         ,'@');
    l_str_length := length(email);
    if ((l_dot_pos = 0) or (l_at_pos = 0) or (l_dot_pos = l_at_pos + 1) or
       (l_at_pos = 1) or (l_at_pos = l_str_length) or
       (l_dot_pos = l_str_length))
    then
      return 'N';
    end if;
    if instr(substr(email
                   ,l_at_pos)
            ,'.') = 0
    then
      return 'N';
    end if;
    return 'Y';
   end;
   

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function extnvl (
   v1 varchar2,v2 varchar2,v3 varchar2 default null,v4 varchar2 default null,v5 varchar2 default null
  ,v6 varchar2 default null,v7 varchar2 default null,v8 varchar2 default null,v9 varchar2 default null,v10 varchar2 default null
  ,v11 varchar2 default null,v12 varchar2 default null,v13 varchar2 default null,v14 varchar2 default null,v15 varchar2 default null
  ,v16 varchar2 default null,v17 varchar2 default null,v18 varchar2 default null,v19 varchar2 default null,v20 varchar2 default null
  ) return varchar2
  is 
  begin
   return 
     nvl( v1, nvl(v2, nvl(v3, nvl(v4, nvl(v5, nvl(v6, nvl(v7, nvl(v8, nvl(v9, nvl(v10, nvl(v11, nvl(v12, nvl(v13, nvl(v14, nvl(v15, nvl(v16, nvl(v17, nvl(v18, nvl(v19, v20)))))))))))))))))));
  end;    
   
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function extnvl (
   v1 number,v2 number,v3 number default null,v4 number default null,v5 number default null
  ,v6 number default null,v7 number default null,v8 number default null,v9 number default null,v10 number default null
  ,v11 number default null,v12 number default null,v13 number default null,v14 number default null,v15 number default null
  ,v16 number default null,v17 number default null,v18 number default null,v19 number default null,v20 number default null
  ) return number   
  is 
  begin
   return 
     nvl( v1, nvl(v2, nvl(v3, nvl(v4, nvl(v5, nvl(v6, nvl(v7, nvl(v8, nvl(v9, nvl(v10, nvl(v11, nvl(v12, nvl(v13, nvl(v14, nvl(v15, nvl(v16, nvl(v17, nvl(v18, nvl(v19, v20)))))))))))))))))));
  end;    

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function extnvl (
   v1 date,v2 date,v3 date default null,v4 date default null,v5 date default null
  ,v6 date default null,v7 date default null,v8 date default null,v9 date default null,v10 date default null
  ,v11 date default null,v12 date default null,v13 date default null,v14 date default null,v15 date default null
  ,v16 date default null,v17 date default null,v18 date default null,v19 date default null,v20 date default null
  ) return date   
  is 
  begin
   return 
     nvl( v1, nvl(v2, nvl(v3, nvl(v4, nvl(v5, nvl(v6, nvl(v7, nvl(v8, nvl(v9, nvl(v10, nvl(v11, nvl(v12, nvl(v13, nvl(v14, nvl(v15, nvl(v16, nvl(v17, nvl(v18, nvl(v19, v20)))))))))))))))))));
  end;    


 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function startOfTime return date is
  begin
   return c_start_of_time;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function endOfTime return date is
  begin
   return c_end_of_time;
  end;
 
 -------------------------------------------------------------------------
 --zmienia niedozwolone znaki XML na kody
 --wiecej na ten temat w Wikipedii i http://www.kurshtml.boo.pl/generatory/unicode.html
 function replaceXMLchars (buffer in varchar2) return varchar2 is
 begin
   return replace(replace(replace(replace(replace(buffer , '&', '&'||'amp;'), '>', '&'||'gt;'), '<', '&'||'lt;'), '''', '&'||'apos;'), '"', '&'||'quot;');
 end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function erasePolishHooks(S varchar2) return varchar2 is
  begin
    return erasePolishChars(s);
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function allTableColumns (pTableName varchar2, pColumNameFilter varchar2 default '%') return varchar2 is
   vOwner     varchar2(255);
   vTableName varchar2(255); 
   res        varchar2(32000);
  begin
    if xxmsz_tools.wordCount(pTableName,'.') = 1 then
      vTableName := pTableName;
      select owner into vOwner from all_tables where table_name = pTableName and rownum = 1;        
    else
      vOwner     := xxmsz_tools.extractWord(1,pTableName,'.');
      vTableName := xxmsz_tools.extractWord(2,pTableName,'.');
    end if;
    
    res := '''|''';
    
    for rec in (select case 
                        when data_type = 'VARCHAR2' then column_name  
                        when data_type = 'NUMBER'   then 'to_char('||column_name||')'
                        when data_type= 'DATE'     then 'to_char('||column_name||')'
                        --when data_type= 'LONG'     then 'to_char('||column_name||')'
                        --when data_type= 'XMLTYPE'  then 'to_char('||column_name||')'
                        when data_type= 'TIMESTAMP(6)'  then 'to_char('||column_name||')'
                        when data_type= 'TIMESTAMP(9)'  then 'to_char('||column_name||')'
                        --when data_type= 'CLOB'  then 'to_char('||column_name||')'
                        when data_type= 'CHAR'  then column_name
                       end column_name 
                 from all_tab_cols 
                where owner = vOwner 
                  and table_name = vTableName
                  and column_name like pColumNameFilter
                  and virtual_column = 'NO'
                order by column_id )
    loop
      res := xxmsz_tools.merge(res, rec.column_name, '||''|''||');
    end loop;            
    return res;
  end;
  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure delete_not_used_records ( pTable_name varchar2 ) is 
  begin
    execute immediate 
     'begin '||
     ' for rec in (select rowid from '||pTable_name||' ) '||
     ' loop '||
     '   begin '||
     '     delete from '||pTable_name||' where rowid = rec.rowid; '||
     '   exception '||
     '    when others then null; '||
     '   end; '|| 
     ' end loop; '||
     'end;';  
  end;
  
  
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function get_primary_key( p_owner varchar2, p_table_name varchar2 ) return varchar2 is
    --
    v_pk_name    varchar2(30);
    v_pk_columns varchar2(2000);
    --
  begin
    --
    select constraint_name
      into v_pk_name
      from all_constraints
     where owner = p_owner
       and table_name = p_table_name
       and constraint_type = 'P';
    --
    for c_rec in (select column_name from all_cons_columns where constraint_name = v_pk_name and owner = p_owner and table_name = p_table_name order by position) loop
      v_pk_columns := v_pk_columns||c_rec.column_name||',';
    end loop;
    --
    return trim(',' from v_pk_columns);
    --
  end get_primary_key;


 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure merge_records(pOwner varchar2, pTable_Name varchar2, pOldId varchar2, pNewId varchar2, pkColumn varchar2) is
    cntOldId number;
    cntNewId number;    
  begin
    execute immediate 'select count(*) from '||pOwner||'.'||pTable_Name||' where '||pkColumn||' = :pOldId' into cntOldId using pOldId;
    execute immediate 'select count(*) from '||pOwner||'.'||pTable_Name||' where '||pkColumn||' = :pOldId' into cntNewId using pNewId;
    if cntOldId <> 1 then raise_application_error(-20000, 'Error. '||cntOldId||' old records found'); end if;  
    if cntNewId <> 1 then raise_application_error(-20000, 'Error. '||cntNewId||' new records found for "'||pNewId||'"'); end if;

    for rec in 
    (
      SELECT   U.NAME detail_owner
             , O.NAME detail_table
               , trim ( ';' from
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 4) ) 
                  detail_cols
               , trim ( ';' from 
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 4) ) 
                 master_cols
            FROM   SYS.CDEF$ C, SYS.CON$ CN, SYS.OBJ$ O, SYS.USER$ U,
                   SYS.CON$ RC, SYS.USER$ RU, SYS.OBJ$ RO
            WHERE  C.CON# = CN.CON#
            AND    C.OBJ# = O.OBJ#
            AND    O.OWNER# = U.USER#
            AND    C.RCON# = RC.CON#(+)
            AND    RC.OWNER# = RU.USER#(+)
            AND    C.ROBJ# = RO.OBJ#(+)
            and c.type# = 4 -- = Referential Integrity
            --
            AND  ro.name  = pTable_Name
            and  ru.name  = pOwner --master_owner 
    )
    loop
      if rec.detail_cols like '%;%' then raise_application_error(-20000, 'Error. Multicolumn joins are not supprted yet'); end if;
      if rec.master_cols <> pkColumn then raise_application_error(-20000, 'Error. Bad PK column '||pkColumn||' Should be ' || rec.master_cols ); end if;
      execute immediate 'update '||rec.detail_owner||'.'||rec.detail_table||' set '||rec.detail_cols||' = :pNewId where '||rec.detail_cols||' = :pOldId'
        using pNewId, pOldId;
    end loop;
    execute immediate 'delete from  '||pOwner||'.'||pTable_Name||' where '||pkColumn||' = :pOldId' using pOldId;
  end;
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure disable_constraints(pOwner varchar2, pTable_Name varchar2, pkColumn varchar2) is
  begin
    for rec in 
    (
      SELECT   U.NAME detail_owner, O.NAME detail_table
               , trim ( ';' from
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 4) ) 
                  detail_cols
               , trim ( ';' from 
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 4) ) 
                 master_cols
              , cn.name   cname
            FROM   SYS.CDEF$ C, SYS.CON$ CN, SYS.OBJ$ O, SYS.USER$ U,
                   SYS.CON$ RC, SYS.USER$ RU, SYS.OBJ$ RO
            WHERE  C.CON# = CN.CON#
            AND    C.OBJ# = O.OBJ#
            AND    O.OWNER# = U.USER#
            AND    C.RCON# = RC.CON#(+)
            AND    RC.OWNER# = RU.USER#(+)
            AND    C.ROBJ# = RO.OBJ#(+)
            and c.type# = 4 -- = Referential Integrity
            --
            AND  ro.name  = pTable_Name
            and  ru.name  = pOwner --master_owner 
    )
    loop
      if rec.detail_cols like '%;%' then raise_application_error(-20000, 'Error. Multicolumn joins are not supprted yet'); end if;
      if rec.master_cols <> pkColumn then raise_application_error(-20000, 'Error. Bad PK column '||pkColumn||' Should be ' || rec.master_cols ); end if;
      execute immediate 'ALTER TABLE '||rec.detail_owner||'.'||rec.detail_table||' DISABLE CONSTRAINT  '||rec.cname;
    end loop;
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure enable_constraints(pOwner varchar2, pTable_Name varchar2, pkColumn varchar2) is
  begin
    for rec in 
    (
      SELECT   U.NAME detail_owner, O.NAME detail_table
               , trim ( ';' from
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 4) ) 
                  detail_cols
               , trim ( ';' from 
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 4) ) 
                 master_cols
              , cn.name   cname
            FROM   SYS.CDEF$ C, SYS.CON$ CN, SYS.OBJ$ O, SYS.USER$ U,
                   SYS.CON$ RC, SYS.USER$ RU, SYS.OBJ$ RO
            WHERE  C.CON# = CN.CON#
            AND    C.OBJ# = O.OBJ#
            AND    O.OWNER# = U.USER#
            AND    C.RCON# = RC.CON#(+)
            AND    RC.OWNER# = RU.USER#(+)
            AND    C.ROBJ# = RO.OBJ#(+)
            and c.type# = 4 -- = Referential Integrity
            --
            AND  ro.name  = pTable_Name
            and  ru.name  = pOwner --master_owner 
    )
    loop
      execute immediate 'ALTER TABLE '||rec.detail_owner||'.'||rec.detail_table||' ENABLE CONSTRAINT  '||rec.cname;
    end loop;
  end;
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure update_record(pOwner varchar2, pTable_Name varchar2, pOldId varchar2, pNewId varchar2, pkColumn varchar2) is
    cntOldId number;
    cntNewId number;    
  begin
    execute immediate 'select count(*) from '||pOwner||'.'||pTable_Name||' where '||pkColumn||' = :pId' into cntOldId using pOldId;
    execute immediate 'select count(*) from '||pOwner||'.'||pTable_Name||' where '||pkColumn||' = :pId' into cntNewId using pNewId;
    if cntOldId <> 1 then raise_application_error(-20000, 'Error. '||cntOldId||' old records found'); end if;  
    if cntNewId <> 0 then raise_application_error(-20000, 'Error. '||cntNewId||' new records found pNewId=' || pNewId); end if;

    for rec in 
    (
      SELECT   U.NAME detail_owner, O.NAME detail_table
               , trim ( ';' from
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=u.name) and (constraint_name=cn.name) and position = 4) ) 
                  detail_cols
               , trim ( ';' from 
                 (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 1) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 2) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 3) 
               ||';'|| (Select column_name from  sys.ALL_CONS_COLUMNS where (owner=ru.name) and (constraint_name=rc.name) and position = 4) ) 
                 master_cols
              , cn.name   cname
            FROM   SYS.CDEF$ C, SYS.CON$ CN, SYS.OBJ$ O, SYS.USER$ U,
                   SYS.CON$ RC, SYS.USER$ RU, SYS.OBJ$ RO
            WHERE  C.CON# = CN.CON#
            AND    C.OBJ# = O.OBJ#
            AND    O.OWNER# = U.USER#
            AND    C.RCON# = RC.CON#(+)
            AND    RC.OWNER# = RU.USER#(+)
            AND    C.ROBJ# = RO.OBJ#(+)
            and c.type# = 4 -- = Referential Integrity
            --
            AND  ro.name  = pTable_Name
            and  ru.name  = pOwner --master_owner 
    )
    loop
      if rec.detail_cols like '%;%' then raise_application_error(-20000, 'Error. Multicolumn joins are not supprted yet'); end if;
      if rec.master_cols <> pkColumn then raise_application_error(-20000, 'Error. Bad PK column '||pkColumn||' Should be ' || rec.master_cols ); end if;
      execute immediate 'ALTER TABLE '||rec.detail_owner||'.'||rec.detail_table||' DISABLE CONSTRAINT  '||rec.cname;
      execute immediate 'update '||rec.detail_owner||'.'||rec.detail_table||' set '||rec.detail_cols||' = :pNewId where '||rec.detail_cols||' = :pOldId'
        using pNewId, pOldId;
    end loop;

    execute immediate 'update  '||pOwner||'.'||pTable_Name||' set '||pkColumn||' = :pNewId where '||pkColumn||' = :pOldId'  using pNewId, pOldId;
    
    enable_constraints(pOwner , pTable_Name , pkColumn );
  end;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
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
    
 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure WriteToClob  ( clob_loc      in out nocopy clob,msg_string    in  varchar2) is
   pos integer;
   amt number;
  begin    
     pos :=   dbms_lob.getlength(clob_loc) +1;
     amt := length(msg_string);
     dbms_lob.write(clob_loc,amt,pos,msg_string);    
  end WriteToClob;

 ---------------------------------------------------------------------------------------------------------------------------------------------------------
  function getAbbreviation ( s varchar2 ) return varchar2 is
  begin
    return REPLACE(translate(upper( erasePolishChars(s) ),'AEIOUY ','@@@@@@@@@@@@@@@@@@@@'),'@','');
  end; 
  
  
end;