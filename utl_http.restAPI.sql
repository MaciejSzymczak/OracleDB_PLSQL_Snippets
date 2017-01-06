not working in Oracle XE and on Oracle AWS

DECLARE
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
  l_response_text  VARCHAR2(32767);
BEGIN
  l_http_request := UTL_HTTP.begin_request ('https://maps.googleapis.com/maps/api/geocode/json?latlng=52.251939,21.128712'
                                          , 'GET'
                                          , 'HTTP/1.1');
  UTL_HTTP.set_header(l_http_request, 'Content-Type', 'application/x-www-form-urlencoded');
  l_http_response := UTL_HTTP.get_response(l_http_request);
  UTL_HTTP.read_text(l_http_response, l_response_text);
  DBMS_OUTPUT.put_line(l_response_text);
  UTL_HTTP.end_response(l_http_response);
EXCEPTION
  WHEN UTL_HTTP.end_of_body 
    THEN UTL_HTTP.end_response(l_http_response);  
END;

ORA-24247? =>

BEGIN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (acl         => 'ws_hosts.xml'
                                   , description => 'ACL for web services hosts'
                                   , principal   => 'ADMIN'
                                   , is_grant    => TRUE
                                   , privilege   => 'connect');
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'ws_hosts.xml'
                                      , principal => 'ADMIN'
                                      , is_grant  => TRUE
                                      , privilege => 'resolve');
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'ws_hosts.xml',
                                    host => 'maps.googleapis.com');
 
  COMMIT;
END;









DECLARE
  l_param_list     VARCHAR2(512);
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
  l_response_text  VARCHAR2(32767);
BEGIN
  -- service's input parameters
  l_param_list := 'FromCurrency=EUR&ToCurrency=USD';
  -- preparing Request...
  l_http_request := UTL_HTTP.begin_request ('http://www.webservicex.net/currencyconvertor.asmx/ConversionRate'
                                          , 'POST'
                                          , 'HTTP/1.1');
  -- ...set header's attributes
  UTL_HTTP.set_header(l_http_request, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(l_http_request, 'Content-Length', LENGTH(l_param_list));
  -- ...set input parameters
  UTL_HTTP.write_text(l_http_request, l_param_list);
  -- get Response and obtain received value
  l_http_response := UTL_HTTP.get_response(l_http_request);
  UTL_HTTP.read_text(l_http_response, l_response_text);
  DBMS_OUTPUT.put_line(l_response_text);
  -- finalizing
  UTL_HTTP.end_response(l_http_response);
EXCEPTION
  WHEN UTL_HTTP.end_of_body 
    THEN UTL_HTTP.end_response(l_http_response);  
END;
