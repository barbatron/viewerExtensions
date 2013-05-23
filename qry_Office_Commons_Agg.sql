USE NQViewer
GO
--
-- All sum/max/average values that include all office subtypes.
--
IF (OBJECT_ID('OFFICE_COMMONS_AGG') IS NOT NULL) DROP VIEW OFFICE_COMMONS_AGG
GO
CREATE VIEW OFFICE_COMMONS_AGG AS
SELECT 
	-- Base office metadata 
	o.OFFICEGUID,
	o.OFFICE_NR,
	o.IP,
	o.LEVEL2_NAME,
	o.LEVEL2_NR,
	o.LEVEL3_NAME,
	o.LEVEL3_NR,

	-- Cashier stats
	cagg.INSTALLED_CASHIERS,
	cagg.ACTIVE_CASHIERS,
	cagg.INACTIVE_CASHIERS,
				
	-- Office commons aggregate stats
	oagg.[ITEM_COUNT],
	oagg.[ST_COUNT],
	oagg.[C_COUNT],
	oagg.[U_COUNT],
	
	oagg.[WAITING_CUSTOMERS_TOT], 
	oagg.[WAITING_CUSTOMERS_MQ], 
	oagg.[WAITING_CUSTOMERS_ST_TOT], 
	oagg.[WAITING_CUSTOMERS_ST_MQ], 

	oagg.[AVG_WAITING_TIME_TOT], 
	oagg.[AVG_WAITING_TIME_MQ], 
	oagg.[AVG_WAITING_TIME_ST_TOT], 
	oagg.[AVG_WAITING_TIME_ST_MQ], 

	oagg.[LONGEST_WT_SECONDS_TOT], 
	oagg.[LONGEST_WT_SECONDS_MQ], 
	oagg.[LONGEST_WT_SECONDS_ST_TOT], 
	oagg.[LONGEST_WT_SECONDS_ST_MQ], 

	oagg.[SERVED_CUSTOMERS_TOT], 
	oagg.[SERVED_CUSTOMERS_MQ], 
	oagg.[SERVED_CUSTOMERS_ST_TOT], 
	oagg.[SERVED_CUSTOMERS_ST_MQ], 

	oagg.[AVG_SERVICE_TIME_TOT], 
	oagg.[AVG_SERVICE_TIME_MQ], 
	oagg.[AVG_SERVICE_TIME_ST_TOT], 
	oagg.[AVG_SERVICE_TIME_ST_MQ], 

	oagg.[MAX_SERVICE_TIME_TOT], 
	oagg.[MAX_SERVICE_TIME_ST], 
	oagg.[MAX_SERVICE_TIME_C], 
	oagg.[MAX_SERVICE_TIME_U]

	-- Feedback


	-- Waste time

FROM OFFICE_INFO o

--
-- Include aggregate cashier stats for info on open/active cashiers etc. 
LEFT OUTER JOIN (
	SELECT 
		OFFICEGUID,
		OFFICE_NR,
		
		-- Office workstation stats
		SUM(CASE WHEN CASHIER_OPEN = 1 AND CASHIER_ACTIVE = 1 THEN 1 ELSE 0 END)	AS [ACTIVE_CASHIERS],
		SUM(CASE WHEN CASHIER_OPEN = 1 AND CASHIER_ACTIVE = 0 THEN 1 ELSE 0 END)	AS [INACTIVE_CASHIERS],
		COUNT(CASHIER_NR)															AS [INSTALLED_CASHIERS]

	FROM dbo.CASHIER_QUEUE_INFO_EXT 
	GROUP BY	
		OFFICEGUID, 
		OFFICE_NR
) AS cagg ON o.OFFICEGUID = cagg.OFFICEGUID 

--
-- Create aggregate data from office commons union:
LEFT OUTER JOIN (
	SELECT 
		OFFICEGUID,
		OFFICE_NR,	

		COUNT(*)														AS [ITEM_COUNT],
		SUM(CASE WHEN SRC = 1 THEN 1 ELSE 0 END)						AS [ST_COUNT],
		SUM(CASE WHEN SRC = 2 THEN 1 ELSE 0 END)						AS [C_COUNT],
		SUM(CASE WHEN SRC = 3 THEN 1 ELSE 0 END)						AS [U_COUNT],
	
		-- # Waiting customers 
		SUM(WAITING_CUSTOMERS_TOT)										AS [WAITING_CUSTOMERS_TOT],		-- All subtypes, all subqueues
		SUM(WAITING_CUSTOMERS_MQ)										AS [WAITING_CUSTOMERS_MQ],		-- All subtypes, MQ
		SUM(CASE WHEN SRC=1 THEN WAITING_CUSTOMERS_TOT ELSE NULL END)	AS [WAITING_CUSTOMERS_ST_TOT],	-- ST tot 
		SUM(CASE WHEN SRC=1 THEN WAITING_CUSTOMERS_MQ ELSE NULL END)	AS [WAITING_CUSTOMERS_ST_MQ]	,-- ST tot 
		
		-- Avg waiting time 
		AVG(AVG_WAITING_TIME_TOT)										AS [AVG_WAITING_TIME_TOT],		
		AVG(AVG_WAITING_TIME_MQ)										AS [AVG_WAITING_TIME_MQ],		
		AVG(CASE WHEN SRC=1 THEN AVG_WAITING_TIME_TOT ELSE NULL END)	AS [AVG_WAITING_TIME_ST_TOT],	-- ST tot 
		AVG(CASE WHEN SRC=1 THEN AVG_WAITING_TIME_MQ ELSE NULL END)		AS [AVG_WAITING_TIME_ST_MQ],	-- ST MQ
		
		-- Max waiting time 
		MAX(LONGEST_WT_SECONDS_TOT)										AS [LONGEST_WT_SECONDS_TOT],
		MAX(LONGEST_WT_SECONDS_MQ)										AS [LONGEST_WT_SECONDS_MQ],
		MAX(CASE WHEN SRC=1 THEN LONGEST_WT_SECONDS_TOT ELSE NULL END)	AS [LONGEST_WT_SECONDS_ST_TOT],	-- ST tot 
		MAX(CASE WHEN SRC=1 THEN LONGEST_WT_SECONDS_MQ ELSE NULL END)	AS [LONGEST_WT_SECONDS_ST_MQ],	-- ST MQ
		
		-- # Served customers
		SUM(SERVED_CUSTOMERS_TOT)										AS [SERVED_CUSTOMERS_TOT],
		SUM(SERVED_CUSTOMERS_MQ)										AS [SERVED_CUSTOMERS_MQ],
		SUM(CASE WHEN SRC=1 THEN SERVED_CUSTOMERS_TOT ELSE NULL END)	AS [SERVED_CUSTOMERS_ST_TOT],	-- Also for ServiceTypes tot ?
		SUM(CASE WHEN SRC=1 THEN SERVED_CUSTOMERS_MQ ELSE NULL END)		AS [SERVED_CUSTOMERS_ST_MQ],	-- Also for ServiceTypes tot ?

		-- Avg service time
		AVG(AVG_SERVICE_TIME_TOT)										AS [AVG_SERVICE_TIME_TOT],
		AVG(AVG_SERVICE_TIME_MQ)										AS [AVG_SERVICE_TIME_MQ],
		AVG(CASE WHEN SRC=1 THEN AVG_SERVICE_TIME_TOT ELSE NULL END)	AS [AVG_SERVICE_TIME_ST_TOT],
		AVG(CASE WHEN SRC=1 THEN AVG_SERVICE_TIME_MQ ELSE NULL END)		AS [AVG_SERVICE_TIME_ST_MQ],
		
		-- Max service time; Max-v�rdet bland alla LONGEST_SERVICE_TIME f�r ST, CASHIER, USER
		MAX(LONGEST_SERVICE_TIME)										AS [MAX_SERVICE_TIME_TOT],
		MAX(CASE WHEN SRC=1 THEN LONGEST_SERVICE_TIME ELSE NULL END)	AS [MAX_SERVICE_TIME_ST],
		MAX(CASE WHEN SRC=2 THEN LONGEST_SERVICE_TIME ELSE NULL END)	AS [MAX_SERVICE_TIME_C],
		MAX(CASE WHEN SRC=3 THEN LONGEST_SERVICE_TIME ELSE NULL END)	AS [MAX_SERVICE_TIME_U]
		
	FROM OFFICE_COMMONS_UNION
	GROUP BY 
		OFFICEGUID,
		OFFICE_NR		
) AS oagg ON o.OFFICEGUID = oagg.OFFICEGUID
GO
