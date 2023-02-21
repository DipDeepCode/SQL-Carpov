-- my solution
SELECT
    name AS product_name
    , sum(revenue) AS revenue
    , sum(share_in_revenue) AS share_in_revenue
FROM (  SELECT
            CASE WHEN share_in_revenue < 0.5 THEN 'ДРУГОЕ' ELSE name END AS name
            , revenue
            , share_in_revenue
        FROM (  SELECT 
                    name
                    , count(product_id) * price AS revenue
                    , round(100 * (count(product_id) * price) / (sum(count(product_id) * price) OVER()), 2) AS share_in_revenue
                FROM (  SELECT 
                            unnest(product_ids) AS product_id
                        FROM orders
                        WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
                LEFT JOIN products AS t2 using(product_id)
                GROUP BY product_id, name, price) AS t1) AS t2
GROUP BY name
ORDER BY revenue DESC

-- right solution
SELECT product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   (SELECT case when round(100 * revenue / sum(revenue) OVER (), 2) >= 0.5 then name
                    else 'ДРУГОЕ' end as product_name,
               revenue,
               round(100 * revenue / sum(revenue) OVER (), 2) as share_in_revenue
        FROM   (SELECT name,
                       sum(price) as revenue
                FROM   (SELECT order_id,
                               unnest(product_ids) as product_id
                        FROM   orders
                        WHERE  order_id not in (SELECT order_id
                                                FROM   user_actions
                                                WHERE  action = 'cancel_order')) t1
                    LEFT JOIN products using(product_id)
                GROUP BY name) t2) t3
GROUP BY product_name
ORDER BY revenue desc