-- my solution

-- Для решения задачи сначала необходимо для каждого дня отдельно рассчитать общее число заказов
SELECT
    time::date AS date
    , COUNT(order_id) AS orders
FROM user_actions
WHERE order_id NOT IN (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
    )
GROUP BY time::date
ORDER BY date
LIMIT 1000

-- число первых заказов и число заказов новых пользователей, а затем объединить полученные таблицы в одну

-- Для расчёта числа первых заказов сперва для каждого пользователя нужно найти дату оформления первого неотменённого заказа
-- и затем произвести группировку по дате, посчитав для каждого дня количество пользователей, сделавших первый заказ.
SELECT
    date
    , COUNT(user_id) AS first_orders
FROM (
    SELECT 
        user_id
        , MIN(time::date) AS date
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order')
    GROUP BY user_id
    ) AS foo
GROUP BY date
ORDER BY date
LIMIT 1000

-- Для расчёта числа заказов новых пользователей сначала нужно для каждого пользователя найти дату совершения первого действия, 
-- а затем дополнить эту таблицу данными о количестве заказов, сделанных пользователем в свой первый день. 
-- Это можно сделать, присоединив к таблице с датами первых действий таблицу с общим числом заказов на каждую дату для каждого пользователя. 
-- Обратите внимание, что в этой таблице для некоторых пользователей могут отсутствовать даты совершения первого действия, т.к. пользователь 
-- мог отменить заказ и фактически не совершить ни одной покупки в свой первый день. После объединения таблиц для таких дней с пропущенными 
-- значениями следует указать число заказов равным 0. Это можно сделать, например, с помощью функции COALESCE.


-- сначала нужно для каждого пользователя найти дату совершения первого действия
-- Это можно сделать, присоединив к таблице с датами первых действий
SELECT 
    user_id
    , MIN(time::date) AS first_action_date
FROM user_actions
GROUP BY user_id
ORDER BY first_action_date, user_id
LIMIT 1000

-- а затем дополнить эту таблицу данными о количестве заказов, сделанных пользователем в свой первый день
-- таблицу с общим числом заказов на каждую дату для каждого пользователя

SELECT 
    time::date AS date
    , user_id
    , COUNT(user_id) orders_per_day
FROM user_actions
WHERE order_id NOT IN (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order')
GROUP BY time::date, user_id
ORDER BY date, user_id
LIMIT 1000
--

SELECT
    t1.date
    , COUNT(t1.user_id)
    , SUM(orders_per_day)::int
FROM    
    (SELECT 
        user_id
        , MIN(time::date) AS date
    FROM user_actions
    GROUP BY user_id) AS t1
LEFT JOIN
    (SELECT 
        time::date AS date
        , user_id
        , COUNT(user_id) orders_per_day
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order')
    GROUP BY time::date, user_id) AS t2
ON t1.user_id = t2.user_id AND t1.date = t2.date
GROUP BY t1.date
ORDER BY t1.date
LIMIT 1000



-- итого мое решение
SELECT t3.date ,
       orders ,
       first_orders ,
       new_users_orders ,
       round(100 * first_orders::decimal / orders, 2) as first_orders_share ,
       round(100 * new_users_orders::decimal / orders, 2) as new_users_orders_share
FROM   (SELECT time::date as date ,
               count(order_id) as orders
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY time::date) as t3
    LEFT JOIN (SELECT date ,
                      count(user_id) as first_orders
               FROM   (SELECT user_id ,
                              min(time::date) as date
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY user_id) as foo
               GROUP BY date) as t4 using (date)
    LEFT JOIN (SELECT t1.date ,
                      sum(orders_per_day)::int as new_users_orders
               FROM   (SELECT user_id ,
                              min(time::date) as date
                       FROM   user_actions
                       GROUP BY user_id) as t1
                   LEFT JOIN (SELECT time::date as date ,
                                     user_id ,
                                     count(user_id) orders_per_day
                              FROM   user_actions
                              WHERE  order_id not in (SELECT order_id
                                                      FROM   user_actions
                                                      WHERE  action = 'cancel_order')
                              GROUP BY time::date, user_id) as t2
                       ON t1.user_id = t2.user_id and
                          t1.date = t2.date
               GROUP BY t1.date) as t5 using (date)
ORDER BY date



-- right solution
SELECT date,
       orders,
       first_orders,
       new_users_orders::int,
       round(100 * first_orders::decimal / orders, 2) as first_orders_share,
       round(100 * new_users_orders::decimal / orders, 2) as new_users_orders_share
FROM   (SELECT creation_time::date as date,
               count(distinct order_id) as orders
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
           and order_id in (SELECT order_id
                         FROM   courier_actions
                         WHERE  action = 'deliver_order')
        GROUP BY date) t5
    LEFT JOIN (SELECT first_order_date as date,
                      count(user_id) as first_orders
               FROM   (SELECT user_id,
                              min(time::date) as first_order_date
                       FROM   user_actions
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')
                       GROUP BY user_id) t4
               GROUP BY first_order_date) t7 using (date)
    LEFT JOIN (SELECT start_date as date,
                      sum(orders) as new_users_orders
               FROM   (SELECT t1.user_id,
                              t1.start_date,
                              coalesce(t2.orders, 0) as orders
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t1
                           LEFT JOIN (SELECT user_id,
                                             time::date as date,
                                             count(distinct order_id) as orders
                                      FROM   user_actions
                                      WHERE  order_id not in (SELECT order_id
                                                              FROM   user_actions
                                                              WHERE  action = 'cancel_order')
                                      GROUP BY user_id, date) t2
                               ON t1.user_id = t2.user_id and
                                  t1.start_date = t2.date) t3
               GROUP BY start_date) t6 using (date)
ORDER BY date
