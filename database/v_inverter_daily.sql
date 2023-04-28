CREATE OR REPLACE VIEW v_inverter_rest_daily AS
  SELECT
    pvt.tag                         tag,
    pvt.first_time_pv_energie       first_time_pv_energie,
    pvt.last_time_pv_energie        last_time_pv_energie,
    i.clientname                    clientname,
    MAX(i.daily_energie)            daily_energie,
    round(AVG(i.actual_energie), 2) avg_actual_energie,
    MIN(i.total_energie)            total_energie_start,
    MAX(i.total_energie)            total_energie_end
  FROM
         v_pv_prod_time pvt
    INNER JOIN inverter_rest i ON ( trunc(i.measure_time) = pvt.tag )
  WHERE
    i.measure_time BETWEEN pvt.first_time_pv_energie AND pvt.last_time_pv_energie
  GROUP BY
    pvt.tag,
    pvt.first_time_pv_energie,
    i.clientname,
    pvt.last_time_pv_energie;

--insert into inverter_rest (id, measure_time, actual_energie, daily_energie, total_energie, clientname) values ( null, to_date('01.04.2022 20:00:00', 'DD.MM.YYYY HH24:MI:SS'), 0,20,35904, 'MANUAL'); 