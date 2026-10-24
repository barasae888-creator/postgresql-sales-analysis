DROP TABLE IF EXISTS orders_raw;

CREATE TABLE orders_raw (
    raw_id         SERIAL PRIMARY KEY,
    order_id       TEXT,
    order_date     TEXT,
    customer_name  TEXT,
    email          TEXT,
    phone          TEXT,
    city           TEXT,
    product        TEXT,
    category       TEXT,
    quantity       TEXT,
    unit_price     TEXT,
    discount       TEXT,
    payment_method TEXT,
    status         TEXT
);

INSERT INTO orders_raw (order_id, order_date, customer_name, email, phone, city,
                        product, category, quantity, unit_price, discount,
                        payment_method, status)
SELECT order_id, order_date, customer_name, email, phone, city,
       product, category, quantity, unit_price, discount,
       payment_method, status
FROM (
    WITH base AS (
        SELECT n,
               (n * 7) % 120                          AS c,
               date '2025-01-01' + ((n * 37) % 365)   AS d,
               (n * 3) % 10                           AS p
        FROM generate_series(1, 1000) AS n
    ),
    named AS (
        SELECT b.*,
               (ARRAY['Amina','Brian','Carol','David','Esther','Faith','George','Hannah','Isaac','Joy','Kevin','Lucy'])[1 + (c % 12)] AS fn,
               (ARRAY['Wanjiru','Otieno','Achieng','Kamau','Njeri','Mutua','Odhiambo','Chebet','Mwangi','Kiplagat'])[1 + (c / 12)]       AS ln,
               (ARRAY['Nairobi','Mombasa','Kisumu','Nakuru','Eldoret'])[1 + (c % 5)]                                                   AS city_c,
               (ARRAY['gmail.com','yahoo.com','outlook.com'])[1 + (c % 3)]                                                              AS dom,
               lpad((((c * 7919) + 12345678) % 100000000)::text, 8, '0')                                                               AS ph8,
               (ARRAY['Laptop','Smartphone','Tablet','Headphones','Printer','Monitor','Keyboard','Router','Power Bank','Webcam'])[1 + p] AS prod,
               (ARRAY['Computers','Phones','Phones','Audio','Office','Computers','Accessories','Networking','Accessories','Accessories'])[1 + p] AS cat,
               (ARRAY[85000,45000,38000,6500,22000,28000,2500,7500,3200,4800])[1 + p]                                                   AS price
        FROM base b
    ),
    messy AS (
        SELECT n,
               CASE WHEN n % 50 = 0 THEN 'ord-' || lpad(n::text, 5, '0')
                    WHEN n % 41 = 0 THEN ' ORD-' || lpad(n::text, 5, '0') || ' '
                    ELSE 'ORD-' || lpad(n::text, 5, '0') END                               AS order_id,
               CASE WHEN n = 250 THEN '31/02/2025'
                    WHEN n = 777 THEN 'not available'
                    WHEN n = 500 THEN '2027-03-15'
                    WHEN n % 4 = 1 THEN to_char(d, 'DD/MM/YYYY')
                    WHEN n % 4 = 2 THEN to_char(d, 'DD-Mon-YYYY')
                    ELSE to_char(d, 'YYYY-MM-DD') END                                      AS order_date,
               CASE WHEN n % 6 = 0 THEN lower(fn || ' ' || ln)
                    WHEN n % 7 = 0 THEN upper(fn || ' ' || ln)
                    WHEN n % 5 = 0 THEN '  ' || fn || '  ' || ln || ' '
                    ELSE fn || ' ' || ln END                                               AS customer_name,
               CASE WHEN n % 23 = 0 THEN NULL
                    WHEN n % 19 = 0 THEN ''
                    WHEN n % 31 = 0 THEN 'N/A'
                    WHEN n % 37 = 0 THEN lower(fn || '.' || ln) || '.' || dom
                    WHEN n % 11 = 0 THEN upper(lower(fn) || '.' || lower(ln) || '@' || dom)
                    WHEN n % 13 = 0 THEN lower(fn) || '.' || lower(ln) || '@' || dom || ' '
                    ELSE lower(fn) || '.' || lower(ln) || '@' || dom END                   AS email,
               CASE WHEN n % 17 = 0 THEN NULL
                    WHEN n % 29 = 0 THEN '07' || substr(ph8, 1, 3)
                    WHEN n % 9  = 0 THEN '+2547' || ph8
                    WHEN n % 8  = 0 THEN '07' || substr(ph8, 1, 2) || ' ' || substr(ph8, 3, 3) || ' ' || substr(ph8, 6, 3)
                    WHEN n % 7  = 0 THEN '2547' || ph8
                    ELSE '07' || ph8 END                                                   AS phone,
               CASE WHEN n % 10 = 0 THEN lower(city_c)
                    WHEN n % 14 = 0 THEN upper(city_c)
                    WHEN n % 12 = 0 THEN ' ' || city_c || ' '
                    WHEN n % 53 = 0 AND city_c = 'Nairobi' THEN 'Nbi'
                    ELSE city_c END                                                        AS city,
               CASE WHEN n % 16 = 0 THEN lower(prod)
                    WHEN n % 18 = 0 THEN upper(prod)
                    ELSE prod END                                                          AS product,
               CASE WHEN n % 20 = 0 THEN NULL
                    WHEN n % 22 = 0 THEN lower(cat)
                    ELSE cat END                                                           AS category,
               CASE WHEN n % 97 = 0 THEN '999'
                    WHEN n % 89 = 0 THEN '-1'
                    WHEN n % 61 = 0 THEN NULL
                    WHEN n % 53 = 0 THEN ''
                    WHEN n % 47 = 0 THEN 'two'
                    ELSE (1 + (n % 5))::text END                                           AS quantity,
               CASE WHEN n % 71 = 0 THEN 'N/A'
                    WHEN n % 73 = 0 THEN '0'
                    WHEN n % 79 = 0 THEN (price * 10)::text
                    WHEN n % 4 = 0 THEN 'KES ' || to_char(price, 'FM999,999')
                    WHEN n % 4 = 1 THEN price::text
                    WHEN n % 4 = 2 THEN to_char(price, 'FM999,999') || '.00'
                    ELSE 'Ksh' || price::text END                                          AS unit_price,
               CASE WHEN n % 83 = 0 THEN '150%'
                    WHEN n % 5 = 0 THEN NULL
                    WHEN n % 5 = 1 THEN '0%'
                    WHEN n % 5 = 2 THEN '5%'
                    WHEN n % 5 = 3 THEN '10%'
                    ELSE '0.15' END                                                        AS discount,
               CASE WHEN n % 67 = 0 THEN NULL
                    ELSE (ARRAY['M-Pesa','mpesa','MPESA','Mpesa','Card','card','Cash','cash on delivery','COD'])[1 + (n % 9)] END AS payment_method,
               (ARRAY['Completed','completed ','COMPLETED','Complete','Completed','Cancelled','canceled','Pending','pending','Refunded','refund','Shipped'])[1 + (n % 12)] AS status
        FROM named
    ),
    combined AS (
        SELECT 1 AS load_seq, n, order_id, order_date, customer_name, email, phone, city,
               product, category, quantity, unit_price, discount, payment_method, status
        FROM messy
        UNION ALL
        SELECT 2, n,
               CASE WHEN n % 50 = 25 THEN order_id || ' ' ELSE order_id END,
               order_date,
               CASE WHEN n % 50 = 25 THEN upper(customer_name) ELSE customer_name END,
               email, phone, city, product, category, quantity, unit_price, discount,
               payment_method, status
        FROM messy
        WHERE n % 25 = 0
    )
    SELECT * FROM combined
) x
ORDER BY load_seq, n;
