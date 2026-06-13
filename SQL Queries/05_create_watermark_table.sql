IF OBJECT_ID('dbo.WatermarkControl', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.WatermarkControl;
END;
GO

CREATE TABLE dbo.WatermarkControl
(
    TableName VARCHAR(100) PRIMARY KEY,
    LastWatermarkValue DATETIME2,
    UpdatedDate DATETIME2
);
GO

INSERT INTO dbo.WatermarkControl
VALUES ('SourceCustomer', '1900-01-01 00:00:00', SYSDATETIME());

SELECT * FROM dbo.WatermarkControl;
