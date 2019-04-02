-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PARAMS";
DROP TYPE "T_RESULTS";
DROP TYPE "T_STATS";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('TECH_ANALYSIS', 'P_SES');

DROP TABLE "RESULTS";
DROP TABLE "STATS";


-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("ID" INTEGER, "NET" double);
CREATE TYPE "T_PARAMS" AS TABLE ("NAME" VARCHAR(60), "INTARGS" INTEGER, "DOUBLEARGS" DOUBLE, "STRINGARGS" VARCHAR(100));
CREATE TYPE "T_RESULTS" AS TABLE ("ID" INTEGER, "NET" double, "LOW80" double, "HI80" double, "LOW95" double, "HI95" double);
CREATE TYPE "T_STATS" AS TABLE ("NAME" VARCHAR(60), "VALUE" DOUBLE);


CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'TECH_ANALYSIS', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'TECH_ANALYSIS', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'TECH_ANALYSIS', 'T_RESULTS', 'OUT');
INSERT INTO "SIGNATURE" VALUES (4, 'TECH_ANALYSIS', 'T_STATS', 'OUT');

CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'SINGLESMOOTH', 'TECH_ANALYSIS', 'P_SES', "SIGNATURE");


-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";
INSERT INTO "#PARAMS" VALUES ('ADAPTIVE_METHOD', 1, null, null); -- 0 : single exponential smoothing; 1 : adaptive-response-rate
INSERT INTO "#PARAMS" VALUES ('ALPHA', null, 0.1, null);
INSERT INTO "#PARAMS" VALUES ('DELTA', null, 0.2, null); -- when adaptive-response-rate
INSERT INTO "#PARAMS" VALUES ('FORECAST_NUM', 6, null, null);
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'MPE'); 
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'MSE');
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'RMSE');
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'ET');
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'MAD'); 
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'MASE');
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'WMAPE');
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'SMAPE');
INSERT INTO "#PARAMS" VALUES ('MEASURE_NAME', null, null, 'MAPE');
INSERT INTO "#PARAMS" VALUES ('EXPOST_FLAG', 1, null, null); -- 0 : do not output; 1 : output expost forecast
INSERT INTO "#PARAMS" VALUES ('PREDICTION_CONFIDENCE_1', null, 0.8, null);
INSERT INTO "#PARAMS" VALUES ('PREDICTION_CONFIDENCE_2', null, 0.95, null);

--CALL "P_SES" ("V_DATA", "#PARAMS", "RESULTS", "STATS") WITH OVERVIEW;
