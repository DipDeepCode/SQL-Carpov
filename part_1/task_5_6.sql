SELECT COUNT(*) AS orders_count
FROM orders
WHERE array_length(product_ids, 1) >= 9;