-- my solution
SELECT 
    weekday
    , weekday_number
    , round(revenue / total_users, 2) AS arpu
    , round(revenue / active_users, 2) AS arppu
    , round(revenue / number_of_orders, 2) AS aov
FROM (
    SELECT
        DATE_PART('isodow', date) AS weekday_number
        , to_char(date, 'Day') AS weekday
        , sum(price) AS revenue
        , count(distinct order_id) AS number_of_orders
    FROM (SELECT 
            creation_time::date AS date
            , unnest(product_ids) AS product_id
            , order_id
        FROM orders 
        WHERE (creation_time BETWEEN '2022-08-26' AND '2022-09-09') AND order_id NOT IN (SELECT order_id FROM user_actions WHERE  action = 'cancel_order')) AS t1
    LEFT JOIN products using (product_id)
    GROUP BY DATE_PART('isodow', date), weekday) AS t2
LEFT JOIN (
    SELECT
        weekday_number
        , count(distinct user_id) AS total_users
    FROM (
        SELECT 
            time
            , user_id
            , DATE_PART('isodow', time) AS weekday_number
        FROM user_actions
        WHERE time BETWEEN '2022-08-26' AND '2022-09-09') AS t3
    GROUP BY weekday_number) AS t4 using (weekday_number)
LEFT JOIN (
    SELECT
        weekday_number
        , count(distinct user_id) AS active_users
    FROM (
        SELECT 
            time
            , user_id
            , DATE_PART('isodow', time) AS weekday_number
        FROM user_actions
        WHERE (time BETWEEN '2022-08-26' AND '2022-09-09') AND order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t4
    GROUP BY weekday_number) AS t5 using (weekday_number)
ORDER BY weekday_number


-- right solution
SELECT weekday,
       t1.weekday_number as weekday_number,
       round(revenue::decimal / users, 2) as arpu,
       round(revenue::decimal / paying_users, 2) as arppu,
       round(revenue::decimal / orders, 2) as aov
FROM   (SELECT to_char(creation_time, 'Day') as weekday,
               max(date_part('isodow', creation_time)) as weekday_number,
               count(distinct order_id) as orders,
               sum(price) as revenue
        FROM   (SELECT order_id,
                       creation_time,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
                   and creation_time >= '2022-08-26'
                   and creation_time < '2022-09-09') t4
            LEFT JOIN products using(product_id)
        GROUP BY weekday) t1
    LEFT JOIN (SELECT to_char(time, 'Day') as weekday,
                      max(date_part('isodow', time)) as weekday_number,
                      count(distinct user_id) as users
               FROM   user_actions
               WHERE  time >= '2022-08-26'
                  and time < '2022-09-09'
               GROUP BY weekday) t2 using (weekday)
    LEFT JOIN (SELECT to_char(time, 'Day') as weekday,
                      max(date_part('isodow', time)) as weekday_number,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
                  and time >= '2022-08-26'
                  and time < '2022-09-09'
               GROUP BY weekday) t3 using (weekday)
ORDER BY weekday_number