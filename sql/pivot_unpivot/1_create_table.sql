CREATE DATABASE IF NOT EXISTS analytics_db;

DROP TABLE IF EXISTS gross_orders;

CREATE TABLE gross_orders (
    date DATE,
    product_id VARCHAR(4),
    price NUMERIC,
    gross_orders NUMERIC
);
