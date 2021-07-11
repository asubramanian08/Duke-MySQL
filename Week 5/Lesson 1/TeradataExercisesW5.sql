--Question 1
SELECT EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, COUNT(DISTINCT EXTRACT(DAY from saledate)) AS dayCount
FROM trnsact
GROUP BY 1, 2

--Question 2
SELECT sku, SUM(CASE WHEN EXTRACT(MONTH from saledate)=6 THEN amt END) AS june_sales,
            SUM(CASE WHEN EXTRACT(MONTH from saledate)=7 THEN amt END) AS july_sales,
            SUM(CASE WHEN EXTRACT(MONTH from saledate)=8 THEN amt END) AS august_sales,
            june_sales+july_sales+august_sales AS summer_sales
FROM trnsact
WHERE stype='P'
GROUP BY sku
ORDER BY summer_sales DESC

--Question 3
SELECT EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, store,
       COUNT(DISTINCT EXTRACT(DAY from saledate)) AS dayCount
FROM trnsact
GROUP BY 1, 2, 3
ORDER BY 4

--Question 4 part 1
SELECT store, EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num,
       SUM(amt)/COUNT(DISTINCT saledate) AS daily_revenue
FROM trnsact
WHERE stype='p'
GROUP BY 1, 2, 3;

--Question 4 part 2
SELECT store, month_num, year_num, avg_daily_rev, day_count, year_month
FROM (SELECT store, EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, COUNT(DISTINCT saledate) as day_count,
          SUM(amt)/day_count AS avg_daily_rev, EXTRACT(YEAR from saledate)||EXTRACT(MONTH from saledate) AS year_month
      FROM trnsact
      WHERE stype='p' AND year_month<>'2005 8'
      GROUP BY 1, 2, 3
      HAVING day_count>=20) AS clean_table
ORDER BY day_count;

--Question 5
SELECT CASE WHEN sm.msa_high>=50 AND sm.msa_high<=60 THEN 'low'
            WHEN sm.msa_high> 60 AND sm.msa_high<=70 THEN 'medium'
            WHEN sm.msa_high> 70 THEN 'high' ELSE 'very low'
            END AS education_group,
       SUM(adr.total_rev)/SUM(adr.day_count) AS avg_daily_rev
FROM (SELECT store, EXTRACT(YEAR from saledate) AS year_num, EXTRACT(MONTH from saledate) AS month_num,
          COUNT(DISTINCT saledate) as day_count, SUM(amt) AS total_rev
      FROM trnsact
      WHERE stype='p' AND (year_num<>2005 OR month_num<>8)
      GROUP BY 1, 2, 3
      HAVING day_count>=20) AS adr JOIN store_msa sm ON adr.store=sm.store
GROUP BY education_group

--Question 6
SELECT sm.city, sm.state, sm.msa_income, SUM(adr.total_rev)/SUM(adr.day_count) AS avg_daily_rev
FROM (SELECT store, EXTRACT(YEAR from saledate) AS year_num, EXTRACT(MONTH from saledate) AS month_num,
          COUNT(DISTINCT saledate) as day_count, SUM(amt) AS total_rev
      FROM trnsact
      WHERE stype='p' AND (year_num<>2005 OR month_num<>8)
      GROUP BY 1, 2, 3
      HAVING day_count>=20) AS adr JOIN store_msa sm ON adr.store=sm.store
WHERE sm.msa_income IN((SELECT MAX(msa_income) FROM store_msa), (SELECT MIN(msa_income) FROM store_msa))
GROUP BY 1, 2, 3

--Question 7
SELECT s.sku, s.brand, STDDEV_SAMP(t.sprice) AS sale_dev, COUNT(DISTINCT t.saledate) AS num_sales
FROM skuinfo s JOIN trnsact t ON s.sku=t.sku
WHERE t.stype='p'
GROUP BY s.sku, s.brand
HAVING num_sales>100
ORDER BY sale_dev DESC

--Question 8
SELECT s.sku, s.brand, EXTRACT(MONTH from t.saledate) AS month_num, STDDEV_SAMP(t.sprice) AS sale_dev, COUNT(DISTINCT t.saledate) AS num_sales
FROM skuinfo s JOIN trnsact t ON s.sku=t.sku
WHERE t.stype='p'
GROUP BY s.sku, s.brand, month_num
HAVING num_sales>10
ORDER BY sale_dev DESC
-- they aren't overpriced because when the month becomes a factor, the STDDEV almost halves

--Question 9
SELECT CASE month_num
            WHEN  1 THEN 'Jan'
            WHEN  2 THEN 'Feb'
            WHEN  3 THEN 'Mar'
            WHEN  4 THEN 'Apr'
            WHEN  5 THEN 'May'
            WHEN  6 THEN 'Jun'
            WHEN  7 THEN 'Jul'
            WHEN  8 THEN 'Aug'
            WHEN  9 THEN 'Sep'
            WHEN 10 THEN 'Oct'
            WHEN 11 THEN 'Nov'
            WHEN 12 THEN 'Dec'
            END AS month_name, EXTRACT(MONTH from saledate) as month_num, 
       COUNT(DISTINCT saledate) as day_count, SUM(amt)/day_count AS avg_daily_rev
FROM trnsact
WHERE stype='p' AND EXTRACT(YEAR from saledate)||month_num<>'2005 8'
GROUP BY month_num
HAVING day_count>=20
ORDER BY avg_daily_rev DESC

--Question 10
SELECT increase.adr_percent_increase, str.store, str.city, str.state, d.dept, d.deptdesc
FROM (SELECT store, sku, 100*(dec_adr-nov_adr)/nov_adr AS adr_percent_increase, nov_rev/nov_days AS nov_adr, dec_rev/dec_days AS dec_adr,
             SUM(CASE WHEN month_num=11 THEN amt END) AS nov_rev, COUNT(DISTINCT CASE WHEN month_num=11 THEN saledate END) AS nov_days,
             SUM(CASE WHEN month_num=12 THEN amt END) AS dec_rev, COUNT(DISTINCT CASE WHEN month_num=12 THEN saledate END) AS dec_days
      FROM (SELECT store, amt, sku, EXTRACT(MONTH from saledate) as month_num, saledate
            FROM trnsact
            WHERE stype='p' AND EXTRACT(YEAR from saledate)||month_num<>'2005 8') AS simple_table
      GROUP BY store, sku
      HAVING nov_days>=20 AND dec_days>=20) AS increase JOIN strinfo str ON increase.store=str.store
      JOIN (skuinfo sku JOIN deptinfo d ON sku.dept=d.dept) ON increase.sku=sku.sku
ORDER BY increase.adr_percent_increase DESC

--Question 11
SELECT decrease.adr_decrease, str.store, str.city, str.state
FROM (SELECT store, sep_adr-aug_adr AS adr_decrease, aug_rev/aug_days AS aug_adr, sep_rev/sep_days AS sep_adr,
             SUM(CASE WHEN month_num=8 THEN amt END) AS aug_rev, COUNT(DISTINCT CASE WHEN month_num=8 THEN saledate END) AS aug_days,
             SUM(CASE WHEN month_num=9 THEN amt END) AS sep_rev, COUNT(DISTINCT CASE WHEN month_num=9 THEN saledate END) AS sep_days
      FROM (SELECT store, amt, sku, EXTRACT(MONTH from saledate) as month_num, saledate
            FROM trnsact
            WHERE stype='p' AND EXTRACT(YEAR from saledate)||month_num<>'2005 8') AS simple_table
      GROUP BY store
      HAVING aug_days>=20 AND sep_days>=20) AS decrease JOIN strinfo str ON decrease.store=str.store
ORDER BY decrease.adr_decrease DESC

--Question 12
SELECT month_num,
       COUNT(DISTINCT CASE WHEN adr_rnum=12 THEN store END) AS adr_count,
       COUNT(DISTINCT CASE WHEN tr_rnum=12 THEN store END) AS tr_count
FROM (SELECT store, EXTRACT(MONTH from saledate) AS month_num, SUM(amt) AS total_rev,
             COUNT(DISTINCT saledate) AS num_days, total_rev/num_days AS avg_daily_rev,
             ROW_NUMBER() OVER (PARTITION BY store ORDER BY avg_daily_rev DESC) AS adr_rnum,
             ROW_NUMBER() OVER (PARTITION BY store ORDER BY total_rev DESC) AS tr_rnum
      FROM trnsact
      QUALIFY adr_rnum=12 OR tr_rnum=12
      WHERE stype='p' AND saledate<'2005-08-01'
      GROUP BY store, month_num
      HAVING num_days>=20) AS clean_table
GROUP BY month_num
ORDER BY month_num