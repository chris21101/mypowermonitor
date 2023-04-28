MERGE INTO daily_discovergy d
USING (
  SELECT
    day,
    clientname,
    min_receive_counter_kwh,
    max_receive_counter_kwh,
    min_feed_in_counter_kwh,
    max_feed_in_counter_kwh,
    min_act_power_watt,
    max_act_power_watt,
    avg_act_power_watt,
    receive_price,
    feed_in_price
  FROM
    v_daily_discovergy
  WHERE
    day >= trunc(sysdate) - floor(:NUM_DAYS)
) src ON ( src.day = d.day
           AND src.clientname = d.clientname )
WHEN MATCHED THEN UPDATE
SET d.min_receive_counter_kwh = src.min_receive_counter_kwh,
    d.max_receive_counter_kwh = src.max_receive_counter_kwh,
    d.min_feed_in_counter_kwh = src.min_feed_in_counter_kwh,
    d.max_feed_in_counter_kwh = src.max_feed_in_counter_kwh,
    d.min_act_power_watt = src.min_act_power_watt,
    d.max_act_power_watt = src.max_act_power_watt,
    d.avg_act_power_watt = src.avg_act_power_watt,
    d.receive_price = src.receive_price,
    d.feed_in_price = src.feed_in_price
WHEN NOT MATCHED THEN
INSERT (
  day,
  clientname,
  min_receive_counter_kwh,
  max_receive_counter_kwh,
  min_feed_in_counter_kwh,
  max_feed_in_counter_kwh,
  min_act_power_watt,
  max_act_power_watt,
  avg_act_power_watt,
  receive_price,
  feed_in_price )
VALUES
  ( src.day,
    src.clientname,
    src.min_receive_counter_kwh,
    src.max_receive_counter_kwh,
    src.min_feed_in_counter_kwh,
    src.max_feed_in_counter_kwh,
    src.min_act_power_watt,
    src.max_act_power_watt,
    src.avg_act_power_watt,
    src.receive_price,
    src.feed_in_price );
    
DECLARE
  NUM_DAYS NUMBER;
BEGIN
  NUM_DAYS := 2;

  REFRESH_DAILY_DISCOVERGY_4_DAYS(
    NUM_DAYS => NUM_DAYS
  );
END;
/
BEGIN
  REFRESH_DAILY_DISCOVERGY_4_ACT_DAY();
  commit;
END;
/   
DECLARE
  P_DATE DATE;
BEGIN
  P_DATE := to_date('25.01.2023');

  REFRESH_DAILY_DISCOVERGY_FOR_DATE(
    P_DATE => P_DATE
  );
--rollback; 
END;
/
commit;
DECLARE
  FROM_DATE DATE;
BEGIN
  FROM_DATE := to_date('22.01.2023');

  REFRESH_DAILY_DISCOVERGY_FROM_DATE(
    FROM_DATE => FROM_DATE
  );
--rollback; 
END;
/
commit;

