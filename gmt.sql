--!time zone !timezone !gmt !cet !strefa czasowa !strefy czasowe

-- conversion from session time zone -->GMT
select cast(from_tz( cast( to_date('20110812 095600','yyyy-mm-dd hh24miss') as timestamp ) , sessiontimezone) at time zone 'GMT' as date) from dual

-------------------------
sessiontimezone for Poland is 'CET' = ('+02:00' in summer AND '+1:00' in Winter)

select * from V$TIMEZONE_NAMES  where TZNAME = 'Europe/Warsaw'

-------------------------
with this as expected we can see an error: ORA-01878: specified field not found in datetime or interval

select cast(from_tz( cast( to_date('20110327 020000','yyyy-mm-dd hh24miss') as timestamp ) , 'CET') at time zone 'GMT' as date) from dual

but this as expected works fine

select cast(from_tz( cast( to_date('20110327 020000','yyyy-mm-dd hh24miss') as timestamp ) , '+02:00') at time zone 'GMT' as date) from dual

