CREATE OR ALTER PROCEDURE dbo.usp_UpdateWatermark
(
    @TableName VARCHAR(100),
    @NewWatermarkValue DATETIME2
)
AS
BEGIN
    UPDATE dbo.WatermarkControl
    SET LastWatermarkValue = @NewWatermarkValue,
        UpdatedDate = SYSDATETIME()
    WHERE TableName = @TableName;
END;
GO
