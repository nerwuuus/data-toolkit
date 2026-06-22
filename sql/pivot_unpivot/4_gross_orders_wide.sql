WITH t AS (
    SELECT
        TO_CHAR(date, 'IYYY')::INT AS isoyear,
        TO_CHAR(date, 'IW')::INT AS isoweek,
        CASE
            WHEN product_id = 'P001' THEN 'acq'
            WHEN product_id = 'P002' THEN 'ret'
            WHEN product_id = 'P003' THEN 'wire'
        END AS product,
        AVG(price) AS non_promo_price,
        SUM(gross_orders * price) AS gross_orders_value,
        SUM(gross_orders) AS gross_orders
    FROM gross_orders
    GROUP BY
        TO_CHAR(date, 'IYYY'),
        TO_CHAR(date, 'IW'),
        product_id
),
t2 AS (
    SELECT isoyear, isoweek, product, 'non_promo_price' AS metric, non_promo_price AS value
    FROM t
    UNION ALL
    SELECT isoyear, isoweek, product, 'gross_orders_value' AS metric, gross_orders_value AS value
    FROM t
    UNION ALL
    SELECT isoyear, isoweek, product, 'gross_orders' AS metric, gross_orders AS value
    FROM t
),
t3 AS (
    SELECT
        isoyear,
        isoweek,
        product || '_' || metric AS product_metric,
        value
    FROM t2
),
t4 AS (
    SELECT
        isoyear,
        isoweek,
        COALESCE(SUM(value) FILTER (WHERE product_metric = 'acq_gross_orders'), 0) AS acq_gross_orders,
        COALESCE(SUM(value) FILTER (WHERE product_metric = 'ret_gross_orders'), 0) AS ret_gross_orders,
        COALESCE(SUM(value) FILTER (WHERE product_metric = 'wire_gross_orders'), 0) AS wire_gross_orders,
        MAX(value) FILTER (WHERE product_metric = 'acq_non_promo_price') AS acq_non_promo_price,
        MAX(value) FILTER (WHERE product_metric = 'ret_non_promo_price') AS ret_non_promo_price,
        MAX(value) FILTER (WHERE product_metric = 'wire_non_promo_price') AS wire_non_promo_price,
        COALESCE(SUM(value) FILTER (WHERE product_metric = 'acq_gross_orders_value'), 0) AS acq_gross_orders_value,
        COALESCE(SUM(value) FILTER (WHERE product_metric = 'ret_gross_orders_value'), 0) AS ret_gross_orders_value,
        COALESCE(SUM(value) FILTER (WHERE product_metric = 'wire_gross_orders_value'), 0) AS wire_gross_orders_value,
        COALESCE(SUM(value) FILTER (WHERE product_metric LIKE '%_gross_orders'), 0) AS gross_orders_all,
        COALESCE(SUM(value) FILTER (WHERE product_metric LIKE '%_gross_orders_value'), 0)
        / NULLIF(
            COALESCE(SUM(value) FILTER (WHERE product_metric LIKE '%_gross_orders'), 0),
            0
        ) AS avg_order_value
    FROM t3
    GROUP BY
        isoyear,
        isoweek
)
SELECT *
FROM t4
WHERE avg_order_value IS NOT NULL
ORDER BY
    isoyear,
    isoweek;
