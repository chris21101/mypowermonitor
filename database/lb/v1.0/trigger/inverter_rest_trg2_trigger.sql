
  CREATE OR REPLACE EDITIONABLE TRIGGER "POWERMONITOR_DEV"."INVERTER_REST_TRG2" 
before insert on inverter_rest 
for each row 
begin
  <<COLUMN_SEQUENCES>>
  BEGIN
    IF INSERTING AND :NEW.ID IS NULL THEN
      SELECT INVERTER_REST_SEQ2.NEXTVAL INTO :NEW.ID FROM SYS.DUAL;
    END IF;
  END COLUMN_SEQUENCES;
end;

/
ALTER TRIGGER "POWERMONITOR_DEV"."INVERTER_REST_TRG2" ENABLE;