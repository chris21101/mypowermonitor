
  CREATE OR REPLACE EDITIONABLE TRIGGER "POWERMONITOR"."INVERTER_REST_TRG2" 
before insert on inverter_rest 
for each row 
begin  
   if inserting then 
      if :NEW."ID" is null then 
         select INVERTER_REST_SEQ2.nextval into :NEW."ID" from dual; 
      end if; 
   end if; 
end;

ALTER TRIGGER "POWERMONITOR"."INVERTER_REST_TRG2" ENABLE