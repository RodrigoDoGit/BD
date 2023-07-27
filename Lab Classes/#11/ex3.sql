SELECT Title
FROM MOVIE
WHERE
 MovieId IN (
  SELECT MovieId
  FROM MOVIE_GENRE
  NATURAL JOIN GENRE
  WHERE Label = 'Action'
 )

 AND MovieId IN (
  SELECT MovieId
  FROM MOVIE_GENRE
  NATURAL JOIN GENRE
  WHERE Label = 'Comedy'
 )
ORDER BY Title;
