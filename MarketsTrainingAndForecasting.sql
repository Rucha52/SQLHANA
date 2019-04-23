do begin

  declare market nvarchar(25) ;
  declare custhier nvarchar(25) := 'FHAAGI';  
  declare t_params   "TECH_ANALYSIS"."T_ARIMA_PARAMS";
  declare t_forecast_params "TECH_ANALYSIS"."T_ARIMA_PARAMS";
  declare i,j int;
  declare  periodInit int :=1;
  declare  numberOfmarkets int := 50;
  declare  periodEnd  int :=18;
  declare maxIteration int := 7;
  declare t_models table( "p" integer, "aicc" double);
  
  
  --perform the test over 10 markets
  
   markets = SELECT top :numberOfmarkets "PH3" FROM  "_SYS_BIC"."dbag_analytics.models/cv_market" 
							                 where "ID_CALENDAR" between :periodInit and :periodEnd 
							                 group by "PH3"
							                 having count("PH3") > 10;	
 
   
   --params

  t_params."NAME"[1] = 'THREAD_NUMBER';
  t_params."INTARGS"[1] = 2;
  t_params."DOUBLEARGS"[1]= null;
  t_params."STRINGARGS"[1] = null; 
  
  t_params."NAME"[2] = 'METHOD';
  t_params."INTARGS"[2] = 1;
  t_params."DOUBLEARGS"[2]= null;
  t_params."STRINGARGS"[2] = null; 
  
  t_params."NAME"[3] = 'P';
  t_params."INTARGS"[3] = 1;
  t_params."DOUBLEARGS"[3]= null;
  t_params."STRINGARGS"[3] = null; 
  
  t_params."NAME"[4] = 'D';
  t_params."INTARGS"[4] = 0;
  t_params."DOUBLEARGS"[4]= null;
  t_params."STRINGARGS"[4] = null;
  
  t_params."NAME"[5] = 'Q';
  t_params."INTARGS"[5] = 0;
  t_params."DOUBLEARGS"[5]= null;
  t_params."STRINGARGS"[5] = null;
  
  --parameters for forecasting with the model and data
  t_forecast_params."NAME"[1] = 'ForecastLength';
  t_forecast_params."INTARGS"[1] = 19;
  t_forecast_params."DOUBLEARGS"[1]= null;
  t_forecast_params."STRINGARGS"[1] = null; 
  
  
  truncate table MODELS;
  truncate table "TECH_ANALYSIS"."MARKET_ANALYSIS";
    --iterate over All selected Markets
    for j in 1..:numberOfmarkets do 
      
		       --take all the Nets for each market merged with calendar info
		       market = :markets."PH3"[:j]; 
		       
		       baseTable = select ( c."ID" - 1 ) as "ID" ,    
			                      s."PH3",
			                    round(sum( s."Net")) as "Net"
			                   from "TECH_ANALYSIS"."sfk_data" as s
				                   join "TECH_ANALYSIS"."T_SFK_CALENDAR" as c
				                       on s."Month" = c."MONTH"
			                   where s."PH3" = :market
			                      and c."ID" between :periodInit and :periodEnd
			                     group by c."ID",s."PH3";
		       
		       --dataset
			   t_data = select "ID","Net" from :baseTable;	                     
			    
			       for i in 1..:maxIteration do
				  
						 t_params."INTARGS"[3] = :i;  --increment the autoregression parameter
			            
						 -- fit the model for the corresponding market 
			             CALL "P_ARIMA" ( :t_data , :t_params, TMODEL) ;	
			             --model temporary table  
			             insert into MODELS values ((select top 1 "VALUE" from :TMODEL where "NAME" = 'p'),(select  "VALUE" from :TMODEL where "NAME" = 'AICC'));
		
			             
				   end for;    
			    
			      --lets take P params as the highest AICC
			       p = select "p" from MODELS where "aicc" IN (select MAX("aicc")  from MODELS  ) ;
			       
			      --clean the model temporary table        
		          truncate table MODELS;
		          
		          --set the P param value according to the most suitable AICC
		          t_params."INTARGS"[3] = :p."p"[1];
		           
		          --recalculate the model with current P vale (the model could be stored and retrevied later..) 
		          CALL "P_ARIMA" ( :t_data , :t_params, TMODEL) ;
		          
		          --forecast with the Generated model
			      CALL "P_ARIMA_FORE" (:TMODEL, :t_forecast_params, TRESULTS);
			      
			       --save the results for visual analysis
			        insert into "TECH_ANALYSIS"."MARKET_ANALYSIS" select  case when a."ID" is not null 
									then a."ID" 
									else b."ID" 
									end as "ID",
									     :market,
										 a."Net",
										 b."Net" as "Predicted Net",
										 b."LOW80",
										 b."HI80",
										 b."LOW95",
										 b."HI95" 
									from :t_data as a full join :TRESULTS as b on a."ID" = b."ID" ;
		 
		
		    end for;    

  end;


