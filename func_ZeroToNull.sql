USE NQViewer
GO

-- =============================================
-- Author:		Joakim
-- Create date: 2013-05-19
-- Description:	Filter integer columns so zero becomes NULL
-- =============================================
CREATE FUNCTION ZeroToNull 
(
	@p1 int
)
RETURNS int
AS
BEGIN
	DECLARE @Result int
	SELECT @Result =CASE @p1 
		WHEN 0 THEN NULL
		ELSE @p1 
		END
	RETURN @Result
END
GO

