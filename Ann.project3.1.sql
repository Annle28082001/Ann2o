--bai1
SELECT 
	productline,
	year_id,
	dealsize,
	sum(sales) as revenue
	FROM sales_dataset_rfm_prj_clean
GROUP BY productline,
	year_id,
	dealsize
--bai2
SELECT 
    year_id,
    month_id,
    revenue,
    ordernumber
FROM (
    SELECT 
        year_id,
        month_id,
        SUM(sales) AS revenue,
        COUNT(ordernumber) AS ordernumber,
        RANK() OVER(PARTITION BY year_id ORDER BY SUM(sales) DESC) AS revenue_rank
    FROM 
        sales_dataset_rfm_prj_clean
    GROUP BY 
        year_id, month_id
) AS ranked_sales
WHERE revenue_rank = 1
ORDER BY 
    year_id, month_id;
--bai3: Classic one

SELECT 
	productline
	FROM
(SELECT 
	productline,
	month_id,
	count(ordernumber) as so_luong,
    sum(sales) as revenue
	FROM sales_dataset_rfm_prj_clean
	GROUP BY productline, month_id) as a
WHERE month_id = 11
ORDER BY so_luong DESC
LIMIT 1

--bai 4
SELECT 
	productline,
	year_id,
	revenue FROM
(SELECT 
	productline,
	year_id,
	sum(sales) as revenue,
	RANK() OVER (PARTITION BY year_id ORDER BY sum(sales) DESC) as ranking
	from  sales_dataset_rfm_prj_clean
	GROUP BY year_id, productline) as a
WHERE ranking = 1

--bai5
/*5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
(sử dụng lại bảng customer_segment ở buổi học 23)
*/
/*Bước 1: Tính giá trị R-F-M*/
WITH customer_rfm AS
(SELECT 
	customername,
	current_date-MAX(orderdate) as R,
	COUNT(ordernumber) as F,
	SUM(sales) as M
	FROM sales_dataset_rfm_prj_clean
	GROUP BY customername)
, rfm_score as
(SELECT customername,
Ntile(5) OVER(ORDER BY R DESC) AS R_score,
Ntile(5) OVER(ORDER BY F) AS F_score,
Ntile(5) OVER(ORDER BY M) AS M_score
FROM customer_rfm)
,rfm_final as
	(SELECT customername,
cast(R_score as varchar)|| cast(F_score as varchar)|| cast(M_Score as varchar) AS rfm_score
FROM rfm_score)

SELECT customername FROM(
SELECT customername,
CAST(rfm_score as numeric) as rfm_score_1
FROM rfm_final) AS a
WHERE rfm_score_1 = 555
