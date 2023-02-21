-- my solution
SELECT 
    date
    , revenue
    , new_users_revenue
    , round(100 * new_users_revenue / revenue, 2) AS new_users_revenue_share
    , 100 - round(100 * new_users_revenue / revenue, 2) AS old_users_revenue_share
FROM (  SELECT
            date
            , SUM(price) AS new_users_revenue
        FROM (  SELECT
                    date
                    , unnest(product_ids) AS product_id
                FROM (  SELECT 
                            t1.date
                            , t1.user_id
                            , order_id
                        FROM (  SELECT 
                                    user_id
                                    , MIN(time::date) AS date
                                FROM user_actions
                                GROUP BY user_id) AS t1
                        LEFT JOIN ( SELECT  
                                        time::date AS date
                                        , user_id
                                        , order_id
                                    FROM user_actions
                                    WHERE  (order_id not in (SELECT order_id FROM user_actions WHERE  action = 'cancel_order'))) AS t2 
                        ON t1.user_id = t2.user_id AND t1.date = t2.date) AS t3
                LEFT JOIN ( SELECT
                                order_id
                                , product_ids
                            FROM orders) AS t4
                using(order_id)) AS t5
        LEFT JOIN products using(product_id)
        GROUP BY date) AS t6
LEFT JOIN ( SELECT date
                   , sum(price) as revenue
            FROM (  SELECT 
                        creation_time::date as date
                        , unnest(product_ids) as product_id
                    FROM orders
                    WHERE order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t7
            LEFT JOIN products using(product_id)
            GROUP BY date) AS t8
using(date)
ORDER BY date

-- right solution
SELECT date,
       revenue,
       new_users_revenue,
       round(new_users_revenue / revenue * 100, 2) as new_users_revenue_share,
       100 - round(new_users_revenue / revenue * 100, 2) as old_users_revenue_share
FROM   (SELECT creation_time::date as date,
               sum(price) as revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t3
            LEFT JOIN products using (product_id)
        GROUP BY date) t1
    LEFT JOIN (SELECT start_date as date,
                      sum(revenue) as new_users_revenue
               FROM   (SELECT t5.user_id,
                              t5.start_date,
                              coalesce(t6.revenue, 0) as revenue
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t5
                           LEFT JOIN (SELECT user_id,
                                             date,
                                             sum(order_price) as revenue
                                      FROM   (SELECT user_id,
                                                     time::date as date,
                                                     order_id
                                              FROM   user_actions
                                              WHERE  order_id not in (SELECT order_id
                                                                      FROM   user_actions
                                                                      WHERE  action = 'cancel_order')) t7
                                          LEFT JOIN (SELECT order_id,
                                                            sum(price) as order_price
                                                     FROM   (SELECT order_id,
                                                                    unnest(product_ids) as product_id
                                                             FROM   orders
                                                             WHERE  order_id not in (SELECT order_id
                                                                                     FROM   user_actions
                                                                                     WHERE  action = 'cancel_order')) t9
                                                         LEFT JOIN products using (product_id)
                                                     GROUP BY order_id) t8 using (order_id)
                                      GROUP BY user_id, date) t6
                               ON t5.user_id = t6.user_id and
                                  t5.start_date = t6.date) t4
               GROUP BY start_date) t2 using (date)