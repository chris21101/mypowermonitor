CREATE OR REPLACE VIEW v_pv_prod_time AS
  SELECT
    f.tag tag,
    f.first_time_pv_energie,
    l.last_time_pv_energie
  FROM
    (
      SELECT
        trunc(measure_time) tag,
        MIN(measure_time)   first_time_pv_energie
      FROM
        inverter_rest
      WHERE
          actual_energie > 0
        AND daily_energie = 0
        AND measure_time >= TO_DATE('01.01.2022', 'DD.MM.YYYY')
      GROUP BY
        trunc(measure_time)
    ) f
    LEFT JOIN (
      SELECT
        trunc(measure_time) tag,
        MIN(measure_time)   last_time_pv_energie
      FROM
        inverter_rest
      WHERE
          actual_energie = 0
        AND daily_energie > 0
        AND measure_time >= TO_DATE('01.01.2022', 'DD.MM.YYYY')
        AND to_number(to_char(measure_time, 'HH24')) > 14
      GROUP BY
        trunc(measure_time)
    ) l ON ( f.tag = l.tag )
  ORDER BY
    f.tag DESC;