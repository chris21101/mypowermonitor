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
    day >= trunc(sysdate) - floor(:num_days)
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
    
    
DECLARE
  FROM_DATE DATE;
BEGIN
  FROM_DATE := to_date('22.01.2023','DD.MM.YYYY');

  REFRESH_DAILY_INVERTER_FROM_DATE(
    FROM_DATE => FROM_DATE
  );
--rollback; 
END;
/
commit;
    
DECLARE
  P_DATE DATE;
BEGIN
  P_DATE := to_date('25.01.2000','DD.MM.YYYY');

  REFRESH_DAILY_INVERTER_4_DATE(
    P_DATE => P_DATE
  );
--rollback; 
END;
/
commit;
BEGIN
  REFRESH_DAILY_INVERTER_4_ACT_DAY();
--rollback; 
END;
/
commit;
DECLARE
  NUM_DAYS NUMBER;
BEGIN
  NUM_DAYS := 5;

  REFRESH_DAILY_INVERTER_4_DAYS(
    NUM_DAYS => NUM_DAYS
  );
--rollback; 
END;
/
commit;    


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
    day = trunc(to_date('01.01.1900'))
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