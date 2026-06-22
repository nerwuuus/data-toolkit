DROP TABLE IF EXISTS campaign_data;

CREATE TABLE campaign_data (
    isoyear INTEGER,
    isoweek INTEGER,
    brand VARCHAR(50),
    media_channel VARCHAR(50),
    sub_channel VARCHAR(50),
    campaign_name VARCHAR(100),
    campaign_objective VARCHAR(100),
    product_category VARCHAR(100),
    target VARCHAR(50),
    net_spend NUMERIC(12,2),
    gross_spend NUMERIC(12,2),
    grps NUMERIC(12,2),
    price_per_grp NUMERIC(12,2)
);
