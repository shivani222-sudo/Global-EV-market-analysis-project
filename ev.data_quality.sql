#### CHECK TOTAL RECORDS IMPORTED 
select 'Total records imported:' as metric , COUNT(*) as value 
from ev_market_data;

#### CHECK FOR DUPLICATE VALUES 
SELECT 
    'Duplicate_check' as test,
    COUNT(*) as total_records,
    COUNT(DISTINCT record_id) as unique_records,
    COUNT(*) - COUNT(DISTINCT record_id) as duplicates
FROM ev_market_data;

##### DATA RANGES
SELECT 'Data_ranges' as test,
MIN(BATTERY_CAPACITY_KWH) AS MIN_BATTERY,
MAX(BATTERY_CAPACITY_KWH) AS MAX_BATTERY,
MIN(VEHICLE_RANGE_KM) AS MIN_RANGE,
MAX(VEHICLE_RANGE_KM) AS MAX_RANGE,
MIN(AVG_EV_PRICE_USD) AS MIN_PRICE,
MAX(AVG_EV_PRICE_USD) AS MAX_PRICE
FROM EV_MARKET_DATA;
#### CHECK CATEGORICAL VALUE CONSISTENCY 
SELECT 'Countries:' as category, COUNT(DISTINCT country) as unique_values FROM ev_market_data
UNION ALL
SELECT 'Regions:', COUNT(DISTINCT region) FROM ev_market_data
UNION ALL
SELECT 'Brands:', COUNT(DISTINCT ev_brand) FROM ev_market_data
UNION ALL
SELECT 'Vehicle Types:', COUNT(DISTINCT vehicle_type) FROM ev_market_data;