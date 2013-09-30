--  FILE:   objcache_dep.sql
--
--  AUTHOR: Andy Rivenes, arivenes@appsdba.com, www.appsdba.com
--          Copyright (c) 2000, AppsDBA Consulting. All Rights Reserved.
--
--  DATE:   11/29/00
--
--  DESCRIPTION:
--          Query to map sessions using objects in the library cache.
--          This can be useful when sessions are waiting on library cache
--          locks (e.g. which sessions have the object pinned).
--          
--  REQUIREMENTS:
--          SELECT access to the following SYS views:
--		v$db_object_cache
--              v$object_dependency
--              v$sql
--              v$session
--		
--  MODIFICATIONS:
-- 
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--          
--
SET LINESIZE 180;
SET PAGESIZE 9999;
PROMPT ;
PROMPT > List Sessions Accessing Objects in the Library Cache By Object ;
COLUMN usrn         HEADING 'User'           FORMAT A7;
COLUMN ssid         HEADING 'SID'            FORMAT 9999;
COLUMN sstat        HEADING 'Session|Status' FORMAT A8;
COLUMN objown       HEADING 'User'           FORMAT A7;
COLUMN objnam       HEADING 'Object|Name'    FORMAT A15;
COLUMN namsp        HEADING 'Namespace'      FORMAT A15;
COLUMN shmem        HEADING 'Memory Used'    FORMAT 999,999,999;
COLUMN lds          HEADING 'Loads'          FORMAT 999,999;
COLUMN locks        HEADING 'Locks'          FORMAT 99;
COLUMN pins         HEADING 'Pins'           FORMAT 99;
COLUMN kept         HEADING 'Kept'           FORMAT A4 TRUNCATE;
COLUMN sqltxt       HEADING 'SQL'            FORMAT A40 WORD_WRAP;
-- SOURCE  Shared Pool Internals, Oracle
-- Note: to gather information for a single cursor, add this line to the where clause:
-- "and s.sql_text like '%cursor text%'".
SELECT ses.username usrn,
       ses.sid ssid,
       ses.status sstat,
       o.owner objown,
       o.name objnam,
       o.namespace namsp,
       o.sharable_mem shmem,
       o.loads lds,
       locks,
       pins,
       kept,
       s.sql_text sqltxt
  FROM v$db_object_cache o,
       v$object_dependency d,
       v$sql s,
       v$session ses
 WHERE o.owner = d.to_owner
   AND o.name = d.to_name
   AND d.from_address = s.address
   AND d.from_hash = s.hash_value
   AND s.address = ses.sql_address
   AND s.hash_value = ses.sql_hash_value
--   AND pins >= 1
   AND o.owner LIKE UPPER('%&owner')
   AND o.name LIKE UPPER('%&name')
/




