set serveroutput on
set timing on
--------------------------------------------------------
--  DDL for Table HOURLY_INVERTER
--------------------------------------------------------
DROP TABLE HOURLY_INVERTER PURGE;
CREATE TABLE "POWERMONITOR"."HOURLY_INVERTER"
  AS
    SELECT
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24') AS datum,
      clientname              AS clientname,
      round(AVG(actual_energie),
            2)                AS avg_actual_energie,
      max(actual_energie)     AS max_actual_energie,
      MIN(actual_energie)     AS min_actual_energie,
      MAX(daily_energie)      AS max_daily_energie,
      MIN(daily_energie)      AS min_daily_energie,
      MAX(total_energie)      AS max_total_energie,
      MIN(total_energie)      AS min_total_energie,
      first_time_pv_energie
    FROM
      v_inverter_rest_clean
    GROUP BY
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24'),
      first_time_pv_energie,
      clientname;
--------------------------------------------------------
--  DDL for Index HOURLY_INVERTER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "POWERMONITOR"."HOURLY_INVERTER_PK" ON "POWERMONITOR"."HOURLY_INVERTER" ("DATUM", "CLIENTNAME") 
  PCTFREE 10 INITRANS 20 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" ;
--------------------------------------------------------
--  Constraints for Table HOURLY_INVERTER
--------------------------------------------------------

  ALTER TABLE "POWERMONITOR"."HOURLY_INVERTER" MODIFY ("DATUM" NOT NULL ENABLE);
  ALTER TABLE "POWERMONITOR"."HOURLY_INVERTER" ADD CONSTRAINT "HOURLY_INVERTER_PK" PRIMARY KEY ("DATUM", "CLIENTNAME")
  USING INDEX "POWERMONITOR"."HOURLY_INVERTER_PK"  ENABLE;
  ALTER TABLE "POWERMONITOR"."HOURLY_INVERTER" MODIFY ("CLIENTNAME" NOT NULL ENABLE);


create or replace PROCEDURE refresh_hourly_inverter_4_days (
  num_days IN NUMBER
) AS
BEGIN
  MERGE INTO hourly_inverter t
  USING (
    SELECT
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24') AS datum,
      clientname              AS clientname,
      round(AVG(actual_energie),
            2)                AS avg_actual_energie,
      max(actual_energie)     AS max_actual_energie,
      MIN(actual_energie)     AS min_actual_energie,
      MAX(daily_energie)      AS max_daily_energie,
      MIN(daily_energie)      AS min_daily_energie,
      MAX(total_energie)      AS max_total_energie,
      MIN(total_energie)      AS min_total_energie,
      first_time_pv_energie
    FROM
      v_inverter_rest_clean
    WHERE
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24') >= trunc(current_date) - num_days
    GROUP BY
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24'),
      first_time_pv_energie,
      clientname
  ) s ON ( s.datum = t.datum
           AND s.clientname = t.clientname )
  WHEN MATCHED THEN UPDATE
  SET t.avg_actual_energie = s.avg_actual_energie,
      t.max_actual_energie = s.max_actual_energie,
      t.min_actual_energie = s.min_actual_energie,
      t.max_daily_energie = s.max_daily_energie,
      t.min_daily_energie = s.min_daily_energie,
      t.max_total_energie = s.max_total_energie,
      t.min_total_energie = s.min_total_energie,
      t.first_time_pv_energie = s.first_time_pv_energie
  WHEN NOT MATCHED THEN
  INSERT (
    datum,
    clientname,
    avg_actual_energie,
    max_actual_energie,
    min_actual_energie,
    max_daily_energie,
    min_daily_energie,
    max_total_energie,
    min_total_energie,
    first_time_pv_energie )
  VALUES
    ( s.datum,
      s.clientname,
      s.avg_actual_energie,
      s.max_actual_energie,
      s.min_actual_energie,
      s.max_daily_energie,
      s.min_daily_energie,
      s.max_total_energie,
      s.min_total_energie,
      s.first_time_pv_energie );
      
  dbms_output.put_line( sql%rowcount || ' rows merged in table hourly_inverter' );

END refresh_hourly_inverter_4_days;
/
set timing on
DECLARE
  num_days NUMBER;
BEGIN
  num_days := 3;
  refresh_hourly_inverter_4_days(num_days => num_days);
END;
/

COMMIT;