CREATE OR REPLACE PACKAGE BODY "ANALRATEFILES" is

  c_base_path varchar2(30) := gnvgen.getgparamstring('SYSlogFileRootDir') || '/';
  c_extension constant varchar2(30) := '.LOG';
  c_number_mask constant varchar2(30) := '99,999,990';
  c_one_second constant number := 1/24/60/60;
  c_full_dt constant varchar2(19) := 'dd/mm/yy hh24:mi:ss';
  c_ymd_dt constant varchar(8) := 'yyyymmdd';
  c_future_date constant date := to_date('31/12/2099','dd/mm/yyyy');
  c_min_output_slots constant pls_integer := 3; -- only output detail if there's enough data to bother about
  
  c_heading_1 constant varchar2(1000) := 
  '  Parallel   Start     Finish   Duration   Processed     Error     Rate Per    Idle   <--Active Only Rate-->  %age';
  c_heading_2 constant varchar2(1000) := 
  '   Streams    Time      Time                 Events      Events      Hour      Time      Hour      Instance   Chng';
  c_separator constant varchar2(1000) := 
  '  --------  --------- --------- --------- ----------  ----------  ----------  ------  ----------  ----------  ----';/*
    -xxx       hh:mm:ss  hh:mm:ss  hh:mm:ss -99,999,999 -99,999,999 -99,999,999 -99.99% -99,999,999 -99,999,999   -- 
     -xxx.xxx   hh:mm:ss  hh:mm:ss  hh:mm:ss-99,999,999 -99,999,999 -99,999,999 -99.99% -99,999,999 -99,999,999
*/
  c_total_sep1a constant varchar2(1000) := 
  '  --------  --------- --------- --------- ----------  -(';
  c_total_sep1b constant varchar2(1000) :=                     '%)-  ----------';
  c_e_heading_1 constant varchar2(1000)   := 
  ' Error Number  Count Error Description';
  c_e_separator_1 constant varchar2(1000) := 
  '-------------- ----- ----------------------------------------------------------------------------------------------------';
  c_e_separator_2 constant varchar2(1000) := 
  '               -----';
  c_e_total_space constant varchar2(1000) := 
  '              ';

  v_version varchar2(400);
  v_process_plan_desc processplan.process_plan_desc%type;
  v_parallelism processplan.parallelism%type;
  v_parameters processplan.parameters%type;
  v_polling_delay processplan.polling_delay%type;
           
  v_time_slot number := 0;
  v_time_slots_hr number := 1;
  v_time_slot_mins pls_integer := 0;
  
  type rate_anal_timeslot_rec 
    is record ( r_good_cnt pls_integer,
                r_error_cnt pls_integer,
                r_idle_cnt pls_integer
               );
  type rate_anal_timeslot_type is table of rate_anal_timeslot_rec
       index by binary_integer;
  type rate_anal_rec 
    is record ( r_good_cnt pls_integer,
                r_error_cnt pls_integer,
                r_start_dtm date,
                r_stop_dtm date,
                r_idle_cnt pls_integer,
                r_timeslots rate_anal_timeslot_type
               );
  type rate_anal_type is table of rate_anal_rec
       index by binary_integer;
  rate_anal_table rate_anal_type;

  type error_anal_rec
    is record ( r_error_domain varchar2(16),
                r_error_num number(5),
                r_error_text varchar2(400),
                r_error_count number(9)
               );
  type error_anal_type is table of error_anal_rec
       index by binary_integer;
  error_anal_table error_anal_type;
  
  -- Forward Declaration...
  procedure AnalOneFile ( p_directory_name varchar2, 
                          p_file_name varchar2,
                          p_start_dtm date,
                          p_rec_number pls_integer
                         );
  procedure OutputStats ( p_output_cnt pls_integer,
                          p_run_start_dtm date,
                          p_total_streams pls_integer,
                          p_running_streams pls_integer,
                          p_detailed_anal boolean
                         );
  procedure OutputErrors;
  procedure DumpRateAnalTable;
  procedure OP (p_output_message varchar2);
  
  -- Public entry point...
  procedure AnalRateLogs( p_process_id number,
                          p_detailed_anal boolean default true,
                          p_time_slot_secs pls_integer default 60*30
                         ) is

    v_total_streams number :=0;
    v_running_streams number :=0;

    v_process_id_cnt pls_integer :=0;
    v_running_id_cnt pls_integer :=0;
    v_base_proc_instance_id pls_integer :=0;

    v_run_start_dtm date;
    v_start_dtm date;
    v_run_end_dtm date;
    
    -- Finished streams - ordered by finished time...
    cursor finished_streams_cur is
    select c_base_path ||
           to_char(pil.start_dtm,c_ymd_dt) directory_name,
           to_char(pil.process_instance_id) ||
           c_extension file_name,
           pil.start_dtm,
           pil.process_instance_id
      from processinstancelog pil
     where pil.process_id = p_process_id
       and pil.end_dtm is not null
       and pil.phase = 'WORK'
     order by pil.end_dtm,
              pil.process_instance_id;

    -- Running streams...
    cursor running_streams_cur is
    select c_base_path ||
           to_char(pil.start_dtm,c_ymd_dt) directory_name,
           to_char(pil.process_instance_id) ||
           c_extension file_name
      from processinstancelog pil
     where pil.process_id = p_process_id
       and pil.end_dtm is null
       and pil.phase = 'WORK'
     order by pil.process_instance_id;

  begin
    v_time_slot := p_time_slot_secs * c_one_second;
    v_time_slots_hr := (1/24) / v_time_slot;
    v_time_slot_mins := p_time_slot_secs / 60;
    error_anal_table.delete;
    
    -- Find the number of streams the job is running in...
    select count(*) into v_total_streams
      from processinstancelog pil
     where pil.process_id = p_process_id
       and pil.phase = 'WORK';
    
    -- If we get a count of zero then the process_id must be wrong  
    if v_total_streams = 0 then
      OP ('Did not find process id : ' || to_char(p_process_id));
    end if;
    
    -- Get the info about the current process plan (assume its not changed since the job was run)
    select pp.process_plan_desc,
           pp.parallelism,
           pp.parameters,
           pp.polling_delay
      into v_process_plan_desc,
           v_parallelism,
           v_parameters,
           v_polling_delay
      from processplan pp
     where ( pp.process_def_id,
             pp.plan_number
            )
           =
           ( select pl.process_def_id,
                    pl.plan_number
               from processlog pl
              where pl.process_id = p_process_id
            );

    -- find the lowest start date (they should all be the same anyway)
    select min(pil.process_instance_id)-1, 
           min(pil.start_dtm),
           max(pil.end_dtm)
      into v_base_proc_instance_id,
           v_run_start_dtm,
           v_run_end_dtm
      from processinstancelog pil
     where pil.process_id = p_process_id
       and pil.phase = 'WORK';
    
    -- Initialize the table for the number of streams
    rate_anal_table.delete;
    for i in 1..v_total_streams
    loop
      rate_anal_table(i).r_good_cnt := 0;
      rate_anal_table(i).r_error_cnt := 0;
      rate_anal_table(i).r_start_dtm := null;
      rate_anal_table(i).r_stop_dtm := c_future_date;
      rate_anal_table(i).r_idle_cnt := 0;
    end loop;
         
    -- find how many streams are still running
    select count(*) into v_running_streams
      from processinstancelog pil
     where pil.process_id = p_process_id
       and pil.phase = 'WORK'
       and pil.end_dtm is null;
    
    -- for the finished streams start counting commits
    v_start_dtm := v_run_start_dtm;
    v_process_id_cnt :=0;
    for finished_streams_rec in finished_streams_cur
    loop
      v_process_id_cnt := v_process_id_cnt + 1;
      AnalOneFile ( finished_streams_rec.directory_name,
                    finished_streams_rec.file_name,
                    v_start_dtm,
                    v_process_id_cnt
                   );
      -- Set the start date to be the last stop time + 1 second
      v_start_dtm := rate_anal_table(v_process_id_cnt).r_stop_dtm + c_one_second;
    end loop;

    -- If we still have stream running...
    if v_running_streams > 0 then
      -- We're going to add all data to a single record
      v_running_id_cnt := v_process_id_cnt + 1;
      for running_streams_rec in running_streams_cur
      loop
        -- continue to count the number of log files
        v_process_id_cnt := v_process_id_cnt + 1;
        AnalOneFile ( running_streams_rec.directory_name,
                      running_streams_rec.file_name,
                      v_start_dtm, -- this came from the last finished job 
                      v_running_id_cnt -- this is constant for all log files
                     );
      end loop;
      -- if the process log files (stopped + running) is not equal the to total streams
      -- then a job must have finished after the initial select for stopped logs and before
      -- the select for running jobs
      if v_process_id_cnt <> v_total_streams then
        raise_application_error(-20500, 'Stream finished during analysis - please rerun');
      end if;
      -- As we're still running the stop time is now
      rate_anal_table(v_running_id_cnt).r_stop_dtm := sysdate;
    end if;

    if v_running_streams <> 0 then v_run_end_dtm := null; end if;

    OP ('         Process : ' || to_char(p_process_id));
    OP ('     Description : ' || v_process_plan_desc);
    OP ('     Parameteres : ' || v_parameters);
    OP (' Program Version : ' || v_version);
    OP ('      Started at : ' || to_char(v_run_start_dtm,c_full_dt));
    OP ('          End at : ' || to_char(v_run_end_dtm,c_full_dt));
    OP ('Streams/Finished : ' || to_char(v_total_streams) || '/' 
                              || to_char(v_total_streams - v_running_streams));
    OP ('');

    OutputStats ( v_process_id_cnt,
                  v_run_start_dtm,
                  v_total_streams,
                  v_running_streams,
                  p_detailed_anal
                 );
                 
    if error_anal_table.first is not null then OutputErrors; end if;
  DumpRateAnalTable;
  
  end AnalRateLogs;


  procedure OutputStats ( p_output_cnt pls_integer,
                          p_run_start_dtm date,
                          p_total_streams pls_integer,
                          p_running_streams pls_integer,
                          p_detailed_anal boolean
                         ) is 

    v_tot_rec number := 0;
    v_total_good pls_integer := 0;
    v_total_error pls_integer := 0;
    v_last_stop_dtm date;
    v_hrs number := 0;
    v_mins number := 0;
    v_secs number := 0;
    v_idle_percent number := 0;

    v_slot_start date;
    v_slot_dur char(8);
    v_slot_end char(8);
    v_slot_rate number := 0;
    v_slot_rate_active number := 0;
    v_slot_t_good number := 0;
    v_slot_t_error number := 0;
    v_slot_idle number := 0;
    v_suppress_zeros boolean := false;
    v_output_slot_detail boolean := false;
    v_detail_percent_sign char(2) := '';

    v_rate char(5);
    v_this_rate number := 0;
    v_next_rate number := 0;
    v_all_streams_rate number := 0;
    v_all_streams_rate_active number := 0;
    
    v_n1 number := 0;
    v_n2 number := 0;
    
    v_skipped_stream boolean := false;
   
  begin  
    OP ( c_heading_1 );
    OP ( c_heading_2 );
    OP ( c_separator );
    for i in 1..p_output_cnt
    loop
      if rate_anal_table(i).r_start_dtm is null then exit; end if;
      
      v_tot_rec := rate_anal_table(i).r_good_cnt + rate_anal_table(i).r_error_cnt;
      v_total_good := v_total_good + rate_anal_table(i).r_good_cnt;
      v_total_error := v_total_error + rate_anal_table(i).r_error_cnt;
      v_last_stop_dtm := rate_anal_table(i).r_stop_dtm;
      
      -- Duration of this Slot
      v_hrs := (rate_anal_table(i).r_stop_dtm - rate_anal_table(i).r_start_dtm) * 24;
      v_mins := abs((v_hrs - trunc(v_hrs)) * 60);
      v_secs := abs((v_mins - trunc(v_mins)) * 60);
      
      if v_hrs > 0 then
        v_n1 := rate_anal_table(i).r_idle_cnt * v_polling_delay / 1000; -- no idle seconds (polling milli secs)
        v_n1 := v_n1 / 60 / 60; -- converts number idle seconds into hours
        v_n2 := v_hrs * (p_total_streams - i + 1); -- total time available for rating across all running streams
        v_idle_percent := v_n1 / v_n2 * 100;
        v_n1 := 100 / (100 - v_idle_percent);
        v_all_streams_rate := v_tot_rec/v_hrs; -- overall rate 
        v_all_streams_rate_active := v_all_streams_rate * v_n1; --overall rate active time only
        v_this_rate := v_all_streams_rate_active/(p_total_streams - i + 1); -- rate/stream
      else
        v_idle_percent := 0;
        v_this_rate :=0;
        v_all_streams_rate := 0;
      end if;
      
      if i = p_output_cnt then
        v_rate := '  n/a';
      else
        v_n1 := rate_anal_table(i + 1).r_good_cnt + rate_anal_table(i + 1).r_error_cnt;
        v_n2 := (rate_anal_table(i + 1).r_stop_dtm - rate_anal_table(i + 1).r_start_dtm ) * 24;
        if v_n2 = 0 then
          v_next_rate :=0;
        else
          v_next_rate := v_n1/v_n2/(p_total_streams - i);
        end if;
        if nvl(v_next_rate,0) = 0 then
          v_rate := '  --';
        else
          v_n1 := (1 - (v_next_rate - v_this_rate) / v_next_rate) * 100;
          v_rate := to_char( v_n1,'999') || '%';
        end if;
      end if;
      
      if i = p_output_cnt and p_running_streams > 0 then
        OP ('');
        OP ('Still running...');
      end if;
      
      if v_hrs < 1 and v_mins < v_time_slot_mins then
        if not v_skipped_stream then
          v_skipped_stream := true;
          OP ( '  Duration too short...');
        end if;
      else
        v_skipped_stream := false;
        OP ( ' ' || 
             to_char(p_total_streams - i + 1,'999') || 
             to_char(rate_anal_table(i).r_start_dtm,'       hh24:mi:ss  ') ||
             to_char(rate_anal_table(i).r_stop_dtm,'hh24:mi:ss ') ||
             to_char(trunc(v_hrs),'90') || ':' ||
             to_char(trunc(v_mins),'FM00') || ':' ||
             to_char(trunc(v_secs),'FM00') || ' ' ||
             to_char(rate_anal_table(i).r_good_cnt,c_number_mask) || ' ' ||
             to_char(rate_anal_table(i).r_error_cnt,c_number_mask) || ' ' ||
             to_char(v_all_streams_rate,c_number_mask) || ' ' ||
             to_char(v_idle_percent,'90.00') || '% ' ||
             to_char(v_all_streams_rate_active,c_number_mask) || ' ' ||
             to_char(v_this_rate,c_number_mask) || ' ' || v_rate
            );
        if p_detailed_anal and nvl(rate_anal_table(i).r_timeslots.last,0) >= c_min_output_slots then 
          v_slot_t_good := 0;
          v_slot_t_error := 0;
          for j in rate_anal_table(i).r_timeslots.first..rate_anal_table(i).r_timeslots.last
          loop
            if j < rate_anal_table(i).r_timeslots.last then  -- if we not at the last record
              if rate_anal_table(i).r_timeslots(j).r_good_cnt = 0 and
                 rate_anal_table(i).r_timeslots(j).r_error_cnt = 0 then
                -- if both elements are zero no commits in the period - if we've previously 
                -- output a zero then don't bother with any more
                v_output_slot_detail := false;
                if v_suppress_zeros and
                   rate_anal_table(i).r_timeslots(j + 1).r_good_cnt = 0 and
                   rate_anal_table(i).r_timeslots(j + 1).r_error_cnt = 0 then
                  -- we've previously written an empty line so don't do any more if the next
                  -- record is zero as well
                  null;
                else
                  OP ( '  ' || 
                       to_char(p_total_streams - i + 1,'999.') ||
                       to_char(j,'FM000') || '  ...'
                      );
                  v_suppress_zeros := true;
                end if;
              else -- we've got non-zero records
                v_output_slot_detail := true;
              end if;
            else -- we are on the last records so output it
              v_output_slot_detail := true;
            end if;
  
            if v_output_slot_detail then
              v_slot_t_good := v_slot_t_good + rate_anal_table(i).r_timeslots(j).r_good_cnt;
              v_slot_t_error := v_slot_t_error + rate_anal_table(i).r_timeslots(j).r_error_cnt;
              v_slot_start := rate_anal_table(i).r_start_dtm + ( v_time_slot * (j - 1) );
              -- if the time slot goes beyond the end of the current section then 
              -- don't output the details
              if (v_slot_start + v_time_slot) > rate_anal_table(i).r_stop_dtm then
                v_slot_end := '';
                v_slot_dur := '';
                v_slot_rate := null;
                v_slot_idle := null;
                v_slot_rate_active := null;
                v_detail_percent_sign := '';
              else
                v_slot_end := to_char(v_slot_start + v_time_slot,'hh24:mi:ss');
                v_n1 := rate_anal_table(i).r_timeslots(j).r_idle_cnt * v_polling_delay / 1000;
                v_n1 := v_n1 / 60 / 60; -- converts number idle seconds into hours
                v_n2 := v_time_slot* 24 * (p_total_streams - i + 1); -- move this into hours
                v_slot_idle := v_n1 / v_n2 * 100;
                v_n1 := 100 / (100 - v_slot_idle);
                v_slot_rate := ( rate_anal_table(i).r_timeslots(j).r_good_cnt + 
                                 rate_anal_table(i).r_timeslots(j).r_error_cnt
                                ) * v_time_slots_hr;
                v_slot_rate_active := v_slot_rate * v_n1;
                v_slot_dur := to_char(trunc(sysdate) + v_time_slot,'hh24:mi:ss');
                if substr(v_slot_dur,1,1) = '0' then 
                  v_slot_dur := ' ' || substr(v_slot_dur,2); 
                end if;
                v_detail_percent_sign := '%';
              end if;
              v_suppress_zeros := false; -- we've output a detail line so show future zeros
              
              OP ( '  ' || 
                   to_char(p_total_streams - i + 1,'999.') ||
                   to_char(j,'FM000') || 
                   to_char(v_slot_start,'   hh24:mi:ss  ') ||
                   v_slot_end ||'  ' || 
                   v_slot_dur || 
                   to_char(rate_anal_table(i).r_timeslots(j).r_good_cnt,c_number_mask) || ' ' ||
                   to_char(rate_anal_table(i).r_timeslots(j).r_error_cnt,c_number_mask) || ' ' ||
                   to_char(v_slot_rate,c_number_mask) || ' ' ||
                   to_char(v_slot_idle,'90.99') || v_detail_percent_sign ||
                   to_char(v_slot_rate_active,c_number_mask) || ' ' ||
                   to_char(v_slot_rate_active/(p_total_streams - i + 1),c_number_mask)
                  );
            end if; -- end of outputting one detail line
          end loop; -- end outputting the detail
          if ( rate_anal_table(i).r_good_cnt <> v_slot_t_good ) or
             ( rate_anal_table(i).r_error_cnt <> v_slot_t_error ) then 
            OP ( '               ERROR Counts not matching:' || 
                 to_char(v_slot_t_good,c_number_mask) || ' ' ||
                 to_char(v_slot_t_error,c_number_mask) || ' ' 
                );
          end if;
        end if; -- end of detailed analysis
      end if; -- end of output of all data if less than time slot
    end loop;
    
    -- Output totals and percentage error...
    OP ( c_separator ); 
    v_hrs := (v_last_stop_dtm - p_run_start_dtm) * 24;
    v_mins := (v_hrs - trunc(v_hrs)) * 60;
    v_secs := (v_mins - trunc(v_mins)) * 60;

    OP ( '      All' || 
         to_char(p_run_start_dtm,'   hh24:mi:ss  ') ||
         to_char(v_last_stop_dtm,'hh24:mi:ss ') ||
         to_char(trunc(v_hrs),'90') || ':' ||
         to_char(trunc(v_mins),'FM00') || ':' ||
         to_char(trunc(v_secs),'FM00') || ' ' ||
         to_char(v_total_good,c_number_mask) || ' ' ||
         to_char(v_total_error,c_number_mask) || ' ' ||
         to_char( (v_total_good + v_total_error) / ((v_last_stop_dtm - p_run_start_dtm) * 24) ,c_number_mask)
        );
    if (v_total_good + v_total_error) > 0 then
        v_n1 := v_total_error / (v_total_good + v_total_error) * 100;
    else
        v_n1 := 0;
    end if;
    OP ( c_total_sep1a || 
         substr(to_char(v_n1,'90.00'),2) ||
         c_total_sep1b
        );
    OP ('');
    
  end OutputStats;
  
  
  procedure OutputErrors is
  v_total_errors number := 0;
  begin
    OP ( c_e_heading_1 );
    OP ( c_e_separator_1 );
    
    for i in error_anal_table.first..error_anal_table.last
    loop
      OP ( lpad(error_anal_table(i).r_error_domain,8) || '-' || 
           to_char(error_anal_table(i).r_error_num,'FM00000') ||
           to_char(error_anal_table(i).r_error_count,'99999') || ' ' ||
           substr(error_anal_table(i).r_error_text,1,100)
          );
      v_total_errors := v_total_errors + error_anal_table(i).r_error_count;
    end loop;
    
    OP ( c_e_separator_2 );
    OP ( c_e_total_space || to_char(v_total_errors,'99999'));
    OP ( '');
  end OutputErrors;
  
  
  -- Look at one log file...
  procedure AnalOneFile ( p_directory_name varchar2, 
                          p_file_name varchar2,
                          p_start_dtm date,
                          p_rec_number pls_integer
                         )
  is
  
    v_log_file_handle utl_file.file_type;
    v_log_rec varchar2(4000);
    v_work_char varchar2(1000);
    v_pos1 pls_integer;
    v_pos2 pls_integer;
    v_good_cnt pls_integer;
    v_error_cnt pls_integer;
    v_timeslot pls_integer;
    v_dtm date;
    v_dtm_char varchar2(17);

    v_error_num_text varchar2(20);
    v_error_domain varchar2(16);
    v_error_num number(5);
    v_error_text varchar2(400);
    v_found boolean;
    v_zero_commit boolean := false;
    
  begin
    v_log_file_handle := utl_file.fopen ( p_directory_name, p_file_name, 'r');

    -- Set the start date to the passed in 
    rate_anal_table(p_rec_number).r_start_dtm := p_start_dtm;
    -- the stop date is big future and the counts are initialzed to zero

    loop
      utl_file.get_line (v_log_file_handle, v_log_rec);
      -- Analyse the string - if its a commit...
      if instr(v_log_rec,'Enqueuing to CostedEvent queue') <> 0 then
        --5.1
        --INFORM----RATEbuffers.c:3373:17/06/04 20:02:54 > Committed to database: 100 rated events, 0 rejected events affecting 7 (possibly non-unique) accounts over 1 commits.
        --5.3
        --INFORM----RATEbuffers.c:3732:01/12/05 23:10:36 > Enqueuing to CostedEvent queue: 100 rated event(s), 0 rejected event(s) and 0 filtered event(s) affecting 8 account(s).

        v_work_char := substr( v_log_rec,instr(v_log_rec,':',-1));
        --: 100 rated events, 0 rejected events affecting 7 (possibly non-unique) accounts over 1 commits.
        -- 1   2     3       4 5  Count of spaces
        v_pos1 := instr(v_work_char,' ',1,1);
        v_pos2 := instr(v_work_char,' ',1,2);
        v_good_cnt := to_number( substr(v_work_char,v_pos1 + 1,v_pos2 - v_pos1 - 1));
        v_pos1 := instr(v_work_char,' ',1,4);
        v_pos2 := instr(v_work_char,' ',1,5);
        v_error_cnt := to_number( substr(v_work_char,v_pos1 + 1,v_pos2 - v_pos1 - 1));
        if v_good_cnt = 0 and v_error_cnt = 0 then -- if the last envelope was empty start checking
          v_zero_commit := true;                   -- for no events passed to function message
        else                                       -- (if last envelope is full then do get the message)
          v_zero_commit := false;
        end if;
        v_pos1 := instr(v_log_rec,':',1,2);
        v_pos2 := instr(v_log_rec,'>');
        v_dtm := to_date( substr(v_log_rec,v_pos1 + 1,v_pos2 - v_pos1 - 1),c_full_dt);
        v_dtm_char := to_char(v_dtm,c_full_dt);
        for i in 1..p_rec_number
        loop
          -- Update the relevant counts based on the time of the commit
          if v_dtm >= rate_anal_table(i).r_start_dtm and v_dtm <= rate_anal_table(i).r_stop_dtm then
            rate_anal_table(i).r_good_cnt := rate_anal_table(i).r_good_cnt + v_good_cnt;
            rate_anal_table(i).r_error_cnt := rate_anal_table(i).r_error_cnt + v_error_cnt;
            -- for the work out which time slot this commit is in
            -- as the files are sequentially written we are always increasing the count
            -- note there may be holes in the sequence due to no commits in the analysis period
            v_timeslot := trunc ( ( v_dtm - rate_anal_table(i).r_start_dtm) / v_time_slot ) + 1;
            if v_timeslot > nvl(rate_anal_table(i).r_timeslots.last,0) then
              for l in nvl(rate_anal_table(i).r_timeslots.last,0) + 1..v_timeslot
              loop
                rate_anal_table(i).r_timeslots(l).r_good_cnt := 0;
                rate_anal_table(i).r_timeslots(l).r_error_cnt := 0;
                rate_anal_table(i).r_timeslots(l).r_idle_cnt := 0;
              end loop;
            end if;
            rate_anal_table(i).r_timeslots(v_timeslot).r_good_cnt 
                          := rate_anal_table(i).r_timeslots(v_timeslot).r_good_cnt + v_good_cnt;
            rate_anal_table(i).r_timeslots(v_timeslot).r_error_cnt 
                          := rate_anal_table(i).r_timeslots(v_timeslot).r_error_cnt + v_error_cnt;
          end if;
        end loop;
      -- the end of 'Committed to database' messages
      elsif instr(v_log_rec,'ERROR---') <> 0 then
        v_pos1 := instr(v_log_rec,'>');
        v_pos2 := instr(v_log_rec,':',1,5);
        v_error_num_text := substr(v_log_rec,v_pos1 + 2,v_pos2 - v_pos1 - 2);
        v_error_domain := substr(v_error_num_text,1,instr(v_error_num_text,'-') - 1);
        begin
            v_error_num := substr(v_error_num_text,instr(v_error_num_text,'-') + 1);
          exception
            when others then
              v_error_num := -9923;
        end;
        v_error_text := substr(v_log_rec,v_pos2 + 2);
        v_found := false;

        for i in nvl(error_anal_table.first,1)..nvl(error_anal_table.last,0)
        loop
          if v_error_domain = error_anal_table(i).r_error_domain 
             and v_error_num = error_anal_table(i).r_error_num then
            error_anal_table(i).r_error_count := error_anal_table(i).r_error_count + 1;
            v_found := true;
            exit;
          end if;
        end loop;
        if not v_found then
          error_anal_table(nvl(error_anal_table.last,0) + 1).r_error_domain := v_error_domain;
          -- since we've just created an entry the last count is now used...
          error_anal_table(error_anal_table.last).r_error_num := v_error_num;
          error_anal_table(error_anal_table.last).r_error_count := 1;
          begin
            select gmm.message_text into error_anal_table(error_anal_table.last).r_error_text
              from gmmessage gmm
             where gmm.message_domain = v_error_domain
               and gmm.message_number = v_error_num;
          exception
            when no_data_found then
              error_anal_table(error_anal_table.last).r_error_text := v_error_text;
          end;
        end if;
      -- the end of 'ERROR---' messages
      elsif instr(v_log_rec,'Geneva Version:') <> 0 then
        v_pos1 := instr(v_log_rec,'Geneva Version:');
        v_version := substr(v_log_rec,v_pos1 + 16);
      -- the end of 'Geneva Version:' messages
      elsif instr(v_log_rec,'SOLRPI: No costed events passed to function') <> 0 and v_zero_commit then
        v_pos1 := instr(v_log_rec,':',1,2);
        v_pos2 := instr(v_log_rec,'>');
        v_dtm := to_date( substr(v_log_rec,v_pos1 + 1,v_pos2 - v_pos1 - 1),c_full_dt);
        v_dtm_char := to_char(v_dtm,c_full_dt);
        for i in 1..p_rec_number
        loop
          -- Update the idle count based on the time of this record
          if v_dtm >= rate_anal_table(i).r_start_dtm and v_dtm <= rate_anal_table(i).r_stop_dtm then
            rate_anal_table(i).r_idle_cnt := rate_anal_table(i).r_idle_cnt + 1;
            v_timeslot := trunc ( ( v_dtm - rate_anal_table(i).r_start_dtm) / v_time_slot ) + 1;
            if v_timeslot > nvl(rate_anal_table(i).r_timeslots.last,0) then
              for l in nvl(rate_anal_table(i).r_timeslots.last,0) + 1..v_timeslot
              loop
                rate_anal_table(i).r_timeslots(l).r_good_cnt := 0;
                rate_anal_table(i).r_timeslots(l).r_error_cnt := 0;
                rate_anal_table(i).r_timeslots(l).r_idle_cnt := 0;
              end loop;
            end if;
            rate_anal_table(i).r_timeslots(v_timeslot).r_idle_cnt := 
                          rate_anal_table(i).r_timeslots(v_timeslot).r_idle_cnt + 1;
          end if;
        end loop;
      -- the end of 'SOLRPI: No costed events passed to function' messages
      end if;
      
    end loop;
    
  exception
    -- We've come to the end of the file - set the stop time and close the file
    when no_data_found then
      rate_anal_table(p_rec_number).r_stop_dtm := v_dtm;
      utl_file.fclose(v_log_file_handle);
      
    -- Problems opening the log file                                        
    when utl_file.invalid_operation then 
      utl_file.fclose(v_log_file_handle);
      raise_application_error(-20500, 'Did not find log file ' || p_directory_name || '/' || p_file_name);

  end AnalOneFile;

  
  procedure DumpRateAnalTable
  is
    --c_debug_user varchar2(50) := 'geneva_admin';
    c_debug_user varchar2(50) := 'nodebug';


    v_user varchar2(50);
    c_heading3 varchar2(1000) :=
 '        good      error             start               end       idle   id       good      error      idle';
  --99,999,999 99,999,999 dd/mm/yy hh:mm:ss dd/mm/yy hh:mm:ss 99,999,999   
    c_spacer varchar2(1000) :=
 '                                                                      ';  
--                                                                       999 99,999,999 99,999,999 99,999,99
  begin
    select user into v_user
      from dual;
     
    if v_user = c_debug_user then
      op ( c_heading3);
      for i in rate_anal_table.first..rate_anal_table.last
      loop
        op ( ' ' ||
             to_char(rate_anal_table(i).r_good_cnt,c_number_mask) ||
             to_char(rate_anal_table(i).r_error_cnt,c_number_mask) || ' ' ||
             to_char(nvl(rate_anal_table(i).r_start_dtm,to_date('01/01/1800','dd/mm/yyyy')),c_full_dt) || ' ' ||
             to_char(nvl(rate_anal_table(i).r_stop_dtm,to_date('01/01/1800','dd/mm/yyyy')),c_full_dt) ||
             to_char(rate_anal_table(i).r_idle_cnt,c_number_mask)
            );
         if rate_anal_table(i).r_timeslots.first is not null then
           for j in rate_anal_table(i).r_timeslots.first..rate_anal_table(i).r_timeslots.last
           loop
             op ( c_spacer ||
                  to_char(j,'999') || ' ' ||
                  to_char(rate_anal_table(i).r_timeslots(j).r_good_cnt,c_number_mask) || 
                  to_char(rate_anal_table(i).r_timeslots(j).r_error_cnt,c_number_mask) ||
                  to_char(rate_anal_table(i).r_timeslots(j).r_idle_cnt,c_number_mask)
                 );
            end loop;
         end if;
      end loop;
    end if;
    
  end DumpRateAnalTable;

  
  procedure OP (p_output_message varchar2)
  is
  begin
    dbms_output.put_line (p_output_message);
  end OP;

end AnalRateFiles;
