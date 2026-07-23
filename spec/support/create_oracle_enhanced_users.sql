-- Abort with a non-zero exit code on any SQL error so CI fails loudly:
-- sqlplus otherwise returns 0 even when a statement fails, which once let a
-- broken GRANT (missing CREATE SESSION) slip through as a green setup step.
WHENEVER SQLERROR EXIT SQL.SQLCODE

alter database default tablespace USERS;

CREATE USER oracle_enhanced IDENTIFIED BY oracle_enhanced;

GRANT unlimited tablespace, create session, create table, create sequence,
create procedure, create trigger, create view, create materialized view,
create database link, create synonym, create type TO oracle_enhanced;
