-- my solution
SELECT 
    t1.date
    , ROUND (users_per_day::decimal / couriers_per_day, 2) AS users_per_courier
    , ROUND (order_per_date::decimal / couriers_per_day, 2) AS orders_per_courier
FROM
    (SELECT 
        time::date AS date
        , COUNT(DISTINCT user_id) AS users_per_day
    FROM user_actions 
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order')
    GROUP BY time::date) AS t1
LEFT JOIN
    (SELECT 
        time::date AS date
        , COUNT(DISTINCT courier_id) AS couriers_per_day
    FROM courier_actions
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY time::date) AS t2
USING (date)
LEFT JOIN 
    (SELECT 
        COUNT(order_id) AS order_per_date
        , creation_time::date AS date
    FROM orders
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY creation_time::date) AS t3
USING (date)
ORDER BY t1.date

-- right solution
SELECT date,
       round(paying_users::decimal / couriers, 2) as users_per_courier,
       round(orders::decimal / couriers, 2) as orders_per_courier
FROM   (SELECT time::date as date,
               count(distinct courier_id) as couriers
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) t1 join (SELECT creation_time::date as date,
                               count(distinct order_id) as orders
                        FROM   orders
                        WHERE  order_id not in (SELECT order_id
                                                FROM   user_actions
                                                WHERE  action = 'cancel_order')
                        GROUP BY date) t2 using (date) join (SELECT time::date as date,
                                            count(distinct user_id) as paying_users
                                     FROM   user_actions
                                     WHERE  order_id not in (SELECT order_id
                                                             FROM   user_actions
                                                             WHERE  action = 'cancel_order')
                                     GROUP BY date) t3 using (date)
ORDER BY date