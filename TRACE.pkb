CREATE OR REPLACE PACKAGE BODY TRACE
IS
	/*
		Only in case of error get stack info
	*/
	FUNCTION ErrorContext(pType IN VARCHAR2)
	RETURN VARCHAR2
	IS
	BEGIN
		RETURN
			CASE
				WHEN pType = cErrorType THEN
					SUBSTR
					(
						'Error code: ' || SQLCODE || CHR(10) ||
						'Error message: ' || SQLERRM || CHR(10) ||
						'Error stack:' || CHR(10) || DBMS_UTILITY.FORMAT_ERROR_STACK ||
						'Error backtrace:' || CHR(10) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
						1,
						cMaxMsgLen
					)
				ELSE ''
			END;
	END;

	/*
		Store message with putput printout as well
	*/
	PROCEDURE SaveMsg(pType IN CHAR, pCaller IN VARCHAR2, pMsg IN VARCHAR2)
	IS
		vMore VARCHAR2(4000) := '';
		vId TRACE_LOG.ID%TYPE;
		vTs TRACE_LOG.TS%TYPE;
		vMsg TRACE_LOG.MSG%TYPE;
	BEGIN
		IF pType = cErrorType
		THEN
			vMore := ErrorContext(pType);
		END IF;
		INSERT INTO TRACE_LOG (ID, TS, TY, CALLER, MSG)
		VALUES
		(
			TRACE_LOG_SEQ.NEXTVAL,
			SYSTIMESTAMP,
			pType,
			pCaller,
			SUBSTR(pMsg || CHR(10) || vMore, 1, cMaxMsgLen)
		)
		RETURNING ID, TS, MSG INTO vId, vTs, vMsg;
		IF IsDbmsOutput
		THEN
			DBMS_OUTPUT.PUT_LINE
			(
				vId || cMsgSep ||
				vTs || cMsgSep ||
				pCaller || cMsgSep ||
				vMsg
			);
		END IF;
	END;

	/*
		Store long message with putput printout as well
	*/
	PROCEDURE SaveLongMsg(pType IN CHAR, pCaller IN VARCHAR2, pMsg IN CLOB)
	IS
		vMore VARCHAR2(4000) := '';
		vId TRACE_LOG.ID%TYPE;
		vTs TRACE_LOG.TS%TYPE;
		vMsgLong TRACE_LOG.MSGL%TYPE;
	BEGIN
		IF pType = cErrorType
		THEN
			vMore := ErrorContext(pType);
		END IF;
		INSERT INTO TRACE_LOG (ID, TS, TY, CALLER, MSGL)
		VALUES
		(
			TRACE_LOG_SEQ.NEXTVAL,
			SYSTIMESTAMP,
			pType,
			pCaller,
			pMsg || cNewLineSep || vMore
		)
		RETURNING ID, TS, MSGL INTO vId, vTs, vMsgLong;
		IF IsDbmsOutput
		THEN
		   DBMS_OUTPUT.PUT_LINE
		   (
				vId || cMsgSep ||
				vTs || cMsgSep ||
				pCaller || cMsgSep ||
				vMsgLong
			);
		END IF;
	END;

	/*
		Info
	*/
	PROCEDURE Info(pMsg IN VARCHAR2, pModule IN VARCHAR2, pAction IN VARCHAR2)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vInfo VARCHAR2(255) := CALLER_INFO;
	BEGIN $IF $$TRACE $THEN
		IF pModule IS NOT NULL
		THEN
			DBMS_APPLICATION_INFO.SET_MODULE
			(
			  module_name => pModule,
			  action_name => pAction
			);
		END IF;
		PRAGMA INLINE (SaveMsg, 'YES');
		SaveMsg(cInfoType, vInfo, pMsg);
		COMMIT;
		$ELSE NULL;
		$END
	END;

	PROCEDURE Info(pMsg IN CLOB, pModule IN VARCHAR2, pAction IN VARCHAR2)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vInfo VARCHAR2(255) := CALLER_INFO;
	BEGIN $IF $$TRACE $THEN
		IF pModule IS NOT NULL
		THEN
			DBMS_APPLICATION_INFO.SET_MODULE
			(
			  module_name => pModule,
			  action_name => pAction
			);
		END IF;
		PRAGMA INLINE (SaveLongMsg, 'YES');
		SaveLongMsg(cInfoType, vInfo, pMsg);
		COMMIT;
		$ELSE NULL;
		$END
	END;

	/*
		Warn
	*/
	PROCEDURE Warn(pMsg IN VARCHAR2)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vInfo VARCHAR2(255) := CALLER_INFO;
	BEGIN
		PRAGMA INLINE (SaveMsg, 'YES');
		SaveMsg(cWarnType, vInfo, pMsg);
		COMMIT;
	END;

	PROCEDURE Warn(pMsg IN CLOB)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vInfo VARCHAR2(255) := CALLER_INFO;
	BEGIN
		PRAGMA INLINE (SaveLongMsg, 'YES');
		SaveLongMsg(cWarnType, vInfo, pMsg);
		COMMIT;
	END;

	/*
		Error
	*/
	PROCEDURE Error(pMsg IN VARCHAR2)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vInfo VARCHAR2(255) := CALLER_INFO;
	BEGIN
		PRAGMA INLINE (SaveMsg, 'YES');
		SaveMsg(cErrorType, vInfo, pMsg);
		COMMIT;
	END;

	PROCEDURE Error(pMsg IN CLOB)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vInfo VARCHAR2(255) := CALLER_INFO;
	BEGIN
		PRAGMA INLINE (SaveLongMsg, 'YES');
		SaveLongMsg(cErrorType, vInfo, pMsg);
		COMMIT;
	END;

	/*
		Free memory of the package session
	*/
	PROCEDURE Reset
	IS
	BEGIN
		--EXECUTE DBMS_SESSION.RESET_PACKAGE;
		NULL;
	END;

	/*
		Forces to whow module and action in the log file
	*/
	PROCEDURE SetModule(pModule IN VARCHAR2, pAction IN VARCHAR2)
	IS
	BEGIN
		DBMS_APPLICATION_INFO.SET_MODULE
		(
		  module_name => pModule,
		  action_name => pAction
		);
	END;

	/*
		FALSE will prohibit buffer overflow while mass testing
		TRUE may be used for unit testing
	*/
	PROCEDURE SetDbmsOutput(flag IN BOOLEAN)
	IS
	BEGIN
		IsDbmsOutput := flag;
	END;
	
	/*
		Enable oracle session trace
	*/
	PROCEDURE Enable(waits IN BOOLEAN, binds IN BOOLEAN)
	IS
	BEGIN
		DBMS_SESSION.SET_SQL_TRACE(TRUE);
		DBMS_SESSION.SESSION_TRACE_ENABLE(waits, binds);
	END;

	/*
		Disable oracle session trace
	*/
	PROCEDURE Disable
	IS
	BEGIN
		DBMS_SESSION.SESSION_TRACE_DISABLE;
	END;

	/*
		Show in log and output session memory statistics
	*/
	PROCEDURE Stat
	IS
	BEGIN
		NULL;
	END;
END;
/

SHOW ERROR

QUIT
