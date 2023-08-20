# SQL Project 2 - Exploratory Data Analysis - Northwind Traders Data Analysis.

## Complete code attached - Northwind Traders Data Analysis.sql

## Microsoft Power BI Dashboard.
### 1) Products & Categories
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/d7ed82d4-8db7-4555-a422-b627a5f95c63)

### 2) Customers
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/b86119bd-e5b3-4c19-938a-ee4ac2e2f3ba)

### 3) Employees
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/963458e9-6ecf-4159-b09f-90c7b6072ce7)

### 4) Sales
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/0ffea64c-f03f-406b-ac71-2001eb282ac0)

## Data Insights Using SQL.
### 1) Stored procedure to find the customer details, product purchased details, customer loyalty rank, and total amount spent on all products.
#### Executing the procedure.
declare @Output decimal(10,2), @ReturnStatus int\
execute @ReturnStatus = Customer_Purchase_Details_CustomerID 86, @Output output -- Pass customer ID here.\
select @Output as Total_Amount_Spent, @ReturnStatus as Return_Status\
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/657ceba5-951d-4f86-994d-5ba24c7185bc)


### 2) Stored proc to see the average cart value of each customer along with the average cart value of all customers.
#### Executing the procedure.
declare @Output decimal(7,2), @ReturnStatus int\
execute @ReturnStatus = Average_Cart_Value 32, @Output output\
select @Output as Average_Overall_Cart_Value_All_Customers, @ReturnStatus as Return_Status\
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/a896576c-ad71-4acc-87a6-af06339c4c35)

### 3) Stored procedure to find the total revenue generated for the specified Year and Month.
#### Executing the procedure.
declare @Output as decimal(9,2), @ReturnStatus as int\
execute @ReturnStatus = Year_Month_Revenue 2014, 1, @Output output\
select @Output as Total_Revenue_Generated, @ReturnStatus as ReturnStatus\
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/9fac8a89-4402-4d57-aefc-d78ddddc6597)

### 4) All customers whose order amount is greater than the average order amount for all orders.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/d1c8f2f4-3e0e-49ca-abd0-0a1c38ac1c3a)
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/dcb12843-c818-4a70-9d3a-506b7dad579a)\

### 5) The total number of suppliers from each country.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/f410dc8f-4a7d-4796-aa52-4c4c90266e68)

### 6) The total number of products supplied by each supplier where the IsDiscontinues flag is 0.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/845a795c-709a-4137-8e1d-dcd623711976)

### 7) Rank the customer cities of each country based on the total sales generated.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/ee52d3e1-03d4-4c5e-9ffb-45e15a4086f2)
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/b1057b30-b1a4-4dd5-a6db-d1a956ef468e)

### 8) Rank the supplier cities of each country based on the total sales generated.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/80ab33c0-e9e3-4bd3-8543-474823bdd378)

### 9) Check if the previous order made by a customer was more than the current order. Count the number of times the current order value was greater than the previous order value.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/20fa382e-2cbc-4a68-9d25-aff51e46e36d)

### 10) Top 5 most selling and least selling products, based on sales. 
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/a8ba18c8-7936-4017-a8b9-afdefca32be2)

### 11) Top 5 most selling and least selling products, based on units sold.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/cab730c9-8f0d-40f4-8615-b6d960fb6231)

### 12) View to see the number of orders made by each customer.
#### Calling the view.
select * from Number_Of_Orders_Per_Customer\
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/19399d78-33e8-4d1b-ad90-e8f9867b07d6)

### 13) Count of orders made in each month for each year in pivot table format.
![image](https://github.com/JoshuaSequeira2000/SQL-Project-2-Northwind-Traders-Data-Analysis/assets/92262753/3f3cd44e-681f-451b-84a7-18122ef72b8d)

