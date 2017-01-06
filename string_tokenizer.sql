select REGEXP_SUBSTR(s, '[^'||chr(10)||']+', 1, 1) a,
       REGEXP_SUBSTR(s, '[^'||chr(10)||']+', 1, 2) b,
       REGEXP_SUBSTR(s, '[^'||chr(10)||']+', 1, 3) c
from (select 'hello'||chr(10)||'howare'||chr(10)||'you' s from dual)

