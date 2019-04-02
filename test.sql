do begin
  declare t_params   "TECH_ANALYSIS"."T_ARIMA_PARAMS";
  declare t_forecast_params "TECH_ANALYSIS"."T_ARIMA_PARAMS";
  declare market nvarchar(25) ;
  declare customer nvarchar(25);
  declare i,j int;
  declare  periodInit int :=1;
  declare  numberOfmarkets int := 10;
  declare  periodEnd  int :=18;
  
  
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
  
  truncate table "TECH_ANALYSIS"."CUSTOMERS_ANALYSIS";
  --perform the test over 10 markets
  
   t_markets = SELECT top :numberOfmarkets "PH3" FROM  "_SYS_BIC"."dbag_analytics.models/cv_market" 
							                 where "ID_CALENDAR" between :periodInit and :periodEnd 
							                 group by "PH3"
							                 having count("PH3") > 10;	
							                 
	for i in 1..:numberOfmarkets do 
	
	    --take all Customers in current Market 
		       market = :t_markets."PH3"[:i]; 
		       
		       t_customers = select                          
			                      s."CustomerHierarchy03"			                    
			                   from "TECH_ANALYSIS"."sfk_data" as s
				                   join "TECH_ANALYSIS"."T_SFK_CALENDAR" as c
				                       on s."Month" = c."MONTH"
			                   where s."PH3" = :market
			                      and s."CustomerHierarchy03" != ''
			                      and c."ID" between :periodInit and :periodEnd
			                      group by s."CustomerHierarchy03"
			                      having count(s."CustomerHierarchy03") > 5;
			                      
			    t_totalCustomers = select count("CustomerHierarchy03") as "Cust" from :t_customers;                 
			    --take all the Nets by Customers and period                 
		       for j in 1..:t_totalCustomers."Cust"[1] do
		       
		          customer =  :t_customers."CustomerHierarchy03"[j];	   
			                      
		       
		         t_baseTable = select ( c."ID" - 1 ) as "ID" , 			                     
			                    round(sum( s."Net")) as "Net",
			                    s."PH3",
			                    s."CustomerHierarchy03"
			                   from "TECH_ANALYSIS"."sfk_data" as s
				                   join "TECH_ANALYSIS"."T_SFK_CALENDAR" as c
				                       on s."Month" = c."MONTH"
			                   where s."PH3" = :market 
			                     and s."CustomerHierarchy03" = :customer
                                 group by c."ID",s."PH3", s."CustomerHierarchy03";
                                 
                 
                  --deals with linear customers
                    t_avg = select AVG("Net") as "Net" from :t_baseTable;             
		            t_max = select MAX("Net") as "Net" from :t_baseTable;  
		            
		            if (:t_avg."Net"[1] != :t_max."Net"[1]) then 
		            
		               --dataset                 
		               t_data = select "ID","Net" from :t_baseTable;
		         
		              -- train the Model 
		              CALL "P_ARIMA" ( :t_data , :t_params, TMODEL) ; 
		              
		               --forecast with the Generated model
			          CALL "P_ARIMA_FORE" (:TMODEL, :t_forecast_params, TRESULTS);
			      
		              --save the results for visual analysis
				        insert into "TECH_ANALYSIS"."CUSTOMERS_ANALYSIS" select  case when a."ID" is not null 
										then a."ID" 
										else b."ID" 
										end as "ID",
										     :market,
										     :customer,
											 a."Net",
											 b."Net" as "Predicted Net",
											 b."LOW80",
											 b."HI80",
											 b."LOW95",
											 b."HI95" 
										from :t_data as a full join :TRESULTS as b on a."ID" = b."ID" ;
		            end if;
		         
		       end for;
	            
	
	end for;
  
	
end ;