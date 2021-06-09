#!/bin/bash

export LOGIN="CGSYSADM/cgsysadm17@T17BSCS"

#
# install all objects
#
sqlplus $LOGIN @CALLER_INFO.sql
sqlplus $LOGIN @TRACE_LOG.sql
sqlplus $LOGIN @TRACE.pks
sqlplus $LOGIN @TRACE.pkb
sqlplus $LOGIN @recompile-with-trace.sql
