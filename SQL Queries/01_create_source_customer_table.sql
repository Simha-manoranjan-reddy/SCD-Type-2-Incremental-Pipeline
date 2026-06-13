IF OBJECT_ID('dbo.SourceCustomer', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.SourceCustomer;
END;
GO

CREATE TABLE dbo.SourceCustomer
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    CreatedDate DATETIME2,
    UpdatedDate DATETIME2
);
GO
