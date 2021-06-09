#!/bin/bash

export LOGIN="CGSYSADM/CGSYSADM@BSCSDB"

#
# install all objects
#
sqlplus $LOGIN @CALLER_INFO_V12.2.sql
sqlplus $LOGIN @TRACE_LOG.sql
sqlplus $LOGIN @TRACE.pks
sqlplus $LOGIN @TRACE.pkb
sqlplus $LOGIN @recompile-with-trace.sql
