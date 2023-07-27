DROP FUNCTION IF EXISTS bonus;
DELIMITER $

CREATE FUNCTION bonus(staff_id INT, year INT)
RETURNS INT
BEGIN
  DECLARE value INT;
  DECLARE nstreams INT;
  DECLARE nsuper INT;
  DECLARE nregion INT;

  SELECT COUNT(StreamId) into nstreams
  FROM STREAM
  WHERE Year(StreamDate) = year AND Month(StreamDate) = 12;

  SELECT COUNT(StaffId) into nsuper
  FROM STAFF
  WHERE Supervisor = staff_id;

  SELECT COUNT(RegionId) into nregion
  FROM REGION
  WHERE RegionManager = staff_id;

  SET value = nstreams * (nsuper + nregion + 1);
  
  IF(value < 300) THEN
    SET value = 300;
  END IF;

  IF(value > 2000) THEN
    SET value = 2000;
  END IF;

  RETURN value;
END$
DELIMITER ;

SELECT StaffId, bonus(StaffId,2017), bonus(StaffId,2018)
FROM STAFF ORDER BY StaffId;

