-- Bulan dengan total nilai transaksi terbesar selama 2021.

SELECT
    FORMAT_DATE('%B',order_date) AS month,
    round(SUM(after_discount)) total_sales
FROM
    `tokopaedi.order_detail`
WHERE is_valid = 1
      AND (order_date BETWEEN '2021-01-01' AND '2021-12-31')
GROUP BY 1
ORDER BY 2 DESC;


-- Kategori dengan nilai transaksi paling besar selama 2022
SELECT
  sd.category,
  SUM(od.after_discount) total_sales
FROM `tokopaedi.order_detail` od
LEFT JOIN `tokopaedi.sku_detail` sd 
  ON sd.id = od.sku_id
WHERE is_valid = 1
    AND (order_date BETWEEN '2022-01-01' AND '2022-12-31')
GROUP BY 1
ORDER BY 2 DESC;

-- Perbandingan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022
WITH a AS (
  SELECT
    sd.category,
    SUM(CASE WHEN order_date BETWEEN '2021-01-01' AND '2021-12-31' THEN od.after_discount END) total_sales_2021,
    SUM(CASE WHEN order_date BETWEEN '2022-01-01' AND '2022-12-31' THEN od.after_discount END) total_sales_2022
  FROM `tokopaedi.order_detail` od
  LEFT JOIN `tokopaedi.sku_detail` sd 
      ON sd.id = od.sku_id
  WHERE is_valid = 1
  GROUP BY 1
  ORDER BY 2 DESC)

SELECT
  a.*,
  ROUND(total_sales_2022 - total_sales_2021, 2) AS growth_value,
  Round((total_sales_2022 - total_sales_2021)/total_sales_2021*100, 2) as percentage
FROM a
ORDER BY 4 DESC;

-- Top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order).
SELECT 
  pd.payment_method,
  count(distinct od.id) total_order
FROM `tokopaedi.order_detail` od
LEFT JOIN `tokopaedi.payment_detail` pd 
  ON pd.id = od.payment_id
WHERE (order_date BETWEEN '2022-01-01' AND '2022-12-31')
      AND is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Top 5 produk dengan nilai transaksi terbesar (Samsung, Apple, Sony, Huawei, dan Lenovo)
WITH a AS (
  SELECT 
    case 
      WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung'
      WHEN LOWER(sd.sku_name) LIKE '%apple%' OR LOWER(sd.sku_name) LIKE '%iphone%' THEN 'Apple'
      WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony'
      WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
      WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
    END product_brand,
    ROUND(SUM(od.after_discount), 2) total_sales
  FROM `tokopaedi.order_detail` od
  LEFT JOIN `tokopaedi.sku_detail` sd 
      ON sd.id = od.sku_id
  WHERE order_date BETWEEN '2022-01-01' AND '2022-12-31'
        AND is_valid = 1
    GROUP BY 1)

SELECT 
  a.*
FROM a
WHERE product_brand is not null
ORDER BY 2 DESC;


