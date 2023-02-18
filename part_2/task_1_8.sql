-- my solution
WITH joins AS 
    (SELECT 
        creation_time
        , t2.action AS courier_action
        , t3.action AS user_action
    FROM orders AS t1
    LEFT JOIN courier_actions AS t2 ON t1.order_id = t2.order_id
    LEFT JOIN user_actions AS t3 ON t1.order_id = t3.order_id
    )
SELECT 
    hour
    , successful_orders
    , canceled_orders
    , ROUND(canceled_orders::numeric / (successful_orders + canceled_orders), 3) AS cancel_rate
FROM 
    (SELECT
        DATE_PART('hour', creation_time)::INT AS hour
        , COUNT(user_action) AS canceled_orders
    FROM joins
    WHERE user_action = 'cancel_order'
    GROUP BY DATE_PART('hour', creation_time)) t4
LEFT JOIN
    (SELECT
        DATE_PART('hour', creation_time)::INT AS hour
        , COUNT(courier_action) AS successful_orders
    FROM joins
    WHERE courier_action = 'deliver_order'
    GROUP BY DATE_PART('hour', creation_time)) t5 USING (hour)
ORDER BY hour

-- right solution
SELECT hour,
       successful_orders,
       canceled_orders,
       round(canceled_orders::decimal / (successful_orders + canceled_orders),
             3) as cancel_rate
FROM   (SELECT date_part('hour', creation_time)::int as hour,
               count(order_id) as successful_orders
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY hour) t1
    LEFT JOIN (SELECT date_part('hour', creation_time)::int as hour,
                      count(order_id) as canceled_orders
               FROM   orders
               WHERE  order_id in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
               GROUP BY hour) t2 using (hour)
ORDER BY hour