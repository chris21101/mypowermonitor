  CREATE UNIQUE INDEX "POWERMONITOR_DEV"."DISCOVERGY_REST_U1" ON "POWERMONITOR_DEV"."DISCOVERGY_REST" ("MEASURE_TIME","CLIENTNAME")
  PCTFREE 10 INITRANS 20 MAXTRANS 255 LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA";