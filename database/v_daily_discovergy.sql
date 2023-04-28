CREATE OR REPLACE VIEW v_daily_discovergy AS
  SELECT
    dis.day,
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
      dis.day BETWEEN start_date
      AND end_date
      AND type = 'STROM' ) AS receive_price,
      (
        SELECT
          price
        FROM
          power_price
        WHERE
          dis.day BETWEEN start_date
          AND end_date
          AND type = 'EINSPEISUNG'
      ) AS feed_in_price
    FROM
      (
        SELECT
          trunc(measure_time)   AS day,
          clientname,
          MIN(energy)           AS min_energy,
          MAX(energy)           AS max_energy,
          MIN(energyout)        AS min_energyout,
          MAX(energyout)        AS max_energyout,
          MIN(act_power) / 1000 AS min_act_power_watt,
          MAX(act_power) / 1000 AS max_act_power_watt,
          round(AVG(act_power) / 1000,
          1)                    AS avg_act_power_watt,
          COUNT(measure_time)   AS count_measure_time
        FROM
          discovergy_rest
        GROUP BY
          trunc(measure_time),
          clientname
      ) dis