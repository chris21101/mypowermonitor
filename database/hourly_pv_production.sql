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
ORDER BY
  datum DESC;