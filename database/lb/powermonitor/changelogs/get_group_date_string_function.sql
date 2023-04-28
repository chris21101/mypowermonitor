
  CREATE OR REPLACE EDITIONABLE FUNCTION "POWERMONITOR"."GET_GROUP_DATE_STRING" (
  p_date   IN DATE,
  p_minute IN NUMBER DEFAULT 5
) RETURN VARCHAR2 AS
BEGIN
  RETURN to_char(p_date, 'YYYYMMDDHH24')
         || to_char(floor((to_number((to_char(p_date, 'MI'))) / p_minute)) * p_minute, 'fm00');
END get_group_date_string;