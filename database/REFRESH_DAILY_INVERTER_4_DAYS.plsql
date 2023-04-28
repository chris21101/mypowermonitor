CREATE OR REPLACE PROCEDURE "POWERMONITOR".refresh_daily_inverter_4_days (
  num_days IN NUMBER
) AS
BEGIN
  MERGE INTO daily_inverter i
  USING (
    SELECT
      day,
      clientname,
      start_prod_date,
      stop_prod_date,
      daily_energie,
      max_total_energie,
      min_total_energie,
      min_actual_energie,
      max_actual_energie,
      avg_actual_energie,
      count_measure
    FROM
      v_daily_inverter
    WHERE
      day > trunc(current_date) - floor(num_days)
  ) s ON ( s.day = i.day
           AND s.clientname = i.clientname )
  WHEN MATCHED THEN UPDATE
  SET i.start_prod_date = s.start_prod_date,
      i.stop_prod_date = s.stop_prod_date,
      i.daily_energie = s.daily_energie,
      i.max_total_energie = s.max_total_energie,
      i.min_total_energie = s.min_total_energie,
      i.min_actual_energie = s.min_actual_energie,
      i.max_actual_energie = s.max_actual_energie,
      i.avg_actual_energie = s.avg_actual_energie,
      i.count_measure = s.count_measure
  WHEN NOT MATCHED THEN
  INSERT (
    day,
    clientname,
    start_prod_date,
    stop_prod_date,
    daily_energie,
    max_total_energie,
    min_total_energie,
    min_actual_energie,
    max_actual_energie,
    avg_actual_energie,
    count_measure )
  VALUES
    ( s.day,
      s.clientname,
      s.start_prod_date,
      s.stop_prod_date,
      s.daily_energie,
      s.max_total_energie,
      s.min_total_energie,
      s.min_actual_energie,
      s.max_actual_energie,
      s.avg_actual_energie,
      s.count_measure );
  dbms_output.put_line( sql%rowcount || ' rows merged in table daily_inverter' );
END refresh_daily_inverter_4_days;