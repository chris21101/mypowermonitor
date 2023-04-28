--Tag
SELECT
  message_date,
  zaehler,
  absoluter_verbrauch,
  round(anzahl_tage,1) anzahl_tage,
  CASE
    WHEN absoluter_verbrauch > 0 THEN
      round(absoluter_verbrauch / anzahl_tage, 2)
    ELSE
      0
  END durchschnitt
FROM
  (
    SELECT
      message_date,
      zaehler,
      LAG(zaehler, 1, 0)
      OVER(
        ORDER BY
          message_date
      )   vorher,
      CASE
        WHEN LAG(zaehler, 1, 0)
             OVER(
          ORDER BY
            message_date
             ) > 0 THEN
          zaehler - LAG(zaehler, 1, 0)
                    OVER(
            ORDER BY
              message_date
                    )
        ELSE
          0
      END absoluter_verbrauch,
      CASE
        WHEN message_date - LAG(message_date, 1, message_date)
                            OVER(
          ORDER BY
            message_date
                            ) > 0 THEN
          message_date - LAG(message_date, 1, message_date)
                         OVER(
            ORDER BY
              message_date
                         )
        ELSE
          0
      END anzahl_tage
    FROM
      gas_power
    ORDER BY
      message_date
  )
order by message_date desc;

-- Monat  
SELECT
  to_char(message_date, 'YYYYMM') monat,
  SUM(absoluter_verbrauch)        absoluter_verbrauch,
  round(SUM(anzahl_tage),1)                anzahl_tage,
  round(SUM(absoluter_verbrauch)/SUM(anzahl_tage),2) durchschnitt
FROM
  (
    SELECT
      message_date,
      zaehler,
      LAG(zaehler, 1, 0)
      OVER(
        ORDER BY
          message_date
      )   vorher,
      CASE
        WHEN LAG(zaehler, 1, 0)
             OVER(
          ORDER BY
            message_date
             ) > 0 THEN
          zaehler - LAG(zaehler, 1, 0)
                    OVER(
            ORDER BY
              message_date
                    )
        ELSE
          0
      END absoluter_verbrauch,
      CASE
        WHEN message_date - LAG(message_date, 1, message_date)
                            OVER(
          ORDER BY
            message_date
                            ) > 0 THEN
          message_date - LAG(message_date, 1, message_date)
                         OVER(
            ORDER BY
              message_date
                         )
        ELSE
          0
      END anzahl_tage
    FROM
      gas_power
    ORDER BY
      message_date
  )
GROUP BY
  to_char(message_date, 'YYYYMM')
ORDER BY
  monat desc;
  
--Jahr
SELECT
  to_char(message_date, 'YYYY') jahr,
  SUM(absoluter_verbrauch)        absoluter_verbrauch,
  round(SUM(anzahl_tage),1)                anzahl_tage,
  round(SUM(absoluter_verbrauch)/SUM(anzahl_tage),2) durchschnitt
FROM
  (
    SELECT
      message_date,
      zaehler,
      LAG(zaehler, 1, 0)
      OVER(
        ORDER BY
          message_date
      )   vorher,
      CASE
        WHEN LAG(zaehler, 1, 0)
             OVER(
          ORDER BY
            message_date
             ) > 0 THEN
          zaehler - LAG(zaehler, 1, 0)
                    OVER(
            ORDER BY
              message_date
                    )
        ELSE
          0
      END absoluter_verbrauch,
      CASE
        WHEN message_date - LAG(message_date, 1, message_date)
                            OVER(
          ORDER BY
            message_date
                            ) > 0 THEN
          message_date - LAG(message_date, 1, message_date)
                         OVER(
            ORDER BY
              message_date
                         )
        ELSE
          0
      END anzahl_tage
    FROM
      gas_power
    ORDER BY
      message_date
  )
GROUP BY
  to_char(message_date, 'YYYY')
ORDER BY
  jahr;

--seit April  
SELECT
  --' Seit 25.03.2022' jahr,
  SUM(absoluter_verbrauch)        absoluter_verbrauch,
  round(SUM(anzahl_tage),1)                anzahl_tage,
  round(SUM(absoluter_verbrauch)/SUM(anzahl_tage),2) durchschnitt
FROM
  (
    SELECT
      message_date,
      zaehler,
      LAG(zaehler, 1, 0)
      OVER(
        ORDER BY
          message_date
      )   vorher,
      CASE
        WHEN LAG(zaehler, 1, 0)
             OVER(
          ORDER BY
            message_date
             ) > 0 THEN
          zaehler - LAG(zaehler, 1, 0)
                    OVER(
            ORDER BY
              message_date
                    )
        ELSE
          0
      END absoluter_verbrauch,
      CASE
        WHEN message_date - LAG(message_date, 1, message_date)
                            OVER(
          ORDER BY
            message_date
                            ) > 0 THEN
          message_date - LAG(message_date, 1, message_date)
                         OVER(
            ORDER BY
              message_date
                         )
        ELSE
          0
      END anzahl_tage
    FROM
      gas_power
    WHERE message_date > to_date('25.03.2022','DD.MM.YYYY')
    ORDER BY
      message_date
  )
--GROUP BY
--  to_char(message_date, 'YYYY') || ' Seit 25.03.2022'
--ORDER BY
--  jahr
; 
  
--gesammt  
SELECT
  --to_char(message_date, 'YYYY') jahr,
  SUM(absoluter_verbrauch)        absoluter_verbrauch,
  round(SUM(anzahl_tage),1)                anzahl_tage,
  round(SUM(absoluter_verbrauch)/SUM(anzahl_tage),2) durchschnitt
FROM
  (
    SELECT
      message_date,
      zaehler,
      LAG(zaehler, 1, 0)
      OVER(
        ORDER BY
          message_date
      )   vorher,
      CASE
        WHEN LAG(zaehler, 1, 0)
             OVER(
          ORDER BY
            message_date
             ) > 0 THEN
          zaehler - LAG(zaehler, 1, 0)
                    OVER(
            ORDER BY
              message_date
                    )
        ELSE
          0
      END absoluter_verbrauch,
      CASE
        WHEN message_date - LAG(message_date, 1, message_date)
                            OVER(
          ORDER BY
            message_date
                            ) > 0 THEN
          message_date - LAG(message_date, 1, message_date)
                         OVER(
            ORDER BY
              message_date
                         )
        ELSE
          0
      END anzahl_tage
    FROM
      gas_power
    ORDER BY
      message_date
  )
;    