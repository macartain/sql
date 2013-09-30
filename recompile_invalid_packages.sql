declare
	-- Please update the OWNER to match your environment
    p_owner VARCHAR2(100) := 'GENEVA_ADMIN';
	allObjectsRow        ALL_OBJECTS%rowtype;
	stmCompile           VARCHAR(300);
	cursor curInvalidObjects is 
		select * from ALL_OBJECTS 
		where upper(OWNER) = p_owner 
		and STATUS = 'INVALID' 
		and OBJECT_TYPE in ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER');
begin
	open curInvalidObjects;
	fetch curInvalidObjects into allObjectsRow;

	-- Cycle through all tables in CachedTable
	while curInvalidObjects%FOUND LOOP

		if    allObjectsRow.OBJECT_TYPE = 'PACKAGE' then
			stmCompile := 'alter package '   || p_owner || '.' || allObjectsRow.OBJECT_NAME || ' compile package REUSE SETTINGS';
		elsif allObjectsRow.OBJECT_TYPE = 'PACKAGE BODY' then
			stmCompile := 'alter package '   || p_owner || '.' || allObjectsRow.OBJECT_NAME || '  compile body REUSE SETTINGS';
		elsif allObjectsRow.OBJECT_TYPE = 'FUNCTION' then
			stmCompile := 'alter function '  || p_owner || '.' || allObjectsRow.OBJECT_NAME || '  compile REUSE SETTINGS';
		elsif allObjectsRow.OBJECT_TYPE = 'PROCEDURE' then
			stmCompile := 'alter procedure ' || p_owner || '.' || allObjectsRow.OBJECT_NAME || '  compile REUSE SETTINGS';                
		elsif allObjectsRow.OBJECT_TYPE = 'TRIGGER' then
			stmCompile := 'alter trigger ' || p_owner || '.' || allObjectsRow.OBJECT_NAME || '  compile REUSE SETTINGS';                
		end if;
        
        BEGIN
			execute immediate stmCompile;
			DBMS_OUTPUT.PUT_LINE ('Compiled:' || allObjectsRow.OBJECT_NAME );       
		exception
		when others then
			DBMS_OUTPUT.PUT_LINE ('Error compiling:' || allObjectsRow.OBJECT_NAME );                  
        END;

		fetch curInvalidObjects into allObjectsRow;

	END LOOP; -- End while loop

end;
/
