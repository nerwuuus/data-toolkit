INSERT INTO campaign_data (
    isoyear,
    isoweek,
    brand,
    media_channel,
    sub_channel,
    campaign_name,
    campaign_objective,
    product_category,
    target,
    net_spend,
    gross_spend,
    grps,
    price_per_grp
)
VALUES
-- 2024 sample data
(2024, 1, 'Brand_A', 'TV', 'National', 'Brand_A Wireless Awareness', 'Brand campaign', 'Wireless', 'Adults 18-49', 12000, 15000, 140.5, 105.74),
(2024, 1, 'Brand_A', 'Digital', 'Social', 'Brand_A Wireline Leads', 'Performance campaign', 'Wireline', 'Adults 25-54', 4200, 5100, 15.1, 338.22),
(2024, 2, 'Brand_B', 'TV', 'National', 'Brand_B Brand Campaign', 'Brand campaign', 'Brand', 'Adults 18-49', 18000, 22000, 200.3, 109.84),
(2024, 2, 'Brand_B', 'OOH', 'Transit', 'Brand_B Bundle Promo', 'Product campaign', 'Wireline & Wireless', 'Adults 25-54', 7000, 8500, 50.2, 169.32),
(2024, 13, 'Brand_A', 'Digital', 'Search', 'Brand_A Wireless Search', 'Performance campaign', 'Wireless', 'Adults 18-49', 5200, 6100, 18.6, 327.96),
(2024, 13, 'Brand_C', 'TV', 'Regional', 'Brand_C PP Offer', 'Product campaign', 'PP Fiber', 'Adults 25-54', 9000, 11000, 90.1, 122.09),

-- 2025 sample data
(2025, 1, 'Brand_A', 'TV', 'National', 'Brand_A Wireless Awareness', 'Brand campaign', 'Wireless', 'Adults 18-49', 25000, 30000, 51.2, 585.94),
(2025, 1, 'Brand_A', 'Digital', 'Social', 'Brand_A Wireline Leads', 'Performance campaign', 'Wireline', 'Adults 25-54', 8000, 9200, 27.2, 338.22),
(2025, 5, 'Brand_B', 'TV', 'National', 'Brand_B Brand Campaign', 'Brand campaign', 'Brand', 'Adults 18-49', 12000, 14500, 65.3, 221.98),
(2025, 5, 'Brand_B', 'OOH', 'Transit', 'Brand_B Bundle Promo', 'Product campaign', 'Wireline & Wireless', 'Adults 25-54', 10000, 11800, 89.1, 132.91),
(2025, 14, 'Brand_C', 'Digital', 'Search', 'Brand_C PP Search', 'Performance campaign', 'PP Mobile', 'Adults 18-49', 6500, 7500, 30.0, 250.00),
(2025, 14, 'Brand_C', 'TV', 'Regional', 'Brand_C Wireline Push', 'Product campaign', 'Wireline', 'Adults 25-54', 16000, 19000, 32.5, 584.62);
