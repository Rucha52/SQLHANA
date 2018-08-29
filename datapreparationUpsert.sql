--

drop table T_MARKET_ANALYSIS;
drop table "temp_table";
truncate table "temp_table";
create column  table "T_MARKET_ANALYSIS" ( "ID" integer , "PH3" nvarchar(25), "Net" double,"Net Predict" double,"LOW80" DOUBLE, "HI80" DOUBLE, "LOW95" DOUBLE, "HI95" DOUBLE ) ; 
  
create column  table "temp_table" ( "ID" integer , "PH3" nvarchar(25), "Net" double); 
  
do    
 begin
	  
	  --declare ph3 nvarchar(25) :='CB0100105'; 
	  --declare phs nvarchar(25) array := array('CB0100105','CB0100100') ;
      truncate table "temp_table";
      
      --phs = select top 3 distinct("PH3") from "_SYS_BIC"."dbag_analytics.models/cv_market" ;
	  --select * from :phs;
	   
	 upsert "temp_table" 
	   select "ID_CALENDAR", "PH3", SUM("Net")  from "_SYS_BIC"."dbag_analytics.models/cv_market" 
	   where ( "ID_CALENDAR" >='1' and "ID_CALENDAR" <= '11' ) 
	   and "PH3" IN 
	   (select top 3 distinct("PH3") from "_SYS_BIC"."dbag_analytics.models/cv_market")
	 group by "ID_CALENDAR","PH3" ;
	 
    
	 
	 
 end; 
 do 
  begin
        truncate table "temp_table";
        phs = select top 3 distinct("PH3") from "_SYS_BIC"."dbag_analytics.models/cv_market" ;
        select * from :phs;
  end;
 

 
           
   

 