drop table Orders
drop table Products
drop table Category
drop table Customers
drop table Customer_Enquiries
drop table Login
Go
drop Proc AddProduct
drop proc UpdateProducts
drop proc FindProduct
drop proc DeleteProduct
drop proc AddCustomerOrder
drop proc AddCustomer_Enquiries
drop proc LookupUserIDandPassword
go
--drop proc FindMenuInfo
go
----------------Start of Create table----------------------
CREATE TABLE [dbo].[Customers](
	[CustomerID] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](40) NOT NULL,
	[LastName] [nvarchar](30) NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
----------------------------------------------------------
CREATE TABLE Category
(
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](15) NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, 
IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, 
ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
----------------------------------------------------------

CREATE TABLE Products
(
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[CategoryID] [int] NOT NULL,
    [Quantity] [int] NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	ActiveProduct bit,
	[Description] text
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, 
IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, 
ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE Products  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Category] FOREIGN KEY([CategoryID])
REFERENCES Category ([CategoryID])
GO

ALTER TABLE Products CHECK CONSTRAINT [FK_Products_Category]
GO
----------------------------------------------------------

CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [nvarchar](50) NOT NULL,
	[ProductID] [int] NOT NULL,
	[TransactionID] [nvarchar](50) NULL,
	[OrderDate] [datetime] NULL,
	[RequiredDate] [datetime] NULL,
	[OrderStatus] [nchar](1) NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customers]
GO

ALTER TABLE [dbo].[Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO

ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Products]
GO
----------------------------------------------------------
CREATE TABLE [dbo].[Customer_Enquiries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypeOfQuestion] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](40) NOT NULL,
	[Message] [ntext] NULL,
	[Active_Enquires] [int] NULL,
 CONSTRAINT [PK_Customer_Enquiries] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Customer_Enquiries] ADD  CONSTRAINT [CE_Active_Enquires]  DEFAULT ((1)) FOR [Active_Enquires]
GO
-----------------------------------------------------------------------------
CREATE TABLE [dbo].[Login](
	[LoginID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [nchar](30) NOT NULL,
	[Password] [nchar](30) NOT NULL,
	[Respond] [nchar](30) NOT NULL,
	[FirstName] [nvarchar](40) NOT NULL,
	[LastName] [nvarchar](30) NULL,
 CONSTRAINT [PK_Login] PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
----------------End of Create table----------------------
----------------Start of Procedure-----------------------
Create Procedure UpdateProducts
(
@ProductID int,
@ProductName nvarchar(40),
@CategoryID int,
@Quantity int,
@UnitPrice money,
@UnitsInStock smallint,
@UnitsOnOrder smallint,
@Description text
)
As
  Declare @ReturnCode int
  Set     @ReturnCode = 1

  If @ProductID is null
      RAISERROR('UpdateProducts - Required parameter: @ProductID',16,1)
  Else
      Begin
      Update Products
	  Set 
	 
	  ProductName = @ProductName,
	  CategoryID = @CategoryID,
	  Quantity = @Quantity,
	  UnitPrice = @UnitPrice,
	  UnitsInStock = @UnitsInStock,
	  UnitsOnOrder = @UnitsOnOrder,
	  [Description] = @Description
	  Where
	  ProductID  = @ProductID
        If @@Error = 0
	    Set @ReturnCode = 0
		Else
			RAISERROR('UpdateProduct',16,1)
		End 
GO
----------------------------------------------------------------
Create Procedure FindProduct
(
@ProductID int = null
)
As
      Declare @ReturnStatus as int
      Set @ReturnStatus = 1
      
	  If @ProductID IS NULL
		    RAISERROR('FindProduct - Required Parameter: @ProductID',16,1)
	  Else 
      Begin 
            Select ProductID, ProductName, CategoryID, Quantity,
			UnitPrice, UnitsInStock, UnitsOnOrder, [Description]
			from Products
            Where ProductID = @ProductID and
			ActiveProduct = 1
      If @@ERROR = 0
	       Set @ReturnStatus = 0
	  Else
	       RAISERROR ('Select ProductID from Products' ,16,1)
	  End
 Return	@ReturnStatus
GO
---------------------------------------------------------------
Create procedure DeleteProduct
(
@ProductID int = null
)
As
  Declare @ReturnCode int
  Set     @ReturnCode = 1

  If @ProductID is null
      RAISERROR('DeleteProducts - Required parameter: @ProductID',16,1)
  Else
      Begin
	  --delete from Products
     Update Products
	 Set 
	 ActiveProduct = 0
	  Where
	  ProductID  = @ProductID
        If @@Error = 0
	    Set @ReturnCode = 0
		Else
			RAISERROR('UpdateProduct',16,1)
		End 
GO
-----------------------------------------------------------------
CREATE PROCEDURE AddProduct
           @ProductName nvarchar(40),
           @CategoryID int,
           @Quantity int,
           @UnitPrice money,
            @UnitsInStock smallint,
            @UnitsOnOrder smallint,
			@Description text
            AS
insert into Products(ProductName, CategoryID, Quantity, UnitPrice, UnitsInStock,UnitsOnOrder, ActiveProduct, [Description]) 
VALUES (@ProductName,@CategoryID ,@Quantity,@UnitPrice ,@UnitsInStock ,@UnitsOnOrder, 1, @Description)
GO
-----------------------------------------------------------------
--drop proc AddCustomerOrder
CREATE PROCEDURE AddCustomerOrder
           @CustomerID nvarchar(50),
           @CustomerFirstName nvarchar(40),
           @CustomerLastName nvarchar(30),
		   @ProductIDOne int,
		   @ProductIDTwo int,
		   @ProductIDThree int,
		   @ProductIDFour int,
		   @ProductIDFive int,
		   @ProductIDSix int,
		   @ProductIDSeven int,
		   @ProductIDEight int,
           @ProductIDNine int,
		   @ProductIDTen int,
		   @ProductIDEleven int,
		   @ProductIDTwelve int,
           @TranscationID nvarchar(50),
           @OrderDate Datetime
AS
if NOT EXISTS(select CustomerID from Customers where CustomerID = @CustomerID)
begin
insert into Customers(CustomerID,FirstName,LastName)
values(@CustomerID,@CustomerFirstName,@CustomerLastName)
end
if @ProductIDOne <> null or @ProductIDOne <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDOne ,@TranscationID, @OrderDate ,DATEADD(day,1,@OrderDate), 1)
end
if @ProductIDTwo <> null or @ProductIDTwo <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDTwo ,@TranscationID, @OrderDate ,DATEADD(day,2,@OrderDate), 1)
end
if @ProductIDThree <> null or @ProductIDThree <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDThree ,@TranscationID, @OrderDate ,DATEADD(day,3,@OrderDate), 1)
end
if @ProductIDFour <> null or @ProductIDFour <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDFour ,@TranscationID, @OrderDate ,DATEADD(day,4,@OrderDate), 1)
end
if @ProductIDFive <> null or @ProductIDFive <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDFive ,@TranscationID, @OrderDate ,DATEADD(day,5,@OrderDate), 1)
end
IF @ProductIDSix <> '' OR @ProductIDSix <> Null
BEGIN
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDSix ,@TranscationID, @OrderDate ,DATEADD(day,6,@OrderDate), 1)
END
if @ProductIDSeven <> null or @ProductIDSeven <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDSeven ,@TranscationID, @OrderDate ,DATEADD(day,7,@OrderDate), 1)
end
if @ProductIDEight <> null or @ProductIDEight <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDEight ,@TranscationID, @OrderDate ,DATEADD(day,8,@OrderDate), 1)
end
if @ProductIDNine <> null or @ProductIDNine <> ''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDNine ,@TranscationID, @OrderDate ,DATEADD(day,9,@OrderDate), 1)
end
if @ProductIDTen <> null or @ProductIDTen <>''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDTen ,@TranscationID, @OrderDate ,DATEADD(day,10,@OrderDate), 1)
end
if @ProductIDEleven <> null or @ProductIDEleven <>''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDEleven ,@TranscationID, @OrderDate ,DATEADD(day,11,@OrderDate), 1)
end
if @ProductIDTwelve <> null or @ProductIDTwelve <>''
begin
insert into Orders(CustomerID, ProductID, TransactionID, OrderDate, RequiredDate,OrderStatus) 
VALUES (@CustomerID,@ProductIDTwelve ,@TranscationID, @OrderDate ,DATEADD(day,12,@OrderDate), 1)
end
GO
---------------Customer Enquire--------------------------
CREATE PROCEDURE AddCustomer_Enquiries

           
         @TypeOfQuestion nvarchar(50),
           @Name nvarchar(50),
           @Email nvarchar(40),
           @Message ntext 
         
            AS
           

insert into Customer_Enquiries(TypeOfQuestion,Name,Email,Message) 
VALUES (@TypeOfQuestion,@Name,@Email,@Message)
Go
---------------------------------------------------------
CREATE PROCEDURE LookupUserIDandPassword
            @UserID nchar(30),
             @Password nchar(30),
			 @Respond nchar(30)
             
            AS
            select *
            FROM login
            WHERE UserID = @UserID and Password = @Password and Respond = @Respond
Go
--------------------------------------------------------------------
----------Menu Lookup-----------------------------------------------
--Create Procedure FindMenuInfo
--As
--Select ProductName, Description ,UnitPrice
--from Products Where ActiveProduct = 1
--Go
--exec FindMenuInfo
------------Start of Inserts and Test Proc in SQL------------------------
-------------------Hard Code Login---------------------------------------
insert into Login (UserID, Password, Respond, FirstName, LastName)
values('Davidz','abc', 'John', 'David', 'Long')
go
insert into Login (UserID, Password, Respond, FirstName, LastName)
values('Cori2','Amazing','Team', 'Cori', 'Pucci')
------------Hard Cold One Category Because All item shows up ones--------
insert into Category (CategoryName, Description)
values('Food',null)
Go
-------------------------ProductList-------------------------------------
execute AddProduct
@ProductName = 'Bark (milk chocolate)',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 4.75,
@UnitsInStock = 50,
@UnitsOnOrder = 0,
@Description = 'Callebaut chocolate and macadamia nuts'
go
execute AddProduct
@ProductName = 'Butter-me-up Tarts',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 1.50,
@UnitsInStock = 90,
@UnitsOnOrder = 0,
@Description = 'Pastry crust, butter, brown sugar, corn syrup, egg, vanilla, white vinegar, raisins and pecans'
go
execute AddProduct
@ProductName = 'Chocolate Covered Blueberries',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 1.50,
@UnitsInStock = 40,
@UnitsOnOrder = 0,
@Description = 'Callebaut chocolate and fresh blueberries'
go
execute AddProduct
@ProductName = 'Chocolate Covered Strawberries',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 1.50,
@UnitsInStock = 90,
@UnitsOnOrder = 0,
@Description = 'Callebaut chocolate and fresh strawberries'
go
execute AddProduct
@ProductName = 'Eatmore Please',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 25.00,
@UnitsInStock = 90,
@UnitsOnOrder = 0,
@Description = 'Semi-sweet chocolate, corn syrup, peanut butter, peanuts and rice krispies cereal'
go
execute AddProduct
@ProductName = 'Heavenly Haystacks',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 1.50,
@UnitsInStock = 50,
@UnitsOnOrder = 0,
@Description = 'Callebaut chocolate chips, Reese peanut butter chips, peanuts and chow mein noodles'
go
execute AddProduct
@ProductName = 'Oooh Henry Balls',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 1.50,
@UnitsInStock = 90,
@UnitsOnOrder = 0,
@Description = 'Peanut butter, dates, peanuts, icing sugar, butter, semi-sweet chocolate'
go
execute AddProduct
@ProductName = 'Pretzel Bites',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 0.50,
@UnitsInStock = 100,
@UnitsOnOrder = 0,
@Description = 'Pretzels, caramel and Callebaut chocolate'
go
execute AddProduct
@ProductName = 'Turtle Cups',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 2.05,
@UnitsInStock = 90,
@UnitsOnOrder = 10,
@Description = 'cupcake'
go
execute AddProduct
@ProductName = 'Yum Yum � Blueberry',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 20.00,
@UnitsInStock = 10,
@UnitsOnOrder = 0,
@Description = '9x9-Graham cracker crumbs, butter, Philadelphia cream cheese, whipping cream, dream whip and blueberry pie filling'
go
execute AddProduct
@ProductName = 'Yum Yum - Cherry',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 20.00,
@UnitsInStock = 10,
@UnitsOnOrder = 0,
@Description = '9x9-Graham cracker crumbs, butter, Philadelphia cream cheese, whipping cream, dream whip and Cherry pie filling'
go
----------------Demo Only!! if need to add new button and assoication from PayPal do Peach as the ID is 12--------------------
execute AddProduct
@ProductName = 'Yum Yum - Peach',
@CategoryID =  1,
@Quantity= 1,
@UnitPrice = 20.00,
@UnitsInStock = 10,
@UnitsOnOrder = 0,
@Description = '9x9-Graham cracker crumbs, butter, Philadelphia cream cheese, whipping cream, dream whip and Peach pie filling'
go
----No Need for second product because PayPal ID needs to be the same---------
----------------------------------------------------------------
--execute UpdateProducts
--@ProductName = 'cookie',
--@CategoryID =  1,
--@Quantity= 2,
--@UnitPrice = 2.0,
--@UnitsInStock = 5,
--@UnitsOnOrder = 3,
--@ProductID = 1
----------------------------------------------------------------
--execute FindProduct
--@ProductID = 1
----------------------------------------------------------------
--execute DeleteProduct
--@ProductID = 1
----------------------------------------------------------------
--Reactive Product-------------------------------------------------

--Update Products
--	  Set 
	 
--	  ActiveProduct = 1
--	  Where
--	  ProductID  = 1
------------------------------------------------------------------
--execute AddCustomerOrder
--@CustomerID = 'John.Snow@hotmail.com',
--@CustomerFirstName =  'John',
--@CustomerLastName= 'Snow',
--@ProductIDOne = 1,
--@ProductIDTwo = 001,
--@ProductIDThree = 1,
--@ProductIDFour = 1,
--@ProductIDFive = 1,
--@ProductIDSix = '',
--@ProductIDSeven = '',
--@ProductIDEight = 1,
--@ProductIDNine = null,
--@ProductIDTen = null,
--@TranscationID = 'SuperID',
--@OrderDate = '02/22/2015'
----------------------------------------------------------
--exec AddCustomer_Enquiries
--@TypeOfQuestion = 'Product Question',
--@Name = 'Linda',
--@Email = 'Linda@hotmail.com',
--@Message = 'Is there nuts in the product?'
----------------------------------------------------------

Select * from Products
Select * from Category
select * from Orders
select * from Customers
select * from Customer_Enquiries
select * from Login
