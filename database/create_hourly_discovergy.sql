set timing on
drop table hourly_discovergy purge;
create table hourly_discovergy
as
SELECT
  dis.datum,
  dis.clientname,
  dis.min_energy / 10000000000    AS min_receive_counter_kwh,
  dis.max_energy / 10000000000    AS max_receive_counter_kwh,
  dis.min_energyout / 10000000000 AS min_feed_in_counter_kwh,
  dis.max_energyout / 10000000000 AS max_feed_in_counter_kwh,
  dis.min_act_power_watt,
  dis.max_act_power_watt,
  dis.avg_act_power_watt,
  (
    SELECT
      price
    FROM
      power_price
    WHERE
      dis.datum BETWEEN start_date AND end_date
      AND type = 'STROM'
  )                               AS receive_price,
  (
    SELECT
      price
    FROM
      power_price
    WHERE
      dis.datum BETWEEN start_date AND end_date
      AND type = 'EINSPEISUNG'
  )                               AS feed_in_price
FROM
  (
    SELECT
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24') AS datum,
      clientname,
      MIN(energy)             AS min_energy,
      MAX(energy)             AS max_energy,
      MIN(energyout)          AS min_energyout,
      MAX(energyout)          AS max_energyout,
      MIN(act_power) / 1000   AS min_act_power_watt,
      MAX(act_power) / 1000   AS max_act_power_watt,
      round(AVG(act_power) / 1000,
            1)                AS avg_act_power_watt,
      COUNT(measure_time)     AS count_measure_time
    FROM
      discovergy_rest
    GROUP BY
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24'),
      clientname
  ) dis
order by dis.datum desc;

--------------------------------------------------------
--  DDL for Index HOURLY_DISCOVERGY_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "POWERMONITOR"."HOURLY_DISCOVERGY_PK" ON "POWERMONITOR"."HOURLY_DISCOVERGY" ("DATUM", "CLIENTNAME") 
  PCTFREE 10 INITRANS 20 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" ;
--------------------------------------------------------
--  Constraints for Table HOURLY_DISCOVERGY
--------------------------------------------------------

  ALTER TABLE "POWERMONITOR"."HOURLY_DISCOVERGY" MODIFY ("CLIENTNAME" NOT NULL ENABLE);
  ALTER TABLE "POWERMONITOR"."HOURLY_DISCOVERGY" ADD CONSTRAINT "HOURLY_DISCOVERGY_PK" PRIMARY KEY ("DATUM", "CLIENTNAME")
  USING INDEX PCTFREE 10 INITRANS 20 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA"  ENABLE;
  ALTER TABLE "POWERMONITOR"."HOURLY_DISCOVERGY" MODIFY ("DATUM" NOT NULL ENABLE);

MERGE INTO HOURLY_DISCOVERGY d using(
SELECT
  dis.datum,
  dis.clientname,
  dis.min_energy / 10000000000    AS min_receive_counter_kwh,
  dis.max_energy / 10000000000    AS max_receive_counter_kwh,
  dis.min_energyout / 10000000000 AS min_feed_in_counter_kwh,
  dis.max_energyout / 10000000000 AS max_feed_in_counter_kwh,
  dis.min_act_power_watt,
  dis.max_act_power_watt,
  dis.avg_act_power_watt,
  (
    SELECT
      price
    FROM
      power_price
    WHERE
      dis.datum BETWEEN start_date AND end_date
      AND type = 'STROM'
  )                               AS receive_price,
  (
    SELECT
      price
    FROM
      power_price
    WHERE
      dis.datum BETWEEN start_date AND end_date
      AND type = 'EINSPEISUNG'
  )                               AS feed_in_price
FROM
  (
    SELECT
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24') AS datum,
      clientname,
      MIN(energy)             AS min_energy,
      MAX(energy)             AS max_energy,
      MIN(energyout)          AS min_energyout,
      MAX(energyout)          AS max_energyout,
      MIN(act_power) / 1000   AS min_act_power_watt,
      MAX(act_power) / 1000   AS max_act_power_watt,
      round(AVG(act_power) / 1000,
            1)                AS avg_act_power_watt,
      COUNT(measure_time)     AS count_measure_time
    FROM
      discovergy_rest
    WHERE measure_time >= trunc(current_date)-3
    GROUP BY
      TO_DATE(to_char(measure_time, 'YYYYMMDDHH24'),
              'YYYYMMDDHH24'),
      clientname
  ) dis
) src on (src.datum=d.datum and src.clientname=d.clientname)
WHEN MATCHED THEN UPDATE
SET d.min_receive_counter_kwh = src.min_receive_counter_kwh,
    d.max_receive_counter_kwh = src.max_receive_counter_kwh,
    d.min_feed_in_counter_kwh = src.min_feed_in_counter_kwh,
    d.max_feed_in_counter_kwh = src.max_feed_in_counter_kwh,
    d.min_act_power_watt = src.min_act_power_watt,
    d.max_act_power_watt = src.max_act_power_watt,
    d.avg_act_power_watt = src.avg_act_power_watt,
    d.receive_price = src.receive_price,
    d.feed_in_price = src.feed_in_price
WHEN NOT MATCHED THEN
INSERT (
  datum,
  clientname,
  min_receive_counter_kwh,
  max_receive_counter_kwh,
  min_feed_in_counter_kwh,
  max_feed_in_counter_kwh,
  min_act_power_watt,
  max_act_power_watt,
  avg_act_power_watt,
  receive_price,
  feed_in_price )
VALUES
  ( src.datum,
    src.clientname,
    src.min_receive_counter_kwh,
    src.max_receive_counter_kwh,
    src.min_feed_in_counter_kwh,
    src.max_feed_in_counter_kwh,
    src.min_act_power_watt,
    src.max_act_power_watt,
    src.avg_act_power_watt,
    src.receive_price,
    src.feed_in_price );
    
