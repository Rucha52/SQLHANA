do
 begin
       declare TRAINDATA        "TECH_ANALYSIS"."T_PH3_ARIMA_DATA" ;
       declare TPARAMS          "TECH_ANALYSIS"."T_ARIMA_PARAMS";
       declare TOFRECAST_PARAMS "TECH_ANALYSIS"."T_ARIMA_PARAMS";
       declare TMODEL           "TECH_ANALYSIS"."ARIMA_TEST_MODEL";
       declare TRESULTS         "TECH_ANALYSIS"."T_ARIMA_FORE_RESULTS";     


       
     --Lets select The Customers with values in the desired TIME periods (1-10) and values in all of those periods  
      DECLARE CURSOR c_customers  FOR  
	      SELECT top 20 "PH3","CustomerHierarchy03"
	              FROM  "_SYS_BIC"."dbag_analytics.models/cv_customers" 
												                 where "ID_CALENDAR" between 1 and 10 and
												                        "CustomerHierarchy03" != ''
												                 group by "PH3","CustomerHierarchy03"
												                having count("CustomerHierarchy03") >= 10 ; 
										       
	  --clean the global result table
        truncate table T_CUSTOMERS_ANALYSIS;
	   --for the moment all parameters will be applied to all markets		
   	    TPARAMS          = select * from "TECH_ANALYSIS"."PARAMS";
   	    TOFRECAST_PARAMS = select * from "TECH_ANALYSIS"."T_FORECAST_PARAMS";  
   	   --lets clean the traning tables 	
   	   truncate table "PH3_ARIMA_DATA_TRAIN";  
   	   TRUNCATE TABLE "ARIMA_MODEL";  
   	   
		for customers AS c_customers
		 do
		      
		   --ONLY 11 months data loaded for  the train data for market   
			   insert into  "TECH_ANALYSIS"."PH3_ARIMA_DATA_TRAIN"  SELECT  "ID_CALENDAR" - 1, round("Net") 
	                                 FROM  "_SYS_BIC"."dbag_analytics.models/cv_customers" 
						                 where  "ID_CALENDAR" between 1 and 10 and 
						                          "PH3" = :customers."PH3"  and 
										        ( "CustomerHierarchy03" != '' and "CustomerHierarchy03" = :customers."CustomerHierarchy03" )
										       group by "ID_CALENDAR","PH3","CustomerHierarchy03","Net"
										       having round("Net") > 0;		
	       --train data to table variable
		     TRAINDATA =    select "ID" ,
		                           "Net" 
		                        from "TECH_ANALYSIS"."PH3_ARIMA_DATA_TRAIN"; 		  				       
			
          --clean the previous generated MODEL        
		     TRUNCATE TABLE "ARIMA_MODEL";  
		  -- call train procedure and store the model
          CALL "P_ARIMA" ( :TRAINDATA , :TPARAMS, :TMODEL) ;
             -- truncate table  "TECH_ANALYSIS"."ARIMA_MODEL";    
            --Analyse the code below since is giving an error  
	        --  insert into "TECH_ANALYSIS"."ARIMA_MODEL" select "NAME","VALUE" from  :TMODEL;   
         -- call predict procedure
           CALL P_ARIMA_FORE (:TMODEL, :TOFRECAST_PARAMS, :TRESULTS); 
           
           --save result into physical Table              
 
	         insert into  "TECH_ANALYSIS"."ARIMA_TEST_RESULTS" select * from :TRESULTS;
	         
	       -- save the Market ID and the predictions in a physcal table
             insert into  "TECH_ANALYSIS"."T_CUSTOMERS_ANALYSIS"  select   v."ID",
                                                                        :customers."PH3",
                                                                        :customers."CustomerHierarchy03",
																		v."Net",
																	round(v."Predicted Net"),
																	round(v."LOW80"),
																	round(v."HI80"),
																	round(v."LOW95"),
																	round(v."HI95")
															  from "TECH_ANALYSIS"."V_MARKET_PREDICTIONS" as v;
          --clean the train data table before each call
           truncate table "PH3_ARIMA_DATA_TRAIN";   															  
           truncate table ARIMA_TEST_RESULTS;
           
	    end for; 
 end;
 

 --truncate table T_CUSTOMER_ANALYSIS;
 