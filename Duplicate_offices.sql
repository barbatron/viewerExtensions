USE [NQViewer]
GO
--SELECT * FROM OFFICE_INFO 

DECLARE @cleanse BIT
SELECT @cleanse = 0

IF (@cleanse = 1) BEGIN	
	--IF (OBJECT_ID('prev_OFFICE_INFO') IS NULL) 
	--	SELECT * INTO prev_OFFICE_INFO FROM OFFICE_INFO 
	--ELSE BEGIN
	--	DELETE FROM prev_OFFICE_INFO; 
	--	INSERT INTO prev_OFFICE_INFO SELECT * FROM OFFICE_INFO; 
	DELETE FROM OFFICE_INFO WHERE OFFICE_NR > 1
	--END
	
	DELETE FROM SERVICETYPE_QUEUE_INFO WHERE OFFICE_NR > 1
	DELETE FROM CASHIER_QUEUE_INFO WHERE OFFICE_NR > 1
	DELETE FROM USER_QUEUE_INFO WHERE OFFICE_NR > 1
END

-- Ensure synchronized officeGUID throughout
DECLARE @tab VARCHAR(60)
SELECT @tab = 'SERVICETYPE_QUEUE_INFO'; EXEC('UPDATE ' + @tab + ' SET OFFICEGUID = O.OFFICEGUID, OFFICE_NAME = O.OFFICE_NAME, OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM ' + @tab + ' st INNER JOIN OFFICE_INFO o ON st.OFFICE_NR=o.OFFICE_NR')
SELECT @tab = 'CASHIER_QUEUE_INFO'; EXEC('UPDATE ' + @tab + ' SET OFFICEGUID = O.OFFICEGUID, OFFICE_NAME = O.OFFICE_NAME, OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM ' + @tab + ' st INNER JOIN OFFICE_INFO o ON st.OFFICE_NR=o.OFFICE_NR')
SELECT @tab = 'USER_QUEUE_INFO'; EXEC('UPDATE ' + @tab + ' SET OFFICEGUID = O.OFFICEGUID, OFFICE_NAME = O.OFFICE_NAME, OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM ' + @tab + ' st INNER JOIN OFFICE_INFO o ON st.OFFICE_NR=o.OFFICE_NR')
SELECT @tab = 'CUSTOMER_QUEUE_INFO'; EXEC('UPDATE ' + @tab + ' SET OFFICEGUID = O.OFFICEGUID, OFFICE_NAME = O.OFFICE_NAME, OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM ' + @tab + ' st INNER JOIN OFFICE_INFO o ON st.OFFICE_NR=o.OFFICE_NR')
SELECT @tab = 'SUBSERVICE_QUEUE_INFO'; EXEC('UPDATE ' + @tab + ' SET OFFICEGUID = O.OFFICEGUID, OFFICE_NAME = O.OFFICE_NAME, OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM ' + @tab + ' st INNER JOIN OFFICE_INFO o ON st.OFFICE_NR=o.OFFICE_NR')
--UPDATE CASHIER_QUEUE_INFO SET OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM SERVICETYPE_QUEUE_INFO st INNER JOIN OFFICE_INFO o ON st.LEVEL2_NR=o.LEVEL2_NR AND st.LEVEL3_NR=o.LEVEL3_NR
--UPDATE USER_QUEUE_INFO SET OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM SERVICETYPE_QUEUE_INFO st INNER JOIN OFFICE_INFO o ON st.LEVEL2_NR=o.LEVEL2_NR AND st.LEVEL3_NR=o.LEVEL3_NR
--UPDATE CUSTOMER_QUEUE_INFO SET OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM SERVICETYPE_QUEUE_INFO st INNER JOIN OFFICE_INFO o ON st.LEVEL2_NR=o.LEVEL2_NR AND st.LEVEL3_NR=o.LEVEL3_NR
--UPDATE SUBSERVICE_QUEUE_INFO SET OFFICE_NR = O.OFFICE_NR, LEVEL2_NR = O.LEVEL2_NR, LEVEL3_NR = O.LEVEL3_NR, LEVEL2_NAME = O.LEVEL2_NAME, LEVEL3_NAME = O.LEVEL3_NAME FROM SERVICETYPE_QUEUE_INFO st INNER JOIN OFFICE_INFO o ON st.LEVEL2_NR=o.LEVEL2_NR AND st.LEVEL3_NR=o.LEVEL3_NR

DECLARE @nr INT
SELECT @nr = COUNT(*) + 1 FROM OFFICE_INFO

PRINT ''
PRINT 'Creating new office'
INSERT INTO [dbo].[OFFICE_INFO]
           ([OFFICEGUID]
           ,[IP]
           ,[OFFICE_NR]
           ,[LEVEL2_NR]
           ,[LEVEL3_NR]
           ,[OFFICE_NAME]
           ,[LEVEL2_NAME]
           ,[LEVEL3_NAME]
           ,[MODIFICATION_DATE]
           ,[MODIFICATION_TIME])
SELECT		NEWID() AS [OFFICEGUID]
           ,[IP]
           ,@nr AS [NEW_OFFICE_NR]
           ,[LEVEL2_NR]
           ,[LEVEL3_NR]
           ,'Office ' + CONVERT(VARCHAR(10), @nr)
           ,[LEVEL2_NAME]
           ,[LEVEL3_NAME]
           ,[OFFICE_NR]			-- Old office nr goes into MODIFICATION_DATE
           ,ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000) AS [RANDSEED]
FROM OFFICE_INFO
WHERE OFFICE_NR IN (1)

-- Service Types
PRINT ''
PRINT 'Duplicating service types for new offices'
INSERT INTO SERVICETYPE_QUEUE_INFO (
	   [OFFICE_NR] 
      ,[LEVEL2_NR]
      ,[LEVEL3_NR]
      ,[SERVICETYPE_NR]
      ,[OFFICEGUID]
      ,[OFFICE_NAME]
      ,[LEVEL2_NAME]
      ,[LEVEL3_NAME]
      ,[SERVICETYPE_NAME]
      ,[OPEN_CASHIERS]
      ,[ACTIVE_CASHIERS]
      ,[LAST_FORWARDED]
      ,[WAITING_CUSTOMERS_MQ]
      ,[WAITING_CUSTOMERS_SQ]
      ,[WAITING_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_MQ]
      ,[SERVED_CUSTOMERS_SQ]
      ,[SERVED_CUSTOMERS_BQ]
      ,[LONGEST_WAITING_TIME_TICKET_MQ]
      ,[LONGEST_WAITING_TIME_TICKET_SQ]
      ,[LONGEST_WAITING_TIME_TICKET_BQ]
      ,[LONGEST_SERVICE_TIME]
      ,[AVG_WAITING_TIME_MQ]
      ,[AVG_WAITING_TIME_SQ]
      ,[AVG_WAITING_TIME_BQ]
      ,[AVG_SERVICE_TIME_MQ]
      ,[AVG_SERVICE_TIME_SQ]
      ,[AVG_SERVICE_TIME_BQ]
      ,[MODIFICATION_DATE]
      ,[MODIFICATION_TIME])
SELECT
	   newoffices.[OFFICE_NR]
      ,newoffices.[LEVEL2_NR]
      ,newoffices.[LEVEL3_NR]
      ,[SERVICETYPE_NR]
      ,newoffices.[OFFICEGUID]
      ,newoffices.[OFFICE_NAME]
      ,newoffices.[LEVEL2_NAME]
      ,newoffices.[LEVEL3_NAME]
      ,[SERVICETYPE_NAME]
      ,5 + CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 5.0) AS OPEN_CASHIERS
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000))*5.0) AS ACTIVE_CASHIERS
      ,[LAST_FORWARDED]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 10) AS [WAITING_CUSTOMERS_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 4) AS [WAITING_CUSTOMERS_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 2) AS [WAITING_CUSTOMERS_BQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [SERVED_CUSTOMERS_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 10) AS [SERVED_CUSTOMERS_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 10) AS [SERVED_CUSTOMERS_BQ]
      ,(CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 7200) + 21600) AS [LONGEST_WAITING_TIME_TICKET_MQ]	-- 7:00
      ,[LONGEST_WAITING_TIME_TICKET_SQ]
      ,[LONGEST_WAITING_TIME_TICKET_BQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 1000) AS [LONGEST_SERVICE_TIME]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [AVG_WAITING_TIME_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [AVG_WAITING_TIME_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [AVG_WAITING_TIME_BQ]
      
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [AVG_SERVICE_TIME_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [AVG_SERVICE_TIME_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 100) AS [AVG_SERVICE_TIME_BQ]
      ,st.[MODIFICATION_DATE]
      ,st.[MODIFICATION_TIME]
FROM SERVICETYPE_QUEUE_INFO st
INNER JOIN (
	SELECT 
		o.OFFICEGUID AS [OFFICEGUID], OFFICE_NR AS [OFFICE_NR], 
		MODIFICATION_DATE AS [OLD_OFFICE_NR], 
		LEVEL2_NR, LEVEL2_NAME, LEVEL3_NR, LEVEL3_NAME, OFFICE_NAME
	FROM OFFICE_INFO o
	INNER JOIN (
		SELECT OFFICEGUID, OFFICE_NR AS [ONR], OFFICE_NAME AS [ONAME]
		FROM OFFICE_INFO 
		WHERE OFFICEGUID NOT IN (SELECT DISTINCT OFFICEGUID FROM SERVICETYPE_QUEUE_INFO) 
	) officesWithoutSt ON o.OFFICEGUID = officesWithoutSt.OFFICEGUID
) AS newOffices  
ON st.OFFICE_NR = newOffices.OLD_OFFICE_NR
WHERE SERVICETYPE_NR > 0

-- Cashiers

INSERT INTO CASHIER_QUEUE_INFO (
	   [OFFICE_NR]
      ,[LEVEL2_NR]
      ,[LEVEL3_NR]
      ,[CASHIER_NR]
      ,[OFFICEGUID]
      ,[OFFICE_NAME]
      ,[LEVEL2_NAME]
      ,[LEVEL3_NAME]
      ,[CASHIER_NAME]
      ,[CASHIER_OPEN]
      ,[CASHIER_ACTIVE]
      ,[CASHIERCALL]
      ,[PRIORITY]
      ,[THIS_CUSTOMER]
      ,[LAST_FORWARDED_MQ]
      ,[LAST_FORWARDED_SQ]
      ,[LAST_FORWARDED_BQ]
      ,[LAST_FORWARDED]
      ,[SERVICETYPE_NR]
      ,[SERVICETYPE_NAME]
      ,[USER_NR]
      ,[USER_NAME]
      ,[WAITING_CUSTOMERS_MQ]
      ,[WAITING_CUSTOMERS_SQ]
      ,[WAITING_CUSTOMERS_BQ]
      ,[LONGEST_WAITING_TIME_TICKET_MQ]
      ,[LONGEST_WAITING_TIME_TICKET_SQ]
      ,[LONGEST_WAITING_TIME_TICKET_BQ]
      ,[LONGEST_SERVICE_TIME]
      ,[SERVED_CUSTOMERS_MQ]
      ,[SERVED_CUSTOMERS_SQ]
      ,[SERVED_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_ST]
      ,[AVG_WAITING_TIME_MQ]
      ,[AVG_WAITING_TIME_SQ]
      ,[AVG_WAITING_TIME_BQ]
      ,[AVG_SERVICE_TIME_MQ]
      ,[AVG_SERVICE_TIME_SQ]
      ,[AVG_SERVICE_TIME_BQ]
      ,[AVG_SERVICE_TIME_ST]
      ,[MESSAGE]
      ,[MODIFICATION_DATE]
      ,[MODIFICATION_TIME])
SELECT newOffices.[OFFICE_NR]
      ,newOffices.[LEVEL2_NR]
      ,newOffices.[LEVEL3_NR]
      ,[CASHIER_NR]
      ,newOffices.[OFFICEGUID]
      ,newOffices.[OFFICE_NAME]
      ,newOffices.[LEVEL2_NAME]
      ,newOffices.[LEVEL3_NAME]
      ,[CASHIER_NAME]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 2) AS [CASHIER_OPEN]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 2) AS [CASHIER_ACTIVE]
      ,[CASHIERCALL]
      ,[PRIORITY]
      ,[THIS_CUSTOMER]
      ,[LAST_FORWARDED_MQ]
      ,[LAST_FORWARDED_SQ]
      ,[LAST_FORWARDED_BQ]
      ,[LAST_FORWARDED]
      ,[SERVICETYPE_NR]
      ,[SERVICETYPE_NAME]
      ,[USER_NR]
      ,[USER_NAME]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 6) AS [WAITING_CUSTOMERS_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 2) AS [WAITING_CUSTOMERS_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 0) AS [WAITING_CUSTOMERS_BQ]
      ,(CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 7200) + 21600) AS [LONGEST_WAITING_TIME_TICKET_MQ]
      ,(CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 7200) + 21600) AS [LONGEST_WAITING_TIME_TICKET_SQ]
      ,[LONGEST_WAITING_TIME_TICKET_BQ]
      ,[LONGEST_SERVICE_TIME]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 6) AS [SERVED_CUSTOMERS_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 6) AS [SERVED_CUSTOMERS_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 6) AS [SERVED_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_ST]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 60) AS [AVG_WAITING_TIME_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 60) AS [AVG_WAITING_TIME_SQ]
      ,[AVG_WAITING_TIME_BQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 60) AS [AVG_SERVICE_TIME_MQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 60) AS [AVG_SERVICE_TIME_SQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 60) AS [AVG_SERVICE_TIME_BQ]
      ,CONVERT(INT, RAND(ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT) % 100000)) * 60) AS [AVG_SERVICE_TIME_ST]
      ,[MESSAGE]
      ,0 AS [MODIFICATION_DATE]
      ,0 AS [MODIFICATION_TIME]
FROM [dbo].[CASHIER_QUEUE_INFO] st
INNER JOIN (
	SELECT 
		o.OFFICEGUID AS [OFFICEGUID], OFFICE_NR AS [OFFICE_NR], 
		MODIFICATION_DATE AS [OLD_OFFICE_NR], 
		LEVEL2_NR, LEVEL2_NAME, LEVEL3_NR, LEVEL3_NAME, OFFICE_NAME
	FROM OFFICE_INFO o
	INNER JOIN (
		SELECT OFFICEGUID
		FROM OFFICE_INFO 
		WHERE OFFICEGUID NOT IN (SELECT DISTINCT OFFICEGUID FROM CASHIER_QUEUE_INFO) 
	) officesWithoutSt ON o.OFFICEGUID = officesWithoutSt.OFFICEGUID
  ) AS newOffices  
ON st.OFFICE_NR = newOffices.OLD_OFFICE_NR
WHERE st.CASHIER_NR > 0

PRINT 'Fixing illegal cashiers (active not open)'
UPDATE CASHIER_QUEUE_INFO SET CASHIER_OPEN = 1 WHERE CASHIER_ACTIVE = 1 AND CASHIER_OPEN = 0

-- Users

INSERT INTO [USER_QUEUE_INFO] (
newOffices.[OFFICE_NR]
      ,[LEVEL2_NR]
      ,[LEVEL3_NR]
      ,[USER_NR]
      ,[OFFICEGUID]
      ,[OFFICE_NAME]
      ,[LEVEL2_NAME]
      ,[LEVEL3_NAME]
      ,[USER_NAME]
      ,[USER_LOGGED_ON]
      ,[USER_ACTIVE]
      ,[PRIORITY]
      ,[THIS_CUSTOMER]
      ,[LAST_FORWARDED_MQ]
      ,[LAST_FORWARDED_SQ]
      ,[LAST_FORWARDED_BQ]
      ,[LAST_FORWARDED]
      ,[SERVICETYPE_NR]
      ,[SERVICETYPE_NAME]
      ,[CASHIER_NR]
      ,[CASHIER_NAME]
      ,[WAITING_CUSTOMERS_MQ]
      ,[WAITING_CUSTOMERS_SQ]
      ,[WAITING_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_MQ]
      ,[SERVED_CUSTOMERS_SQ]
      ,[SERVED_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_CQ]
      ,[SERVED_CUSTOMERS_ST]
      ,[LONGEST_WAITING_TIME_TICKET_MQ]
      ,[LONGEST_WAITING_TIME_TICKET_SQ]
      ,[LONGEST_WAITING_TIME_TICKET_BQ]
      ,[LONGEST_SERVICE_TIME]
      ,[AVG_WAITING_TIME_MQ]
      ,[AVG_WAITING_TIME_SQ]
      ,[AVG_WAITING_TIME_BQ]
      ,[AVG_SERVICE_TIME_MQ]
      ,[AVG_SERVICE_TIME_SQ]
      ,[AVG_SERVICE_TIME_BQ]
      ,[AVG_SERVICE_TIME_CQ]
      ,[AVG_SERVICE_TIME_ST]
      ,[MESSAGE]
      ,[MODIFICATION_DATE]
      ,[MODIFICATION_TIME])
SELECT newOffices.[OFFICE_NR]
      ,newOffices.[LEVEL2_NR]
      ,newOffices.[LEVEL3_NR]
      ,[USER_NR]
      ,newOffices.[OFFICEGUID]
      ,newOffices.[OFFICE_NAME]
      ,newOffices.[LEVEL2_NAME]
      ,newOffices.[LEVEL3_NAME]
      ,[USER_NAME]
      ,[USER_LOGGED_ON]
      ,[USER_ACTIVE]
      ,[PRIORITY]
      ,[THIS_CUSTOMER]
      ,[LAST_FORWARDED_MQ]
      ,[LAST_FORWARDED_SQ]
      ,[LAST_FORWARDED_BQ]
      ,[LAST_FORWARDED]
      ,[SERVICETYPE_NR]
      ,[SERVICETYPE_NAME]
      ,[CASHIER_NR]
      ,[CASHIER_NAME]
      ,[WAITING_CUSTOMERS_MQ]
      ,[WAITING_CUSTOMERS_SQ]
      ,[WAITING_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_MQ]
      ,[SERVED_CUSTOMERS_SQ]
      ,[SERVED_CUSTOMERS_BQ]
      ,[SERVED_CUSTOMERS_CQ]
      ,[SERVED_CUSTOMERS_ST]
      ,[LONGEST_WAITING_TIME_TICKET_MQ]
      ,[LONGEST_WAITING_TIME_TICKET_SQ]
      ,[LONGEST_WAITING_TIME_TICKET_BQ]
      ,[LONGEST_SERVICE_TIME]
      ,[AVG_WAITING_TIME_MQ]
      ,[AVG_WAITING_TIME_SQ]
      ,[AVG_WAITING_TIME_BQ]
      ,[AVG_SERVICE_TIME_MQ]
      ,[AVG_SERVICE_TIME_SQ]
      ,[AVG_SERVICE_TIME_BQ]
      ,[AVG_SERVICE_TIME_CQ]
      ,[AVG_SERVICE_TIME_ST]
      ,[MESSAGE]
      ,[MODIFICATION_DATE]
      ,[MODIFICATION_TIME]
  FROM [dbo].[USER_QUEUE_INFO] st
  INNER JOIN (
	SELECT 
		o.OFFICEGUID AS [OFFICEGUID], OFFICE_NR AS [OFFICE_NR], 
		CASE WHEN OFFICE_NR=1 THEN 1 ELSE MODIFICATION_DATE END AS [OLD_OFFICE_NR], 
		LEVEL2_NR, LEVEL2_NAME, LEVEL3_NR, LEVEL3_NAME, OFFICE_NAME
	FROM OFFICE_INFO o
	INNER JOIN (
		SELECT OFFICEGUID
		FROM OFFICE_INFO 
		WHERE OFFICEGUID NOT IN (SELECT DISTINCT OFFICEGUID FROM USER_QUEUE_INFO) 
	) officesWithoutSt ON o.OFFICEGUID = officesWithoutSt.OFFICEGUID
  ) AS newOffices  
ON st.OFFICE_NR = newOffices.OLD_OFFICE_NR 
WHERE st.USER_NR > 0


SELECT * FROM OFFICE_INFO ORDER BY OFFICE_NR, LEVEL2_NR
SELECT * FROM SERVICETYPE_QUEUE_INFO ORDER BY OFFICE_NR, LEVEL2_NR
SELECT * FROM CASHIER_QUEUE_INFO ORDER BY OFFICE_NR, LEVEL2_NR
SELECT * FROM USER_QUEUE_INFO ORDER BY OFFICE_NR, LEVEL2_NR

--delete from office_info where office_nr>1
--delete from SERVICETYPE_QUEUE_INFO where office_nr>1

--select * from SERVICETYPE_QUEUE_INFO_EXT where officeguid = '7997D26E-5885-4C51-B5E3-D3AA1D686B4E'
--select * from CASHIER_QUEUE_INFO_EXT where officeguid = '7997D26E-5885-4C51-B5E3-D3AA1D686B4E'
--select * from OFFICE_COMMONS_UNION where officeguid  = '7997D26E-5885-4C51-B5E3-D3AA1D686B4E' 
--SELECT * FROM OFFICE_COMMONS_AGG where officeguid  = '7997D26E-5885-4C51-B5E3-D3AA1D686B4E' 

