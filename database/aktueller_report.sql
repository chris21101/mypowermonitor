SELECT
  TO_DATE(d.datum, 'YYYYMMDDHH24MI')               AS datum,
  d.aktueller_bezug,
  nvl(i.aktueller_pv_strom, 0)                     aktueller_pv_strom,
  nvl(i.aktueller_pv_strom, 0) + d.aktueller_bezug AS aktueller_verbrauch
FROM
  (
    SELECT
      get_group_date_string(d.measure_time, 2) AS datum,
      round(AVG(d.act_power) / 1000,
            0)                                 aktueller_bezug,
      d.clientname
    FROM
      discovergy_rest d
    WHERE
      d.measure_time >= current_date - ( 1 / 1440 * 30 )
    GROUP BY
      get_group_date_string(d.measure_time, 2),
      d.clientname
  ) d
  LEFT JOIN (
    SELECT
      get_group_date_string(i.measure_time, 2) AS datum,
      round(AVG(actual_energie),
            0)                                 aktueller_pv_strom
    FROM
      inverter_rest i
    WHERE
      i.measure_time >= current_date - ( 1 / 1440 * 30 )
    GROUP BY
      get_group_date_string(i.measure_time, 2)
  ) i ON ( d.datum = i.datum )
ORDER BY
  1 DESC;

DROP TABLE actual_power_monitor PURGE;

CREATE TABLE actual_power_monitor
  AS
    SELECT
      d.datum,
      d.aktueller_bezug,
      nvl(i.aktueller_pv_strom, 0)                     aktueller_pv_strom,
      nvl(i.aktueller_pv_strom, 0) + d.aktueller_bezug AS aktueller_verbrauch
    FROM
      (
        SELECT
          get_group_date_string(d.measure_time, 1) AS datum,
          round(AVG(d.act_power) / 1000,
                0)                                 aktueller_bezug,
          d.clientname
        FROM
          discovergy_rest d
        WHERE
          d.measure_time >= current_date - 2
        GROUP BY
          get_group_date_string(d.measure_time, 1),
          d.clientname
      ) d
      LEFT JOIN (
        SELECT
          get_group_date_string(i.measure_time, 1) AS datum,
          round(AVG(actual_energie),
                0)                                 aktueller_pv_strom
        FROM
          inverter_rest i
        WHERE
          i.measure_time >= current_date - 2
        GROUP BY
          get_group_date_string(i.measure_time, 1)
      ) i ON ( d.datum = i.datum )
    ORDER BY
      1 DESC;

DROP TABLE actual_power_monitor PURGE;

CREATE TABLE actual_power_monitor
  AS
    SELECT
      TO_DATE(d.datum, 'YYYYMMDDHH24MI')               AS datum,
      d.aktueller_bezug,
      nvl(i.aktueller_pv_strom, 0)                     aktueller_pv_strom,
      nvl(i.aktueller_pv_strom, 0) + d.aktueller_bezug AS aktueller_verbrauch
    FROM
      (
        SELECT
          get_group_date_string(d.measure_time, 2) AS datum,
          round(AVG(d.act_power) / 1000,
                0)                                 aktueller_bezug,
          d.clientname
        FROM
          discovergy_rest d
        WHERE
          d.measure_time >= current_date - 2
        GROUP BY
          get_group_date_string(d.measure_time, 2),
          d.clientname
      ) d
      LEFT JOIN (
        SELECT
          get_group_date_string(i.measure_time, 2) AS datum,
          round(AVG(actual_energie),
                0)                                 aktueller_pv_strom
        FROM
          inverter_rest i
        WHERE
          i.measure_time >= current_date - 2
        GROUP BY
          get_group_date_string(i.measure_time, 2)
      ) i ON ( d.datum = i.datum )
    ORDER BY
      1 DESC;

MERGE INTO actual_power_monitor t
USING (
  SELECT
    TO_DATE(d.datum, 'YYYYMMDDHH24MI')               AS datum,
    d.aktueller_bezug,
    nvl(i.aktueller_pv_strom, 0)                     aktueller_pv_strom,
    nvl(i.aktueller_pv_strom, 0) + d.aktueller_bezug AS aktueller_verbrauch
  FROM
    (
      SELECT
        get_group_date_string(d.measure_time, 2) AS datum,
        round(AVG(d.act_power) / 1000,
              0)                                 aktueller_bezug,
        d.clientname
      FROM
        discovergy_rest d
      WHERE
        d.measure_time >= current_date - ( 1 / 1440 * 30 )
      GROUP BY
        get_group_date_string(d.measure_time, 2),
        d.clientname
    ) d
    LEFT JOIN (
      SELECT
        get_group_date_string(i.measure_time, 2) AS datum,
        round(AVG(actual_energie),
              0)                                 aktueller_pv_strom
      FROM
        inverter_rest i
      WHERE
        i.measure_time >= current_date - ( 1 / 1440 * 30 )
      GROUP BY
        get_group_date_string(i.measure_time, 2)
    ) i ON ( d.datum = i.datum )
) s ON ( s.datum = t.datum )
WHEN MATCHED THEN UPDATE
SET t.aktueller_bezug = s.aktueller_bezug,
    t.aktueller_pv_strom = s.aktueller_pv_strom,
    t.aktueller_verbrauch = s.aktueller_verbrauch 
WHEN NOT MATCHED THEN
INSERT (
  datum,
  aktueller_bezug,
  aktueller_pv_strom,
  aktueller_verbrauch )
VALUES
  ( s.datum,
    s.aktueller_bezug,
    s.aktueller_pv_strom,
    s.aktueller_verbrauch );
    
delete from actual_power_monitor where datum < current_date-2;
commit;

SELECT
  datum,
  aktueller_bezug,
  aktueller_pv_strom,
  aktueller_verbrauch
FROM
  actual_power_monitor
ORDER BY
  datum DESC;

SELECT
  datum,
  aktueller_bezug,
  aktueller_pv_strom,
  aktueller_verbrauch
FROM
  actual_power_monitor
WHERE
  datum = (
    SELECT
      MAX(datum)
    FROM
      actual_power_monitor
  );


  
SELECT
  to_char(datum, 'DD.MM-HH24') stunde,
  round(AVG(aktueller_bezug),
        0)                          aktueller_bezug,
  round(AVG(aktueller_pv_strom),
        0)                          aktueller_pv_strom,
  round(AVG(aktueller_verbrauch),
        0)                          aktueller_verbrauch
FROM
  actual_power_monitor
WHERE
  datum >= trunc(current_date)-1
GROUP BY
  to_char(datum, 'DD.MM-HH24')
ORDER BY
  stunde;

