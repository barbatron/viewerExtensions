USE NQViewer
GO

IF (OBJECT_ID('SERVICETYPE_QUEUE_INFO_EXT') IS NOT NULL) DROP VIEW SERVICETYPE_QUEUE_INFO_EXT
GO

CREATE VIEW SERVICETYPE_QUEUE_INFO_EXT AS
SELECT
	a.OFFICE_NR,
	a.OFFICEGUID,
	a.SERVICETYPE_NR,

-- Columns straight out of source
	a.ACTIVE_CASHIERS,
	
-- Waiting customers
	a.WAITING_CUSTOMERS_MQ,
	a.WAITING_CUSTOMERS_SQ,
	a.WAITING_CUSTOMERS_BQ,
	CONVERT(INT, 
		a.WAITING_CUSTOMERS_MQ + 
		a.WAITING_CUSTOMERS_SQ + 
		a.WAITING_CUSTOMERS_BQ)
	AS [WAITING_CUSTOMERS_TOT],

-- Average waiting time total (mq+sq+bq)
	dbo.ZeroToNull(a.AVG_WAITING_TIME_MQ) AS [AVG_WAITING_TIME_MQ],
	dbo.ZeroToNull(a.AVG_WAITING_TIME_SQ) AS [AVG_WAITING_TIME_SQ],
	dbo.ZeroToNull(a.AVG_WAITING_TIME_BQ) AS [AVG_WAITING_TIME_BQ],
	dbo.SafeAveragePositives(
		a.AVG_WAITING_TIME_MQ,
		a.AVG_WAITING_TIME_SQ,
		a.AVG_WAITING_TIME_BQ ) 
	AS [AVG_WAITING_TIME_TOT],
	 
-- Longest waiting time (mq+sq+bq): Longest waiting time among MQ+SQ+BQ.
	a.[LONGEST_WAITING_TIME_TICKET_MQ], 
	a.[LWT_DATETIME_MQ],
	a.[LONGEST_WT_SECONDS_MQ],	--DATEDIFF(ss, a.[LWT_DATETIME_MQ], GETDATE()) AS [LWT_DIFF_SEC_MQ],	
	a.[LONGEST_WAITING_TIME_TICKET_SQ], 
	a.[LWT_DATETIME_SQ],
	a.[LONGEST_WT_SECONDS_SQ],	--DATEDIFF(ss, a.[LWT_DATETIME_SQ], GETDATE()) AS [LWT_DIFF_SEC_SQ],	
	a.[LONGEST_WAITING_TIME_TICKET_BQ], 
	a.[LWT_DATETIME_BQ],
	a.[LONGEST_WT_SECONDS_BQ],	--DATEDIFF(ss, a.[LWT_DATETIME_BQ], GETDATE()) AS [LWT_DIFF_SEC_BQ],	
	dbo.MaxOfThree(
		a.LONGEST_WT_SECONDS_MQ,
		a.LONGEST_WT_SECONDS_SQ,
		a.LONGEST_WT_SECONDS_BQ)			AS [LONGEST_WT_SECONDS_TOT],
	
-- Served customers (mq+sq+bq)
	a.SERVED_CUSTOMERS_MQ,
	a.SERVED_CUSTOMERS_SQ,
	a.SERVED_CUSTOMERS_BQ,
	(a.SERVED_CUSTOMERS_MQ + a.SERVED_CUSTOMERS_SQ + a.SERVED_CUSTOMERS_BQ) 
	AS [SERVED_CUSTOMERS_TOT],
	
-- Avg Service time (mq+sq+bq)
	dbo.ZeroToNull(a.AVG_SERVICE_TIME_MQ) AS [AVG_SERVICE_TIME_MQ], 
	dbo.ZeroToNull(a.AVG_SERVICE_TIME_SQ) AS [AVG_SERVICE_TIME_SQ], 
	dbo.ZeroToNull(a.AVG_SERVICE_TIME_BQ) AS [AVG_SERVICE_TIME_BQ],
	dbo.SafeAveragePositives(
		a.AVG_SERVICE_TIME_MQ, 
		a.AVG_SERVICE_TIME_SQ, 
		a.AVG_SERVICE_TIME_BQ)
	AS [AVG_SERVICE_TIME_TOT],

---- Max of average service time
--	dbo.ZeroToNull(dbo.MaxOfThree(
--		a.AVG_SERVICE_TIME_MQ,
--		a.AVG_SERVICE_TIME_SQ,
--		a.AVG_SERVICE_TIME_BQ))
--	AS [MAX_AVG_SERVICE_TIME_TOT],
	
-- Longest service time 
	dbo.ZeroToNull(a.LONGEST_SERVICE_TIME) AS [LONGEST_SERVICE_TIME]

FROM (
	SELECT a.*

	-- Calc readable DateTime values for LONGEST_WAITING_TIME_TICKET:
	,  dbo.NQDateTime(a.LONGEST_WAITING_TIME_TICKET_MQ, NULL, NULL) AS [LWT_DATETIME_MQ]
	,  dbo.NQDateTime(a.LONGEST_WAITING_TIME_TICKET_SQ, NULL, NULL) AS [LWT_DATETIME_SQ]
	,  dbo.NQDateTime(a.LONGEST_WAITING_TIME_TICKET_BQ, NULL, NULL) AS [LWT_DATETIME_BQ]
	
	-- Calc diff in seconds from "now" to the point in time, today, when the LWT ticket was dispensed:
	,  dbo.DiffSecondOfDay(a.LONGEST_WAITING_TIME_TICKET_MQ, GETDATE()) AS [LONGEST_WT_SECONDS_MQ]
	,  dbo.DiffSecondOfDay(a.LONGEST_WAITING_TIME_TICKET_SQ, GETDATE()) AS [LONGEST_WT_SECONDS_SQ]
	,  dbo.DiffSecondOfDay(a.LONGEST_WAITING_TIME_TICKET_BQ, GETDATE()) AS [LONGEST_WT_SECONDS_BQ]
	
	FROM SERVICETYPE_QUEUE_INFO a
	WHERE SERVICETYPE_NR > 0			-- Filter away any template instances
) AS a 
GO

select * from SERVICETYPE_QUEUE_INFO_EXT