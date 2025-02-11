#Create database
CREATE DATABASE WalmartSales;

SHOW DATABASES; 
USE WalmartSales;
#Create table
CREATE TABLE sales(
       invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
       branch VARCHAR(5) NOT NULL,
       city VARCHAR(30) NOT NULL,
       customer_type VARCHAR(30) NOT NULL,
       gender VARCHAR(30) NOT NULL,
       product_line VARCHAR(100) NOT NULL,
       unit_price DECIMAL(10,2) NOT NULL,
       quantity INT NOT NULL,
       tax_pct FLOAT(6,4) NOT NULL,
       total DECIMAL(12,4) NOT NULL,
       date DATE NOT NULL,
       time TIMESTAMP NOT NULL,
       payment VARCHAR(15) NOT NULL,
       cogs DECIMAL(10,2) NOT NULL,
       gross_margin_pct FLOAT(11,9),
       gross_income DECIMAL(12,4),
       rating FLOAT(2,1)
);
SHOW TABLES;
SELECT * FROM sales;

##FEATURE ENGINEERING

#1)Add time_of_day column
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;
UPDATE sales
SET time_of_day = 
    CASE 
        WHEN HOUR (time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR (time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;    

#2)Add day_name column
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

#3)Add month_name column
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

##3)Exploratory Data Analysis(EDA)
#1)How many unique cities does the data have?
SELECT COUNT(DISTINCT city) AS unique_cities FROM sales;
#2)Which city has each branch?
SELECT branch, city FROM sales GROUP BY branch, city;
#3)Which part of the day has the most sales?
SELECT time_of_day, SUM(total) AS total_sales 
FROM sales
GROUP BY time_of_day 
ORDER BY total_sales DESC;
#4)Which day of the week is the busiest for each branch?
SELECT branch, day_name, COUNT(*) AS total_sales
FROM sales 
GROUP BY branch, day_name 
ORDER BY total_sales DESC;
#5)Which month has the most sales and profit?
SELECT month_name, SUM(total) AS total_sales 
FROM sales
GROUP BY month_name 
ORDER BY total_sales DESC;

## Conclusion:
#1) The given data have 3 unique cities.
#2) 'Yangon','Naypyitaw' & 'Mandalay' cities has each branch which is 'A','C'&'B' respectively.
#3)  At 'Afternoon' time of the day has most sales which is 171530.8560.
#4) 'Saturday' (total_sales=60) of the week is the busiest for each branch .
#5) January (total_sales=116291.8680) month has the most sales & profit.

## Business Questions To Answer
### Generic Question
#1. How many unique cities does the data have?
SELECT COUNT(DISTINCT city) AS unique_cities FROM sales;
#Ans: The data have 3 unique cities.
#2. In which city is each branch?
SELECT branch, city FROM sales GROUP BY branch, city;
#Ans : 'Yangon','Naypyitaw' & 'Mandalay' cities has each branch which is 'A','C'&'B' respectively.

### Product Analysis
#1. How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) AS unique_product_lines 
FROM sales;
#Ans: There are 6 unique product line does the data have.

SELECT * FROM sales;
#2. What is the most common payment method?
SELECT payment, COUNT(payment) AS count
FROM sales
GROUP BY payment
ORDER BY count DESC
LIMIT 1;
#Ans: The most common payment method is 'Cash'(count=344)

#3.3. What is the most selling product line?
SELECT product_line, COUNT(*) AS total_sold
FROM sales
GROUP BY product_line
ORDER BY total_sold DESC
LIMIT 1;
#Ans : Fashion accessories(total_sold = 178) is the most selling product line.

#4. What is the total revenue by month?
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;
#Ans: January(total_revenue=116291.8680) , March (total_revenue=108867.1500) & Februarytotal_revenue=95727.3765)

#5. What month had the largest COGS?
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;
#Ans : January month had largest cogs which is 110754.16 .

#6. What product line had the largest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;
#Ans : 'Food and beverages' product_line had largest revenue which is 56144.8440 . 

#7. What is the city with the largest revenue?
SELECT city, SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;
#Ans : 'Naypyitaw' city had largest revenue which is 110490.7755 .
SELECT * FROM sales;
#8.What product line had the largest VAT?
SELECT product_line, SUM(tax_pct) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;
#Ans : 'Food and beverages' product_line had largest VAT which is 2673.5640 . 

#9.. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line,
       SUM(total) AS total_sales,
       CASE 
           WHEN SUM(total) > (SELECT AVG(total) FROM sales) THEN 'Good'
           ELSE 'Bad'
       END AS sales_performance
FROM sales
GROUP BY product_line;
#Ans : Food and beverages(total_sales=56144.8440),Health and beautytotal_sales=48854.3790)etc has good sales performance

#10.. Which branch sold more products than average product sold?
SELECT branch, COUNT(*) AS total_products_sold
FROM sales
GROUP BY branch
HAVING total_products_sold > (SELECT AVG(product_count) FROM 
                             (SELECT COUNT(*) AS product_count FROM sales GROUP BY branch) AS avg_sales);
#Ans : "A"(total_product_sold=339) branch sold more product than average product sold.

#11.What is the most common product line by gender?
SELECT gender, product_line, COUNT(*) AS total_count
FROM sales
GROUP BY gender, product_line
ORDER BY gender, total_count DESC;
#Ans : 'Fashion accessories' is the most common product_line by gender 'Female'(total_count=96)

#12.What is the average rating of each product line?
SELECT product_line, AVG(rating) AS average_rating
FROM sales
GROUP BY product_line
ORDER BY average_rating DESC;
#Ans :'Food and beverages' is the most common average_rating(7.11322)

### Sales Analysis
#1. Number of sales made in each time of the day per weekday
SELECT day_name, time_of_day, COUNT(*) AS total_sales
FROM sales
GROUP BY day_name, time_of_day
ORDER BY day_name, total_sales DESC;

#2.Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;
#Ans : 'Member' customer_type has the most common revenue.(total_revenue=163625.1015)

#3.Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT city, AVG(tax_pct) AS avg_vat
FROM sales
GROUP BY city
ORDER BY avg_vat DESC
LIMIT 1;
#Ans : 'Naypyitaw' city has the largest avg_vat(16.09010850)

#4.Which customer type pays the most in VAT?
SELECT customer_type, SUM(tax_pct) AS total_vat_paid
FROM sales
GROUP BY customer_type
ORDER BY total_vat_paid DESC
LIMIT 1;
#Ans : 'Member' customer_type pays the most in vat(total_vat_paid=7791.6715)

### Customer Analysis
#1. How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) AS unique_customer_types 
FROM sales;
#Ans : There are '2' unique customer type in the given data.
SELECT * FROM sales;
#2. How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) AS unique_payment_methods 
FROM sales;
#Ans : There are '3' unique payment methods in the given data.

#3. What is the most common customer type?
SELECT customer_type, COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;
#Ans : 'Member'(count=499) is the most common customer_type.  

#4.Which customer type buys the most?
SELECT customer_type, SUM(total) AS total_purchases
FROM sales
GROUP BY customer_type
ORDER BY total_purchases DESC
LIMIT 1;
#Ans : 'Member'(total_purchases=163625.1015) customer_type buys the most.

#5. What is the gender of most of the customers?
SELECT gender, COUNT(*) AS total_customers
FROM sales
GROUP BY gender
ORDER BY total_customers DESC
LIMIT 1;
#Ans : In 'Male' gender there are the most customers(total_customers=498)

#6. What is the gender distribution per branch? 
SELECT branch, gender, COUNT(*) AS total_customers
FROM sales
GROUP BY branch, gender
ORDER BY branch, total_customers DESC;
#Ans: 'A' branch ;gender:Male has most customers(total_customers=179

#7. Which time of the day do customers give most ratings?
SELECT time_of_day, COUNT(rating) AS total_ratings
FROM sales
GROUP BY time_of_day
ORDER BY total_ratings DESC
LIMIT 1;
#Ans: Customer gives the most rating(total_ratings=525) in the 'Afternoon' time of the day.

#8. Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, COUNT(rating) AS total_ratings
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, total_ratings DESC;
#Ans : Customer gives the most rating(total_ratings=184) at the 'Afternoon' time of the day by the branch 'A'.

#9. Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;
#Ans: 'Monday' of the week has the best avg rating which is 7.13065.

#10. Which day of the week has the best average ratings per branch?
SELECT branch, day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;
#Ans: 'Friday'(avg_rating = 7.31200) is the best average rating by branch 'A'. 

### Revenue And Profit Calculations:

#1. Calculate COGS (Cost of Goods Sold):
SELECT product_line, (unit_price * quantity) AS COGS12
FROM sales;

#2. Calculate VAT (5% of COGS):
SELECT product_line, (unit_price * quantity) AS COGS, 
       (0.05 * (unit_price * quantity)) AS VAT
FROM sales;

#3. Calculate Total Revenue (Gross Sales):
SELECT product_line, 
       (unit_price * quantity) AS COGS, 
       (0.05 * (unit_price * quantity)) AS VAT,
       ((unit_price * quantity) + (0.05 * (unit_price * quantity))) AS total_revenue
FROM sales;
#4. Calculate Gross Profit:
SELECT product_line, 
       (unit_price * quantity) AS COGS, 
       (0.05 * (unit_price * quantity)) AS VAT,
       ((unit_price * quantity) + (0.05 * (unit_price * quantity))) AS total_revenue,
       ((0.05 * (unit_price * quantity))) AS gross_profit
FROM sales;

#5. Calculate Gross Margin Percentage:
SELECT product_line, 
       (unit_price * quantity) AS COGS, 
       (0.05 * (unit_price * quantity)) AS VAT,
       ((unit_price * quantity) + (0.05 * (unit_price * quantity))) AS total_revenue,
       ((0.05 * (unit_price * quantity))) AS gross_profit,
       ( (0.05 * (unit_price * quantity)) / ((unit_price * quantity) + (0.05 * (unit_price * quantity))) ) * 100 
       AS gross_margin_percentage
FROM sales;

SELECT * FROM sales;

#UPDATE TABLE & STORE VALUES:
ALTER TABLE sales
ADD COLUMN COGS12 DECIMAL(10,2),
ADD COLUMN VAT DECIMAL(10,2),
ADD COLUMN total_revenue DECIMAL(10,2),
ADD COLUMN gross_profit DECIMAL(10,2),
ADD COLUMN gross_margin_percentage DECIMAL(10,2);

UPDATE sales
SET COGS12 = (unit_price * quantity),
    VAT = (0.05 * COGS),
    total_revenue = (COGS + VAT),
    gross_profit = VAT,
    gross_margin_percentage = (gross_profit / total_revenue) * 100;



