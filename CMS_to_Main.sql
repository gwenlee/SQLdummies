
/*Template example for merging various platforms*/

SELECT  MainID, CMSFirst.firstName, CMSFirst.lastName, CMSFirst.Email, CMSFirst.DateAccountCreated, CMSFirst.EventCode AS EventCode, 
CMSFirst.CombinedStreet AS StreetName,CMSFirst.Suburb, CMSFirst.State, CMSFirst.Postcode,(CASE WHEN CMSFirst.Phone IS NULL THEN CMSFirst.Mobile ELSE CMSFirst.Phone END) AS MobilenNumber, CMSFirst.Optin, 
CMSFirst.TeamName, CMSFirst.TeamURL, CMSFirst.FundraiserURL

FROM CMSFirst
LEFT JOIN Main
ON lower(CMSFirst.Email) = lower(Main.Email) or lower(CMSFirst.Email) = lower(Main.EmailAlt)
WHERE Eventcode LIKE 'CompanyName%' AND CMSFirst.IsActive IS 'Y' AND CMSFirst.IsComplete IS 'Y'

UNION 

SELECT MainID, CMSSecond.firstName, CMSSecond.lastName, CMSSecond.email, substr(CMSSecond.createdAtLocal,1,10) AS CreatedDate, CMSSecond.campaignName, 
CMSSecond.street, CMSSecond.city, CMSSecond.state, CMSSecond.postcode, CMSSecond.phoneNumber, CMSSecond.newsletterOptIn, 
CMSSecond.pageTeamName, CMSSecond.pageTeamUrl, CMSSecond.pageFundraiserUrl
FROM CMSSecond
LEFT JOIN Main
ON lower(CMSSecond.Email) = lower(Main.Email) or lower(CMSSecond.Email) = lower(Main.EmailAlt)
WHERE status IS 'Live'

