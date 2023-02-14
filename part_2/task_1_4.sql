-- my solution 1
SELECT
    date
    , ROUND (100 * one::decimal / (one + more), 2) AS single_order_users_share
    , ROUND (100 * more::decimal / (one + more), 2) AS several_orders_users_share
FROM (
    SELECT 
        date
        , SUM (CASE WHEN number_of_user_orders_per_day = 1 THEN 1 ELSE 0 END) AS one
        , SUM (CASE WHEN number_of_user_orders_per_day > 1 THEN 1 ELSE 0 END) AS more
    FROM (
        SELECT
            time::date AS date
            , user_id
            , COUNT (user_id) AS number_of_user_orders_per_day
        FROM user_actions
        WHERE order_id NOT IN (
            SELECT 
                order_id
            FROM user_actions
            WHERE action LIKE 'cancel_order'
            )
        GROUP BY time::date, user_id
        ) AS t1
    GROUP BY date
    ) AS t2
ORDER BY date


-- right solution
SELECT date,
       round(100 * single_order_users::decimal / paying_users,
             2) as single_order_users_share,
       100 - round(100 * single_order_users::decimal / paying_users,
                   2) as several_orders_users_share
FROM   (SELECT time::date as date,
               count(distinct user_id) as paying_users
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) t1
    LEFT JOIN (SELECT date,
                      count(user_id) as single_order_users
               FROM   (SELECT time::date as date,
                              user_id,
                              count(distinct order_id) as user_orders
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY date, user_id having count(distinct order_id) = 1) t2
               GROUP BY date) t3 using (date)
ORDER BY date