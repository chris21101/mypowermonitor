  CREATE INDEX "POWERMONITOR"."INVERTER_REST_IDX2" ON "POWERMONITOR"."INVERTER_REST" ("MEASURE_TIME")
  PCTFREE 10 INITRANS 20 MAXTRANS 255 LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA";