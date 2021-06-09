CREATE OR REPLACE FUNCTION CALLER_INFO
RETURN VARCHAR2
IS
    s VARCHAR2 (4000);
BEGIN
	$IF DBMS_DB_VERSION.ver_le_11_1 $THEN
	RETURN s;
	$ELSE
	for i in 1 .. utl_call_stack.dynamic_depth
	loop
		s := SUBSTR(s || utl_call_stack.backtrace_unit(i) || utl_call_stack.unit_line(i), 1, 4000);
    end loop;
	$END
	
	return s;
END;
/

SHOW ERRORS

QUIT

