-- Global EV Market Analysis
-- Author: Shivani Chhabra
-- Tools: SQL (MySQL)
-- Description:
-- End-to-end analytics project covering EV adoption,
-- charging infrastructure, government incentives,
-- revenue potential, and environmental impact.
create database ev_market;
use ev_market;

CREATE TABLE ev_market_data (
    record_id VARCHAR(10) PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    ev_brand VARCHAR(50) NOT NULL,
    vehicle_type VARCHAR(20) NOT NULL,
    ev_sales_units INTEGER NOT NULL CHECK (ev_sales_units >= 0),
    battery_capacity_kwh INTEGER NOT NULL CHECK (battery_capacity_kwh BETWEEN 40 AND 120),
    vehicle_range_km INTEGER NOT NULL CHECK (vehicle_range_km > 0),
    charging_time_hours DECIMAL(4,2) NOT NULL CHECK (charging_time_hours > 0),
    charging_stations INTEGER NOT NULL CHECK (charging_stations >= 0),
    avg_ev_price_usd INTEGER NOT NULL CHECK (avg_ev_price_usd > 0),
    energy_consumption_kwh DECIMAL(5,2) NOT NULL CHECK (energy_consumption_kwh > 0),
    govt_incentives VARCHAR(3) NOT NULL CHECK (govt_incentives IN ('Yes', 'No')),
    market_adoption_rate DECIMAL(5,2) NOT NULL CHECK (market_adoption_rate BETWEEN 0 AND 100),
    co2_reduction_mt DECIMAL(6,2) NOT NULL CHECK (co2_reduction_mt >= 0),
    year INTEGER NOT NULL DEFAULT 2026);
    
CREATE TABLE dim_brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(50) UNIQUE NOT NULL,
    headquarters_country VARCHAR(50),
    market_segment VARCHAR(20)
);
CREATE TABLE dim_countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(50) UNIQUE NOT NULL,
    region VARCHAR(50) NOT NULL,
    continent VARCHAR(50));
    
    CREATE TABLE dim_vehicle_types (
    vehicle_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) UNIQUE NOT NULL,
    category VARCHAR(50),
    description TEXT);
    
 INSERT INTO dim_countries (country_name, region, continent)
SELECT DISTINCT country,region,
    CASE WHEN region = 'Asia' THEN 'Asia'
        WHEN region = 'Europe' THEN 'Europe'
        WHEN region = 'North America' THEN 'North America'
        WHEN region = 'Oceania' THEN 'Oceania'
    END as continent
FROM ev_market_data
ORDER BY country;   

INSERT INTO dim_brands(brand_name, market_segment)
select distinct ev_brand,
   case when ev_brand in ('Tesla', 'Mercedes', 'BMW') THEN 'PREMIUM'
	    when ev_brand in ('Toyota', 'Ford', 'VolksWagen', 'Hyundai','Nissan', 'Kia') then 'MassMarket'
	    when ev_brand = 'BYD' then 'Value'
        else 'other'
	END as market_segment
from ev_market_data
order by ev_brand;

INSERT INTO dim_vehicle_types (type_name, category, description)
values
	('Car', 'Passenger', 'Standard passenger cars and sedans'),
    ('SUV', 'Passenger', 'Sport Utility Vehicles'),
    ('Truck', 'Commercial', 'Light and heavy-duty trucks'),
    ('Bus', 'Commercial', 'Public and private buses');
    
    ALTER TABLE ev_market_data
ADD CONSTRAINT fk_brand FOREIGN KEY (ev_brand) 
    REFERENCES dim_brands(brand_name);

    ALTER TABLE ev_market_data
ADD CONSTRAINT fk_country FOREIGN KEY (country) 
    REFERENCES dim_countries(country_name);
    
 
    ALTER TABLE ev_market_data
ADD CONSTRAINT fk_vehicle_type FOREIGN KEY (vehicle_type) 
    REFERENCES dim_vehicle_types(type_name);   
    
CREATE INDEX idx_country ON ev_market_data(country);
CREATE INDEX idx_brand ON ev_market_data(ev_brand);
CREATE INDEX idx_adoption ON ev_market_data(market_adoption_rate);