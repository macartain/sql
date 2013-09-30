set echo off
REM Formatting columns
set lines 200
col indx format 9999
col inst_id heading "INST" format 9999
col ksppinm heading "NAME" format a40
col ksppdesc heading "DESC" format a70
col ksppstvl heading "CURR VAL" format a15
col ksppstdvl heading "DEFAULT VAL" format a15
REM Query to check the value of input "parameter_name"
set echo on
select v.indx,v.inst_id,ksppinm,ksppstvl,ksppstdvl,ksppdesc from x$ksppi i ,x$ksppcv v
where i.indx=v.indx;
