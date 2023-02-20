-- my solution
SELECT 
    date
    , round(sum(revenue) OVER (ORDER BY date) / sum(total_users) OVER (ORDER BY date), 2) AS running_arpu
    , round(sum(revenue) OVER (ORDER BY date) / sum(active_users) OVER (ORDER BY date), 2) AS running_arppu
    , round(sum(revenue) OVER (ORDER BY date) / sum(number_of_orders) OVER (ORDER BY date), 2) AS running_aov
FROM (  SELECT 
            date
            , sum(price) AS revenue
            , count(distinct order_id) AS number_of_orders
        FROM (SELECT 
                  creation_time::date AS date
                  , unnest(product_ids) AS product_id
                  , order_id
              FROM orders
              WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
        LEFT JOIN products using(product_id)
        GROUP BY date) AS revenue_table
LEFT JOIN ( SELECT
                date
                , count(distinct user_id) AS total_users
            FROM (
                SELECT 
                    user_id
                    , MIN(time::date) AS date
                FROM user_actions
                GROUP BY user_id) AS t2
            GROUP BY date) AS total_users_table using (date)
LEFT JOIN ( SELECT
                date
                , count(distinct user_id) AS active_users
            FROM (  SELECT 
                        user_id
                        , MIN(time::date) AS date
                    FROM user_actions
                    WHERE (order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order'))
                    GROUP BY user_id) AS t3
            GROUP BY date) AS active_users_table using(date)

-- right solution
SELECT date,
       round(sum(revenue) OVER (ORDER BY date)::decimal / sum(new_users) OVER (ORDER BY date),
             2) as running_arpu,
       round(sum(revenue) OVER (ORDER BY date)::decimal / sum(new_paying_users) OVER (ORDER BY date),
             2) as running_arppu,
       round(sum(revenue) OVER (ORDER BY date)::decimal / sum(orders) OVER (ORDER BY date),
             2) as running_aov
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
    LEFT JOIN (SELECT date,
                      count(user_id) as new_users
               FROM   (SELECT user_id,
                              min(time::date) as date
                       FROM   user_actions
                       GROUP BY user_id) t5
               GROUP BY date) t6 using (date)
    LEFT JOIN (SELECT date,
                      count(user_id) as new_paying_users
               FROM   (SELECT user_id,
                              min(time::date) as date
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY user_id) t7
               GROUP BY date) t8 using (date)