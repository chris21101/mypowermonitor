TRUNCATE TABLE powermonitor_dev.discovergy_rest;

INSERT INTO powermonitor_dev.discovergy_rest (
  id,
  measure_time,
  energyout,
  energy,
  act_power,
  clientname
)
  SELECT
    NULL,
    measure_time,
    energyout,
    energy,
    act_power,
    'discovergy_dev_ws'
  FROM
    powermonitor.discovergy_rest;

TRUNCATE TABLE powermonitor_dev.inverter_rest;

INSERT INTO powermonitor_dev.inverter_rest
  SELECT
    null,
    measure_time,
    actual_energie,
    daily_energie,
    total_energie,
    'kostal_dev_ws'
  FROM
    POWERMONITOR.inverter_rest;