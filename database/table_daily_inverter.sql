--------------------------------------------------------
--  DDL for Table DAILY_INVERTER
--------------------------------------------------------

  CREATE TABLE "POWERMONITOR"."DAILY_INVERTER" 
   (	"DAY" DATE, 
	"CLIENTNAME" VARCHAR2(256 BYTE) COLLATE "USING_NLS_COMP", 
	"START_PROD_DATE" DATE, 
	"STOP_PROD_DATE" DATE, 
	"DAILY_ENERGIE" NUMBER, 
	"MAX_TOTAL_ENERGIE" NUMBER, 
	"MIN_TOTAL_ENERGIE" NUMBER, 
	"MIN_ACTUAL_ENERGIE" NUMBER, 
	"MAX_ACTUAL_ENERGIE" NUMBER, 
	"AVG_ACTUAL_ENERGIE" NUMBER, 
	"COUNT_MEASURE" NUMBER
   )  DEFAULT COLLATION "USING_NLS_COMP" SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 10 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" ;

   COMMENT ON COLUMN "POWERMONITOR"."DAILY_INVERTER"."DAILY_ENERGIE" IS 'kWh';
   COMMENT ON COLUMN "POWERMONITOR"."DAILY_INVERTER"."MAX_TOTAL_ENERGIE" IS 'kWh';
   COMMENT ON COLUMN "POWERMONITOR"."DAILY_INVERTER"."MIN_TOTAL_ENERGIE" IS 'kWh';
   COMMENT ON COLUMN "POWERMONITOR"."DAILY_INVERTER"."MIN_ACTUAL_ENERGIE" IS 'Watt';
   COMMENT ON COLUMN "POWERMONITOR"."DAILY_INVERTER"."MAX_ACTUAL_ENERGIE" IS 'Watt';
   COMMENT ON COLUMN "POWERMONITOR"."DAILY_INVERTER"."AVG_ACTUAL_ENERGIE" IS 'Watt';
--------------------------------------------------------
--  DDL for Index DAILY_INVERTER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "POWERMONITOR"."DAILY_INVERTER_PK" ON "POWERMONITOR"."DAILY_INVERTER" ("DAY", "CLIENTNAME") 
  PCTFREE 10 INITRANS 20 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" ;
--------------------------------------------------------
--  Constraints for Table DAILY_INVERTER
--------------------------------------------------------

  ALTER TABLE "POWERMONITOR"."DAILY_INVERTER" MODIFY ("DAY" NOT NULL ENABLE);
  ALTER TABLE "POWERMONITOR"."DAILY_INVERTER" MODIFY ("CLIENTNAME" NOT NULL ENABLE);
  ALTER TABLE "POWERMONITOR"."DAILY_INVERTER" ADD CONSTRAINT "DAILY_INVERTER_PK" PRIMARY KEY ("DAY", "CLIENTNAME")
  USING INDEX PCTFREE 10 INITRANS 20 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA"  ENABLE;
