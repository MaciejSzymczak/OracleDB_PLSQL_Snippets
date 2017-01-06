eksport danych w formacie xml
==================================
--!xml export

set  echo on
set  long 32000
var  cb clob
declare
  c             dbms_xmlquery.ctxtype;
begin
  c := dbms_xmlquery.newContext('select * from xxzaw007_definicja_klauzul_all');
--  dbms_xmlquery.setTagCase(c,1);
--  dbms_xmlquery.setBindValue(c,'deptno',10);
  :cb := dbms_xmlquery.getXML(c);
  dbms_xmlquery.closeContext(c);
end;
/
print cb


xml
-------------------------------------------------
swietny material: "SQL-XML.mht"

typ do przechowywania XML:
    XMLTYPE

2/funkcje do wykonywania roznych rzeczy na XMLTYPE ( to jest alternatywa do  dbms_xmldom - this package is obsolete due performance issues, use xmltype instead ):

READING XML:
==========================================================================================================================================
  SELECT extractvalue(value(d),'/TABLE_NAME') as TABLE_NAMEFROM 
   from table( xmlsequence( extract(xmltype.createXML(dbms_xmlgen.getxml('select * from user_tables')),'/ROWSET/ROW/TABLE_NAME'))) d 
    
    xmltable <-- funkcja która zmienia plik XML w tabelê, jej argumentem moze byc. xmltype.createXML <--zmiania cloba w xml
    xmltable obsluguje tez specjalny jezyk do analizy xml ( where, order by  )
    
    EXTRACT      - zwraca ca³¹ ga³¹Ÿ (xmltype), tj. wartoœæ otoczon¹ znacznikami np. <VAL>Ala</VAL>, mo¿e byæ kilka wartoœci np. <VAL>Ala</VAL><VAL>Ala</VAL>    
    EXTRACTVALUE - zwraca wartoœæ bez znaczników np. Ala, zawsze jedna wartoœæ  
                   EXTRACTVALUE = xmltype.extract().getStringVal 

    XMLSequence - rozbija XML na wiele wierszy, w ten sposób sql zwróci wiele wierszy, a nie jeden wiersz. Inverse of XMLAGG
    EXISTSNODE

WRITING XML:
==========================================================================================================================================
    XMLElement    : SELECT to_clob( XMLElement("statusRaportu",'Zbyt wiele wyników podczas pobierania XML_DATA!')  ) FROM dual --> <statusRaportu>Zbyt wiele wyników podczas pobierania XML_DATA!</statusRaportu>
    XMLAttribiutes: SELECT to_clob ( XMLElement("tns:parameter",XMLATTRIBUTES('attrvalue1' as "first",'attrvalue2' as "second"), XMLElement("tns:inside",'insideval'), null, null) ) FROM dual
    appendChildXML: SELECT to_clob ( appendChildXML(   XMLElement("Liabilities",'vLiabilities')  ,'/Liabilities',  XMLElement("inside",'vinside') ) ) FROM DUAL; --> <Liabilities>vLiabilities<inside>vinside</inside></Liabilities>
    XMLCDATA
    XMLCOMMENT  
    XMLPI                                                                
    XMLROOT   
      SELECT to_clob(XMLROOT(XMLELEMENT("x", dummy), VERSION '1.0', STANDALONE YES)) FROM dual

    pretty formatting
     there is an easy way of turning so-called "pretty-printing" on, and that's by using the EXTRACT method of XMLELEMENT, with either the "/" or "/*" XPath expressions, i.e. 
     SQL> SELECT XMLELEMENT("test", XMLELEMENT("test2", NULL),
       2                            XMLELEMENT("test3", NULL)).EXTRACT('/*')
       3    FROM dual;     
     */result
     --------------------------------------------------------------------------------
     <test>
       <test2/>
       <test3/>
     </test>
     Note, for further information see Metalink note : 301262.1, or this Metalink forum entry. 
     
MANIPULATING XML
==========================================================================================================================================
    DELETEXML
    UPDATEXML


inne funkcje xml plsql (http://www.psoug.org/reference/xml_functions.html)

XMLCAST (new in 11g)
DEPTH

INSERTCHILDXML
INSERTXMLBEFORE
PATH
SYS_DBURIGEN
SYS_XMLAGG
SYS_XMLGEN

itd.

http://psoug.org/reference/builtin_functions.html 
XMLCOLLATVAL                                 
XMLDIFF                            
XMLEXISTS                                
XMLFOREST                                 
XMLISVALID                                 
XMLPARSE                                 
XMLPATCH                                 
XMLQUERY                                                             
XMLSERIALIZE                                
XMLTABLE                                 
XMLTRANSFORM  
 obsolete alternative for this function is "XSLProcessor.PROCESSXSL" more: zsip_dossier.zip

3/ poza tym xmltype ma równie¿ wbudowane funkcje np.

xmltype.extract 

przyk³ad na budowanie XML
-------------------------------

select to_clob(
       XMLROOT(
       xmlelement("r"
         , xmlattributes('attr1' as "val1", 'attr2' as "val2") 
         , 'val'
        ,(
         select xmlelement("inside"
                ,xmlagg (
                  xmlelement("r"
                  , a
                  )
                )
                )
           from (      
                select '1' a from dual union select '2' from dual union select '3' from dual
                )
         )       
       )
       , VERSION '1.0', STANDALONE YES)
       )       
  from dual

przyk³ad na czytanie XML
-----------------------------------

select to_clob( extract( column_value , '/r/text()')) 
  from table (xmlsequence(
       ( 
       select extract(d, '//r') 
        from (
             select xmltype.createxml(
                 --'<rowset><r>1</r><r>2</r><r>3</r><r>4</r><r>5</r></rowset>'
                 ( select  '<rowset><r>'||replace(d,',','</r><r>')||'</r></rowset>' from (select 'A,B,C,D,E,F,G,H' d from dual)  )
               ) d
               from dual
             )
       )     
       )) d      

enumeration
-----------------------------------
-- -- A+B+C+D+E <--> <lib:VehicleLicenceCode>A</lib:VehicleLicenceCode><lib:VehicleLicenceCode>B</lib:VehicleLicenceCode><lib:VehicleLicenceCode>C</lib:VehicleLicenceCode><lib:VehicleLicenceCode>D</lib:VehicleLicenceCode><lib:VehicleLicenceCode>E</lib:VehicleLicenceCode>
-- see project eposterunek
--     SWD2_UTIL.VEHICLE_LICENCE_CODE2XML
--     SWD2_UTIL.VEHICLE_LICENCE_CODE2VARCHAR2

konwersje
---------------------------------------------------------------------------------------------

--!konwersje !konwersja
--!conversions

+---------+----+---+--------+-----+----+
|to->     |clob|xml|varchar2| lob |blob|
+---------+----+---+--------+-----+----|
|clob     |  x | 1 |   2    |  3  | d  |
|xml      |  4 | x |   5    |  6  | e  |
|varchar2 |  7 | 8 |   x    |  9  | f  |
|lob      |  a | b |   c    |  x  | g  |
|blob     |  h | i |   j    |  k  | x  |
+---------+----+---+--------+-----+----+

1. clob     --> XML      : xmltype.createXML( . ) 
2. clob     --> varchar2 : to_char ( . )
3. clob     --> lob      :
4. XML      --> CLOB     : to_clob(.) lub xmltype.getClobVal(.) 
5. XML      --> CHAR     : xmltype.getStringVal
6. xml      --> lob      : 
7. varchar2 --> clob     : to_clob
8. varchar2 --> xml      : xmltype.createXML( . )
9. varchar2 --> lob      : 
a. lob      --> clob     : 
b. lob      --> xml      : 
c. lob      --> varchar2 :  
d. clob     --> blob     : see below
e. XML      --> blob     : XML --> clob --> blob
f. varchar2 --> blob     : 
g. lob      --> blob     :
h. blob     --> clob     : see below
i. blob     --> xml      : blob --> clob --> xml
j. blob     --> varchar2 : see below

d. clob --> blob
-------------------------------------------------------------------------------
  FUNCTION BASE64_C2B ( p_c IN CLOB )
  RETURN BLOB
  IS
    --
    v_buffer_varchar VARCHAR2(32000);         -- 1. odczytana paczka znaków
    v_buffer_raw     RAW     (32000);         -- 2. zdekodowana paczka
    v_blob           BLOB;                   -- 3. bufor na skladanie paczek w wynik
    --
    v_offset         INTEGER;                -- wskaŸnik znaku do odczytu c
    v_buffer_size    BINARY_INTEGER := 32000; -- dlugoœæ paczki znaków w c
    --
  BEGIN
    --
    IF p_c IS NULL THEN
      RETURN NULL;
    END IF;
    --
    DBMS_LOB.CREATETEMPORARY ( v_blob, TRUE );
    --
    v_offset := 1;
    --
    -- Pêtla odczytywania z p_c paczek znaków i ich dekodowania
    LOOP
      --
      BEGIN
        DBMS_LOB.READ ( p_c
                        , v_buffer_size
                        , v_offset
                        , v_buffer_varchar
                        );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXIT;
      END;
      --
      v_buffer_raw := UTL_ENCODE.BASE64_DECODE( UTL_RAW.CAST_TO_RAW( v_buffer_varchar ));
      --
      DBMS_LOB.WRITEAPPEND( v_blob
                             , UTL_RAW.LENGTH(v_buffer_raw)
                             , v_buffer_raw
                             );
      --
      v_offset := v_offset + v_buffer_size;
      --
     END LOOP;
     --
     RETURN v_blob;
     --
  END BASE64_C2B;


j. blob --> varchar2
-------------------------------------------------------------------------------
DECLARE
  my_blob     BLOB;
  dl          NUMBER;
  i           NUMBER :=1;
  linia       NUMBER;
  gdzie_enter NUMBER;
BEGIN
  SELECT fl.file_data
    INTO my_blob
    FROM FND_LOBS fl
   WHERE file_id = 304573;
  
  dl          := dbms_lob.getlength(my_blob);
  linia       := 1;
  gdzie_enter := dbms_lob.instr(my_blob, utl_raw.cast_to_raw(chr(10)), 1, linia);

  WHILE gdzie_enter>0
  LOOP
    dbms_output.put_line(linia||' '||i||' '|| gdzie_enter||' '||dl);
    dbms_output.put_line(
      utl_raw.cast_to_varchar2(dbms_lob.substr(my_blob, gdzie_enter - i, i))
      );
    linia := linia + 1;
    i := gdzie_enter + 1;
    gdzie_enter := dbms_lob.instr(my_blob,utl_raw.cast_to_raw(chr(10)),1, linia);
  END LOOP;
END;

problem with polish chars ? Look into XXPAMSPROJECT
  vline_content := convert( vline_content , NLS_CHARSET_NAME(NLS_CHARSET_ID('char_cs')) , 'EE8MSWIN1250' );

h. blob --> clob
-------------------------------------------------------------------------------
Simple casting:
CREATE OR REPLACE FUNCTION BLOB2CLOB(L_BLOB BLOB) RETURN CLOB IS
  L_CLOB         CLOB;
  L_SRC_OFFSET      NUMBER;
  L_DEST_OFFSET  NUMBER;
  L_BLOB_CSID       NUMBER := DBMS_LOB.DEFAULT_CSID;
  V_LANG_CONTEXT NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
  L_WARNING         NUMBER;
  L_AMOUNT  NUMBER;
BEGIN
  DBMS_LOB.CREATETEMPORARY(L_CLOB, TRUE);
  L_SRC_OFFSET     := 1;
  L_DEST_OFFSET := 1;
  L_AMOUNT := DBMS_LOB.GETLENGTH(L_BLOB);
  DBMS_LOB.CONVERTTOCLOB(L_CLOB,
                         L_BLOB,
                         L_AMOUNT,
                         L_SRC_OFFSET,
                         L_DEST_OFFSET,
                         1,
                         V_LANG_CONTEXT,
                         L_WARNING);
  RETURN L_CLOB;
END;
/ 

Base64:
FUNCTION BASE64_B2C ( p_b IN BLOB )
RETURN CLOB
IS
  --
  v_clob        CLOB;
  v_offset      INTEGER;
  v_buffer_size BINARY_INTEGER := 19683;
  v_buffer_raw  RAW(19683);
  --
BEGIN 
  --
  IF p_b IS NULL THEN
    RETURN NULL;
  END IF;
  --
  DBMS_LOB.CREATETEMPORARY( v_clob
                             , FALSE
                             , DBMS_LOB.CALL
                             );
  --
  v_offset := 1;
  --
  LOOP
    --
    BEGIN
      DBMS_LOB.READ ( p_b
                      , v_buffer_size
                      , v_offset
                      , v_buffer_raw
                      );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
    --
    DBMS_LOB.APPEND( v_clob, TO_CLOB(UTL_RAW.CAST_TO_VARCHAR2( UTL_ENCODE.BASE64_ENCODE( v_buffer_raw ))));
    --
    v_offset := v_offset + v_buffer_size;
    --
  END LOOP;
  --
  RETURN v_clob;
  --
END BASE64_B2C;
  
  
 
more
-------------------------------------------------------------------------------
http://download.oracle.com/docs/cd/B19306_01/appdev.102/b14259/xdb_preface.htm 

    Chapter 1, "Introduction to Oracle XML DB"
    Chapter 2, "Getting Started with Oracle XML DB"
    Chapter 3, "Using Oracle XML DB"
    Chapter 4, "XMLType Operations"
    Chapter 5, "XML Schema Storage and Query: Basic"
    Chapter 6, "XPath Rewrite"
    Chapter 7, "XML Schema Storage and Query: Advanced"
    Chapter 8, "XML Schema Evolution"
    Chapter 9, "Transforming and Validating XMLType Data"
    Chapter 10, "Full-Text Search Over XML"
    Chapter 11, "PL/SQL API for XMLType"
    Chapter 12, "Package DBMS_XMLSTORE"
    Chapter 13, "Java API for XMLType"
    Chapter 14, "Using the C API for XML"
    Chapter 15, "Using Oracle Data Provider for .NET with Oracle XML DB"
    Chapter 16, "Generating XML Data from the Database"
    Chapter 17, "Using XQuery with Oracle XML DB"
    Chapter 18, "XMLType Views"
    Chapter 19, "Accessing Data Through URIs"
    Chapter 20, "Accessing Oracle XML DB Repository Data"
    Chapter 21, "Managing Resource Versions"
    Chapter 22, "SQL Access Using RESOURCE_VIEW and PATH_VIEW"
    Chapter 23, "PL/SQL Access Using DBMS_XDB"
    Chapter 24, "Repository Resource Security"
    Chapter 25, "FTP, HTTP(S), and WebDAV Access to Repository Data"
    Chapter 26, "User-Defined Repository Metadata"
    Chapter 27, "Writing Oracle XML DB Applications in Java"
    Chapter 28, "Administering Oracle XML DB"
    Chapter 29, "Loading XML Data Using SQL*Loader"
    Chapter 30, "Importing and Exporting XMLType Tables"
    Chapter 31, "Exchanging XML Data with Oracle Streams AQ"
     
======================================================================================================================================
technologie XML
 XSD  - opisuje strukturê pliku XML, prosty przyk³ad poni¿ej. mo¿e zawieraæ definicjê zagnie¿dzonych typów ( patrz projekt Dnb/tasks/bik)
 XSLT - transformuje jeden XML w drugi XML
 WSDL - standard tworzenia WebService  
 
 przydatne narzêdzie: XML Spy
 
przestarza³e:
DTD - zast¹pione przez XSD 

XSD:
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ora="ear.managed.view.cw.oracle.com" targetNamespace="ear.managed.view.cw.oracle.com" elementFormDefault="qualified" attributeFormDefault="unqualified">
        <xs:element name="ScanDocumentParameters">
                <xs:complexType>
                        <xs:sequence>
                                <xs:element name="PESELEKlientow" type="xs:string" nillable="false"/>
                                <xs:element name="ImionaINazwiskaKlientow" type="xs:string" nillable="false"/>
                                <xs:element name="NazwyFirmKlientow" type="xs:string" nillable="false"/>
                                <xs:element name="RegonyKlientow" type="xs:string" nillable="false"/>
                                <xs:element name="IdentyfikatorDoradcy" type="xs:string" nillable="false"/>
                                <xs:element name="ImieINazwiskoDoradcy" type="xs:string" nillable="false"/>
                        </xs:sequence>
                </xs:complexType>
        </xs:element>
</xs:schema>

Sample XML:
<ora:ScanDocumentParameters xmlns:ora="ear.managed.view.cw.oracle.com">
        <ora:PESELEKlientow>String</ora:PESELEKlientow>
        <ora:ImionaINazwiskaKlientow>String</ora:ImionaINazwiskaKlientow>
        <ora:NazwyFirmKlientow>String</ora:NazwyFirmKlientow>
        <ora:RegonyKlientow>String</ora:RegonyKlientow>
        <ora:IdentyfikatorDoradcy>String</ora:IdentyfikatorDoradcy>
        <ora:ImieINazwiskoDoradcy>String</ora:ImieINazwiskoDoradcy>
</ora:ScanDocumentParameters>


jak zrobic XML na podstawie XSD
==========================================
1/
narzêdzie do generowania typów java z xsd - xjc
(od jdk 6 w std)

ZapytanieDoBIK req = new ZapytanieDoBIK();
JAXBContext jc = JAXBContext.newInstance(ZapytanieDoBIK.class);
Marshaller marshaller = jc.createMarshaller();
StringWriter xmlReq = new StringWriter();
marshaller.marshal(req, xmlReq);   
               
2/
xmlspy

replace envelope
===========================================

select to_clob ( xmlelement("newTag", extract ( xmltype.createxml('<oldTag><B>b1</B><B>b2</B><C>c1</C></oldTag>'), '/oldTag/*' ) ) ) from dual
--<newTag><B>b1</B><B>b2</B><C>c1</C></newTag>


playing with xml schemas               
===========================================
declare
v xmltype := xmltype.createxml(
'<?xml version="1.0" encoding="UTF-8"?>
<k6:CreateFormRequestBSM xsi:schemaLocation="http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2A/V1 FormKSIP2AEBM.xsd" xmlns:lib="http://policja.gov.pl/EnterpriseObjectLibrary/Common/V1" xmlns:k6="http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2A/V1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<k6:FormKSIP2AEBO>
		<k6:FormKSIP2APerson>
			<lib:Identification>
				<lib:ID objectName="normalizedString" schemaName="normalizedString">SHOWME</lib:ID>
				<lib:BusinessID contextName="normalizedString">normalizedString</lib:BusinessID>
				<lib:AlternateID contextName="normalizedString">normalizedString</lib:AlternateID>
			</lib:Identification>
		</k6:FormKSIP2APerson>
	</k6:FormKSIP2AEBO>
	<k6:ConfirmFormRequestBSM>
		<lib:ConfirmationDuplicate>
			<lib:ConfirmationMark>T</lib:ConfirmationMark>
			<lib:DuplicateReason>String</lib:DuplicateReason>
		</lib:ConfirmationDuplicate>
	</k6:ConfirmFormRequestBSM>
</k6:CreateFormRequestBSM>');
x varchar2(2000);
x2 varchar2(2000);
tmp_xmltype xmltype;
begin
  -- "tns" instead of "t6" - it works 
  select to_clob ( extract(v,'/tns:CreateFormRequestBSM/tns:FormKSIP2AEBO/tns:FormKSIP2APerson/lib:Identification/lib:ID/text()','xmlns:lib="http://policja.gov.pl/EnterpriseObjectLibrary/Common/V1" xmlns:tns="http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2A/V1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"') ) 
    into x
   from dual;
  -- 
  select extract(v,'/tns:CreateFormRequestBSM/tns:FormKSIP2AEBO','xmlns:lib="http://policja.gov.pl/EnterpriseObjectLibrary/Common/V1" xmlns:tns="http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2A/V1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"')  
    into tmp_xmltype
   from dual;
  select to_clob ( extract(tmp_xmltype,'/tns:FormKSIP2AEBO/tns:FormKSIP2APerson/lib:Identification/lib:ID/text()','xmlns:lib="http://policja.gov.pl/EnterpriseObjectLibrary/Common/V1" xmlns:tns="http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2A/V1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"') ) 
    into x2
   from dual;
   raise_application_error(-20000, 'X=' || x || '=' || x2);
end;

see also "playing with xml schemas.txt"   
      
Known Oracle Bugs
-----------------------------
1/ first argument of xmlelement must be a constant. workaround is dynamic SQL or xslt tranformation:

  FUNCTION GET_LOOKUP_CODE (P_ELEMENT_NAME VARCHAR2, P_VALUE_CODE VARCHAR2, P_TABK_TYPE VARCHAR2) RETURN XMLTYPE IS
   l_TMP XMLTYPE;
   l_SQLSTMT VARCHAR2(32000);
  BEGIN
    l_SQLSTMT := 
    'select xmlelement("'||p_element_name||'"
               ,xmlattributes(
                 :p_value_code as "valueCode"
                ,:p_tabk_type as "typeCode"
                ,(select opis from zsip_tabko where kod = :p_value_code and tabk_type = :p_tabk_type) as "description"
               )
           )        
       from dual';
    --   
    EXECUTE IMMEDIATE l_SQLSTMT INTO l_TMP USING P_VALUE_CODE, P_TABK_TYPE, P_VALUE_CODE, P_TABK_TYPE;          
    RETURN l_TMP;
  END;
     
2/ inside XMLELEMENT you can use XMLATTRIBUTE only one time

workaround:
SELECT XMLELEMENT("tns:FORMKSIP2PersonName"
          ,XMLATTRIBUTES('http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2/V1 FormKSIP2EBO.xsd' AS "xsi:schemaLocation"
                        ,'http://policja.gov.pl/EnterpriseObjectLibrary/Common/V1' AS "xmlns:lib"
                        ,'http://policja.gov.pl/EnterpriseObjectLibrary/Object/FormKSIP2/V1' AS "xmlns:tns"
                        ,'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi")
       )
  FROM DUAL                   

3/ XMLATTRIBUTES ( variable as "xmlns:xsi" ) will not work, problem applies to  "xmlns:xsi" only.
   pass parameter as a constant for example
   XMLATTRIBUTES ( 'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi")
   
   
4/ XMLCONCAT requires xmlns, so there is a problem with using it, example:

declare
 doc xmltype;
begin
 select xmlconcat( xmlelement("lib:a"), xmlelement("lib:a") ) into doc from dual;
 select xmlconcat( doc, doc ) into doc from dual;
 select xmlconcat( doc, doc ) into doc from dual;
end;

workaround 1 - for tables

use XMLAGG intead of XMLCONCAT

workaround 2 - for pl/sql tables

CREATE OR REPLACE TYPE SWD2_XMLTYPE IS VARRAY(100) OF XMLTYPE; 
/

declare
  g_concat_xml SWD2_XMLTYPE;
begin
  g_concat_xml := SWD2_XMLTYPE (l_xml_FormKSIP12HForgeryRecord, l_xml_tmp);
  --
  SELECT XMLAgg( VALUE(agg))
    INTO l_xml_FormKSIP12HForgeryRecord
    FROM TABLE ( g_concat_xml ) agg;
end;
                  
              
5/ XMLELEMENT("A", null) returns always <a></a> since for numbers, data, and enumeration should be no element (required by xsd)

workaround
select to_clob(column_Value)
 from 
 table(
 xmlsequence( 
     xmltype.createxml('<syncform><form><formp><per><personname><x></x><y>x</y></personname><pec></pec><notnull>notnull</notnull><i1><i2><i3></i3></i2></i1></per></formp></form></syncform>') 
   .EXTRACT('/*')
 ) ) 
 
<syncform>
  <form>
    <formp>
      <per>
        <personname>
          <x/>                         <======= TO DELETE
          <y>x</y>
        </personname>
        <pec/>                         <======= TO DELETE
        <notnull>notnull</notnull>
        <i1>                           
          <i2>                         
            <i3/>                      <======= TO DELETE
          </i2>                        
        </i1>                          
      </per>
    </formp>
  </form>
</syncform>

select to_clob(column_Value)
 from 
 table(
 xmlsequence( 
   deletexml(
     xmltype.createxml('<syncform><form><formp><per><personname><x></x><y>x</y></personname><pec></pec><notnull>notnull</notnull><i1><i2><i3></i3></i2></i1></per></formp></form></syncform>') 
   -- .="" no element value AND NO CHILD ELEMENTS
   -- @* = no attribute
   ,'//*[(not(node()) and not(@*)) or (not(node()) and @*="")]')    
   .EXTRACT('/*') --pretty format
 ) ) 

<syncform>
  <form>
    <formp>
      <per>
        <personname>
          <y>x</y>
        </personname>
        <notnull>notnull</notnull>
        <i1>
          <i2/>
        </i1>
      </per>
    </formp>
  </form>
</syncform>

6/ xmltype.createxml accepts clobs up to 64KB only ! 
  (ORA-31167: XML nodes over 64K in size cannot be inserted)
   xml size cannot be larger than 64KB !
      
Workarounds
1/ Code in java - see java_in_db.sql "XSLTExtract"
1/ extract large elements ( pictures ) from xml file and pass it as a clobs
2/ use xmlelement() syntax instead of xmltype.createxml. Still extract will work badly.   
3/ xmltype.createxml(, validated=>1, wellformed=>1). Still extract will work badly.

8/ "ORA-19011: Character string buffer too small" during INSERT INTO CLOB

Workaround: XMLType ( XMLtypValue.getClobVal() ).getClobVal()

9/ see "Known Oracle Bugs" in  "SQL-XML.mht"