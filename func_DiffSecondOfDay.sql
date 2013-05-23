USE NQViewer
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF (OBJECT_ID('DiffSecondOfDay') IS NOT NULL) DROP FUNCTION dbo.DiffSecondOfDay
GO
-- =============================================
-- Author:		Joakim
-- Create date: 
-- Description:	Calculates time diff in seconds, from provided second-of-day value to now.
-- =============================================
CREATE FUNCTION DiffSecondOfDay
(
	@timeValue int,
	@compareWith datetime 
)
RETURNS int
AS
BEGIN
---- Begin debug section
--DECLARE @timeValue int
--DECLARE @compareWith datetime 
--SELECT @timeValue = 32400
--SELECT @compareWith = GETDATE()
---- End debug section
	
	DECLARE @Result int

	IF (@timeValue > 0) BEGIN
		DECLARE @todaysDateStr VARCHAR(8)
		SELECT @todaysDateStr = CONVERT(VARCHAR(8), GETDATE(), 112)
		
		-- Compose dateTime from date/time values
		DECLARE @date1 DATETIME 
		SELECT @date1 = DATEADD(ss, @timeValue, CONVERT(DATETIME, @todaysDateStr))
		
		SELECT @Result = DATEDIFF(ss, @date1, @compareWith)
		
		IF (@Result < 0) SELECT @Result = NULL
	END
		
	RETURN @Result 

END
