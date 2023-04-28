--10 Minuten
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
  INNER JOIN (
    SELECT
      get_group_date_string(inv.measure_time, 10)     AS minute,
      MAX(inv.daily_energie) - MIN(inv.daily_energie) AS produktion,
      AVG(inv.actual_energie)                         AS actual_energie
    FROM
      (
        SELECT
          i.id,
          i.measure_time,
          i.actual_energie,
          i.daily_energie,
          i.total_energie,
          i.first_time_pv_energie,
          i.last_time_pv_energie
        FROM
          v_inverter_rest_clean i
      ) inv
    GROUP BY
      get_group_date_string(measure_time, 10)
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  minute DESC;
--Stunde
SELECT
  dis.minute                                             AS Stunde,
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
      get_group_date_string(measure_time, 60)                   AS minute,
      round((MAX(energy) - MIN(energy)) / 10000000000, 6)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 6) AS einspeisung
    FROM
      discovergy_rest
    WHERE
      measure_time > sysdate - 2
    GROUP BY
      get_group_date_string(measure_time, 60)
  ) dis
  INNER JOIN (
    SELECT
      get_group_date_string(inv.measure_time, 60)     AS minute,
      MAX(inv.daily_energie) - MIN(inv.daily_energie) AS produktion,
      AVG(inv.actual_energie)                         AS actual_energie
    FROM
      (
        SELECT
          i.id,
          i.measure_time,
          i.actual_energie,
          i.daily_energie,
          i.total_energie,
          i.first_time_pv_energie,
          i.last_time_pv_energie
        FROM
          v_inverter_rest_clean i
      ) inv
    GROUP BY
      get_group_date_string(measure_time, 60)
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  dis.minute DESC;

--Tag
SELECT
  dis.minute                                             AS TAG,
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
      get_group_date_string(measure_time, 0)                   AS minute,
      round((MAX(energy) - MIN(energy)) / 10000000000, 6)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 6) AS einspeisung
    FROM
      discovergy_rest
    WHERE
      measure_time > sysdate - 31
    GROUP BY
      get_group_date_string(measure_time, 0)
  ) dis
  INNER JOIN (
    SELECT
      get_group_date_string(inv.measure_time, 0)     AS minute,
      MAX(inv.daily_energie) - MIN(inv.daily_energie) AS produktion,
      AVG(inv.actual_energie)                         AS actual_energie
    FROM
      (
        SELECT
          i.id,
          i.measure_time,
          i.actual_energie,
          i.daily_energie,
          i.total_energie,
          i.first_time_pv_energie,
          i.last_time_pv_energie
        FROM
          v_inverter_rest_clean i
      ) inv
    GROUP BY
      get_group_date_string(measure_time, 0)
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  dis.minute DESC;
  
--Monat  
SELECT
  dis.minute                                             AS MONAT,
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
      get_group_date_string(measure_time, -1)                   AS minute,
      round((MAX(energy) - MIN(energy)) / 10000000000, 6)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 6) AS einspeisung
    FROM
      discovergy_rest
    GROUP BY
      get_group_date_string(measure_time, -1)
  ) dis
  INNER JOIN (
    SELECT
      get_group_date_string(inv.measure_time, -1)     AS minute,
      MAX(inv.total_energie) - MIN(inv.total_energie) AS produktion,
      AVG(inv.actual_energie)                         AS actual_energie
    FROM
      (
        SELECT
          i.id,
          i.measure_time,
          i.actual_energie,
          i.daily_energie,
          i.total_energie,
          i.first_time_pv_energie,
          i.last_time_pv_energie
        FROM
          v_inverter_rest_clean i
      ) inv
    GROUP BY
      get_group_date_string(measure_time, -1)
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  dis.minute DESC;

--Jahr 
SELECT
  dis.minute                                             AS Jahr,
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
      get_group_date_string(measure_time, -2)                   AS minute,
      round((MAX(energy) - MIN(energy)) / 10000000000, 6)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 6) AS einspeisung
    FROM
      discovergy_rest
    GROUP BY
      get_group_date_string(measure_time, -2)
  ) dis
  INNER JOIN (
    SELECT
      get_group_date_string(inv.measure_time, -2)     AS minute,
      MAX(inv.total_energie) - MIN(inv.total_energie) AS produktion,
      AVG(inv.actual_energie)                         AS actual_energie
    FROM
      (
        SELECT
          i.id,
          i.measure_time,
          i.actual_energie,
          i.daily_energie,
          i.total_energie,
          i.first_time_pv_energie,
          i.last_time_pv_energie
        FROM
          v_inverter_rest_clean i
      ) inv 
    GROUP BY
      get_group_date_string(inv.measure_time, -2)
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  dis.minute DESC;
