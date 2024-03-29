USE NQViewer
GO

IF (OBJECT_ID('SERVICETYPE_QUEUE_INFO_CUST') IS NOT NULL) DROP VIEW SERVICETYPE_QUEUE_INFO_CUST
GO

CREATE VIEW SERVICETYPE_QUEUE_INFO_CUST AS
SELECT 	
	a.OFFICE_NR,
	a.OFFICEGUID,
	a.SERVICETYPE_NR,

-- Total service time 
	SUM(cust.SERVICE_TIME) AS [TOT_SERVICE_TIME]

FROM SERVICETYPE_QUEUE_INFO a
LEFT OUTER JOIN CUSTOMER_QUEUE_INFO cust
	ON a.SERVICETYPE_NR = cust.SERVICETYPE_NR 
	AND a.OFFICEGUID = cust.OFFICEGUID
WHERE a.SERVICETYPE_NR > 0
GROUP BY 
	a.OFFICE_NR, 
	a.OFFICEGUID, 
	a.SERVICETYPE_NR 