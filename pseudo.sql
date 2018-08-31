do
 begin
       declare TRAINDATA        "TECH_ANALYSIS"."T_PH3_ARIMA_DATA" ;
       declare TPARAMS          "TECH_ANALYSIS"."T_ARIMA_PARAMS";
       declare TOFRECAST_PARAMS "TECH_ANALYSIS"."T_ARIMA_PARAMS";
       declare TMODEL           "TECH_ANALYSIS"."ARIMA_TEST_MODEL";
       declare TRESULTS         "TECH_ANALYSIS"."T_ARIMA_FORE_RESULTS";
       
     --Lets select The Markets with values in the desired TIME periods (1-10) and values in all of those periods  
       DECLARE CURSOR c_markets  FOR  
       SELECT top 10 "PH3" FROM  "_SYS_BIC"."dbag_analytics.models/cv_market" 
							                 where "ID_CALENDAR" between 1 and 10 
							                 group by "PH3"
							                 having count("PH3") = 10;	
   /**							                      
		SELECT distinct("PH3") as "PH3" FROM  "_SYS_BIC"."dbag_analytics.models/cv_market"
		                 where "ID_CALENDAR" between 1 and 10 ; 
  **/
		                  
   --for the moment all parameters will be applied to all markets		
   	    TPARAMS          = select * from "TECH_ANALYSIS"."PARAMS";
   	    TOFRECAST_PARAMS = select * from "TECH_ANALYSIS"."T_FORECAST_PARAMS";
   	    	
		for market AS c_markets
		 do
		
		   --clean the train data table before each call
	        truncate table "PH3_ARIMA_DATA_TRAIN";
	         
		   --ONLY 11 months data loaded for  the train data for market   
			  insert into  "TECH_ANALYSIS"."PH3_ARIMA_DATA_TRAIN" select ( ID_CALENDAR - 1 ),
			                                                               round("Net")
			                                                       from "_SYS_BIC"."dbag_analytics.models/cv_market" 
														          where "PH3" = :market.PH3 and 
														                ("ID_CALENDAR" between 1 and 10 )
														           group by "ID_CALENDAR","PH3","Net";
	      --train data to table variable
		     TRAINDATA =    select "ID" ,
		                           "Net" 
		                        from "TECH_ANALYSIS"."PH3_ARIMA_DATA_TRAIN"; 
						        
		   --clean the previous generated MODEL        
		      TRUNCATE TABLE "ARIMA_MODEL";
		       
		   -- call train procedure and store the model
           CALL "P_ARIMA" ( :TRAINDATA , :TPARAMS, :TMODEL) ;
              truncate table  "TECH_ANALYSIS"."ARIMA_MODEL";      
	          insert into "TECH_ANALYSIS"."ARIMA_MODEL" select "NAME","VALUE" from  :TMODEL;
	          
	       -- call predict procedure
           CALL P_ARIMA_FORE (:TMODEL, :TOFRECAST_PARAMS, :TRESULTS);
           
           --save result into physical Table   
             truncate table ARIMA_TEST_RESULTS; 
	         insert into  "TECH_ANALYSIS"."ARIMA_TEST_RESULTS" select * from :TRESULTS;
	         
	       -- save the Market ID and the predictions in a physcal table
             insert into  "TECH_ANALYSIS"."T_MARKET_ANALYSIS"  select   v."ID",
                                                                        :market.PH3,
																		v."Net",
																	round(v."Predicted Net"),
																	round(v."LOW80"),
																	round(v."HI80"),
																	round(v."LOW95"),
																	round(v."HI95")
															  from "TECH_ANALYSIS"."V_MARKET_PREDICTIONS" as v;			
	          
	    end for; 
 end;
 
 truncate table "TECH_ANALYSIS"."T_MARKET_ANALYSIS";
 truncate table ARIMA_TEST_RESULTS;
 truncate table PH3_ARIMA_DATA_TRAIN;
  truncate table  "TECH_ANALYSIS"."ARIMA_MODEL";
  
 -- app runtime
DROP TABLE T_FORECAST_PARAMS;
CREATE  COLUMN TABLE T_FORECAST_PARAMS LIKE T_ARIMA_PARAMS;

INSERT INTO T_FORECAST_PARAMS VALUES ('ForecastLength', 11, null, null); 
