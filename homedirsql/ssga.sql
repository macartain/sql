col COMPONENT for a35
col curr for 999,999
col minsz for 999,999
col maxsz for 999,999
col usersz for 999,999
col OPER_COUNT for 999,999,999
col GRANULE  for a8

select COMPONENT, CURRENT_SIZE/(1024*1024) curr, MIN_SIZE/(1024*1024) minsz, MAX_SIZE/(1024*1024) maxsz, USER_SPECIFIED_SIZE/(1024*1024) usersz, OPER_COUNT, LAST_OPER_TYPE type, LAST_OPER_mode as opmode, TO_CHAR(LAST_OPER_TIME,'DDMONYYYY-HH24:MI:SS') last_op, GRANULE_SIZE/(1024*1024)||'K' granule
from v$sga_dynamic_components;

