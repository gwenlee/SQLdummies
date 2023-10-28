/*As a result of 1.Join.sql*/
/*This code allows to update your Recent Identifier per download*/

UPDATE Matched
SET Identifier = (CASE WHEN Matched.Identifier IS NULL THEN (SELECT Identifier
FROM Main
WHERE lower(Matched.email) = lower(Main.Email) OR lower(Matched.email) = lower(Main.EmailAlt))
ELSE Identifier END)