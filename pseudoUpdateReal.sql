do
 begin
 
    upsert  "TECH_ANALYSIS"."T_MARKET_ANALYSIS" 
         SELECT  a."ID" , m."PH3", round( m."Net"), a."Net Predict",
										 a."LOW80",
										 a."HI80",
										 a."LOW95",
										 a."HI95" 
                                       from 
                                   ( select a."ID",
                                         a."PH3",                                
	                                     a."Net Predict",
										 a."LOW80",
										 a."HI80",
										 a."LOW95",
										 a."HI95" 
                                        from "TECH_ANALYSIS"."T_MARKET_ANALYSIS" as a where "Net" IS NULL ) as a
                                  join 
                                    ( SELECT "ID_CALENDAR",
                                              "PH3",
                                               sum("Net") as "Net" 
                                         from  "_SYS_BIC"."dbag_analytics.models/cv_market"  group by "PH3","ID_CALENDAR" ) as m
                                   on  a."ID" = m."ID_CALENDAR" - 1 and a."PH3" = m."PH3" ;
                                  
 end;
 
 truncate table "TECH_ANALYSIS"."T_MARKET_ANALYSIS";
 truncate table ARIMA_TEST_RESULTS;
 truncate table PH3_ARIMA_DATA_TRAIN;
  truncate table  "TECH_ANALYSIS"."ARIMA_MODEL";
  

