CREATE OR REPLACE VIEW v_daily_powermonitor_basis AS
  SELECT
    d.day                                                           tag,
    round(d.max_receive_counter_kwh - d.min_receive_counter_kwh, 4) bezug_kwh,
    round(d.max_feed_in_counter_kwh - d.min_feed_in_counter_kwh, 4) einspeisung_kwh,
    nvl(i.daily_energie, 0)                                         prod_kwh,
    nvl(i.max_total_energie, 0) - nvl(i.min_total_energie, 0)       calc_prod_kwh,
    round(nvl(i.avg_actual_energie, 0),
          0)                                                        avg_pv_watt,
    receive_price                                                   bezugs_preis,
    feed_in_price                                                   einspeise_preis,
    d.max_receive_counter_kwh,
    d.min_receive_counter_kwh,
    d.max_feed_in_counter_kwh,
    d.min_feed_in_counter_kwh,
    nvl(i.max_total_energie, 0)                                     max_total_energie,
    nvl(i.min_total_energie, 0)                                     min_total_energie
  FROM
    daily_discovergy d
    LEFT JOIN daily_inverter   i ON ( d.day = i.day );
    
CREATE OR REPLACE VIEW v_daily_powermonitor AS
  SELECT
    tag,
    bezug_kwh                                                                                  bezug,
    einspeisung_kwh                                                                            einspeisung,
    prod_kwh                                                                                   produktion,
    avg_pv_watt                                                                                pv_leistung,
    prod_kwh - einspeisung_kwh                                                                 eigenverbrauch,
    ( prod_kwh - einspeisung_kwh ) + bezug_kwh                                                 gesamtverbrauch,
    CASE
      WHEN ( ( prod_kwh - einspeisung_kwh ) + bezug_kwh ) > 0 THEN
        ( 1 - round(bezug_kwh /((prod_kwh - einspeisung_kwh) + bezug_kwh), 2) ) * 100
      ELSE
        0
    END                                                                                        proz_autarkie,
    CASE
      WHEN prod_kwh > 0 THEN
        round((prod_kwh - einspeisung_kwh) / prod_kwh * 100, 0)
      ELSE
        0
    END                                                                                        proz_eigenverbrauch,
    round((bezug_kwh * bezugs_preis) -(einspeisung_kwh * einspeise_preis), 2)                  arbeitskosten,
    round((bezug_kwh * bezugs_preis), 2)                                                       bezugskosten,
    round((einspeisung_kwh * einspeise_preis) +(prod_kwh - einspeisung_kwh) * bezugs_preis, 2) einsparrung,
    max_receive_counter_kwh,
    min_receive_counter_kwh,
    max_feed_in_counter_kwh,
    min_feed_in_counter_kwh,
    min_total_energie,
    max_total_energie,
    bezugs_preis,
    einspeise_preis
  FROM
    v_daily_powermonitor_basis;

CREATE OR REPLACE VIEW v_monthly_powermonitor_basis AS
  SELECT
    last_day(d.day)                                                 monat,
    ( MAX(max_receive_counter_kwh) - MIN(min_receive_counter_kwh) ) bezug_kwh,
    ( MAX(max_feed_in_counter_kwh) - MIN(min_feed_in_counter_kwh) ) einspeisung_kwh,
    --SUM(i.daily_energie)                                            prod_kwh,
    MAX(i.max_total_energie) - MIN(i.min_total_energie)             prod_kwh,
    round(AVG(i.avg_actual_energie),
          0)                                                        avg_pv_watt,
    MAX(receive_price)                                              bezugs_preis,
    MAX(feed_in_price)                                              einspeise_preis,
    MAX(max_receive_counter_kwh)                                    max_receive_counter_kwh,
    MIN(min_receive_counter_kwh)                                    min_receive_counter_kwh,
    MAX(max_feed_in_counter_kwh)                                    max_feed_in_counter_kwh,
    MIN(min_feed_in_counter_kwh)                                    min_feed_in_counter_kwh,
    MAX(max_total_energie)                                          max_total_energie,
    MIN(min_total_energie)                                          min_total_energie
  FROM
    daily_discovergy d
    LEFT JOIN daily_inverter   i ON ( last_day(d.day) = last_day(i.day) )

  GROUP BY
    last_day(d.day);

CREATE OR REPLACE VIEW v_monthly_powermonitor AS
  SELECT
    monat,
    bezug_kwh                                                                                  bezug,
    einspeisung_kwh                                                                            einspeisung,
    prod_kwh                                                                                   produktion,
    avg_pv_watt                                                                                pv_leistung,
    prod_kwh - einspeisung_kwh                                                                 eigenverbrauch,
    ( prod_kwh - einspeisung_kwh ) + bezug_kwh                                                 gesamtverbrauch,
    CASE
      WHEN ( ( prod_kwh - einspeisung_kwh ) + bezug_kwh ) > 0 THEN
        ( 1 - round(bezug_kwh /((prod_kwh - einspeisung_kwh) + bezug_kwh), 2) ) * 100
      ELSE
        0
    END                                                                                        proz_autarkie,
    CASE
      WHEN prod_kwh > 0 THEN
        round((prod_kwh - einspeisung_kwh) / prod_kwh * 100, 0)
      ELSE
        0
    END                                                                                        proz_eigenverbrauch,
    round((bezug_kwh * bezugs_preis) -(einspeisung_kwh * einspeise_preis), 2)                  arbeitskosten,
    round((bezug_kwh * bezugs_preis), 2)                                                       bezugskosten,
    round((einspeisung_kwh * einspeise_preis) +(prod_kwh - einspeisung_kwh) * bezugs_preis, 2) einsparrung,
    max_receive_counter_kwh,
    min_receive_counter_kwh,
    max_feed_in_counter_kwh,
    min_feed_in_counter_kwh,
    min_total_energie,
    max_total_energie,
    bezugs_preis,
    einspeise_preis
  FROM
    v_monthly_powermonitor_basis;

CREATE OR REPLACE VIEW v_yearly_powermonitor_basis AS
  SELECT
    EXTRACT(YEAR FROM d.day)                                     jahr,
    ( MAX(max_receive_counter_kwh) - MIN(min_receive_counter_kwh) ) bezug_kwh,
    ( MAX(max_feed_in_counter_kwh) - MIN(min_feed_in_counter_kwh) ) einspeisung_kwh,
    --SUM(i.daily_energie)                                            prod_kwh,
    MAX(i.max_total_energie) - MIN(i.min_total_energie)             prod_kwh,
    round(AVG(i.avg_actual_energie),
          0)                                                        avg_pv_watt,
    MAX(receive_price)                                              bezugs_preis,
    MAX(feed_in_price)                                              einspeise_preis,
    MAX(max_receive_counter_kwh)                                    max_receive_counter_kwh,
    MIN(min_receive_counter_kwh)                                    min_receive_counter_kwh,
    MAX(max_feed_in_counter_kwh)                                    max_feed_in_counter_kwh,
    MIN(min_feed_in_counter_kwh)                                    min_feed_in_counter_kwh,
    MAX(max_total_energie)                                          max_total_energie,
    MIN(min_total_energie)                                          min_total_energie
  FROM
    daily_discovergy d
    LEFT JOIN daily_inverter   i ON ( EXTRACT(YEAR FROM d.day) = EXTRACT(YEAR FROM i.day) )

  GROUP BY
    EXTRACT(YEAR FROM d.day);

CREATE OR REPLACE VIEW v_yearly_powermonitor AS
  SELECT
    jahr,
    bezug_kwh                                                                                  bezug,
    einspeisung_kwh                                                                            einspeisung,
    prod_kwh                                                                                   produktion,
    avg_pv_watt                                                                                pv_leistung,
    prod_kwh - einspeisung_kwh                                                                 eigenverbrauch,
    ( prod_kwh - einspeisung_kwh ) + bezug_kwh                                                 gesamtverbrauch,
    CASE
      WHEN ( ( prod_kwh - einspeisung_kwh ) + bezug_kwh ) > 0 THEN
        ( 1 - round(bezug_kwh /((prod_kwh - einspeisung_kwh) + bezug_kwh), 2) ) * 100
      ELSE
        0
    END                                                                                        proz_autarkie,
    CASE
      WHEN prod_kwh > 0 THEN
        round((prod_kwh - einspeisung_kwh) / prod_kwh * 100, 0)
      ELSE
        0
    END                                                                                        proz_eigenverbrauch,
    round((bezug_kwh * bezugs_preis) -(einspeisung_kwh * einspeise_preis), 2)                  arbeitskosten,
    round((bezug_kwh * bezugs_preis), 2)                                                       bezugskosten,
    round((einspeisung_kwh * einspeise_preis) +(prod_kwh - einspeisung_kwh) * bezugs_preis, 2) einsparrung,
    max_receive_counter_kwh,
    min_receive_counter_kwh,
    max_feed_in_counter_kwh,
    min_feed_in_counter_kwh,
    min_total_energie,
    max_total_energie,
    bezugs_preis,
    einspeise_preis
  FROM
    v_yearly_powermonitor_basis;

SELECT
  jahr,
  round(bezug)                            bezug,
  round(einspeisung)                      einspeisung,
  produktion,
  round(pv_leistung, 0)                   pv_leistung,
  round(eigenverbrauch, 0)                eigenverbrauch,
  round(gesamtverbrauch, 0)               gesamtverbrauch,
  proz_autarkie,
  proz_eigenverbrauch,
  arbeitskosten,
  bezugskosten,
  einsparrung,
  round(gesamtverbrauch / get_days_of_year(jahr),2) verbrauch_pro_tag,
  round(bezug / get_days_of_year(jahr),2) bezug_pro_tag,
  round(produktion / get_days_of_year(jahr),2) prod_pro_tag
FROM
  v_yearly_powermonitor
--where jahr = :JAHR
ORDER BY
  jahr DESC;

SELECT
  to_char(monat,'YYYY-MM') monat_str,
  round(bezug) bezug,
  round(einspeisung) einspeisung,
  produktion,
  round(pv_leistung, 0 ) pv_leistung,
  round(eigenverbrauch,0) eigenverbrauch,
  round(gesamtverbrauch,0) gesamtverbrauch,
  proz_autarkie,
  proz_eigenverbrauch,
  arbeitskosten,
  bezugskosten,
  einsparrung,
  case when last_day(trunc(current_date)) = monat then
    round(gesamtverbrauch/to_number(to_char(current_date,'DD')),2)
  else
   round(gesamtverbrauch/to_number(to_char(monat,'DD')),2) end verbrauch_pro_tag,
  case when last_day(trunc(current_date)) = monat then
    round(bezug/to_number(to_char(current_date,'DD')),2)
  else
   round(bezug/to_number(to_char(monat,'DD')),2) end bezug_pro_tag,
  case when last_day(trunc(current_date)) = monat then
    round(produktion/to_number(to_char(current_date,'DD')),2)
  else
   round(produktion/to_number(to_char(monat,'DD')),2) end prod_pro_tag
FROM
  v_monthly_powermonitor
ORDER BY
  monat desc;
    
SELECT
  to_char(tag, 'DD.MM.YYYY') AS datum,
  bezug,
  einspeisung,
  produktion,
  pv_leistung,
  eigenverbrauch,
  gesamtverbrauch,
  proz_autarkie,
  proz_eigenverbrauch,
  arbeitskosten,
  bezugskosten,
  einsparrung
FROM
  v_daily_powermonitor
WHERE
  tag >= trunc(sysdate) - 31
ORDER BY
  tag DESC;
  
