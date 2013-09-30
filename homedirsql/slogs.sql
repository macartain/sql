select id,parent_id,level,lpad(' ',(level-1)*3)||substr(name,1,40) as "name", to_char(substr(value,1,50)) as "value"
from ipf_admin.systemregistryentry
start with parent_id = -2 and name = 'platform'
connect by prior id = parent_id;
