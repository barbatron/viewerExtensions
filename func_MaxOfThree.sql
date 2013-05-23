USE NQViewer
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF (OBJECT_ID('MaxOfThree') IS NOT NULL) DROP FUNCTION MaxOfThree
GO
-- =============================================
-- Author:		Joakim Olsson
-- Create date: 
-- Description:	Returns the max value of three parameters
-- =============================================
CREATE FUNCTION MaxOfThree 
(	
	@p1 int, 
	@p2 int,
	@p3 int)
RETURNS INT
AS
BEGIN
	DECLARE @maxValue INT	
	SELECT @maxValue = CASE
        WHEN @p1 IS NOT NULL AND ((@p2 IS NULL OR @p1 >= @p2) AND (@p3 IS NULL OR @p1 >= @p3)) THEN @p1
        WHEN @p2 IS NOT NULL AND ((@p1 IS NULL OR @p2 >= @p1) AND (@p3 IS NULL OR @p2 >= @p3)) THEN @p2
        WHEN @p3 IS NOT NULL AND ((@p1 IS NULL OR @p3 >= @p1) AND (@p2 IS NULL OR @p3 >= @p2)) THEN @p3        
    END 
	RETURN @maxValue
END

-- Test routine:
--SELECT 
--	dbo.MaxOfThree(1, 2, 3),
--	dbo.MaxOfThree(1, 3, 2),
--	dbo.MaxOfThree(2, 1, 3),
--	dbo.MaxOfThree(2, 3, 1),
--	dbo.MaxOfThree(3, 1, 2),
--	dbo.MaxOfThree(3, 2, 1),

--	dbo.MaxOfThree(NULL, NULL, 3),
--	dbo.MaxOfThree(NULL, 3, NULL),
--	dbo.MaxOfThree(3, NULL, NULL),
--	dbo.MaxOfThree(NULL, NULL, NULL)
