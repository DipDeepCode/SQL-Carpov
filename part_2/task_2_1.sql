-- my solution
SELECT date ,
       revenue ,
       sum(revenue) OVER(ORDER BY date) as total_revenue ,
       round(100 * (revenue - lag(revenue) OVER()) / lag(revenue) OVER(), 2) as revenue_change
FROM   (SELECT creation_time::date as date ,
               sum(price) as revenue
        FROM   (SELECT order_id ,
                       creation_time::date ,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) as unnest_orders
            LEFT JOIN products
                ON unnest_orders.product_id = products.product_id
        GROUP BY creation_time::date) as t1
ORDER BY date

-- right solution
SELECT date,
       revenue,
       sum(revenue) OVER (ORDER BY date) as total_revenue,
       round(100 * (revenue - lag(revenue, 1) OVER (ORDER BY date))::decimal / lag(revenue, 1) OVER (ORDER BY date),
             2) as revenue_change
FROM   (SELECT creation_time::date as date,
               sum(price) as revenue
        FROM   (SELECT creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using (product_id)
        GROUP BY date) t2