## INSIGHT 1 : TOTAL EV SALES BY COUNTRY 

SELECT COUNTRY , REGION ,
SUM(EV_SALES_UNITS) AS TOTAL_SALES,
ROUND(AVG(MARKET_ADOPTION_RATE),2) AS AVG_ADOPTION_RATE,
(SUM(EV_SALES_UNITS)*100.0 / SUM(SUM(EV_SALES_UNITS)) OVER()) AS market_share
FROM EV_MARKET_DATA
GROUP BY COUNTRY, REGION 
ORDER BY TOTAL_SALES DESC;

##  INSIGHT 2: EV SALES BY REGION 

SELECT REGION, COUNT(DISTINCT COUNTRY) AS NUM_COUNTRIES, 
SUM(EV_SALES_UNITS) AS TOTAL_SALES,
ROUND(AVG(EV_SALES_UNITS),0) AS AVG_SALES_PER_RECORD,
ROUND(AVG(MARKET_ADOPTION_RATE),2) AS AVG_ADOPTION_RATE
FROM EV_MARKET_DATA
GROUP BY REGION 
ORDER BY TOTAL_SALES DESC;

### INSIGHT 3.BRAND PERFORMANCE ANALYSIS

SELECT EV_BRAND, 
SUM(EV_SALES_UNITS) AS TOTAL_SALES,
ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
ROUND(AVG(battery_capacity_kwh), 1) as avg_battery_capacity,
ROUND(AVG(vehicle_range_km), 0) as avg_range,
(SUM(ev_sales_units) * 100.0 / SUM(SUM(ev_sales_units)) OVER()) as market_share
FROM ev_market_data
GROUP BY ev_brand
ORDER BY total_sales DESC;

## INSIGHT 4. VEHICLE TYPE DISTRIBUTION 

SELECT vehicle_type, 
SUM(ev_sales_units) as total_sales,
round(avg(avg_ev_price_usd),0) as avg_price,
round(avg(battery_capacity_kwh),1) as avg_battery_kwh,
round(avg(vehicle_range_km),0) as avg_range_km,
round(avg(charging_time_hours),2) as avg_charging_time
from ev_market_data
group by vehicle_type 
ORDER BY TOTAL_SALES DESC;

### INSIGHT 5.TOP PERFORMING COUNTRY BRAND COMBINATIONS 
### WHICH BRAND-COUNTRY COMBINATIONS DRIVE THE MOST SALES??

SELECT COUNTRY, EV_BRAND, SUM(EV_SALES_UNITS) AS TOTAL_SALES,
ROUND(AVG(MARKET_ADOPTION_RATE),2) AS AVG_ADOPTION_RATE, 
RANK() OVER (PARTITION BY COUNTRY ORDER BY SUM(EV_SALES_UNITS)DESC) AS BRAND_RANK
FROM EV_MARKET_DATA
GROUP BY COUNTRY, EV_BRAND
HAVING SUM(EV_SALES_UNITS) > 500000
ORDER BY TOTAL_SALES DESC
LIMIT 20;

## INSIGHT 6.CHARGING INFRASTRUCTURE BY COUNTRY 

SELECT 
    country,
    region,
    SUM(charging_stations) as total_stations,
    SUM(ev_sales_units) as total_evs,
    ROUND(SUM(charging_stations)/ NULLIF(SUM(ev_sales_units), 0) * 1000, 2) as stations_per_1000_evs,
    CASE 
        WHEN SUM(charging_stations)/ NULLIF(SUM(ev_sales_units), 0) * 1000 > 1.0 THEN 'Excellent'
        WHEN SUM(charging_stations) / NULLIF(SUM(ev_sales_units), 0) * 1000 > 0.5 THEN 'Good'
        WHEN SUM(charging_stations) / NULLIF(SUM(ev_sales_units), 0) * 1000 > 0.25 THEN 'Fair'
        ELSE 'Poor'
    END as infrastructure_rating
FROM ev_market_data
GROUP BY country, region
ORDER BY stations_per_1000_evs DESC;

## INSIGHT 7: CORRELATION BETWEEN CHARGING_STATIONS AND MARKET_ADOPTION

SELECT COUNTRY, 
SUM(CHARGING_STATIONS) AS TOTAL_STATIONS,
ROUND(AVG(MARKET_ADOPTION_RATE),2) AS AVG_ADOPTION_RATE,
CASE WHEN SUM(CHARGING_STATIONS) > 150000 AND AVG(MARKET_ADOPTION_RATE) > 40 THEN 'High Infrastructure, High Adoption'
 WHEN SUM(charging_stations) > 150000 AND AVG(market_adoption_rate) <= 40 THEN 'High Infrastructure, Low Adoption'
WHEN SUM(charging_stations) <= 150000 AND AVG(market_adoption_rate) > 40 THEN 'Low Infrastructure, High Adoption'
        ELSE 'Low Infrastructure, Low Adoption'
    END as infrastructure_adoption_segment
FROM ev_market_data
GROUP BY country
ORDER BY total_stations DESC; 

### INSIGHT 8. battery capacity vs vehicle range efficiency 
### which vehicles offer best range per kwh ??

select ev_brand, 
vehicle_type, 
battery_capacity_kwh,
vehicle_range_km,
round(vehicle_range_km / battery_capacity_kwh,2) as km_per_kwh,
avg_ev_price_usd,
round(avg_ev_price_usd / vehicle_range_km,2) as price_per_km_range
from ev_market_data 
where battery_capacity_kwh > 0
order by km_per_kwh DESC
limit 20;

### INSIGHT 9. energy efficiency analysis by vehicle type 
### WHICH VEHICLE TYPES ARE MOST EFFIECIENT 

SELECT 
    vehicle_type,
    ROUND(AVG(energy_consumption_kwh), 2) as avg_energy_consumption,
    ROUND(MIN(energy_consumption_kwh), 2) as best_efficiency,
    ROUND(MAX(energy_consumption_kwh), 2) as worst_efficiency,
    ROUND(AVG(vehicle_range_km), 0) as avg_range
FROM ev_market_data
GROUP BY vehicle_type
ORDER BY avg_energy_consumption ASC;

USE EV_MARKET;

## INSIGHT 10. charging type analysis 
### how does charging time varies across vehicle type and brand type

SELECT 
    vehicle_type,
    ev_brand,
    ROUND(AVG(charging_time_hours), 2) as avg_charging_time,
    ROUND(AVG(battery_capacity_kwh), 1) as avg_battery_capacity,
    ROUND(AVG(battery_capacity_kwh) / AVG(charging_time_hours), 2) as avg_charging_speed_kwh_per_hour
FROM ev_market_data
GROUP BY vehicle_type, ev_brand
ORDER BY avg_charging_speed_kwh_per_hour DESC
LIMIT 15;

## INSIGHT 11. PRICE DISTRIBUTION BY BRAND AND VEHICLE TYPE 

SELECT EV_BRAND, VEHICLE_TYPE, 
ROUND(AVG(AVG_EV_PRICE_USD), 0) AS AVG_PRICE,
MIN(AVG_EV_PRICE_USD) AS MIN_PRICE,
MAX(AVG_EV_PRICE_USD) AS MAX_PRICE,
 CASE 
        WHEN AVG(avg_ev_price_usd) > 70000 THEN 'Premium'
        WHEN AVG(avg_ev_price_usd) > 50000 THEN 'Mid-Range'
        ELSE 'Budget'
    END as price_DISTRIBUTION
FROM EV_MARKET_DATA
GROUP BY EV_BRAND, VEHICLE_TYPE
ORDER BY AVG_PRICE DESC;

### INSIGHT 12. PRICE V/S RANGE 

SELECT 
    record_id,
    country,
    ev_brand,
    vehicle_type,
    avg_ev_price_usd,
    vehicle_range_km,
    ROUND(avg_ev_price_usd/ vehicle_range_km, 2) as price_per_km_range,
    battery_capacity_kwh,
    ROUND(avg_ev_price_usd/ battery_capacity_kwh, 2) as price_per_kwh,
    market_adoption_rate
FROM ev_market_data
ORDER BY price_per_km_range ASC
LIMIT 20;

## INSIGHT 13. REVENUE POTENTIAL ANALYSIS

SELECT 
    region,
    country,
    ev_brand,
    SUM(ev_sales_units) as total_units_sold,
    ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
    ROUND(SUM(ev_sales_units * avg_ev_price_usd) / 1000000000.0, 2) as revenue_billion_usd
FROM ev_market_data
GROUP BY region, country, ev_brand
ORDER BY revenue_billion_usd DESC
LIMIT 15;

### INSIGHT 14. IMPACT OF GOVERNMENT INCENTIVES IMPACT 

SELECT GOVT_INCENTIVES, SUM(ev_sales_units) as total_sales,
ROUND(AVG(ev_sales_units), 0) as avg_sales,
ROUND(AVG(market_adoption_rate), 2) as avg_adoption_rate
FROM EV_MARKET_DATA
GROUP BY GOVT_INCENTIVES
ORDER BY GOVT_INCENTIVES;

### INSIGHT 15. EFFECTIVENESS BY VEHICLE TYPE 

SELECT vehicle_type,
    govt_incentives,
    ROUND(AVG(market_adoption_rate), 2) as avg_adoption
FROM ev_market_data
GROUP BY vehicle_type, govt_incentives
ORDER BY vehicle_type, govt_incentives;

### ENVIRONMENT IMPACT ANALYSIS 
### INSIGHT 16. CO2 REDUCTION BY COUNTRY 

SELECT 
    country,
    region,
    SUM(ev_sales_units) as total_evs,
    SUM(co2_reduction_mt) as total_co2_reduction_mt,
    ROUND(AVG(co2_reduction_mt), 2) as avg_co2_per_vehicle,
    ROUND(SUM(co2_reduction_mt) / SUM(ev_sales_units) * 1000, 2) as co2_reduction_per_1000_evs
FROM ev_market_data
GROUP BY country, region
ORDER BY total_co2_reduction_mt DESC
LIMIT 10;

### INSIGHT 17. ENVIRONMENTAL IMPACT VS ECONOMIC VALUE 

SELECT 
    ev_brand,
    vehicle_type,
    ROUND(AVG(avg_ev_price_usd), 0) as avg_price,
    ROUND(AVG(co2_reduction_mt), 2) as avg_co2_reduction,
    ROUND(AVG(co2_reduction_mt) / AVG(avg_ev_price_usd) * 1000000, 2) as co2_reduction_per_million_usd
FROM ev_market_data
GROUP BY ev_brand, vehicle_type
HAVING COUNT(*) >= 3
ORDER BY co2_reduction_per_million_usd DESC
LIMIT 15; 

### : INSIGHT 18. Top 3 Brands per Country
USE EV_MARKET;
WITH brand_rankings AS (
    SELECT 
        country,
        ev_brand,
        SUM(ev_sales_units) as brand_sales,
        ROUND(AVG(market_adoption_rate), 2) as avg_adoption,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY SUM(ev_sales_units) DESC) as brand_rank
    FROM ev_market_data
    GROUP BY country, ev_brand
)
SELECT 
    country,
    ev_brand,
    brand_sales,
    avg_adoption,
    brand_rank
FROM brand_rankings
WHERE brand_rank <= 3
ORDER BY country, brand_rank;
