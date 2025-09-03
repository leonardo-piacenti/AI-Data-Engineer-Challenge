CREATE TABLE IF NOT EXISTS ads_spend (
    id SERIAL PRIMARY KEY,
    date DATE,
    platform VARCHAR(50),
    account VARCHAR(100),
    campaign VARCHAR(255),
    country VARCHAR(10),
    device VARCHAR(50),
    spend NUMERIC(12,2),
    clicks INT,
    impressions INT,
    conversions INT,
    load_date DATE,
    source_file_name VARCHAR(50)
);
