--  FILE:   asm_info.sql
--
--  AUTHOR: Andy Rivenes, arivenes@appsdba.com, www.appsdba.com
--          Copyright (c) 2004, AppsDBA Consulting.  All Rights Reserved.
--
--  DATE:   12/14/2004
--
--  DESCRIPTION:
--          Query to show ASM information
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
SET PAGESize 9999;
SET LINESize 120;
SET VERIFY off;
SET TRIMSpool on;
--
--ACCEPT fileid CHAR PROMPT 'Enter File ID --> ';
--ACCEPT loblk  CHAR PROMPT 'Enter Low Block Num --> ';
--ACCEPT hiblk  CHAR PROMPT 'Enter High Block Num --> ';
--
PROMPT > ASM Diskgroup Information
--
COLUMN name       HEADING 'Group Name'          FORMAT A30;
COLUMN blks       HEADING 'Block|Size'          FORMAT 99,999;
COLUMN allocs     HEADING 'Allocation|Size'     FORMAT 999,999,999;
COLUMN state      HEADING 'State'               FORMAT A11;
COLUMN type       HEADING 'Type'                FORMAT A6;
COLUMN total_mb   HEADING 'Total MB'            FORMAT 9,999,999;
COLUMN free_mb    HEADING 'Free MB'             FORMAT 9,999,999;
--
SELECT name,
       block_size blks,
       allocation_unit_size allocs,
       state,
       type,
       total_mb,
       free_mb
  FROM v$asm_diskgroup
 ORDER BY group_number
/
--
PROMPT > ASM Connected Clients
--
COLUMN gnam       HEADING 'Group Name'          FORMAT A15;
COLUMN inam       HEADING 'Instance|Name'       FORMAT A10;
COLUMN dnam       HEADING 'Database|Name'       FORMAT A8;
COLUMN status     HEADING 'Status'              FORMAT A12;
--
SELECT dg.name gnam,
       c.instance_name inam,
       c.db_name dnam,
       status
  FROM v$asm_diskgroup dg,
       v$asm_client c
 WHERE dg.group_number = c.group_number
 ORDER BY c.instance_name,
       c.db_name, 
       c.group_number
/
--
PROMPT > ASM Disk Status
--
COLUMN gnam             HEADING 'Group Name'          FORMAT A10;
COLUMN disk_number      HEADING 'Disk|Num'            FORMAT 9999;
COLUMN name             HEADING 'Name'                FORMAT A10;
COLUMN path             HEADING 'Path'                FORMAT A10;
COLUMN mount_status     HEADING 'Mount|Status'        FORMAT A7;
COLUMN header_status    HEADING 'Header|Status'       FORMAT A12;
COLUMN mode_status      HEADING 'Mode|Status'         FORMAT A7;
COLUMN state            HEADING 'State'               FORMAT A8;
COLUMN redundancy       HEADING 'Redncy'              FORMAT A7;
COLUMN total_mb         HEADING 'Total(MB)'           FORMAT 9,999,999;
COLUMN free_mb          HEADING 'Free(MB)'            FORMAT 9,999,999;
COLUMN rds              HEADING 'Rds(K)'              FORMAT 9,999,999;
COLUMN brds             HEADING 'Bytes|Rd(MB)'        FORMAT 9,999,999;
COLUMN read_time        HEADING 'Rd Tim'              FORMAT 9,999,999;
COLUMN read_errs        HEADING 'Rd Errs'             FORMAT 99,999;
COLUMN wrts             HEADING 'Wrts'                FORMAT 9,999,999;
COLUMN bwrts            HEADING 'Bytes|Wrt(MB)'       FORMAT 9,999,999;
COLUMN write_time       HEADING 'Wrt Tim'             FORMAT 9,999,999;
COLUMN write_errs       HEADING 'Wrt Errs'            FORMAT 99,999;
--
select dg.name gnam,
       d.disk_number,
       d.name,
--       d.path,
       d.mount_status,
       d.header_status,
       d.mode_status,
       d.state,
       d.redundancy,
       d.total_mb,
       d.free_mb,
--
       DECODE(d.reads,0,0,d.reads/1024) rds,
       DECODE(d.bytes_read,0,0,
              d.bytes_read/1024/1024) brds,
--       d.read_time,
       d.read_errs,
--
       DECODE(d.writes,0,0,d.writes/1024) wrts,
       DECODE(d.bytes_written,0,0,
              d.bytes_written/1024/1024) bwrts,
--       d.write_time,
       d.write_errs
  FROM v$asm_disk d,
       v$asm_diskgroup dg
 WHERE dg.group_number = d.group_number
 ORDER BY d.group_number,
       d.disk_number
/
--
PROMPT > ASM File Summary
--
COLUMN gnam             HEADING 'Group Name'          FORMAT A15;
COLUMN type             HEADING 'File Type'           FORMAT A20;
COLUMN num              HEADING 'Number'              FORMAT 999,999;
COLUMN bused            HEADING 'Space Used(MB)'      FORMAT 9,999,999;
COLUMN balloc           HEADING 'Space Alloc(MB)'     FORMAT 9,999,999;
--
SELECT dg.name gnam,
       f.type,
       count(*) num,
       sum(f.bytes)/1024/1024 bused,
       sum(f.space)/1024/1024 balloc
  FROM v$asm_file f,
       v$asm_diskgroup dg
 WHERE dg.group_number = f.group_number
 GROUP BY dg.name,
       f.type
/
--
PROMPT > ASM Templates
--
COLUMN gnam             HEADING 'Group Name'          FORMAT A15;
COLUMN en               HEADING 'Template|Number'     FORMAT 9999999;
COLUMN re               HEADING 'Redundancy'          FORMAT A6;
COLUMN stripe           HEADING 'Stripe'              FORMAT A6;
COLUMN system           HEADING 'System|Template?'    FORMAT A9;
COLUMN name             HEADING 'Template|Name'       FORMAT A30;
--
SELECT dg.name gnam,
       t.entry_number en,
       t.redundancy re,
       t.stripe,
       DECODE(t.system,'Y','Yes','N','No') system,
       t.name
  FROM v$asm_template t,
       v$asm_diskgroup dg
 WHERE dg.group_number = t.group_number
/

