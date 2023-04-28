select d.datum,
 d.bezug_kwh,
 d.einspeise_kwh,
 nvl(p.sonne,0) sonne,
 nvl(p.sonne,0) + d.bezug_kwh - d.einspeise_kwh verbrauch
from
(
SELECT
  dis.day as datum,
  round((dis.max_energy-dis.min_energy) / 10000000000,2)  AS bezug_kwh,
  round((dis.max_energyout - dis.min_energyout ) / 10000000000,2) as einspeise_kwh, 
  dis.min_act_power_watt,
  dis.max_act_power_watt,
  dis.avg_act_power_watt,
  (
    SELECT
      price
    FROM
      power_price
    WHERE
      dis.day BETWEEN start_date AND end_date
      AND type = 'STROM'
  )                               AS receive_price,
  (
    SELECT
      price
    FROM
      power_price
    WHERE
      dis.day BETWEEN start_date AND end_date
      AND type = 'EINSPEISUNG'
  )                               AS feed_in_price
FROM
  (
    SELECT
      TO_DATE(to_char(measure_time, 'DD.MM.YYYY HH24'),
              'DD.MM.YYYY HH24') AS day,
      clientname,
      MIN(energy)                AS min_energy,
      MAX(energy)                AS max_energy,
      MIN(energyout)             AS min_energyout,
      MAX(energyout)             AS max_energyout,
      MIN(act_power) / 1000      AS min_act_power_watt,
      MAX(act_power) / 1000      AS max_act_power_watt,
      round(AVG(act_power) / 1000,
            1)                   AS avg_act_power_watt,
      COUNT(measure_time)        AS count_measure_time
    FROM
      discovergy_rest
    where measure_time >= current_date - 2
    GROUP BY
      TO_DATE(to_char(measure_time, 'DD.MM.YYYY HH24'),
              'DD.MM.YYYY HH24'),
      clientname
  ) dis
) d 
left join (
SELECT
  i.datum,
  i.first_time_pv_energie,
  i.avg_energie,
  i.daily_energie,
  CASE
    WHEN i.sonne < 0 THEN
      0
    ELSE
      i.sonne
  END sonne,
  i.total_energie
FROM
  (
    SELECT
      datum,
      first_time_pv_energie,
      avg_energie,
      daily_energie,
      daily_energie - LAG(daily_energie)
                      OVER(
        ORDER BY
          datum
                      ) sonne,
      total_energie
    FROM
      (
        SELECT 
          TO_DATE(to_char(measure_time, 'DD.MM.YYYY HH24'),
                  'DD.MM.YYYY HH24') AS datum,
          first_time_pv_energie,
          round(AVG(actual_energie),
                2)                   avg_energie,
          MAX(daily_energie)         daily_energie,
          MAX(total_energie)         total_energie
        FROM
          v_inverter_rest_clean
        WHERE
          measure_time >= current_date - 2
        GROUP BY
          TO_DATE(to_char(measure_time, 'DD.MM.YYYY HH24'),
                  'DD.MM.YYYY HH24'),
          first_time_pv_energie
      )
  ) i
) p on (p.datum = d. datum ) 
order by d.datum desc;