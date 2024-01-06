CREATE DATABASE Walmart;

USE Walmart;
-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


SELECT * FROM walmart.sales;
SELECT * FROM sales;

SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

USE Walmart;
-- How many unique customer types does the data have?
SELECT 
    customer_type, 
    COUNT(*) AS unique_customer
FROM sales
GROUP BY customer_type;


-- How many unique payment methods does the data have?
SELECT
	payment AS pay_method, COUNT(payment) AS total_pay
FROM sales
GROUP BY payment;


-- What is the most common customer type?
SELECT
    customer_type,
    COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*) AS count
FROM sales
GROUP BY customer_type ORDER BY count DESC
LIMIT 1;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC LIMIT 1;

-- What is the gender distribution per branch?
SELECT
    branch,
    gender,
    COUNT(*) AS gender_count
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender_count DESC;


-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT
    branch,
    time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
    branch,
    DAYNAME(date) AS day_of_week,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, day_of_week
ORDER BY branch, avg_rating DESC;



SELECT branch, day_of_week, avg_rating
FROM (
    SELECT
        branch,
        DAYNAME(date) AS day_of_week,
        AVG(rating) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rn
    FROM sales
    GROUP BY branch, day_of_week
) ranked
WHERE rn = 1;


-- Number of sales made in each time of the day per weekday 

SELECT
    DAYNAME(date) AS day_of_week,
    time_of_day,
    COUNT(*) AS total_sales
FROM sales
GROUP BY day_of_week, time_of_day
ORDER BY day_of_week, total_sales DESC;

-- Which of the customer types brings the most revenue?

SELECT
    customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax DESC;