column instt_num  heading "Inst Num"  format 99999;
column instt_name heading "Instance"  format a12;
column dbb_name   heading "DB Name"   format a12;
column dbbid      heading "DB Id"     format 9999999999 just c;
column host       heading "Host"      format a12;

variable dbid       number;
variable inst_num   number;
variable bid        number;
variable eid        number;

prompt
prompt
prompt Instances in this Statspack schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct 
       dbid            dbbid
     , instance_number instt_num
     , db_name         dbb_name
     , instance_name   instt_name
     , host_name       host
  from stats$database_instance;

prompt
prompt Using &dbid for database Id
prompt Using &inst_num for instance number


--
--  Set up the binds for dbid, instance_number, snap_ids

begin
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num;
  :bid       :=  &begin_snap;
  :eid       :=  &end_snap;
end;
/


prompt Using &&bid for start
prompt Using &&eid for finish
