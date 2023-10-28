/*As a result of 1.Join.sql*/
/*Following template has been used to migrate into the template*/

/*Make sure 
1.to convert Date column to "yyyy-mm-dd hh:mm" via Excel
2.to convert Date column to 'Integer' on Database

Sometimes the hour difference (between NZ and USA)can change because of summertime*/

SELECT strftime('%d-%m-%Y %H:%M',Created,'+12 hour') AS PaidDate, 
(CASE WHEN TransactionType IS 'merchandise' THEN sum(UnitCost) ELSE sum(PaidAmount)END) AS Amount, 
sum(ShopContribution) As ShouldBeZero, EventCode, Description
FROM Matched
/*Filter PaymentGateway Fee and withdrwals*/
WHERE (Identifier IS NULL AND PaymentGatewayType IS 'Something')
GROUP BY (CASE WHEN EventCode LIKE 'Example%'
THEN 'Categorise' ELSE Eventcode END),strftime("%m-%Y",Created)
ORDER BY EventCode