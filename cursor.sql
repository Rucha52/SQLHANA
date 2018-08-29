do
 begin
 
   DECLARE CURSOR c_markets  FOR
		SELECT distinct("PH3") as "PH3" FROM  "_SYS_BIC"."dbag_analytics.models/cv_market";
		--WHERE "ID" between 1 and 16;
		
       declare a varchar(25);
	truncate table "temp_table";
	

	
	for market AS c_markets
	 do
	
	  a = market.PH3;
	  
	  insert into  "temp_table" select "ID_CALENDAR","PH3", round("Net") from "_SYS_BIC"."dbag_analytics.models/cv_market" 
          where "PH3" = :market.PH3
           group by "ID_CALENDAR","PH3","Net";
	  
    end for; 
 
 
 end;