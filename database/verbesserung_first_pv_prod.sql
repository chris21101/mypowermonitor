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
        WHEN pvt.first_pv_prod is null or i.measure_time < pvt.first_pv_prod THEN
          0
        ELSE
          i.daily_energie
      END daily_energie,
      i.total_energie,
      i.clientname,
      pvt.first_pv_prod
    FROM
           inverter_rest i
      left JOIN (
        SELECT
          trunc(measure_time) AS tag,
          MIN(measure_time)   AS first_pv_prod
        FROM
          inverter_rest 
        WHERE
            actual_energie > 0
          AND daily_energie = 0
          and trunc(measure_time) >= trunc(sysdate - 31)
        GROUP BY
          trunc(measure_time)
      ) pvt ON ( trunc(i.measure_time) = pvt.tag )
      where trunc(measure_time) >= trunc(sysdate) - 2
  )
WHERE
  --trunc(measure_time) >= trunc(sysdate - 31)
  measure_time between sysdate - 2 and sysdate
ORDER BY
  measure_time DESC;
