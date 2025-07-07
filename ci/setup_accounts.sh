#!/usr/bin/env bash

set -ev

sqlplus sys/${DATABASE_SYS_PASSWORD}@${DATABASE_NAME} as sysdba<<SQL
@@spec/support/create_oracle_enhanced_users.sql
exit
SQL
