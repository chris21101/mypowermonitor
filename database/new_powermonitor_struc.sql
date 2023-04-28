CREATE OR REPLACE VIEW v_hourly_powermonitor AS
  SELECT
    d.datum                                               AS datum,
    d.max_receive_counter_kwh                             AS max_receive_counter_kwh,
    d.min_receive_counter_kwh                             AS min_receive_counter_kwh,
    d.max_receive_counter_kwh - d.min_receive_counter_kwh AS bezug_kwh,
    d.max_feed_in_counter_kwh                             AS max_feed_in_counter_kwh,
    d.min_feed_in_counter_kwh                             AS min_feed_in_counter_kwh,
    d.max_feed_in_counter_kwh - d.min_feed_in_counter_kwh AS einspeisung_kwh,
    d.avg_act_power_watt                                  AS avg_act_power_watt,
    d.receive_price                                       AS receive_price,
    d.feed_in_price                                       AS feed_in_price,
    i.clientname                                          AS inverter_clientname,
    i.max_daily_energie                                   AS daily_energie,
    i.max_daily_energie - i.min_daily_energie             AS pv_prod,
    i.max_total_energie                                   AS max_total_energie,
    i.min_total_energie                                   AS min_total_energie,
    i.avg_actual_energie                                  AS avg_actual_energie,
    i.max_actual_energie                                  AS max_actual_energie,
    i.min_actual_energie                                  AS min__actual_energie,
    i.first_time_pv_energie                               AS first_time_pv_energie
  FROM
    hourly_discovergy d
    LEFT JOIN hourly_inverter   i ON ( i.datum = d.datum );
-- Last 25 Hourly
SELECT
  d.datum                                                   AS datum,
  nvl(d.pv_prod, 0)+bezug_kwh+einspeisung_kwh               AS verbrauch_kwh,
  bezug_kwh                                                 AS bezug_kwh,
  einspeisung_kwh                                           AS einspeisung_kwh,
  nvl(d.pv_prod, 0)                                         AS prod_kwh,
  nvl(d.max_total_energie, 0) - nvl(d.min_total_energie, 0) AS calc_prod_kwh,
  round(nvl(d.avg_actual_energie, 0),0)                     AS avg_pv_watt,
  d.receive_price                                           AS bezugs_preis,
  d.feed_in_price                                           AS einspeise_preis
FROM
  v_hourly_powermonitor d
WHERE d.datum >= to_date(to_char(current_date,'YYYYMMDDHH24'),'YYYYMMDDHH24')-25/24
ORDER BY
  d.datum DESC;


--v_daily_inverter
CREATE OR REPLACE VIEW v_daily_inverter AS
  SELECT
    trunc(datum)                        day,
    clientname                          clientname,
    first_time_pv_energie               first_pv_prod,
    MIN(datum)                          start_prod_date,
    MAX(datum) + 59 / 1440 + 59 / 86400 stop_prod_date,
    MAX(max_daily_energie)              daily_energie,
    MAX(max_total_energie)              max_total_energie,
    MIN(min_total_energie)              min_total_energie,
    MIN(min_actual_energie)             min_actual_energie,
    MAX(max_actual_energie)             max_actual_energie,
    round(AVG(avg_actual_energie),
          4)                            avg_actual_energie,
    COUNT(datum)                        count_measure
  FROM
    hourly_inverter
  GROUP BY
    trunc(datum),
    clientname,
    first_time_pv_energie;

-- hourly_discovergy
SELECT
  trunc(d.datum)                 AS day,
  d.clientname                   AS clientname,
  MIN(d.min_receive_counter_kwh) AS min_receive_counter_kwh,
  MAX(d.max_receive_counter_kwh) AS max_receive_counter_kwh,
  MIN(d.min_feed_in_counter_kwh) AS min_feed_in_counter_kwh,
  MAX(d.max_feed_in_counter_kwh) AS max_feed_in_counter_kwh,
  MIN(d.min_act_power_watt)      AS min_act_power_watt,
  MAX(d.max_act_power_watt)      AS max_act_power_watt,
  round(AVG(d.avg_act_power_watt),
        2)                       AS avg_act_power_watt,
  receive_price                  AS receive_price,
  feed_in_price                  AS feed_in_price
FROM
  hourly_discovergy d
GROUP BY
  trunc(d.datum),
  d.clientname,
  receive_price,
  feed_in_price
ORDER BY
  trunc(d.datum) DESC;
--   

CREATE OR REPLACE VIEW v_daily_discovergy AS
  SELECT
    trunc(d.datum)                 AS day,
    d.clientname                   AS clientname,
    MIN(d.min_receive_counter_kwh) AS min_receive_counter_kwh,
    MAX(d.max_receive_counter_kwh) AS max_receive_counter_kwh,
    MIN(d.min_feed_in_counter_kwh) AS min_feed_in_counter_kwh,
    MAX(d.max_feed_in_counter_kwh) AS max_feed_in_counter_kwh,
    MIN(d.min_act_power_watt)      AS min_act_power_watt,
    MAX(d.max_act_power_watt)      AS max_act_power_watt,
    round(AVG(d.avg_act_power_watt),
          2)                       AS avg_act_power_watt,
    receive_price                  AS receive_price,
    feed_in_price                  AS feed_in_price
  FROM
    hourly_discovergy d
  GROUP BY
    trunc(d.datum),
    d.clientname,
    receive_price,
    feed_in_price;

