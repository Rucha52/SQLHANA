do
 begin
 
  truncate table "TECH_ANALYSIS"."temp_table";
  
  upsert "TECH_ANALYSIS"."temp_table"
    select "ID_CALENDAR","PH3","Net" from "_SYS_BIC"."dbag_analytics.models/cv_market"
      where  ("ID_CALENDAR" between 1 and 10 ) and 
             "PH3" IN (select top 3 distinct("PH3") from  "_SYS_BIC"."dbag_analytics.models/cv_market")
       group by "ID_CALENDAR","PH3","Net";
 
 update "temp_table" set ID = ID - 1;
 end;
 
--drop table "temp_table";
/**create column table "temp_table"("ID" integer,"PH3" nvarchar(25),"Net" double,
                                  primary key(ID,PH3) );**/
truncate table "TECH_ANALYSIS"."ARIMA_DATA_10";
update "TECH_ANALYSIS"."ARIMA_DATA_10" set ID = ID - 1; 
select * from "TECH_ANALYSIS"."ARIMA_DATA_10" as a join "temp_table" as t
     on a."ID" = t."ID"  and a."Net" = t."Net";

--test