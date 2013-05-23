USE [NQViewer]
GO
/****** Object:  UserDefinedFunction [dbo].[DiffSecondOfDay]    Script Date: 05/21/2013 15:50:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF (OBJECT_ID('NQDateTime') IS NOT NULL) DROP FUNCTION NQDateTime
GO
-- =============================================
-- Author:		Joakim
-- Create date: 
-- Description:	Converts two-part date/time pair into native the DateTime format.
-- =============================================
CREATE FUNCTION [dbo].[NQDateTime]
(
	@timeValue int,
	@dateValue int,					-- Can be left out - result will then use todays date.
	@origin datetime = null
)
RETURNS DATETIME
AS
BEGIN
-- Begin debug section
--DECLARE @timeValue INT select @timeValue = 57000 
--DECLARE @dateValue INT select @dateValue = 41415
--DECLARE @origin DATETIME
-- End debug section
	
	DECLARE @nqdt DATETIME

	IF (@timeValue > 0) BEGIN
	
		-- Get a string rep of "now" in order to build time from midnight tonight:
		IF (@origin IS NULL) SELECT @origin = CONVERT(DATETIME, '1899-12-30')
		
		-- Interpret missing dateValue as todays date:
		IF (@dateValue IS NULL) SELECT @dateValue = DATEDIFF(dd, @origin, GETDATE()) 
		
		-- Compose dateTime from date/time values
		SELECT @nqdt = 
			DATEADD(ss, @timeValue,						-- (3) Add seconds
				DATEADD(D, @dateValue,					-- (2) Add days
					@origin								-- (1) Start at given origin
				)					
			) 	
	END	
	RETURN @nqdt
END
