create or replace view v_inverter_rest_clean as
SELECT
  i.id,
  i.measure_time,
  i.actual_energie,
  CASE
    WHEN i.measure_time < pvt.first_time_pv_energie THEN
      0
    ELSE
      i.daily_energie
  END daily_energie,
  i.total_energie,
  pvt.first_time_pv_energie,
  pvt.last_time_pv_energie
FROM
       inverter_rest i
  INNER JOIN v_pv_prod_time pvt ON pvt.tag = trunc(i.measure_time)
;