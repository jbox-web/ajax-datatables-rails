#!/bin/bash

wget 'https://github.com/cbandy/travis-oracle/archive/v2.0.2.tar.gz'
mkdir -p ~/.travis/oracle
tar xz --strip-components 1 -C ~/.travis/oracle -f v2.0.2.tar.gz

~/.travis/oracle/download.sh
~/.travis/oracle/install.sh

"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
ALTER USER $USER IDENTIFIED BY $USER;
SQL
