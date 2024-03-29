-- USER SQL
CREATE USER POWERMONITOR IDENTIFIED BY "&PASSWORT"  
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";

-- QUOTAS
ALTER USER POWERMONITOR QUOTA UNLIMITED ON "DATA";

-- ROLES
GRANT "GRAPH_DEVELOPER" TO POWERMONITOR ;
ALTER USER POWERMONITOR DEFAULT ROLE "GRAPH_DEVELOPER";

-- SYSTEM PRIVILEGES
GRANT CREATE JOB TO POWERMONITOR ;
GRANT CREATE TRIGGER TO POWERMONITOR ;
GRANT CREATE MATERIALIZED VIEW TO POWERMONITOR ;
GRANT CREATE DIMENSION TO POWERMONITOR ;
GRANT CREATE OPERATOR TO POWERMONITOR ;
GRANT CREATE INDEXTYPE TO POWERMONITOR ;
GRANT CREATE VIEW TO POWERMONITOR ;
GRANT CREATE SESSION TO POWERMONITOR ;
GRANT CREATE TABLE TO POWERMONITOR ;
GRANT CREATE TYPE TO POWERMONITOR ;
GRANT CREATE SYNONYM TO POWERMONITOR ;
GRANT CREATE SEQUENCE TO POWERMONITOR ;
GRANT CREATE CLUSTER TO POWERMONITOR ;
GRANT CREATE PROCEDURE TO POWERMONITOR ;

