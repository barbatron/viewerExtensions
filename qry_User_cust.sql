USE NQViewer
GO

IF (OBJECT_ID('USER_QUEUE_INFO_CUST') IS NOT NULL) DROP VIEW USER_QUEUE_INFO_CUST
GO

CREATE VIEW USER_QUEUE_INFO_CUST AS
SELECT 	
	a.OFFICE_NR,
	a.OFFICEGUID,
	a.USER_NR,

-- Total service time 
	SUM(cust.SERVICE_TIME) AS [TOT_SERVICE_TIME]

FROM USER_QUEUE_INFO a
LEFT OUTER JOIN CUSTOMER_QUEUE_INFO cust
	ON a.USER_NR = cust.USER_NR 
	AND a.OFFICEGUID = cust.OFFICEGUID
WHERE a.USER_NR > 0
GROUP BY 
	a.OFFICE_NR, 
	a.OFFICEGUID, 
	a.USER_NR 

