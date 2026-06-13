UPDATE dbo.SourceCustomer
SET City = 'Bangalore', UpdatedDate = SYSDATETIME()
WHERE CustomerID = 101;

UPDATE dbo.SourceCustomer
SET Phone = '9999999999', UpdatedDate = SYSDATETIME()
WHERE CustomerID = 102;

UPDATE dbo.SourceCustomer
SET Email = 'priya.new@gmail.com', UpdatedDate = SYSDATETIME()
WHERE CustomerID = 104;

INSERT INTO dbo.SourceCustomer
VALUES
(106, 'Meena Das', 'Delhi', 'meena.das@gmail.com', '9000000006', SYSDATETIME(), SYSDATETIME());

SELECT * FROM dbo.SourceCustomer;
