-- minute
SELECT
  dis.minute                                             AS minute,
  dis.bezug                                              AS bezug,
  dis.einspeisung                                        AS einspeisung,
  kos.produktion                                         AS produktion,
  round(kos.actual_energie,2)                                     AS PV_Leistung,
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
      to_char(measure_time, 'YYYYMMDDHH24MI')                   AS minute,
      round((MAX(energy) - MIN(energy)) / 10000000000, 6)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 6) AS einspeisung
    FROM
      discovergy_rest
    WHERE
      measure_time > sysdate - 7
    GROUP BY
      to_char(measure_time, 'YYYYMMDDHH24MI')
  ) dis
  JOIN (
    SELECT
      to_char(i.measure_time, 'YYYYMMDDHH24MI')   AS minute,
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
      ) i
    GROUP BY
      to_char(measure_time, 'YYYYMMDDHH24MI')
  ) kos ON ( kos.minute = dis.minute )
ORDER BY
  minute DESC;

-- Stunde
SELECT
  dis.stunde                                                                          AS stunde,
  dis.bezug                                                                           AS bezug,
  dis.einspeisung                                                                     AS einspeisung,
  kos.produktion                                                                      AS produktion,
  round(kos.actual_energie,0)  as Durchschnitt_PV_Leistung,
  kos.produktion - dis.einspeisung                                                    AS eigenverbrauch,
  ( kos.produktion - dis.einspeisung ) + dis.bezug                                    AS gesamtverbrauch,
  CASE
    WHEN kos.produktion > 0 THEN
      round((kos.produktion - dis.einspeisung) / kos.produktion * 100, 0)
    ELSE
      0
  END                                                                                 AS prozent_eigenverbrauch,
  ( 1 - round(dis.bezug /((kos.produktion - dis.einspeisung) + dis.bezug), 2) ) * 100 AS prozent_autakie,
  round((dis.bezug * 0.29) -(dis.einspeisung * 0.13), 2)                              AS arbeitskosten,
  round(dis.bezug * 0.29, 2)                                                          AS bezugskosten
FROM
       (
    SELECT
      to_char(measure_time, 'YYYYMMDDHH24')                     AS stunde,
      round((MAX(energy) - MIN(energy)) / 10000000000, 4)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 4) AS einspeisung
    FROM
      discovergy_rest
    WHERE
      measure_time > sysdate - 7
    GROUP BY
      to_char(measure_time, 'YYYYMMDDHH24')
  ) dis
  JOIN (
    SELECT
      to_char(i.measure_time, 'YYYYMMDDHH24')     AS stunde,
      avg(i.actual_energie) as actual_energie,
      MAX(i.daily_energie) - MIN(i.daily_energie) AS produktion
    FROM
      -- inverter_rest 
      (
        SELECT
          measure_time,
          inverter_rest.actual_energie,
          CASE
            WHEN to_number(to_char(measure_time, 'HH24')) > 0
                 AND to_number(to_char(measure_time, 'HH24')) < 6 THEN
              0
            ELSE
              daily_energie
          END AS daily_energie
        FROM
          inverter_rest
      ) i
    GROUP BY
      to_char(measure_time, 'YYYYMMDDHH24')
  ) kos ON ( kos.stunde = dis.stunde )
ORDER BY
  stunde DESC;

-- Tag
SELECT
  dis.tag,
  dis.bezug,
  dis.einspeisung,
  kos.produktion,
  kos.produktion - dis.einspeisung                                                    AS eigenverbrauch,
  ( kos.produktion - dis.einspeisung ) + dis.bezug                                    AS gesamtverbrauch,
  round((kos.produktion - dis.einspeisung) / kos.produktion * 100, 0)                 AS prozent_eigenverbrauch,
  ( 1 - round(dis.bezug /((kos.produktion - dis.einspeisung) + dis.bezug), 2) ) * 100 AS prozent_autakie,
  round((dis.bezug * 0.29) -(dis.einspeisung * 0.13), 2)                              AS arbeitskosten,
  round(dis.bezug * 0.29, 2)                             AS bezugskosten
FROM
       (
    SELECT
      to_char(measure_time, 'YYYYMMDD')                         AS tag,
      round((MAX(energy) - MIN(energy)) / 10000000000, 2)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 2) AS einspeisung
    FROM
      discovergy_rest
    WHERE
      measure_time > sysdate - 31
    GROUP BY
      to_char(measure_time, 'YYYYMMDD')
  ) dis
  JOIN (
    SELECT
      to_char(measure_time, 'YYYYMMDD')                                   AS tag,
      MAX(inverter_rest.total_energie) - MIN(inverter_rest.total_energie) AS produktion
    FROM
      inverter_rest
    GROUP BY
      to_char(measure_time, 'YYYYMMDD')
  ) kos ON ( kos.tag = dis.tag )
ORDER BY
  tag DESC;
  
-- Monat
SELECT
  dis.monat,
  dis.bezug,
  dis.einspeisung,
  kos.produktion,
  kos.produktion - dis.einspeisung                                                    AS eigenverbrauch,
  ( kos.produktion - dis.einspeisung ) + dis.bezug                                    AS gesamtverbrauch,
  round((kos.produktion - dis.einspeisung) / kos.produktion * 100, 0)                 AS prozent_eigenverbrauch,
  ( 1 - round(dis.bezug /((kos.produktion - dis.einspeisung) + dis.bezug), 2) ) * 100 AS prozent_autakie,
  round((dis.bezug * 0.29) -(dis.einspeisung * 0.13), 2)                              AS arbeitskosten,
  round(dis.bezug * 0.29, 2)                                                          AS bezugskosten
FROM
       (
    SELECT
      to_char(measure_time, 'YYYYMM')                           AS monat,
      round((MAX(energy) - MIN(energy)) / 10000000000, 2)       AS bezug,
      round((MAX(energyout) - MIN(energyout)) / 10000000000, 2) AS einspeisung
    FROM
      discovergy_rest
    GROUP BY
      to_char(measure_time, 'YYYYMM')
  ) dis
  JOIN (
    SELECT
      to_char(measure_time, 'YYYYMM')                                     AS monat,
      MAX(inverter_rest.total_energie) - MIN(inverter_rest.total_energie) AS produktion
    FROM
      inverter_rest
    GROUP BY
      to_char(measure_time, 'YYYYMM')
  ) kos ON ( kos.monat = dis.monat )
ORDER BY
  monat ASC;

DROP INDEX inverter_rest_idx1;

CREATE INDEX inverter_rest_idx1 ON
  inverter_rest ( to_number(to_char(
    measure_time, 'HH24')) );

DROP INDEX chb_inverter_rest2;

CREATE INDEX inverter_rest_idx2 ON
  inverter_rest (
    measure_time
  );

--delete from discovergy_rest where measure_time < to_date('01.04.2022','DD.MM.YYYY');