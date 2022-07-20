SELECT Title AS Título, Name AS Nome
FROM MOVIE_ACTOR
 JOIN MOVIE USING(MovieId)
 JOIN ACTOR USING(ActorId)
WHERE
 MovieId IN(
  SELECT MovieId FROM MOVIE_ACTOR
  JOIN ACTOR USING(ActorId)
  WHERE Name = 'Johnny Depp' 
  GROUP BY Name
 )

 AND Name != 'Johnny Depp'
ORDER BY Título ASC, Nome ASC;
