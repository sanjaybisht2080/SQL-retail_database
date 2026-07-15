create database  retaildb_2 ;
use retaildb_2;
CREATE TABLE Customers (
 customer_id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 email VARCHAR(100),
 city VARCHAR(50),
 signup_date DATE
);

CREATE TABLE Suppliers (
 supplier_id INT AUTO_INCREMENT PRIMARY KEY,
 supplier_name VARCHAR(100),
 contact_email VARCHAR(100),
 city VARCHAR(50)
);

CREATE TABLE Products (
 product_id INT AUTO_INCREMENT PRIMARY KEY,
 product_name VARCHAR(100),
 category VARCHAR(50),
 price DECIMAL(10,2),
 stock_qty INT,
 supplier_id INT,
 FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);
CREATE TABLE Orders (
 order_id INT AUTO_INCREMENT PRIMARY KEY,
 customer_id INT,
 order_date DATE,
 total_amount DECIMAL(10,2),
 payment_mode VARCHAR(50),
 FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
 order_item_id INT AUTO_INCREMENT PRIMARY KEY,
 order_id INT,
 product_id INT,
 quantity INT,
 price_each int,
 FOREIGN KEY (order_id) REFERENCES Orders(order_id),
 FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

select*from order_items;
-- 1. Fetch all products along with their supplier name (INNER JOIN).

select
pp.product_name,ss.supplier_name
 from products as pp
inner join 
suppliers as ss
on pp.supplier_id = ss.supplier_id;

-- 2. Find all customers and their orders, even if they have not placed any (LEFT JOIN).

select cc.customer_id,cc.name, oo.order_id
from customers as cc
left join orders as oo
on cc.customer_id = oo.customer_id;

-- 3. Get all suppliers and the products they supply, even if no products exist for a supplier (RIGHT JOIN).

select  ss.supplier_id,ss.supplier_name, pp.product_name
from products as pp
right join suppliers as ss
on pp.supplier_id = ss.supplier_id;

-- 4. Show all customers and all orders (FULL OUTER JOIN simulation using UNION).

SELECT c.customer_id,
       c.name,
       o.order_id
FROM customers as c
LEFT JOIN orders as o
    ON c.customer_id = o.customer_id

UNION

SELECT c.customer_id,
       c.name,
       o.order_id
FROM customers as c
RIGHT JOIN orders as o
    ON c.customer_id = o.customer_id;
    
-- 5. List all products priced between ₹5000 and ₹50,000 and supplied from "Mumbai".

select p.product_name, p.price, s.city 
from products as p
inner join suppliers as s
on p.supplier_id= s.supplier_id
where p.price between 5000 and 50000
and lower(s.city) ='mumbai';

-- 6. Find the total number of orders placed by each customer and show only those 
-- who placed more than 2 (GROUP BY + HAVING).


select customer_id , count(customer_id) as total_orders from orders group by customer_id having total_orders>2;

-- 7. Show each supplier’s total sales value (sum of quantity × price_each).

SELECT p.supplier_id,
       SUM(oi.quantity * oi.price_each) AS total_sales_value
FROM order_items AS oi
INNER JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.supplier_id;

-- 8. Find the average, highest, and lowest price of products in each category.
select  category, avg(price), max(price), min(price)
from products
group by category;

-- 9. Find the top 5 customers by total spending (ORDER BY SUM(total_amount) DESC LIMIT 5).

select customer_id , sum(total_amount)as total_spending from orders group by customer_id order by total_spending desc limit 5 ;

-- 10.Show the number of unique products ordered by each customer.

select o.customer_id, count(distinct oi.product_id) as unique_product
from orders as o
inner join order_items as oi
on o.order_id=oi.order_id
group by o.customer_id;

-- 11.Find customers who placed an order with an amount greater than the average order amount (subquery).

 select customer_id, total_amount from orders where total_amount>(select avg(total_amount) from orders);
 
 -- 12.Find products that have never been ordered (subquery with NOT IN).

SELECT *FROM products
WHERE product_id NOT IN (SELECT product_id FROM order_items);

-- 13.List customers who ordered at least one product from the "Electronics" category.

select customer_id, name from customers 
	WHERE customer_id IN (
    SELECT o.customer_id
    FROM Orders o
    JOIN Order_items ot
        ON o.order_id = ot.order_id
    JOIN Products p
        ON ot.product_id = p.product_id
    WHERE p.category = 'Electronics'
);

-- 14.Get suppliers who provide products that have been ordered more than 100 times in total.

SELECT supplier_id, supplier_name
FROM suppliers
WHERE supplier_id IN (
    SELECT p.supplier_id
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.supplier_id
    HAVING SUM(oi.quantity) > 100
);

-- 15.Find the most expensive product(s) using a subquery with MAX().

SELECT product_id,
       product_name,
       price
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
);

-- 16.Show orders placed by customers who live in either Mumbai, Delhi, or Bengaluru (IN operator).

select * from orders where customer_id in 
(select customer_id from customers where city in ('mumbai','delhi','bengaluru'));

-- 17.Show orders where payment mode is NOT UPI or Credit Card (NOT IN).

select * from orders where payment_mode not in ('UPI', 'credit card');

-- 18.Find customers who have no email address recorded (IS NULL).

select * from customers where email is null;

-- 19.Show suppliers who are not from the same city as any customer (NOT IN subquery).

select supplier_id , supplier_name from suppliers where city not in (select city from customers);

-- 20.Get the latest 3 orders placed, skipping the first 2 (ORDER BY + LIMIT + OFFSET).

select * from orders order by order_date desc limit 3 offset 2 ;
