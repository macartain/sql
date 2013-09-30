-- *********************************************************
-- Copied from RBM4.3 static data SQL - basic role setup
-- to allow GENEVA_ADMIN login.
-- *********************************************************

-- *********************************************************
-- GENEVAUSER
-- *********************************************************

delete from GENEVAUSER
where geneva_user_ora = 'GENEVA_ADMIN';
commit;

insert into GENEVAUSER (
geneva_user_ora,
language_id,
encrypt_password_boo
)
VALUES
(
'GENEVA_ADMIN',
-1,
'F'
);
commit;

-- *********************************************************
-- GENEVAUSERHASBUSINESSROLE
-- *********************************************************

delete from GENEVAUSERHASBUSINESSROLE
where geneva_user_ora = 'GENEVA_ADMIN'
and business_role_id = 27;

commit;

insert into GENEVAUSERHASBUSINESSROLE (
geneva_user_ora,
business_role_id
)
VALUES
(
'GENEVA_ADMIN',
27
);
commit;

