GRANT ANALYZE ANY TO SYSTEM;
DROP PACKAGE dba_stats_maint_pkg;

CREATE OR REPLACE PACKAGE dba_stats_maint_pkg
/* Package is intended for use when managing
   the optimizer statistics for 9i and 10g
   databases. Once on 11g, each tables' statistics
   setting can be customized and used by Oracle's automatic
   job

   Assumptions:

   For 10g, STATISTICS_LEVEL is set to a level
   above basic, so that DBA_TAB_MODIFICATIONS
   is populated (i.e. tables are monitored)

   For 9i, relevant tables have their MONITORING
   attribute set, so that DBA_TAB_MODIFICATIONS
   view is populated

   This package is either compiled as a privileged user
   and/or it is compiled under someone else and
   all applicable grants on system packages and
   dynamic performance views are made

   Has a dependency to dbms_lock.sleep procedure - this is assumed to be present

   Explicit ANALYZE ANY grant has been made to SYSTEM user
*/
AS
   --Removes all Statistic for the Database
   PROCEDURE delete_all_stats;

   --Procedure that disables Oracle's Auto Jobs
   --at user request. p_job_name represents
   --the dbms_scheduler job to be disabled
   PROCEDURE disable_auto_job (p_job_name IN VARCHAR);

   --Procedure that disables the automatic gathering of stats
   --since, until 10g, this 'canned' procedure is not adequate
   --to gather statistics responsibly
   PROCEDURE disable_auto_stats_job;

   --Procedure that disables the automatic segment space advisor job
   --The running of this job can use up a lot of resources, hence
   --why many disable it
   PROCEDURE disable_auto_space_job;

   --Procedure gathers stats for SYSTEM and SYS schemas, including fixed objects
   --Basically a wrapped calls to the applicable DBMS_STATS procedure
   PROCEDURE gather_data_dict_stats;

   --Procedure that gathers non-fixed, non-locked table, index, partition, and subpartition statistics
   --based upon whether there have been significant changes (i.e. DBA_TAB_MODIFICATIONS)
   --and or whether stats are empty
   --Package level defaults can be modified for your
   PROCEDURE gather_stats;

   --Procedure either start or stops the gathering of system-level statistics (i.e. I/O, CPU)
   --Other wise known as the values found in sys.aux_stats$
   -- User passes the number of seconds that the gather should run
   PROCEDURE gather_system_stats (p_duration_secs IN NUMBER);

   --Procedure makes internal calls to first delete all stats
   --and then gather them, including a gathering of system statistics
   PROCEDURE start_over;
END dba_stats_maint_pkg;
/

SHOW errors

CREATE OR REPLACE PACKAGE BODY dba_stats_maint_pkg
/* Package is intended for use when managing
   the optimizer statistics for 9i and 10g
   databases. Once on 11g, each tables' statistics
   setting can be customized and used by Oracle's automatic
   job

   Assumptions:

   For 10g, STATISTICS_LEVEL is set to a level
   above basic, so that DBA_TAB_MODIFICATIONS
   is populated (i.e. tables are monitored)

   For 9i, relevant tables have their MONITORING
   attribute set, so that DBA_TAB_MODIFICATIONS
   view is populated

   This package is either compiled as a privileged user
   and/or it is compiled under someone else and
   all applicable grants on system packages and
   dynamic performance views are made

   */
AS
   --Removes all Statistic for the Database
   PROCEDURE delete_all_stats
   AS
   BEGIN
      DBMS_STATS.delete_dictionary_stats;
      DBMS_STATS.delete_database_stats;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   --Procedure that disables Oracle's Auto Jobs
   --at user request. p_job_name represents
   --the dbms_scheduler job to be disabled
   PROCEDURE disable_auto_job (p_job_name IN VARCHAR)
   AS
      lv_enabled   dba_scheduler_jobs.enabled%TYPE;
   BEGIN
      DBMS_SCHEDULER.DISABLE (UPPER (p_job_name));

      SELECT enabled
        INTO lv_enabled
        FROM dba_scheduler_jobs
       WHERE job_name = UPPER (p_job_name);

      IF UPPER (lv_enabled) = 'FALSE'
      THEN
         DBMS_OUTPUT.put_line (   'Auto Job: '
                               || UPPER (p_job_name)
                               || ' has been disabled...'
                              );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLCODE || ' - ' || SQLERRM);
   END disable_auto_job;

   --Procedure that disables the automatic gathering of stats
   --since, until 10g, this 'canned' procedure is not adequate
   --to gather statistics responsibly
   PROCEDURE disable_auto_stats_job
   AS
   BEGIN
      disable_auto_job (p_job_name => 'GATHER_STATS_JOB');
   END;

   --Procedure that disables the automatic segment space advisor job
   --The running of this job can use up a lot of resources, hence
   --why many disable it
   PROCEDURE disable_auto_space_job
   AS
   BEGIN
      disable_auto_job (p_job_name => 'AUTO_SPACE_ADVISOR_JOB');
   END;

   PROCEDURE gather_data_dict_stats
   AS
   BEGIN
      DBMS_STATS.gather_dictionary_stats;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE gather_stats
   AS
      /* Cursor with the names of all the non-partitioned, non-system, non-locked, non-iot overflow type segments
         which don't have statistics currently */
      lv_owner           dba_tables.owner%TYPE;
      lv_table_name      dba_tables.table_name%TYPE;
      lv_part_name       dba_tab_partitions.partition_name%TYPE;
      lv_change_factor   NUMBER (16, 2);
      lv_partitioned     VARCHAR (10);

      CURSOR lc_ns_np_nostats
      IS
         SELECT owner, table_name
           FROM dba_tables
          WHERE partitioned = 'NO'
            AND NOT owner IN ('SYSTEM', 'SYS', 'OUTLN', 'DBSNMP')
            AND num_rows IS NULL
            AND iot_type IS NULL
            AND NOT (owner, table_name) IN (SELECT owner, table_name
                                              FROM dba_tab_statistics
                                             WHERE stattype_locked = 'ALL')
            AND NOT (owner, table_name) IN (SELECT owner, table_name
                                              FROM dba_external_tables);

      CURSOR lc_ns_p_nostats
      IS
         SELECT table_owner, table_name, partition_name
           FROM dba_tab_partitions
          WHERE num_rows IS NULL
            AND NOT table_owner IN ('SYSTEM', 'SYS', 'OUTLN', 'DBSNMP')
            AND NOT (table_owner, table_name) IN (
                                                 SELECT owner, table_name
                                                   FROM dba_tab_statistics
                                                  WHERE stattype_locked =
                                                                         'ALL')
            AND NOT (table_owner, table_name) IN (SELECT owner, table_name
                                                    FROM dba_external_tables);

      CURSOR lc_ss
      IS
         SELECT dtm.table_owner, dtm.table_name, dtm.partition_name,
                  ROUND (  (dtm.inserts + dtm.updates + dtm.deletes)
                         / dt.num_rows,
                         2
                        )
                * 100 "CHANGE_FACTOR",
                dt.partitioned
           FROM dba_tab_modifications dtm, dba_tables dt
          WHERE dtm.table_owner = dt.owner
            AND dtm.table_name = dt.table_name
            AND NOT dtm.table_owner IN ('SYS', 'SYSTEM', 'OUTLN', 'DBSNMP')
            AND NOT dt.num_rows IS NULL
            AND iot_type IS NULL
            AND (   (dt.partitioned = 'YES' AND NOT dtm.partition_name IS NULL
                    )
                 OR (dt.partitioned = 'NO' AND dtm.partition_name IS NULL)
                )
            AND NOT (dtm.table_owner, dtm.table_name) IN (
                                             SELECT dts.owner, dts.table_name
                                               FROM dba_tab_statistics dts
                                              WHERE dts.stattype_locked =
                                                                         'ALL')
            AND NOT (dtm.table_owner, dtm.table_name) IN (
                                              SELECT det.owner,
                                                     det.table_name
                                                FROM dba_external_tables det);
   BEGIN
      -- First process the cursor above; alternatively, you could
      -- do something similar via a call to DBMS_STATS with the 'GATHER EMPTY' option
      OPEN lc_ns_np_nostats;               -- open the cursor before fetching

      LOOP
         FETCH lc_ns_np_nostats
          INTO lv_owner, lv_table_name;   -- fetches 2 columns into variables

         EXIT WHEN lc_ns_np_nostats%NOTFOUND;
         -- Call stats package
         DBMS_OUTPUT.put_line (   'Gathering Stats for Table and Indexes of '
                               || lv_owner
                               || '.'
                               || lv_table_name
                               || ' because they are empty...'
                              );
         -- For these tables we will use most of the oracle defaults
         -- We are assuming that partitioned tables are to be treated differently in terms
         -- of sample size, parallelism degree and the like
         DBMS_STATS.gather_table_stats
                              (ownname               => lv_owner,
                               tabname               => lv_table_name,
                               granularity           => 'AUTO',
                               method_opt            => 'for all columns',
                               CASCADE               => DBMS_STATS.auto_cascade,
                               estimate_percent      => DBMS_STATS.auto_sample_size
                              );
      END LOOP;

      CLOSE lc_ns_np_nostats;

      -- In prepartion for change-based gathering
      -- we will flush the database's monitoring info via:
      DBMS_STATS.flush_database_monitoring_info ();

      -- Next we process table partitions whose statistics are null
      -- We will use smaller samples and parallelism
      OPEN lc_ns_p_nostats;                 -- open the cursor before fetching

      LOOP
         FETCH lc_ns_p_nostats
          INTO lv_owner, lv_table_name, lv_part_name;

         -- fetches 3 columns into variables
         EXIT WHEN lc_ns_p_nostats%NOTFOUND;
         -- Call stats package
         DBMS_OUTPUT.put_line (   'Gathering Stats for Partition '
                               || lv_owner
                               || '.'
                               || lv_table_name
                               || '.'
                               || lv_part_name
                               || ' because they are empty...'
                              );
         -- For these partitioned tables we will use smaller sample sizes
         DBMS_STATS.gather_table_stats (ownname               => lv_owner,
                                        tabname               => lv_table_name,
                                        partname              => lv_part_name,
                                        granularity           => 'AUTO',
                                        method_opt            => 'for all columns',
                                        CASCADE               => DBMS_STATS.auto_cascade,
                                        DEGREE                => 8,
                                        estimate_percent      => .00001
                                       );
      END LOOP;

      CLOSE lc_ns_p_nostats;

      -- Lastly we flush the database monitoring information
      -- and then use the information therein to gather stats
      -- on significantly changed objects
      OPEN lc_ss;                           -- open the cursor before fetching

      LOOP
         FETCH lc_ss
          INTO lv_owner, lv_table_name, lv_part_name, lv_change_factor,
               lv_partitioned;

         EXIT WHEN lc_ss%NOTFOUND;

         -- If change factor is greater than 5% then we will analyze the changed object in question
         IF lv_change_factor >= 5.00
         THEN
            -- Now determine whether the Object is a partition
            IF lv_partitioned = 'YES'
            THEN
               DBMS_OUTPUT.put_line
                                  (   'Gathering Stats for Partition '
                                   || lv_owner
                                   || '.'
                                   || lv_table_name
                                   || '.'
                                   || lv_part_name
                                   || ' because its change factor exceeds 5%...'
                                  );
               DBMS_STATS.gather_table_stats
                                          (ownname               => lv_owner,
                                           tabname               => lv_table_name,
                                           partname              => lv_part_name,
                                           granularity           => 'AUTO',
                                           method_opt            => 'for all columns',
                                           CASCADE               => DBMS_STATS.auto_cascade,
                                           DEGREE                => 8,
                                           estimate_percent      => .00001
                                          );
            ELSE
               DBMS_OUTPUT.put_line
                              (   'Gathering Stats for Table and Indexes of '
                               || lv_owner
                               || '.'
                               || lv_table_name
                               || ' because its change factor exceeds 5%...'
                              );
               DBMS_STATS.gather_table_stats
                              (ownname               => lv_owner,
                               tabname               => lv_table_name,
                               granularity           => 'AUTO',
                               method_opt            => 'for all columns',
                               CASCADE               => DBMS_STATS.auto_cascade,
                               estimate_percent      => DBMS_STATS.auto_sample_size
                              );
            END IF;
         ELSE
            NULL;
         END IF;
      END LOOP;

      CLOSE lc_ss;
   END;

   -- Procedure either start or stops the gathering of system-level statistics (i.e. I/O, CPU)
   -- Other wise known as the values found in sys.aux_stats$
   -- User passes the number of seconds that the gather should run
   PROCEDURE gather_system_stats (p_duration_secs IN NUMBER)
   AS
   BEGIN
      DBMS_STATS.gather_system_stats (gathering_mode => 'start');
      DBMS_LOCK.sleep (p_duration_secs);
      DBMS_STATS.gather_system_stats (gathering_mode => 'stop');
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   --Procedure makes internal calls to first delete all stats
   --and then gather them, including a gathering of system statistics
   PROCEDURE start_over
   AS
   BEGIN
      DBMS_OUTPUT.put_line ('Deleting all stats...');
      delete_all_stats;
      DBMS_OUTPUT.put_line ('Gathering user stats...');
      gather_stats;
      DBMS_OUTPUT.put_line ('Gathering dictionary stats...');
      gather_data_dict_stats;
      DBMS_OUTPUT.put_line ('Gathering system stats...');
      gather_system_stats (p_duration_secs => 120);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;
END dba_stats_maint_pkg;
/

SHOW errors