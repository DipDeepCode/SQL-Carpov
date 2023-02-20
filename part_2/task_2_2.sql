-- my solution
SELECT date ,
       round(revenue / total_users, 2) as arpu ,
       round(revenue / active_users, 2) as arppu ,
       round(revenue / number_of_orders, 2) as aov
FROM   (SELECT date ,
               sum(price) as revenue ,
               count(distinct order_id) as number_of_orders
        FROM   (SELECT creation_time::date as date ,
                       unnest(product_ids) as product_id ,
                       order_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) as t1
            LEFT JOIN products using(product_id)
        GROUP BY date) as revenue_table
    LEFT JOIN (SELECT time::date as date ,
                      count(distinct user_id) as total_users
               FROM   user_actions
               GROUP BY time::date) as total_users_table using (date)
    LEFT JOIN (SELECT time::date as date ,
                      count(distinct user_id) as active_users
               FROM   user_actions
               WHERE  (order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order'))
               GROUP BY time::date) as active_users_table using(date)
ORDER BY date

-- right solution
SELECT date,
       round(revenue::decimal / users, 2) as arpu,
       round(revenue::decimal / paying_users, 2) as arppu,
       round(revenue::decimal / orders, 2) as aov
FROM   (SELECT creation_time::date as date,
               count(distinct order_id) as orders,
               sum(price) as revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN products using(product_id)
        GROUP BY date) t2
    LEFT JOIN (SELECT time::date as date,
                      count(distinct user_id) as users
               FROM   user_actions
               GROUP BY date) t3 using (date)
    LEFT JOIN (SELECT time::date as date,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t4 using (date)
ORDER BY date