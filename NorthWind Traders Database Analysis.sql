-- Selecting the database.
use [Northwind traders]

-- Select statements for all tables.
select * from [dbo].[Customer]
select * from [dbo].[Order]
select * from [dbo].[OrderItem]
select * from [dbo].[Product]
select * from [dbo].[Supplier]
GO

-- 1) Stored procedure to find the customer details, product purchased details, customer loyalty rank and total amount spent on all products.
create proc Customer_Purchase_Details_CustomerID(@CustomerID int, @TotalAmountSpent decimal(10,2) output)
as
begin
    -- Checks if the customer ID exists in the database. If ID does not exists, the code in the else statement will be shown in ouput.
	if exists(select * from Customer where CustomerId = @CustomerID)
		begin
			-- Stores customer name.
			select CustomerId, FirstName, LastName from Customer
			where CustomerId = @CustomerID

			-- Stores order details, including total amount for each order.
			select ord.OrderId, p.ProductId, p.ProductName, oi.UnitPrice, oi.Quantity,
			SUM(oi.UnitPrice * oi.Quantity) as Cost, p.Package, ord.TotalAmount
			from [dbo].[Order] ord inner join [dbo].[OrderItem] oi on ord.OrderId = oi.OrderId
			inner join [dbo].[Product] p on oi.ProductId = p.ProductId
			where ord.CustomerId = @CustomerID
			group by ord.OrderId, p.ProductId, p.ProductName, oi.UnitPrice, oi.Quantity, p.Package, ord.TotalAmount

			-- Stores total amount spent by customer for all purchases.
			select @TotalAmountSpent = SUM(TotalAmount) from [dbo].[Order]
			where @CustomerID = CustomerId

			-- Stores the number of unique orders made by the customer.
			select COUNT(distinct OrderId) as Number_Of_Orders from [dbo].[Order]
			where @CustomerID = CustomerId

			-- Stores the customer royalty rank. Used a derived table to fetch the Rank.
			select tbl1.Customer_Loyalty_Rank from
				(select c.CustomerId, DENSE_RANK() over(order by (SUM(o.TotalAmount))desc) as Customer_Loyalty_Rank
				 from Customer c
				 inner join [dbo].[Order] o on c.CustomerId = o.CustomerId
				 group by c.CustomerId) as tbl1
			where tbl1.CustomerId = @CustomerID

			-- Used to specify success.
			return 0 
		end
	else
		begin
			-- If customer ID does not exist in database, the default total amount will be set to 0.00
			select 'Customer ID does not exist in database' as Error
			set @TotalAmountSpent = 0
			return 1 -- Used to specify failure.
		end
end
GO

-- Executing the procedure.
declare @Output decimal(10,2), @ReturnStatus int
execute @ReturnStatus = Customer_Purchase_Details_CustomerID 86, @Output output -- Pass customer ID here.
select @Output as Total_Amount_Spent, @ReturnStatus as Return_Status 
GO

-- 2) Stored proc to see the average cart value of each customer along with average cart value of all customers.
create proc Average_Cart_Value(@CustomerID int, @Overall_Cart_Value decimal(7,2) output)
as
begin
	if exists(select * from Customer where CustomerId = @CustomerID)
		begin
			-- Storing customer details
			select CustomerId, FirstName, LastName from Customer
			where CustomerId = @CustomerID

			-- Storing average cart value of the customer
			select cast(AVG(TotalAmount) as decimal(7,2)) as Current_CustomerID_Avg_Cart_Value from [dbo].[Order]
			where CustomerId = @CustomerID

			-- Storing overall average cart value for all customers
			select @Overall_Cart_Value = AVG(totalamount) from [dbo].[Order]

			return 0
		end
	else
		begin
			select 'Customer ID does not exist in database' as Error
			set @Overall_Cart_Value = 0
			return 1
		end
end
GO

-- Executing the procedure.
declare @Output decimal(7,2), @ReturnStatus int
execute @ReturnStatus = Average_Cart_Value 32, @Output output
select @Output as Average_Overall_Cart_Value_All_Customers, @ReturnStatus as Return_Status
GO

-- 3) Stored procedure to find the total revenue generated for the specified Year and Month.
create proc Year_Month_Revenue(@Year int, @Month int, @Revenue decimal(9,2) output)
as
begin
	if exists(select * from [dbo].[Order] where @Year = YEAR(OrderDate) and @Month = MONTH(OrderDate))
		begin
		    -- Storing the year and month.
			select distinct YEAR(OrderDate) as Year ,MONTH(OrderDate) as Month from [dbo].[Order]
			where @Year = YEAR(OrderDate) and @Month = MONTH(OrderDate)

			-- Storing the total revenue generated and return status.
			select @Revenue = SUM(TotalAmount) from [dbo].[Order]
			where @Year = YEAR(OrderDate) and @Month = MONTH(OrderDate)
			group by YEAR(OrderDate), MONTH(OrderDate)
			return 0
		end
	else
		begin
			set @Revenue = 0
			select 'The year and month combination does not exist within database.' as Error
			return 1
		end
end
GO

-- Executing the procedure.
declare @Output as decimal(9,2), @ReturnStatus as int
execute @ReturnStatus = Year_Month_Revenue 2014, 1, @Output output
select @Output as Total_Revenue_Generated, @ReturnStatus as ReturnStatus
GO

-- 4) All customers whos order amount is greater than the average order amount for all orders.
select * from customer c 
inner join [dbo].[Order] o on c.CustomerId = o.CustomerId 
where o.TotalAmount > (select AVG(TotalAmount) from [dbo].[Order]) -- Sub Query used to filter data only where total amount spent by a single customer is greater than the total avg amount spent by all customers
order by TotalAmount asc
GO

-- 5) The total number of suppliers from each country.
select Country, COUNT(distinct SupplierId) as Number_Of_Suppliers from Supplier -- COUNT Distinct only counts the unique number of supplier IDs.
group by Country
order by Number_Of_Suppliers desc
GO

-- 6) The total number of products supplied by each supplier where the IsDiscontinues flag is 0.
select case when s.CompanyName is null then 'TOTAL' else s.CompanyName end as Company_Name, -- Used case when to elimite the NULL and replace it with TOTAL
COUNT(p.ProductId) as Number_Of_Products, -- Counts the number of distinct products.
GROUPING(s.CompanyName) as Is_Grouped -- Displays 1 when row was grouped. Else displays 0.
from Product p 
inner join Supplier s on p.SupplierId = s.SupplierId
where p.IsDiscontinued = 0
group by rollup (s.CompanyName) -- Sums the total number of companies/suppliers.
order by Number_Of_Products asc
GO

-- 7) Rank the customer cities of each country based in the total sales generated.
select c.Country, c.City, 
sum(ord.TotalAmount) as Total_Amount, -- Total sales from grouped based on each Country and City.
DENSE_RANK() over(partition by c.Country order by sum(ord.TotalAmount) desc) as Rank -- Ranking function.
from Customer c
inner join [dbo].[Order] ord on c.CustomerId = ord.CustomerId
inner join [dbo].[OrderItem] oi on ord.OrderId = oi.OrderId
inner join [dbo].[Product] p on oi.ProductId = p.ProductId
inner join [dbo].[Supplier] s on p.SupplierId = s.SupplierId
group by c.Country, c.City
GO

-- 8) Rank the supplier cities of each country based on the total sales generated.
select s.Country, s.City, 
sum(ord.TotalAmount) as Total_Amount, -- Total sales from grouped based on each Country and City.
DENSE_RANK() over(partition by s.Country order by sum(ord.TotalAmount) desc) as Rank -- Ranking function.
from [dbo].[Order] ord 
inner join OrderItem oi on ord.OrderId = oi.OrderId
inner join Product p on oi.ProductId = p.ProductId
inner join Supplier s on p.SupplierId = s.SupplierId
group by s.Country, s.City
GO

-- 9) Check if the previous order made by a customer was more than the current order. Count the number of times the current order value was greater than previous order value.
with Table1 as -- Creating a temporary table
(select c.CustomerId, c.FirstName, o.OrderId, o.TotalAmount,
LEAD(o.TotalAmount) over(partition by c.CustomerID order by o.OrderId) as Next_Order_Value, -- Stores the next order amount made us the customer.
case when LEAD(o.TotalAmount) over(partition by c.CustomerID order by o.OrderId) > o.TotalAmount
		then 'Greater Order Value' 
	 when LEAD(o.TotalAmount) over(partition by c.CustomerID order by o.OrderId) is null 
		then 'NA'
	 else 'Lower Or Equal Order Value' 
	 end as Result -- Checks if current order amount was greater than previous order amount.
from Customer c 
inner join [dbo].[Order] o on c.CustomerId = o.CustomerId)
select Table1.*,
case when Table1.Result = 'Greater Order Value' then 1 else 0 end as Is_Greater_1, -- Storing 1 when amount was greater than previous order.
COUNT(Table1.OrderId) over(partition by CustomerId order by (select Null)) as Total_Number_Of_Orders, -- Finds total number of orders made by each customer.
SUM(case when Table1.Result = 'Greater Order Value' then 1 else 0 end) 
over(partition by CustomerID order by (select null)) as Count -- Adding the 1's to find the number of times the previous order was greater than current order.
from Table1
order by Table1.CustomerId
GO

-- 10) Top 5 most selling and least selling products, based on sales. 
select table1.* from
(select s.Country, p.ProductName, SUM(oi.UnitPrice * oi.Quantity) as Total_Amount, -- Derived table.
DENSE_RANK() over(Order by (SUM(oi.UnitPrice * oi.Quantity)) desc) as Product_Popularity_Revenue_Rank
from [dbo].[Order] o 
inner join OrderItem oi on o.OrderId = oi.OrderId 
inner join Product p on oi.ProductId = p.ProductId
inner join Supplier s on p.SupplierId = s.SupplierId
group by p.ProductName, s.Country) as Table1
where Table1.Product_Popularity_Revenue_Rank <= 5
GO

select table1.* from
(select s.Country, p.ProductName, SUM(oi.UnitPrice * oi.Quantity) as Total_Amount, -- Derived table
DENSE_RANK() over(Order by (SUM(oi.UnitPrice * oi.Quantity)) asc) as Product_Popularity_Revenue_Rank
from [dbo].[Order] o 
inner join OrderItem oi on o.OrderId = oi.OrderId 
inner join Product p on oi.ProductId = p.ProductId
inner join Supplier s on p.SupplierId = s.SupplierId
group by p.ProductName, s.Country) as Table1
where Table1.Product_Popularity_Revenue_Rank <= 5
GO

-- 11) Top 5 most selling and least selling products, based on units sold.
select Table1.* from
(select s.Country, p.ProductName, COUNT(oi.Quantity) as Number_Of_Units_Sold, -- Derived table
DENSE_RANK() over(Order by (COUNT(oi.Quantity)) desc) as Product_Popularity_UnitsSold_Rank
from [dbo].[Order] o 
inner join OrderItem oi on o.OrderId = oi.OrderId 
inner join Product p on oi.ProductId = p.ProductId
inner join Supplier s on p.SupplierId = s.SupplierId
group by s.Country, p.ProductName) as Table1
where Table1.Product_Popularity_UnitsSold_Rank <= 5
GO

select Table1.* from
(select s.Country, p.ProductName, COUNT(oi.Quantity) as Number_Of_Units_Sold, -- Derived table
DENSE_RANK() over(Order by (COUNT(oi.Quantity)) asc) as Product_Popularity_UnitsSold_Rank
from [dbo].[Order] o 
inner join OrderItem oi on o.OrderId = oi.OrderId 
inner join Product p on oi.ProductId = p.ProductId
inner join Supplier s on p.SupplierId = s.SupplierId
group by s.Country, p.ProductName) as Table1
where Table1.Product_Popularity_UnitsSold_Rank <= 5
GO


-- 12) View to see the number of order's made by each customer.
create view Number_Of_Orders_Per_Customer as
select top 100 percent c.CustomerId, -- Used top 100 percent as Order By clause will not work without it.
c.FirstName, c.LastName, COUNT(ord.OrderId) as Number_Of_Orders from Customer c 
inner join [dbo].[Order] ord on c.CustomerId = ord.CustomerId
group by c.CustomerId, c.FirstName, c.LastName
order by c.CustomerId, c.FirstName, c.LastName
GO

-- Calling the view.
select * from Number_Of_Orders_Per_Customer
GO

-- 13) Count of orders made in each month for each year in pivot table format.
with PivotTable as
	(select YEAR(OrderDate) as Order_Year, MONTH(OrderDate) as Order_Month, OrderId
	 from [dbo].[Order])
select Order_Year, [1] as January, [2] as February, [3] as March, [4] as April, [5] as May, [6] as June, [7] as July, 
	   [8] as August, [9] as September, [10] as October, [11] as November, [12] as December from PivotTable
pivot(Count(OrderId) for Order_Month in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as pvt
order by Order_Year
GO