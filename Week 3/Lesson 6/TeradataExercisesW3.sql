--Question 1 part a
SELECT COUNT(DISTINCT skuinfo.sku) AS SKU_COUNT
FROM (skuinfo JOIN skstinfo ON skuinfo.sku=skstinfo.sku) JOIN trnsact ON skuinfo.sku=trnsact.sku;

--Question 1 part b
SELECT COUNT(*) AS SKU_INSTANCE
FROM trnsact JOIN skstinfo ON trnsact.sku=skstinfo.sku AND trnsact.store=skstinfo.store;

--Question 2 part a
SELECT COUNT(DISTINCT store) AS STORE_COUNT FROM strinfo;   --1
SELECT COUNT(DISTINCT store) AS STORE_COUNT FROM store_msa; --3
SELECT COUNT(DISTINCT store) AS STORE_COUNT FROM skstinfo;  --2
SELECT COUNT(DISTINCT store) AS STORE_COUNT FROM trnsact;   --4

--Question 2 part b
SELECT DISTINCT strinfo.store AS strinfo_store, store_msa.store AS store_msa_store, skstinfo.store AS skstinfo_store, trnsact.store AS trnsact_store
FROM (strinfo FULL JOIN store_msa ON strinfo.store=store_msa.store) FULL JOIN (skstinfo FULL JOIN trnsact ON skstinfo.store=trnsact.store) ON strinfo.store=trnsact.store
GROUP BY 1, 2, 3, 4;

--Question 3
SELECT trnsact.*
FROM trnsact LEFT JOIN skstinfo ON trnsact.sku=skstinfo.sku
WHERE skstinfo.sku IS NULL

--Question 4
SELECT SUM(trnsact.amt-trnsact.quantity*skstinfo.cost)/COUNT(DISTINCT trnsact.saledate) AS profitPerDay
FROM trnsact JOIN skstinfo ON trnsact.sku=skstinfo.sku AND trnsact.store=skstinfo.store
WHERE trnsact.stype='P'

--Question 5 part a
SELECT saledate, SUM(amt) AS totalReturned
FROM trnsact
WHERE stype='R'
GROUP BY 1
ORDER BY 2 DESC;

--Question 5 part b
SELECT saledate, SUM(quantity) AS returnCount
FROM trnsact
WHERE stype='R'
GROUP BY 1
ORDER BY 2 DESC;

--Question 6
SELECT MAX(cost), MIN(cost)
FROM skstinfo

--Question 7
SELECT deptinfo.deptdesc, COUNT(DISTINCT skuinfo.brand) AS brandCount
FROM deptinfo JOIN skuinfo ON deptinfo.dept=skuinfo.dept
GROUP BY 1
HAVING brandCount>100;

--Question 8
SELECT DISTINCT skstinfo.sku, deptinfo.deptdesc
FROM (skstinfo JOIN skuinfo ON skstinfo.sku=skuinfo.sku) JOIN deptinfo ON skuinfo.dept=deptinfo.dept

--Question 9
SELECT deptinfo.deptdesc, skuinfo.brand, skuinfo.style, skuinfo.color, SUM(trnsact.amt)
FROM (deptinfo JOIN skuinfo ON deptinfo.dept=skuinfo.dept) JOIN trnsact ON skuinfo.sku=trnsact.sku
WHERE trnsact.stype='R'
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC

--Question 10
SELECT strinfo.state, strinfo.city, strinfo.zip, SUM(trnsact.amt)
FROM strinfo JOIN trnsact ON strinfo.store=trnsact.store
GROUP BY strinfo.store, 1, 2, 3
ORDER BY 4 DESC