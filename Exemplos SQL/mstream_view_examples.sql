

DROP VIEW IF EXISTS COUNTRY_DATA;


CREATE VIEW COUNTRY_DATA    
(Name, Region, Customers) 
AS       
  SELECT COUNTRY.Name, REGION.Name, COUNT(*)      
  FROM 
     COUNTRY JOIN REGION USING(RegionId) 
             JOIN CUSTOMER ON(CUSTOMER.Country=COUNTRY.Name)    
  GROUP BY COUNTRY.Name     
  ORDER BY COUNTRY.Name 
;

DROP VIEW IF EXISTS MOVIE_DATA;

CREATE VIEW MOVIE_DATA
(Title, Year, Actors, Genres)
AS 
  SELECT M.Title, 
         M.Year, 
         A.Actors, 
         G.Genres
  FROM 
    MOVIE M
  NATURAL JOIN (
    SELECT MovieId, GROUP_CONCAT(Name) AS Actors
    FROM ACTOR NATURAL JOIN MOVIE_ACTOR
    GROUP BY MovieId
  ) A
  NATURAL JOIN (
    SELECT MovieId, GROUP_CONCAT(Label) AS Genres
    FROM GENRE NATURAL JOIN MOVIE_GENRE
    GROUP BY MovieId
  ) G
;
