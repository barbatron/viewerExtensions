USE NQViewer
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF (OBJECT_ID('SafeAveragePositives') IS NOT NULL) DROP FUNCTION dbo.SafeAveragePositives
GO
-- =============================================
-- Author:		Joakim
-- Create date: 
-- Description:	Calculates the average from three parameters, of which only non-null positive values are included.
-- =============================================
CREATE FUNCTION SafeAveragePositives
(
	@p1 int,
	@p2 int,
	@p3 int
)
RETURNS int
AS
BEGIN
---- Begin debug section
--DECLARE @p1 INT
--DECLARE @p2 INT
--DECLARE @p3 INT
--SELECT @p1 = 10, @p2 = 20, @p3 = NULL
---- End debug section
	
	DECLARE @Result INT
	
	DECLARE @partCount INT
	SELECT @partCount = 
		CASE WHEN ISNULL(@p1, 0) > 0 THEN 1 ELSE 0 END +
		CASE WHEN ISNULL(@p2, 0) > 0 THEN 1 ELSE 0 END +
		CASE WHEN ISNULL(@p3, 0) > 0 THEN 1 ELSE 0 END 

	IF @partCount > 0 BEGIN
		SELECT @Result = CONVERT(INT, 
			-- Sum parts
			(	CONVERT(FLOAT, ISNULL(@p1,0)) + 
				CONVERT(FLOAT, ISNULL(@p2,0)) + 
				CONVERT(FLOAT, ISNULL(@p3,0)) ) /
			-- Divide by part count
			CONVERT(FLOAT, @partCount) )
	END

	RETURN @Result

END
GO
