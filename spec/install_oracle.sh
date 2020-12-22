#!/bin/bash

wget 'https://github.com/cbandy/travis-oracle/archive/v2.0.3.tar.gz'
mkdir -p ~/.travis/oracle
tar xz --strip-components 1 -C ~/.travis/oracle -f v2.0.3.tar.gz

if [ -n ${CUSTOM_ORACLE_FILE} ]; then
  wget -q ${CUSTOM_ORACLE_FILE} -O ~/.travis/oracle/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
else
  ~/.travis/oracle/download.sh
fi

~/.travis/oracle/install.sh

# in dev env: sqlplus system/password@localhost/XE
"${ORACLE_HOME}/bin/sqlplus" -L -S / AS SYSDBA <<SQL
ALTER USER ${USER} IDENTIFIED BY ${USER};
SQL
