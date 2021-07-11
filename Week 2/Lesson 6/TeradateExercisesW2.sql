--Question 1
HELP TABLE trnsact;
SHOW TABLE trnsact;
--repeat this for all the tables

--Question 2
SELECT *
FROM deptinfo
SAMPLE 14;

SELECT *
FROM skstinfo
SAMPLE 14;

SELECT *
FROM skuinfo
SAMPLE 14;
--pay attention to this one

SELECT *
FROM store_msa
SAMPLE 14;

SELECT *
FROM strinfo
SAMPLE 14;

SELECT *
FROM trnsact
SAMPLE 14;

--Question 3
SELECT DISTINCT * FROM deptinfo;
SELECT DISTINCT * FROM skstinfo;
SELECT DISTINCT * FROM skuinfo;
SELECT DISTINCT * FROM store_msa;
SELECT DISTINCT * FROM strinfo;
SELECT DISTINCT * FROM trnsact;

--Question 4
SELECT * FROM trnsact WHERE amt<>sprice;
--the spice decreases when there is a higher quantity
--not sure about how AMT relates

--Question 5
SELECT * from trnsact WHERE orgprice=0;           --a
SELECT * from skstinfo WHERE cost=0 AND retail=0; --b
SELECT * from skstinfo WHERE cost>retail;         --c

--Question 6
SELECT *
FROM skuinfo
ORDER BY packsize
WHERE color IN ('black', 'blue');
SAMPLE .10;

SELECT sprice, saledate
FROM trnsact
WHERE saledate<'2005-04-15'
SAMPLE .10;