-- 9i prompt
set termout off
    define new_prompt='nolog'
    column value new_value new_prompt
    select SYS_CONTEXT('USERENV', 'SESSION_USER') || '@' ||SYS_CONTEXT('USERENV', 'DB_NAME') value
        from dual;
    set sqlprompt "&new_prompt> "
set termout on

-- 10g prompt
-- SET SQLPROMPT '&_USER@&_CONNECT_IDENTIFIER > '
set lines 200
set pages 500
set serveroutput on size 1000000
-- don't truncate LONGS & CLOBs
set long 1000000000 longc 60000
col object_name for a40
col name for a40
col value for a40
col string_value for a55
