SELECT DISTINCT CUSTOMER.Name AS Nome
FROM STREAM
 JOIN CUSTOMER USING(CustomerId)
 JOIN MOVIE USING(MovieId)
WHERE Duration >= 180 AND HOUR(StreamDate) >= 20
ORDER BY Nome ASC;
