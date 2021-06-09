CREATE OR REPLACE PACKAGE TRACE
IS
	/*
		General purpose tracing module.
		It uses the table TRACE_LOG to store the messages and DBMS_OUTPUT.
		Conditional compilation with symbol $TRACE causes storing the trace
		message always. Without it, only errors and warnings are stored.
		The module name and action are stored in in the session context.
		They are used in the logging.
		The session memory statistics may be dumpped and the ression reset.
	*/

	IsDbmsOutput BOOLEAN := FALSE;

	/*
		Trace log message types for storage in TRACE_LOG
	*/
	cInfoType CONSTANT CHAR := 'I';
	cWarnType CONSTANT CHAR := 'W';
	cErrorType CONSTANT CHAR := 'E';

	/*
		Formatting line
	*/
	cNewLineSep CONSTANT CHAR := CHR(10);
	cMaxStringLen CONSTANT PLS_INTEGER := 4000;
	cMsgSep CONSTANT CHAR := ':';
	cMaxMsgLen CONSTANT PLS_INTEGER := 4000;

	/*
		Public methods
	*/
	PROCEDURE Info(pMsg IN VARCHAR2, pModule IN VARCHAR2 DEFAULT NULL, pAction IN VARCHAR2 DEFAULT NULL);
	PROCEDURE Info(pMsg IN CLOB, pModule IN VARCHAR2 DEFAULT NULL, pAction IN VARCHAR2 DEFAULT NULL);
	PROCEDURE Warn(pMsg IN VARCHAR2);
	PROCEDURE Warn(pMsg IN CLOB);
	PROCEDURE Error(pMsg IN VARCHAR2);
	PROCEDURE Error(pMsg IN CLOB);
	PROCEDURE Reset;
	PROCEDURE SetDbmsOutput(flag IN BOOLEAN DEFAULT FALSE);
	PROCEDURE SetModule(pModule IN VARCHAR2 DEFAULT NULL, pAction IN VARCHAR2 DEFAULT NULL);
	PROCEDURE Enable(waits IN BOOLEAN DEFAULT TRUE, binds IN BOOLEAN DEFAULT FALSE);
	PROCEDURE Disable;
	PROCEDURE Stat;
END;
/

SHOW ERROR

QUIT

