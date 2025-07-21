-- 1 let's create a view, baby!
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
SELECT * FROM customer_rental_summary;

-- 2 make a temp table
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    crs.first_name,
    crs.last_name,
    crs.email,
    crs.rental_count,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY 
    crs.customer_id,
    crs.first_name,
    crs.last_name,
    crs.email,
    crs.rental_count;
 SELECT * FROM customer_payment_summary;
 
 -- 3 CTE and a customer service report
 WITH customer_cte AS (
    SELECT 
        cps.first_name,
        cps.last_name,
        cps.email,
        cps.rental_count,
        cps.total_paid
    FROM customer_payment_summary cps
    JOIN customer_rental_summary crs 
        ON cps.customer_id = crs.customer_id
)
SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_cte
ORDER BY total_paid DESC;