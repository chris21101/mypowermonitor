SELECT
  dis.minute                                             AS minute,
  dis.bezug                                              AS bezug,
  dis.einspeisung                                        AS einspeisung,
  kos.produktion                                         AS produktion,
  round(kos.actual_energie, 2)                           AS pv_leistung,
  kos.produktion - dis.einspeisung                       AS eigenverbrauch,
  ( kos.produktion - dis.einspeisung ) + dis.bezug       AS gesamtverbrauch,
   CASE
    WHEN kos.produktion > 0 THEN
      round((kos.produktion - dis.einspeisung) / kos.produktion * 100, 0)
    ELSE
      0
  END                                                    AS prozent_eigenverbrauch,
  CASE
    WHEN ( ( kos.produktion - dis.einspeisung ) + dis.bezug ) > 0 THEN
      ( 1 - round(dis.bezug /((kos.produktion - dis.einspeisung) + dis.bezug), 2) ) * 100
    ELSE
      0
  END                                                    AS prozent_autakie,
  round((dis.bezug * 0.29) -(dis.einspeisung * 0.13), 6) AS arbeitskosten,
  round(dis.bezug * 0.29, 6)                             AS bezugskosten
FROM
       (
    SELECT
      get_group_date_string(measure_time, 10)                   AS minute,
      round((MAX(energy) - MIN(energy)) / 10000000000, 6)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 6) AS einspeisung
    FROM
      discovergy_rest
    WHERE
      measure_time > sysdate - 1
    GROUP BY
      get_group_date_string(measure_time, 10)
  ) dis
  JOIN (
    SELECT
      get_group_date_string(measure_time, 10)     AS minute,
      MAX(i.daily_energie) - MIN(i.daily_energie) AS produktion,
      AVG(i.actual_energie)                       AS actual_energie
    FROM
      -- inverter_rest 
      (
        SELECT
          measure_time,
          actual_energie,
          CASE
            WHEN to_number(to_char(measure_time, 'HH24')) > 0
                 AND to_number(to_char(measure_time, 'HH24')) < 6 THEN
              0
            ELSE
              daily_energie
          END AS daily_energie
        FROM
          inverter_rest
        WHERE
          measure_time > sysdate - 1
      ) i
    GROUP BY
      get_group_date_string(measure_time, 10)
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  minute DESC;