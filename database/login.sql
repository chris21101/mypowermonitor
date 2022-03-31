set termout on
set trimspool on
set trimout on
set serveroutput on size 1000000
set timing off
set pagesize 50
set linesize 200

set statusbar on
set statusbar add editmode 
set statusbar add txn
set statusbar add timing
set highlighting on
set highlighting keyword foreground green
set highlighting identifier foreground magenta
set highlighting string foreground yellow
set highlighting number foreground cyan
set highlighting comment background white
set highlighting comment foreground black 

set feedback on sql_id

set cloudconfig c:\Users\cblank\Documents\Oracle\network\Wallet_DB202110152122.zip

-- DEFINE BASEDIR="C:\Users\cblank\git_repos\DBA_Day\scripts"
-- DEFINE ETCDIR=&&BASEDIR.\etc
-- DEFINE ALIASESDIR=&&ETCDIR.\sqlcl_aliases

-- DEFINE ACTUSER=&&user_name
-- DEFINE DBUNIQUE_NAME=&&db_unique_name
 -- cd &&ALIASESDIR
-- @@&&ALIASESDIR.\env_aliases.sql

-- BASEDIR for SQL Tuning
--DEFINE SQL_TUNE_BASEDIR=C:\Users\cblank\git_repos\db_tuning
--DEFINE SQLTUNINGDATABASE=C:\Users\cblank\git_repos\SQLTuningData
--@@&&SQL_TUNE_BASEDIR.\etc\setenv_sqltuning.sql
--
