How to get the information about the numer of updated/deleted/inserted records
==============================================================================

update bla bla bla

The number of updated records is keept in variable:
SQL%ROWCOUNT

the foolowing boolean variables may be also usefull 

SQL%FOUND (TRUE WHEN SQL%ROWCOUNT >0 ELSE FALSE)
SQL%NOTFOUND (= NOT SQL%FOUND)


exaple od use:
    DELETE FROM PO_QUOTATION_APPROVALS WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;


