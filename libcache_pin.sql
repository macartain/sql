--  FILE:   libcache_pin.sql
--
--  AUTHOR: Andy Rivenes, arivenes@appsdba.com, www.appsdba.com
--          (Source: Oracle Note: 61623.1)
--          Copyright (C) 1999 AppsDBA Consulting
--
--  DATE:   01/12/1999
--
--  DESCRIPTION:
--          Query to display objects in the library cache that have "chunks"
--          greater than 5K.  These objects are the best candidates to be
--          "pinned". 
--
--  REQUIREMENTS:
--          Oracle Version 7.3+
--          
--  MODIFICATIONS:
--          A. Rivenes, 10/11/1999, Combined code from another "libcache"
--                                  SQL statement to make this query more usable.
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
PROMPT >     Objects listed are the best candidates for "keeping" ;
COLUMN type         HEADING 'Type'           FORMAT A12 TRUNCATE;
COLUMN owner        HEADING 'Owner'          FORMAT A10 TRUNCATE;
COLUMN name         HEADING 'Name'           FORMAT A35 TRUNCATE;
COLUMN executions   HEADING 'Executions'     FORMAT 9,999,999;
COLUMN loads        HEADING 'Loads'          FORMAT 999,999
COLUMN sharable_mem HEADING 'Memory Used'    FORMAT 999,999,999;
COLUMN kept         HEADING 'Kept'           FORMAT A4 TRUNCATE;
SELECT dbc.type,
       dbc.owner,
       dbc.name,
       dbc.executions,
       dbc.loads,
       dbc.sharable_mem,
       dbc.kept
  FROM v$db_object_cache dbc,
       ( SELECT DISTINCT DECODE(kglobtyp,0,'CURSOR',
                                7,'PROCEDURE',
                                8,'FUNCTION',
                                9,'PACKAGE',
                               11,'PACKAGE BODY',
                               12,'TRIGGER',
                               13,'TYPE',
                               14,'TYPE BODY',
                               'OTHER') type,
                kglnaown,
                kglnaobj
           FROM x$kglob
          WHERE kglobhd4 IN ( SELECT ksmchpar
                                FROM x$ksmsp
                               WHERE ksmchcom = 'PL/SQL MPCODE'
                                 AND ksmchsiz > 5120 ) ) chnk
 WHERE dbc.owner = chnk.kglnaown
   AND dbc.name = chnk.kglnaobj
   AND dbc.type = chnk.type
 ORDER BY dbc.sharable_mem desc;
