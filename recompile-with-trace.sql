ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=3;

ALTER PACKAGE TRACE COMPILE plsql_ccflags='TRACE:TRUE';

SHOW ERRORS

QUIT
