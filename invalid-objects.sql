set pages 200
set lines 180
col OBJECT_NAME for a35
col owner for a22

select OBJECT_TYPE, OWNER, OBJECT_NAME
   from DBA_OBJECTS A
  where A.STATUS = 'INVALID'
  and OBJECT_TYPE !='SYNONYM'
order   by OWNER, A.OBJECT_TYPE,
        A.OBJECT_NAME;