  CREATE TABLE "POWERMONITOR_DEV"."DISCOVERGY_REST"
   (	"ID" NUMBER NOT NULL ENABLE,
	"MEASURE_TIME" DATE NOT NULL ENABLE,
	"ENERGYOUT" NUMBER NOT NULL ENABLE,
	"ENERGY" NUMBER NOT NULL ENABLE,
	"POWER" NUMBER NOT NULL ENABLE,
	"CLIENTNAME" VARCHAR2(100) COLLATE "USING_NLS_COMP" DEFAULT 'discovergy_ws',
	CONSTRAINT "DISCOVERGY_REST_PK" PRIMARY KEY ("ID")
  USING INDEX
  PCTFREE 10 INITRANS 20 MAXTRANS 255 LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA"  ENABLE
   ) DEFAULT COLLATION "USING_NLS_COMP"  SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 10 NOCOMPRESS LOGGING
  STORAGE( INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA";
