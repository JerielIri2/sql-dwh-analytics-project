/*
=============================================================
Load Bronze Layer (stored procedure)
=============================================================
Purpose:
    Truncates and reloads the Bronze tables from the source
    CSV files while tracking individual and total load times.
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE 
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN

    batch_start_time := clock_timestamp();
    RAISE NOTICE '===============================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '===============================================';

    RAISE NOTICE '-----------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '-----------------------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_customer_info';
    TRUNCATE TABLE bronze.crm_customer_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_customer_info';
    COPY bronze.crm_customer_info
    FROM '[file_path].../cust_info.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := clock_timestamp();
    RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
    RAISE NOTICE '----------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_product_info';
    TRUNCATE TABLE bronze.crm_product_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_product_info';
    COPY bronze.crm_product_info
    FROM '[file_path].../prd_info.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := clock_timestamp();
    RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
    RAISE NOTICE '----------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM '[file_path].../sales_details.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := clock_timestamp();
    RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
    RAISE NOTICE '----------------';

    RAISE NOTICE '-----------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '-----------------------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_customer';
    TRUNCATE TABLE bronze.erp_customer;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_customer';
    COPY bronze.erp_customer
    FROM '[file_path].../customer.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := clock_timestamp();
    RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
    RAISE NOTICE '----------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_location';
    TRUNCATE TABLE bronze.erp_location;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_location';
    COPY bronze.erp_location
    FROM '[file_path].../location.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := clock_timestamp();
    RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
    RAISE NOTICE '----------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_category';
    TRUNCATE TABLE bronze.erp_category;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_category';
    COPY bronze.erp_category
    FROM '[file_path].../category.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    end_time := clock_timestamp();
    RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
    RAISE NOTICE '----------------';

    batch_end_time := clock_timestamp();

    RAISE NOTICE '==================================';
    RAISE NOTICE 'Total Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::numeric, 2);
    RAISE NOTICE '==================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Bronze layer load failed: %', SQLERRM;
        RAISE;

END;
$$;
