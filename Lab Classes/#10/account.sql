
USE rodrigo;
DROP TABLE IF EXISTS ACCOUNT;

CREATE TABLE ACCOUNT 
(
  AccountId INT PRIMARY KEY,
  Value INT 
);

INSERT INTO ACCOUNT(AccountId, Value)
VALUES (1, 100), 
       (2, 200), 
       (3, 300), 
       (4, 400), 
       (5, 500);

DROP PROCEDURE IF EXISTS transfer;

DELIMITER $
CREATE PROCEDURE transfer(IN id1 INT, IN id2 INT, IN amount INT, OUT done BOOLEAN) 
BEGIN

  DECLARE Valor INT;

  SELECT Value INTO Valor
  FROM ACCOUNT
  WHERE AccountId = id1;

  START TRANSACTION;

  UPDATE ACCOUNT 
  SET Value = Value - amount 
  WHERE AccountId = id1;

  UPDATE ACCOUNT 
  SET Value = Value + amount 
  WHERE AccountId = id2;

  IF (id1 < 1 OR id1 > 5 OR id2 < 1 OR id2 > 5) THEN
    SET DONE = FALSE;
    ROLLBACK;
  END IF;

  IF (Valor < amount) THEN
    SET DONE = FALSE;
    ROLLBACK;
  END IF;

  IF (id1 = id2) THEN
    SET DONE = FALSE;
    ROLLBACK;
  END IF;
  
  SET DONE = TRUE;
  COMMIT;
END $

DELIMITER ;

