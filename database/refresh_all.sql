set timing on
set serveroutput on
DECLARE
  num_days NUMBER;
BEGIN
  num_days := 2;
  refresh_hourly_inverter_4_days(num_days => num_days);
  refresh_hourly_discovergy_4_days(num_days => num_days);
  refresh_daily_inverter_4_days (num_days => num_days);
  refresh_daily_discovergy_4_days (num_days => num_days);
  COMMIT;
END;
/

COMMIT;