
  CREATE OR REPLACE EDITIONABLE TRIGGER "POWERMONITOR_DEV"."DISCAOVERGY_REST_PK_TRG" 
   before insert on "DISCOVERGY_REST" 
   for each row 
begin  
   if inserting then 
      if :NEW."ID" is null then 
         select DISCOVERGY_REST_SEQ.nextval into :NEW."ID" from dual; 
      end if; 
   end if; 
end;

/
ALTER TRIGGER "POWERMONITOR_DEV"."DISCAOVERGY_REST_PK_TRG" ENABLE;