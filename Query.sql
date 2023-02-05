-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT t2.region, t3.rep, t2.top_sales
FROM (SELECT region, MAX(total_sales) top_sales
      FROM (SELECT r.name region, s.name rep, SUM(o.total_amt_usd) total_sales
            FROM region r
            JOIN sales_reps s
            ON r.id = s.region_id
            JOIN accounts a
            ON s.id = a.sales_rep_id
            JOIN orders o
            ON a.id = o.account_id
            GROUP BY 1, 2
            ORDER BY 1, 3 DESC) t1
      GROUP BY 1
      ORDER BY 2 DESC) t2
JOIN (SELECT r.name region, s.name rep, SUM(o.total_amt_usd) total_sales
      FROM region r
      JOIN sales_reps s
      ON r.id = s.region_id
      JOIN accounts a
      ON s.id = a.sales_rep_id
      JOIN orders o
      ON a.id = o.account_id
      GROUP BY 1, 2
      ORDER BY 1, 3 DESC) t3
ON t2.region = t3.region AND t2.top_sales = t3.total_sales;

-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed? 
SELECT r.name region, COUNT(o.id) orders_placed
FROM region r
JOIN sales_reps s
ON r.id = s.region_id AND r.name = (SELECT region
                                    FROM (SELECT r.name region, SUM(o.total_amt_usd) sales
                                          FROM region r
                                          JOIN sales_reps s
                                          ON r.id = s.region_id
                                          JOIN accounts a
                                          ON s.id = a.sales_rep_id
                                          JOIN orders o
                                          ON a.id = o.account_id
                                          GROUP BY 1
                                          ORDER BY 2 DESC
                                          LIMIT 1) t1)
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1;

/* How many accounts had more total purchases than the account name which has bought the most standard_qty paper
throughout their lifetime as a customer? */
SELECT COUNT(*)
FROM (SELECT account_id, SUM(total) total_qty
      FROM orders
      GROUP BY 1
      HAVING total_qty > (SELECT total_qty
                          FROM (SELECT account_id, SUM(standard_qty) total_standard_qty, SUM(total) total_qty
                                FROM orders
	                            GROUP BY 1
                                ORDER BY 2 DESC
                                LIMIT 1) t1)
      ORDER BY 2 DESC) t2;
      
/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events
did they have for each channel? */
SELECT t2.name, t4.channel, t4.num_of_web_events
FROM (SELECT id, name
      FROM accounts
      WHERE id = (SELECT account_id
				  FROM (SELECT account_id, SUM(total_amt_usd)
                        FROM orders
                        GROUP BY 1
				        ORDER BY 2 DESC
                        LIMIT 1) t1)) t2
JOIN (SELECT account_id, channel, COUNT(id) num_of_web_events
      FROM web_events
      WHERE account_id = (SELECT account_id
                          FROM (SELECT account_id, SUM(total_amt_usd)
                                FROM orders
                                GROUP BY 1
						        ORDER BY 2 DESC
                                LIMIT 1) t3)
      GROUP BY 1, 2
      ORDER BY 3 DESC) t4
ON t2.id = t4.account_id;

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT AVG(t1.total_amt_avg) lifetime_avg
FROM (SELECT account_id, SUM(total_amt_usd) total_amt_avg
      FROM orders
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10) t1;
      
/* What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per
order, on average, than the average of all orders. */
SELECT AVG(t1.total_avg_amt) lifetime_avg
FROM (SELECT account_id, AVG(total_amt_usd) total_avg_amt
	  FROM orders
      GROUP BY 1
      HAVING AVG(total_amt_usd) > (SELECT AVG(total_amt_usd)
                                   FROM orders)
      ORDER BY 2 DESC) t1;