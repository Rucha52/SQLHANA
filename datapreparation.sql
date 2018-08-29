drop view "TECH_ANALYSIS"."V_PH_STATS";
  
--  
 CREATE VIEW "TECH_ANALYSIS"."V_PH_STATS" 
    ( "ID",      
      "PH",	  
	  "PHMean",
	  "PHStddev" ) AS 
  select
      D."ID",     
	  D."PH",
	  ( select AVG("Net") 
	   from "TECH_ANALYSIS"."sfk_data" as V 
	     where V."PH" = D."PH" and V."Month" = D."Month") ,
	 ( select STDDEV("Net") 
	   from "TECH_ANALYSIS"."sfk_data" as V 
	     where  V."PH" = D."PH" and V."Month" = D."Month") 
  from "TECH_ANALYSIS"."sfk_data" as D ;

   
 drop  VIEW "TECH_ANALYSIS"."V_CUSTOMER_STATS" ; 
  
   CREATE VIEW "TECH_ANALYSIS"."V_CUSTOMER_STATS" 
    ( "ID",
      "Sold-to party",
      "CustomerMean",
	  "CustomerStddev" ) AS 
  select
      D."ID",     
	  D."Sold-to party",
	  ( select AVG("Net") 
	   from "TECH_ANALYSIS"."sfk_data" as V 
	     where V."Sold-to party" = D."Sold-to party" and V."Month" = D."Month") ,
	 ( select STDDEV("Net") 
	   from "TECH_ANALYSIS"."sfk_data" as V 
	     where  V."Sold-to party" = D."Sold-to party" and V."Month" = D."Month") 
  from "TECH_ANALYSIS"."sfk_data" as D;
  
   drop  VIEW "TECH_ANALYSIS"."V_MATERIAL_STATS" ; 
  
   CREATE VIEW "TECH_ANALYSIS"."V_MATERIAL_STATS" 
    ( "ID",
      "Material",
      "MaterialMean",
	  "MaterialStddev" ) AS 
  select
      D."ID",     
	  D."Material",
	  ( select AVG("Net") 
	   from "TECH_ANALYSIS"."sfk_data" as V 
	     where V."Material" = D."Material" and V."Month" = D."Month") ,
	 ( select STDDEV("Net") 
	   from "TECH_ANALYSIS"."sfk_data" as V 
	     where  V."Material" = D."Material" and V."Month" = D."Month") 
  from "TECH_ANALYSIS"."sfk_data" as D;    
  
 
 select AVG("Net"), STDDEV("Net") from "TECH_ANALYSIS"."sfk_data" where "PH" = 'CB01001001010CX' and "Month" = 'Aug-17'
 
 
 drop table ARIMA_DATA_12;
 drop table ARIMA_DATA_10;
 drop table "temp_table";
 truncate table ARIMA_DATA_10;
 create column  table "ARIMA_DATA_10" ( "ID" integer, "Net" double ) ;
 create column  table "ARIMA_DATA_12" ( "ID" integer, "Net" double ) ;
 

insert into  ARIMA_DATA_10 select "ID_CALENDAR", "Net" from "_SYS_BIC"."dbag_analytics.models/cv_market" 
where ( "ID_CALENDAR" between 1 and 10 ) and "PH3" = 'CB0100105'
  group by "ID_CALENDAR", "PH3","Net";

insert into  ARIMA_DATA_12 select top 20 SUM("Net") as "Net", "ID_CALENDAR" from "_SYS_BIC"."dbag_analytics.models/cv_market" 
where ( "ID_CALENDAR" >='1' and "ID_CALENDAR" <= '16' ) and "PH3" = 'CB0100105'
 group by "ID_CALENDAR";

truncate table ARIMA_DATA_12;


update "ARIMA_DATA_10" SET ID = ID - 1 ;
update "ARIMA_DATA_12" SET ID = ID - 1 ; 
update "T_SFK_CALENDAR" SET ID = ID -1 ;

 insert into  ARIMA_DATA_10 select top 5 "Net" from PH3_ARIMA_DATA_TRAIN ;

update ARIMA_DATA_10 set ID = ID - 1 ;

truncate table ARIMA_DATA_10;
truncate table PH3_ARIMA_DATA_TRAIN;

truncate table PH3_ARIMA_DATA_TRAIN;
insert into  PH3_ARIMA_DATA_TRAIN select top 10 "ID","Net" from ARIMA_DATA_10; 

 
 select * from ARIMA_DATA_10;
 select top 3 distinct("PH3") from "_SYS_BIC"."dbag_analytics.models/cv_market" ;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
