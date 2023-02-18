-- my solution
SELECT 
    t1.accept_order_time::date AS date
    , CEIL(AVG(DATE_PART('minute', deliver_order_time - accept_order_time))::decimal)::INT AS minutes_to_deliver
FROM
    (SELECT 
        order_id
        , time AS accept_order_time
    FROM courier_actions
    WHERE action = 'accept_order') AS t1
LEFT JOIN
    (SELECT 
        order_id
        , time AS deliver_order_time
    FROM courier_actions
    WHERE action = 'deliver_order') AS t2
ON t1.order_id = t2.order_id
WHERE t1.order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
GROUP BY t1.accept_order_time::date
ORDER BY t1.accept_order_time::date

-- right solution
SELECT date,
       round(avg(delivery_time))::int as minutes_to_deliver
FROM   (SELECT order_id,
               max(time::date) as date,
               extract(epoch FROM max(time) - min(time))/60 as delivery_time
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY order_id) t
GROUP BY date
ORDER BY date