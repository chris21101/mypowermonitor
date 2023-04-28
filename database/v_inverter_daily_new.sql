--------------------------------------------------------
--  DDL for View V_INVERTER_DAILY
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "POWERMONITOR"."V_INVERTER_DAILY" ("DAY", "CLIENTNAME", "START_PROD_DATE", "STOP_PROD_DATE", "DAILY_ENERGIE", "MAX_TOTAL_ENERGIE", "MIN_TOTAL_ENERGIE", "MIN_ACTUAL_ENERGIE", "MAX_ACTUAL_ENERGIE", "AVG_ACTUAL_ENERGIE", "COUNT_MEASURE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  trunc(measure_time) day,
  clientname,
  MIN(measure_time)   start_prod_date,
  MAX(measure_time)   stop_prod_date,
  MAX(daily_energie)  daily_energie,
  MAX(total_energie)  max_total_energie,
  MIN(total_energie)  min_total_energie,
  MIN(actual_energie) min_actual_energie,
  MAX(actual_energie) max_actual_energie,
  round(AVG(actual_energie),
        4)            avg_actual_energie,
  count(measure_time) count_measure
FROM
  (
    SELECT
      id,
      measure_time,
      actual_energie,
      daily_energie,
      total_energie,
      clientname,
      first_pv_prod
    FROM
      (
        SELECT
          i.id,
          i.measure_time,
          i.actual_energie,
          CASE
            WHEN pvt.first_pv_prod IS NULL
                 OR i.measure_time < pvt.first_pv_prod THEN
              0
            ELSE
              i.daily_energie
          END daily_energie,
          i.total_energie,
          i.clientname,
          pvt.first_pv_prod
        FROM
          inverter_rest i
          LEFT JOIN (
            SELECT
              trunc(measure_time) AS tag,
              MIN(measure_time)   AS first_pv_prod
            FROM
              inverter_rest
            WHERE
                actual_energie > 0
              AND daily_energie = 0
            GROUP BY
              trunc(measure_time)
          )             pvt ON ( trunc(i.measure_time) = pvt.tag )
      )
    WHERE
        actual_energie > 0
      AND daily_energie > 0
  )
GROUP BY
  trunc(measure_time),
  clientname,
  first_pv_prod
;
