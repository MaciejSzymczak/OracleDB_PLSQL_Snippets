--!mutanting tables
problem tabel mutuj¹cych
===============================================================================

1. wykonaj 2 triggery
  a) w³aœciwy - for each row
  b) dodatkowy - bez for each row
   Trigger b) nie ma ograniczeñ takich jak a), np. mo¿na wykonaæ update. 
   Nie mo¿na wykonaæ commit i chyba nie mo¿na wykonaæ polecen DDL, ale mo¿na i to obejœæ poprzez wywo³anie 
   funkcji w transakcji autonomicznej z poziomu tego triggera (zobacz autonomous_transaction.txt).
2. trigger a) pakuje dane do tabeli tymczasowej, któr¹ czyta trigger b) i robi co trzeba


CREATE OR REPLACE package xx_po_headers_all as
  type xx_table is table of number index by binary_integer;
  xx_po_headers_id xx_table;
END xx_po_headers_all;
/

CREATE OR REPLACE TRIGGER APPS.XX_PO_HEADERS_ALL_T1
AFTER INSERT ON PO_HEADERS_ALL REFERENCING NEW AS NEW FOR EACH ROW
WHEN (new.type_lookup_code = 'BLANKET' AND new.from_type_lookup_code = 'QUOTATION' AND new.attribute_category = 'POXSCERQ')
DECLARE
  l_char		VARCHAR2(250);
  i           NUMBER;
BEGIN
  i := xx_po_headers_all.xx_po_headers_id.count;
  xx_po_headers_all.xx_po_headers_id( i+1 ) := :new.po_header_id;
  --l_char := 'XX_PO_HEADERS_ALL_T1 trigger H_ID='||TO_CHAR(:new.po_header_id);
  --INSERT INTO PO_WF_DEBUG (execution_date, debug_message) VALUES (SYSDATE, l_char);
EXCEPTION
  WHEN others THEN
    l_char := 'XX_PO_HEADERS_ALL_T1 trigger H_ID='||TO_CHAR(:new.po_header_id)||' EXCEPTION: CODE: '||sqlcode||', MESSAGE: '||sqlerrm;
    INSERT INTO PO_WF_DEBUG (execution_date, debug_message) VALUES (SYSDATE, l_char);
END;

CREATE OR REPLACE TRIGGER APPS.XX_PO_HEADERS_ALL_T2
AFTER INSERT ON PO_HEADERS_ALL
DECLARE
  l_char		VARCHAR2(250);
  j			NUMBER;
BEGIN
  j := xx_po_headers_all.xx_po_headers_id.first;
  WHILE j IS NOT NULL LOOP
    UPDATE	PO_HEADERS_ALL ph
       SET	ph.attribute_category = 'POXPOEPO'
     WHERE	ph.po_header_id = xx_po_headers_all.xx_po_headers_id (j);
    --l_char := l_char || ' '||TO_CHAR(xx_po_headers_all.xx_po_headers_id (j));
    j := xx_po_headers_all.xx_po_headers_id.next(j);
  END LOOP;
  xx_po_headers_all.xx_po_headers_id.delete;
  --INSERT INTO PO_WF_DEBUG (execution_date, debug_message) VALUES (SYSDATE, l_char);
EXCEPTION
  WHEN others THEN
  l_char := 'XX_PO_HEADERS_ALL_T2 trigger EXCEPTION: CODE: '||sqlcode||', MESSAGE: '||sqlerrm;
  INSERT INTO PO_WF_DEBUG (execution_date, debug_message) VALUES (SYSDATE, l_char);
END;
