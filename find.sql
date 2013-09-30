set lines 200
column "Obj Name" for a30
column "Owner" for a15
COLUMN "Timestamp" for A20
column "Owner" for a20
col "Sub Obj" for a10

accept x_obj_name prompt "[= allowed  ] Object Name : ";
accept x_obj_type prompt "[=,! allowed] Object Type : ";
accept x_owner prompt    "[= allowed  ] Owner       : ";

select object_type "Obj Type", 
       object_name "Obj Name",
       subobject_name "Sub Obj",
       owner "Owner",
       substr( timestamp, 1, 20 ) "Timestamp",
       created "Created",
       last_ddl_time "Last DDL",
       status "Status"
from dba_objects
where ( ( substr( upper( nvl( '&&x_obj_name', 'x' ) ), 1, 1 ) <> '='
          and instr( nvl( '&&x_obj_name', 'x' ), '_' ) = 0
          and object_name like upper( '%&&x_obj_name%' ) )
        or 
        ( substr( upper( '&&x_obj_name' ), 1, 1 ) = '=' and object_name = upper( substr( '&&x_obj_name', 2 ) ) )
        or
        -- Oracle substitutes '_' as a generalised expression
        ( substr( upper( nvl( '&&x_obj_name', 'x' ) ), 1, 1 ) <> '='
          and instr( nvl( '&&x_obj_name', 'x' ), '_' ) > 0
          and instr( object_name, upper( '&&x_obj_name' ) ) > 0
        )
      )
  and ( ( substr( upper( '&&x_obj_type' ), 1, 1 ) = '!'  and object_type <> upper( substr( '&&x_obj_type', 2 ) ) )
         or
        ( substr( upper( '&&x_obj_type' ), 1, 1 ) = '='  and object_type = upper( substr( '&&x_obj_type', 2 ) ) )
         or
        (     substr( upper( nvl( '&&x_obj_type', 'x' ) ), 1, 1 ) <> '='
          and substr( upper( nvl( '&&x_obj_type', 'x' ) ), 1, 1 ) <> '!'
          and object_type like upper( '%&&x_obj_type%' )  )
      )
  and ( ( substr( upper( nvl( '&&x_owner', 'x' ) ), 1, 1 ) <> '=' and owner like upper( '%&&x_owner%' ) )
        or
        ( substr( upper( '&&x_owner' ), 1, 1 ) = '='  and owner = upper( substr( '&&x_owner', 2 ) ) )
      )
order by object_name, object_type, owner, created
/
