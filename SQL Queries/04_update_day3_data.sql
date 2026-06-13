UPDATE dbo.SourceCustomer
SET Phone = '8888888888', UpdatedDate = SYSDATETIME()
WHERE CustomerID = 101;

UPDATE dbo.SourceCustomer
SET City = 'Hyderabad', UpdatedDate = SYSDATETIME()
WHERE CustomerID = 103;

UPDATE dbo.SourceCustomer
SET Email = 'kiran.new@gmail.com', UpdatedDate = SYSDATETIME()
WHERE CustomerID = 105;

INSERT INTO dbo.SourceCustomer
VALUES
(107, 'Neha Singh', 'Noida', 'neha.singh@gmail.com', '9000000007', SYSDATETIME(), SYSDATETIME());

SELECT * FROM dbo.SourceCustomer;
