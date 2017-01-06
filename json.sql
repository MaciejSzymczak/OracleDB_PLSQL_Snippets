https://docs.oracle.com/database/121/ADXDB/json.htm#ADXDB6252
http://oracle-base.com/articles/10g/oracle-data-pump-10g.php

CREATE TABLE j_purchaseorder
   (id          RAW (16) NOT NULL,
    date_loaded TIMESTAMP WITH TIME ZONE,
    po_document CLOB
    CONSTRAINT ensure_json CHECK (po_document IS JSON));
	
	INSERT INTO j_purchaseorder
  VALUES (SYS_GUID(),
          SYSTIMESTAMP,
          '{ "PONumber"             : 1600,
  "Reference"            : "ABULL-20140421",
  "Requestor"            : "Alexis Bull",
  "User"                 : "ABULL",
  "CostCenter"           : "A50",
  "ShippingInstructions" : { "name"   : "Alexis Bull",
                             "Address": { "street"  : "200 Sporting Green",
                                          "city"    : "South San Francisco",
                                          "state"   : "CA",
                                          "zipCode" : 99236,
                                          "country" : "United States of America" },
                             "Phone" : [ { "type" : "Office", "number" : "909-555-7307" },
                                         { "type" : "Mobile", "number" : "415-555-1234" } ] },
  "Special Instructions" : null,
  "AllowPartialShipment" : false,
  "LineItems"            : [ { "ItemNumber" : 1,
                               "Part"       : { "Description" : "One Magic Christmas",
                                                "UnitPrice"   : 19.95,
                                                "UPCCode"     : 13131092899 },
                               "Quantity"   : 9.0 },
                             { "ItemNumber" : 2,
                               "Part"       : { "Description" : "Lethal Weapon",
                                                "UnitPrice"   : 19.95,
                                                "UPCCode"     : 85391628927 },
                               "Quantity"   : 5.0 } ] }');
			
			
SELECT po.po_document.ShippingInstructions.Phone FROM j_purchaseorder po;

Way 2
----------------
https://oracle-base.com/articles/misc/apex_json-package-generate-and-parse-json-documents-in-oracle

SET SERVEROUTPUT ON
DECLARE
  l_cursor SYS_REFCURSOR;
BEGIN
  
  OPEN l_cursor FOR
    SELECT e.empno AS "employee_number",
           e.ename AS "employee_name",
           e.deptno AS "department_number"
    FROM   emp e
    WHERE  rownum <= 2;

  APEX_JSON.initialize_clob_output;

  APEX_JSON.open_object;
  APEX_JSON.write('employees', l_cursor);
  APEX_JSON.close_object;

  DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
  APEX_JSON.free_output;
END;
/
{
  "employees": [
    {
      "employee_number": 7369,
      "employee_name": "SMITH",
      "department_number": 20
    },
    {
      "employee_number": 7499,
      "employee_name": "ALLEN",
      "department_number": 30
    }
  ]
}

