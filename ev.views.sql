USE EV_MARKET;

CREATE VIEW vw_country_summary AS
SELECT 
    country,
    region,
    COUNT(*) as total_records,
    COUNT(DISTINCT ev_brand) as num_brands,
    COUNT(DISTINCT vehicle_type) as num_vehicle_types,
    SUM(ev_sales_units) as total_sales,
    ROUND(AVG(ev_sales_units), 0) as avg_sales_per_record,
    ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
    ROUND(AVG(market_adoption_rate), 2) as avg_adoption_rate,
    SUM(charging_stations) as total_charging_stations,
    SUM(co2_reduction_mt) as total_co2_reduction,
    ROUND(AVG(battery_capacity_kwh), 1) as avg_battery_capacity,
    ROUND(AVG(vehicle_range_km), 0) as avg_vehicle_range
FROM ev_market_data
GROUP BY country, region;

CREATE VIEW vw_brand_performance AS
SELECT 
    ev_brand,
    COUNT(*) as total_models,
    COUNT(DISTINCT country) as markets_present,
    SUM(ev_sales_units) as total_sales,
    ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
    ROUND(AVG(battery_capacity_kwh), 1) as avg_battery_capacity,
    ROUND(AVG(vehicle_range_km), 0) as avg_range,
    ROUND(AVG(charging_time_hours), 2) as avg_charging_time,
    ROUND(AVG(energy_consumption_kwh), 2) as avg_energy_consumption,
    ROUND(AVG(market_adoption_rate), 2) as avg_adoption_rate,
    SUM(co2_reduction_mt) as total_co2_reduction,
    ROUND(SUM(ev_sales_units) * 100.0 / SUM(SUM(ev_sales_units)) OVER(), 2) as market_share_pct
FROM ev_market_data
GROUP BY ev_brand;

CREATE VIEW vw_vehicle_type_analysis AS
SELECT 
    vehicle_type,
    COUNT(*) as total_records,
    SUM(ev_sales_units) as total_sales,
    ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
    MIN(avg_ev_price_usd) as min_price,
    MAX(avg_ev_price_usd) as max_price,
    ROUND(AVG(battery_capacity_kwh), 1) as avg_battery,
    ROUND(AVG(vehicle_range_km), 0) as avg_range,
    ROUND(AVG(charging_time_hours), 2) as avg_charging_time,
    ROUND(AVG(energy_consumption_kwh), 2) as avg_energy_consumption,
    ROUND(AVG(market_adoption_rate), 2) as avg_adoption_rate,
    SUM(co2_reduction_mt) as total_co2_reduction
FROM ev_market_data
GROUP BY vehicle_type;

CREATE VIEW vw_incentives_impact AS
SELECT 
    country,
    region,
    govt_incentives,
    COUNT(*) as record_count,
    SUM(ev_sales_units) as total_sales,
    ROUND(AVG(market_adoption_rate), 2) as avg_adoption_rate,
    ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
    SUM(co2_reduction_mt) as total_co2_reduction
FROM ev_market_data
GROUP BY country, region, govt_incentives;

CREATE VIEW vw_top_performers AS
WITH sales_rankings AS (
    SELECT 
        'Country' as category,
        country as name,
        SUM(ev_sales_units) as value,
        RANK() OVER (ORDER BY SUM(ev_sales_units) DESC) as sales_rank
    FROM ev_market_data
    GROUP BY country
),
brand_rankings AS (
    SELECT 
        'Brand' as category,
        ev_brand as name,
        SUM(ev_sales_units) as value,
        RANK() OVER (ORDER BY SUM(ev_sales_units) DESC) as brand_rank
    FROM ev_market_data
    GROUP BY ev_brand
),
vehicle_rankings AS (
    SELECT 
        'Vehicle Type' as category,
        vehicle_type as name,
        SUM(ev_sales_units) as value,
        RANK() OVER (ORDER BY SUM(ev_sales_units) DESC) as vehicle_rank
    FROM ev_market_data
    GROUP BY vehicle_type
)
SELECT * FROM sales_rankings WHERE sales_rank <= 5
UNION ALL
SELECT * FROM brand_rankings WHERE brand_rank <= 5
UNION ALL
SELECT * FROM vehicle_rankings;
