USE NQViewer
GO
--
-- SERVICE TYPE subservice entries
--
IF (OBJECT_ID('SUBSERVICE_SERVICETYPE') IS NOT NULL) DROP VIEW SUBSERVICE_SERVICETYPE
GO
CREATE VIEW SUBSERVICE_SERVICETYPE AS
SELECT
	base.OFFICEGUID,
	base.OFFICE_NR,
	base.SERVICETYPE_NR,

	-- Subservice entry 	
	subs.CASHIER_NR,
	subs.USER_NR,	
	subs.SUBSERVICE_NR, 
	subs.SUBSERVICE_NAME, 
	subs.FACTOR,
	subs.SERVICE_TIME,
	subs.SUBSERVICE_TIME,
	subs.TRACK_NR

FROM SERVICETYPE_QUEUE_INFO base

LEFT OUTER JOIN SUBSERVICE_QUEUE_INFO subs ON 
	subs.OFFICEGUID = base.OFFICEGUID AND
	subs.SERVICETYPE_NR = base.SERVICETYPE_NR 

WHERE base.SERVICETYPE_NR	> 0
GO




