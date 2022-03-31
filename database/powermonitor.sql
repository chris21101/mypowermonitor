
connect powermonitor/222Fin_Ott222@db202110152122_medium

set termout off
col user_name new_value user_name
col host_name new_value host_name
col instance_name new_value instance_name
col db_unique_name new_value db_unique_name;
col database_role new_value database_role;
select lower(user) user_name,
  sys_context('USERENV','CON_NAME') con_name,
  sys_context('USERENV','CON_ID') con_id,
  sys_context('USERENV','DB_NAME') db_unique_name,
  sys_context('USERENV','DATABASE_ROLE') database_role ,
  sys_context('USERENV','INSTANCE') instance_num,
  regexp_replace(sys_context('USERENV','DB_NAME'),'(^..).*','\10')|| sys_context('USERENV','INSTANCE') instance_name
from dual;
    
set sqlprompt "&&user_name.@&&db_unique_name>"

HOST TITLE &&user_name@&&db_unique_name

DEFINE BASEDIR="C:\Users\cblank\git_repos\DBA_Day\scripts"
DEFINE ETCDIR=&&BASEDIR.\etc
DEFINE ALIASESDIR=&&ETCDIR.\sqlcl_aliases

DEFINE ACTUSER=&&user_name
DEFINE DBUNIQUE_NAME=&&db_unique_name
-- cd &&ALIASESDIR
@@&&ALIASESDIR.\env_aliases.sql

-- BASEDIR for SQL Tuning
--DEFINE SQL_TUNE_BASEDIR=C:\Users\cblank\git_repos\db_tuning
--DEFINE SQLTUNINGDATABASE=C:\Users\cblank\git_repos\SQLTuningData
--@@&&SQL_TUNE_BASEDIR.\etc\setenv_sqltuning.sql
