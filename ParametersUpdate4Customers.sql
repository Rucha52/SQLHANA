
-- runtimetest
truncate TABLE "PARAMS";

INSERT INTO "PARAMS" VALUES ('THREAD_NUMBER', 2, null, null);
INSERT INTO "PARAMS" VALUES ('METHOD', 1, null, null); -- 0: conditional sum squares, 1: max likelihood estimation
--INSERT INTO "PARAMS" VALUES ('STATIONARY', 1, null, null); -- 0: result may not be stationary, 1: is stationary
--INSERT INTO "PARAMS" VALUES ('P', 1, null, null); -- Auto Regression
--INSERT INTO "PARAMS" VALUES ('D', 0, null, null); -- Differentiation
--INSERT INTO "PARAMS" VALUES ('Q', 1, null, null); -- Moving Average
INSERT INTO "PARAMS" VALUES ('SEASONAL_P', 1, null, null); -- Seasonal Auto Regression
INSERT INTO "PARAMS" VALUES ('SEASONAL_D', 1, null, null); -- Seasonal Differentiation
INSERT INTO "PARAMS" VALUES ('SEASONAL_Q', 1, null, null); -- Seasonal Moving Average
INSERT INTO "PARAMS" VALUES ('SEASONAL_PERIOD', 3, null, null); -- Seasonal Period
