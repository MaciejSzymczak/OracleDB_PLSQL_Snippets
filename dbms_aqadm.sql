!advanced queueing !queue

http://www.oracle-developer.net/display.php?id=411

CREATE TYPE demo_queue_payload_type AS OBJECT ( message VARCHAR2(4000) ); 

BEGIN
    DBMS_AQADM.CREATE_QUEUE_TABLE (
       queue_table        => 'demo_queue_table',
       queue_payload_type => 'demo_queue_payload_type'
       --,multiple_consumers => TRUE
       );
 END;
 /

 BEGIN 
    DBMS_AQADM.CREATE_QUEUE (
       queue_name  => 'demo_queue',
       queue_table => 'demo_queue_table'
       );
    DBMS_AQADM.START_QUEUE (
       queue_name => 'demo_queue'
       );
 END;
 /

 SELECT object_name, object_type
 FROM   user_objects
 WHERE  object_name = 'DEMO_QUEUE_PAYLOAD_TYPE';
 
DECLARE
   r_enqueue_options    DBMS_AQ.ENQUEUE_OPTIONS_T;
   r_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
   v_message_handle     RAW(16);
   o_payload            demo_queue_payload_type;
BEGIN
   o_payload := demo_queue_payload_type('Here is a message');
   DBMS_AQ.ENQUEUE(
      queue_name         => 'demo_queue',
      enqueue_options    => r_enqueue_options,
      message_properties => r_message_properties,
      payload            => o_payload,
      msgid              => v_message_handle
      );
  COMMIT;
END;
/

DECLARE
   r_dequeue_options    DBMS_AQ.DEQUEUE_OPTIONS_T;
   r_message_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
   v_message_handle     RAW(16);
   o_payload            demo_queue_payload_type;
BEGIN
   --r_dequeue_options.dequeue_mode := DBMS_AQ.BROWSE; = do not dequeue element
   DBMS_AQ.DEQUEUE(
      queue_name         => 'demo_queue',
      dequeue_options    => r_dequeue_options,
      message_properties => r_message_properties,
      payload            => o_payload,
      msgid              => v_message_handle
      );
   DBMS_OUTPUT.PUT_LINE(
      '*** message is [' || o_payload.message || '] ***'
      );
END;
/

BEGIN
   DBMS_AQADM.STOP_QUEUE(
      queue_name => 'demo_queue'
      );
   DBMS_AQADM.DROP_QUEUE(
      queue_name => 'demo_queue'
      );
   DBMS_AQADM.DROP_QUEUE_TABLE(
      queue_table => 'demo_queue_table'
      , force => true --czasami jak sie coœ pokrzaczy na bazie, funkcja zwraca b³¹d ORA-942. wtedy ten parametr pomaga usun¹æ obiekt
      );
END;
/

