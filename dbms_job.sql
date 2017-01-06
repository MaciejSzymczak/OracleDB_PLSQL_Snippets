This package is obsolete. Use dbms_scheduler instead
=============================

Introduction to DBMS_JOB 

by Alex Gaethofs <Alex.Gaethofs@elia.be>, Database Administrator 

Overview 


It is possible to setup a kind of automatic batch that would be lauched every night in order to clean up tables using truncate-statements to avoid useless redo log creation. 
This month, Alex Gaethofs introduces how to perform nightly clean up jobs while introducing the DBMS_JOB package. 

DBMS_JOB 

DBMS_JOB is an Oracle PL/SQL package provided to users. It is available with PL/SQL 2.2 and higher. DBMS_JOB allows a user to schedule a job to run at a specified time. A job is submitted to a job queue and runs at the specified time. The user can also input a parameter that specifies how often the job should run. A job can consist of any PL/SQL code. 
To run jobs using DBMS_JOB you have to specify two parameters in the init.ora of the database : 

    # Simultaneous job listeners for running batch jobs (every 2 minutes=120)
    JOB_QUEUE_PROCESSES=10
    JOB_QUEUE_INTERVAL=120
Remember restarting the instance after modifying the init.ora. 
SNP processes run in the background and implement database snapshots and job queues. Without an SNP process (JOB_QUEUE_PROCESSES = 0) the DBMS_JOB package cannot run automatically. 

Setup 

    Step 1 : Connect to the database as application-owner.
    In the example below, "ALEX" is the owner of the schema.

    Step 2 : Create a package called "Batch_Job"


      Package Specification 
      --------------------------------

      PACKAGE Batch_Job IS

      PROCEDURE submit(
        p_job       OUT INTEGER,
        p_what      IN VARCHAR2,
        p_next_date IN DATE     DEFAULT SYSDATE,
        p_interval  IN VARCHAR2 DEFAULT 'null',
        p_no_parse  IN BOOLEAN  DEFAULT FALSE
      );

      PROCEDURE remove(p_job IN INTEGER);

      PROCEDURE disable_constraint(p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2);
      PROCEDURE truncate_table(p_table_name IN VARCHAR2);
      PROCEDURE enable_constraint(p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2);
      PROCEDURE run_daily_morning_job;
  
      END Batch_Job;

      Package Body
      ---------------------

      PACKAGE BODY Batch_Job IS

      l_job NUMBER := 0;

      PROCEDURE submit(
        p_job   OUT INTEGER,
        p_what      IN VARCHAR2,
        p_next_date IN DATE     DEFAULT SYSDATE,
        p_interval  IN VARCHAR2 DEFAULT 'null',
        p_no_parse  IN BOOLEAN  DEFAULT FALSE
      ) IS
        BEGIN
          DBMS_JOB.submit(p_job, p_what, p_next_date,p_interval,p_no_parse);
        END submit;
  
        PROCEDURE remove(p_job IN INTEGER) IS
        BEGIN
          DBMS_JOB.remove(p_job);
        END remove;

        PROCEDURE disable_constraint(p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2) IS
        BEGIN
          EXECUTE IMMEDIATE('ALTER TABLE '||p_table_name||' DISABLE CONSTRAINT '||p_constraint_name);
        END disable_constraint;
  
        PROCEDURE truncate_table(p_table_name IN VARCHAR2) IS
        BEGIN
          EXECUTE IMMEDIATE('TRUNCATE TABLE '||p_table_name);
        END truncate_table;
  
        PROCEDURE enable_constraint(p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2) IS
        BEGIN
          EXECUTE IMMEDIATE('ALTER TABLE '||p_table_name||' ENABLE CONSTRAINT '||p_constraint_name);
        END enable_constraint;

        /* Start defining the batch jobs to run */
        PROCEDURE run_daily_morning_job IS
        BEGIN
          Batch_Job.Submit(l_job,'daily_morning_job;',sysdate,'TRUNC(sysdate)+1+1/288');
        END run_daily_morning_job; 

        PROCEDURE run_daily_night_job IS
        BEGIN
          Batch_Job.Submit(l_job,'daily_night_job;',sysdate,'TRUNC(sysdate)+1+1/288');
          NULL;
        END run_daily_night_job; 

        END Batch_Job;

    Step 3 : Create a procedure called "daily_morning_job" :

      PROCEDURE daily_morning_job IS
        BEGIN
          Batch_Job.disable_constraint('ALEX_EMP','SYS_C001205');
          Batch_Job.truncate_table('ALEX_DEPT');
          Batch_Job.truncate_table('ALEX_EMP');
          Batch_Job.enable_constraint('ALEX_EMP','SYS_C001205');
        END;

        If someone wants to truncate other tables, he just needs to modify
        the procedure "daily_morning_job", add the necessary 
        truncate-instructions. The day after, at exactly 00:05, 
        the updated version of the procedure "daily_morning_job" will run.

        As you can see in the package "batch_job", another job called
        "daily_night_job" is almost available. You just have to remove 
        the remarks and create a procedure "daily_nigh_job".

    Step 4 : Check the view 'USER_JOBS' to findout jobs you have submitted 
             in the job-queue.

      SELECT job,what,next_date,next_sec FROM user_jobs;
Summary 
    How do you submit a DBMS_JOB ?

    SQL>DECLARE l_job NUMBER := 0;
    SQL>BEGIN
    SQL> DBMS_JOB.SUBMIT(l_job,'procedure_name;',sysdate,TRUNC(sysdate)+1+1/288);
    SQL>END;
    SQL>/

    How do we resubmit our job ?

    SQL>EXECUTE batch_job.run_daily_morning_job;

    REMEMBER : The first time the job is being run it will run immediately.
               The next time the job will run is specified with the interval 
               parameter of the DBMS_JOB package.

    How do you remove a submitted DMBS_JOB  ?
	
    SQL>EXECUTE DBMS_JOB.REMOVE(jobno);


    Some additional documentation which can help you by setting up a job
    mechanisme :

    Note 74149.1 : Invoker Rights versus Definer Rights in Oracle 8i
    Using PL/SQL Version 2 packages in Developer 2000 (Author : Chris Halioris)
