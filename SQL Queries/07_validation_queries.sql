SELECT * FROM dbo.SourceCustomer;
SELECT * FROM dbo.WatermarkControl;

SELECT COUNT(*) AS TotalRecords
FROM dbo.SourceCustomer;

SELECT MAX(UpdatedDate) AS MaxUpdatedDate
FROM dbo.SourceCustomer;

SELECT 
    CustomerID,
    CustomerName,
    City,
    Email,
    Phone,
    UpdatedDate
FROM dbo.SourceCustomer
ORDER BY UpdatedDate DESC;
