
-- getChargeValue
DROP FUNCTION IF EXISTS getChargeValue;
DELIMITER $

CREATE FUNCTION getChargeValue(stream_time DATETIME, movie_duration INT)
RETURNS DECIMAL(4,2)
BEGIN
  DECLARE c DECIMAL(4,2);
  SET c = 0.5 + 0.01 * movie_duration;
  IF HOUR(stream_time) >= 21 THEN
    SET c = c + 0.75;
    -- Obs.: WEEKDAY retorna valor de 0 a 6 (Seg. a Domingo)
    -- 6ª feira = 4
    IF WEEKDAY(stream_time) >= 4 THEN
      SET c = c + 0.75;
    END IF;
  END IF;
  RETURN c;
END $
DELIMITER ;


-- getChargeValue_v2 (variante - movie_id como parâmetro)
DROP FUNCTION IF EXISTS getChargeValue_v2;
DELIMITER $

CREATE FUNCTION getChargeValue_v2(stream_time DATETIME, movie_id INT)
RETURNS DECIMAL(4,2)
BEGIN
  DECLARE c DECIMAL(4,2);
  DECLARE movie_duration INT;
  SELECT Duration INTO movie_duration
  FROM MOVIE WHERE MovieId = movie_id;
  SET c = 0.5 + 0.01 * movie_duration;
  IF HOUR(stream_time) >= 21 THEN
    SET c = c + 0.75;
    IF WEEKDAY(stream_time) >= 4 THEN
      SET c = c + 0.75;
    END IF;
  END IF;
  RETURN c;
END $

DELIMITER ;

-- registerMovieStream

DROP PROCEDURE IF EXISTS registerMovieStream;
DELIMITER $
CREATE PROCEDURE registerMovieStream
(IN movie_id INT,  IN customer_id INT,  IN time DATETIME,
 OUT charge DECIMAL(4,2), OUT stream_id INT)
BEGIN
  DECLARE d INT;
  -- Obtém duração do filme.
  SELECT Duration INTO d FROM MOVIE WHERE MovieId = movie_id;
  -- Obtém valor a cobrar usando função getChargeValue()
  SET charge = getChargeValue(time, d);
  -- Insere registo na tabela STREAM.
  INSERT INTO STREAM(CustomerId, MovieId, StreamDate, Charge)
  VALUES(customer_id, movie_id, time, charge);
  -- Obtém id de registo inserido (função LAST_INSERT_ID)
  SET stream_id = LAST_INSERT_ID();
END $
DELIMITER ;

DROP TRIGGER IF EXISTS validateMovieInsertion;

DELIMITER $

CREATE TRIGGER validateMovieInsertion
BEFORE INSERT ON MOVIE FOR EACH ROW
BEGIN
  -- 99999 designa um código de erro da aplicação
  DECLARE error CONDITION FOR SQLSTATE '99999'; 
  -- Valida ano
  IF NEW.Year < 1900 THEN
    SIGNAL error SET MESSAGE_TEXT = 'Invalid year!';
  END IF;
  -- Valida duração
  IF NEW.Duration <= 0 THEN
    SIGNAL error SET MESSAGE_TEXT = 'Invalid duration!';
  END IF;
END $
DELIMITER ; 

DROP TABLE IF EXISTS OPERATION_LOG;
CREATE TABLE OPERATION_LOG
(
  OpLogId INT NOT NULL AUTO_INCREMENT, 
  Time DATETIME NOT NULL,
  Event ENUM ('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  TableName VARCHAR(128) NOT NULL,
  EntryId INT NOT NULL,
  PRIMARY KEY(OpLogId)
);

DROP TRIGGER IF EXISTS beforeMovieInsertion;
DELIMITER $

CREATE TRIGGER beforeMovieInsertion
BEFORE INSERT ON MOVIE FOR EACH ROW
BEGIN
  -- 99999 designa um código de erro da aplicação
  DECLARE error CONDITION FOR SQLSTATE '99999';
  -- Valida ano
  IF NEW.Year < 1900 THEN
    SIGNAL error SET MESSAGE_TEXT = 'Invalid year!';
  END IF;
  -- Valida duração
  IF NEW.Duration <= 0 THEN
    SIGNAL error SET MESSAGE_TEXT = 'Invalid duration!';
  END IF;
END $
DELIMITER ;

DROP TRIGGER IF EXISTS logMovieIns;
DELIMITER $

CREATE TRIGGER logMovieIns
AFTER INSERT
ON MOVIE
FOR EACH ROW
BEGIN
   INSERT INTO OPERATION_LOG(Time, Event, TableName, EntryId)
   VALUES(NOW(), 'INSERT', 'MOVIE', NEW.MovieId);
END $

DELIMITER ;


DROP PROCEDURE IF EXISTS ensureNotDepartmentManager;
DELIMITER $

CREATE PROCEDURE
ensureNotDepartmentManager(IN staff_id INT)
BEGIN 
  DECLARE is_manager BOOL;
  DECLARE error CONDITION FOR SQLSTATE '99999'; 
  SET is_manager = FALSE;
  SELECT TRUE INTO is_manager 
  FROM DEPARTMENT WHERE Manager = staff_id;
  IF is_manager THEN
    SIGNAL error 
    SET MESSAGE_TEXT = 'No staff member can supervise more than one department!';
  END IF;
END $

DELIMITER ;  

DROP TRIGGER IF EXISTS beforeDepartmentUpdate;
DROP TRIGGER IF EXISTS beforeDepartmentInsert;
DELIMITER $

CREATE TRIGGER beforeDepartmentUpdate 
BEFORE UPDATE ON DEPARTMENT FOR EACH ROW
BEGIN
  IF NEW.Manager <> OLD.Manager THEN
    CALL ensureNotDepartmentManager(NEW.Manager);
  END IF;
END $

CREATE TRIGGER beforeDepartmentInsert 
BEFORE INSERT ON DEPARTMENT FOR EACH ROW
BEGIN
  CALL ensureNotDepartmentManager(NEW.Manager);
END $

DELIMITER ;

DROP TRIGGER IF EXISTS beforeCustomerDelete;
DELIMITER $

CREATE TRIGGER beforeCustomerDelete
BEFORE DELETE ON CUSTOMER FOR EACH ROW
BEGIN
  DECLARE error CONDITION FOR SQLSTATE '99999'; 
  IF OLD.ACTIVE = TRUE THEN
    SIGNAL error 
    SET MESSAGE_TEXT = 'Not allowed!';
  ELSE
    DELETE FROM STREAM WHERE CustomerId=OLD.CustomerId;
  END IF;
END $

DELIMITER ;

