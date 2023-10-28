/*Hauling all platforms and join all raw data*/

SELECT
MainData.MainDataID, 
MainData.AccountName AS AccountNameInMainData, 
MainData.Email AS MainDataPrimaryEmail, 
PaymentGateway.Type AS PaymentGatewayType, 
PaymentGateway.ID AS PaymentGatewayID, 
PaymentGateway.Created, 
PaymentGateway.Description, 
(CASE WHEN CMSFirst.TransactionType IS NULL THEN 'donation' ELSE CMSFirst.TransactionType END) AS TransactionType,
(CASE WHEN PaymentGateway.Type IS 'Refund' THEN PaymentGateway.Amount ELSE 
(CASE WHEN row_number() OVER(PARTITION BY PaymentGateway.ID ORDER BY CMSSecond.donationId DESC) = 1 THEN PaymentGateway.Amount ELSE 0 END)END)
 AS PaidAmount,
PaymentGateway.currency, 
(CASE WHEN PaymentGateway.Type IS 'Refund' THEN PaymentGateway.ConvertedAmount ELSE 
(CASE WHEN row_number() OVER(PARTITION BY PaymentGateway.ID ORDER BY CMSSecond.donationId DESC) = 1 THEN PaymentGateway.ConvertedAmount ELSE 0 END)END)AS ConvertedAmount,
(CASE WHEN PaymentGateway.Type IS 'Refund' THEN PaymentGateway.Fees ELSE 
(CASE WHEN row_number() OVER(PARTITION BY PaymentGateway.ID ORDER BY CMSSecond.donationId DESC) = 1 THEN PaymentGateway.Fees ELSE 0 END)END)AS PaymentGatewayFees,
(CASE WHEN PaymentGateway.Type IS 'Refund' THEN PaymentGateway.Net ELSE 
(CASE WHEN row_number() OVER(PARTITION BY PaymentGateway.ID ORDER BY CMSSecond.donationId DESC) = 1 THEN PaymentGateway.Net ELSE 0 END)END)AS Net,
PaymentGateway.ConvertedCurrency, 
PaymentGateway.Details AS CardHolder,
PaymentGateway.CustomerID AS PaymentGatewayCustomerID, 
SHOP.Quantity AS ShopQuantity,
Shop.GST,
Shop.UnitCost,
Shop.OptionalContributionFee AS ShopContribution,  
shop.ProductName AS ShopProductName,

(CASE WHEN CMSFirst.PoNumber IS NULL THEN 
(CASE WHEN CMSSecond.donationId IS NULL THEN (
CASE WHEN CMSthird.DonatableID IS NULL THEN (
CASE WHEN CMSFourth.GatewayChargeID IS NULL THEN 
'' ELSE 'CMSFourth:' END)
ELSE'CMSthird:' || CMSthird.DonationID END) ELSE 
'CMSSecond:'||CMSSecond.donationId END)
ELSE 'CMSFirst:' || CMSFirst.PoNumber END) DonationReference,

(CASE WHEN Donation.IsAnonymous IS NULL THEN CMSSecond.isAnonymous 
ELSE Donation.IsAnonymous END)As isAnonymous,
(CASE
WHEN CMSFirst.Company IS NULL THEN CMSSecond.businessName 
ELSE CMSFirst.Company
END)As Organisation,
(CASE WHEN CMSFirst.firstName IS NULL THEN (
CASE WHEN CMSSecond.firstName IS NULL THEN CMSFourth.UserFirstName 
ELSE CMSSecond.firstName END)
ELSE CMSFirst.firstName
END)As FirstName,
(CASE
WHEN CMSFirst.lastName IS NULL THEN (
CASE WHEN CMSSecond.lastName IS NULL THEN CMSFourth.UserLastName 
ELSE CMSSecond.lastName END)
ELSE CMSFirst.lastName
END)As LastName,
CMSthird.DonorName AS CMSthirdDonorName,

(CASE WHEN CMSFirst.EmailAddress IS NULL THEN 
(CASE WHEN CMSSecond.email IS NULL THEN (
CASE WHEN CMSthird.DonorEmail IS NULL THEN lower(CMSFourth.UserEmail)
ELSE CMSthird.DonorEmail END) ELSE CMSSecond.email END) 
ELSE lower(CMSFirst.EmailAddress) END)As Email,

(CASE WHEN CMSFirst.Address IS NULL THEN (CASE WHEN CMSSecond.street IS NULL THEN '' ELSE CMSFourth.UserAddress1 END) 
ELSE CMSFirst.Address END) AS Address, 
(CASE WHEN CMSFourth.UserAddress2 IS NULL THEN CMSFirst.AddressTwo ELSE CMSFourth.UserAddress2 END) AS AddressTwo, 
(CASE WHEN  CMSFirst.Suburb IS NULL THEN (CASE WHEN CMSSecond.City IS NULL THEN '' ELSE CMSFourth.UserSuburb END)
ELSE CMSFirst.Suburb END) AS SuburbOrCity, 
(CASE WHEN CMSFirst.Region IS NULL THEN (CASE WHEN CMSSecond.state IS NULL THEN '' ELSE CMSFourth.UserState END) 
ELSE CMSFirst.Region END) AS Region, 
(CASE WHEN CMSFirst.country IS NULL THEN (CASE WHEN CMSSecond.country IS NULL THEN '' ELSE CMSFourth.UserCountry END) 
ELSE CMSFirst.country END) AS Country, 
(CASE WHEN CMSFirst.PostCode IS NULL THEN (CASE WHEN CMSSecond.postCode IS NULL THEN '' ELSE CMSFourth.UserPostcode END)
ELSE CMSFirst.PostCode END) AS Postcode,
(CASE WHEN CMSFirst.Mobile IS NULL THEN CMSSecond.phoneNumber ELSE CMSFirst.Mobile END) AS MobilePhone,
(CASE WHEN CMSFirst.OptIn IS NULL THEN 
(CASE WHEN CMSSecond.newsletterOptIn IS NULL THEN CMSthird.CharityCanContact
ELSE CMSSecond.newsletterOptIn END) 
ELSE CMSFirst.OptIn END)As OptIn,
Donation.DonationReason,
(CASE WHEN PaymentGateway.Type LIKE 'Refund' THEN 'REFUND' ELSE
(CASE WHEN PaymentGateway.Type LIKE 'Charge' THEN  
(CASE WHEN CMSFirst.DonationType LIKE 'recurring' THEN 'REGULAR' ELSE
(CASE WHEN PaymentGateway.Description LIKE '%EventName%' THEN 'Event-code1' ELSE 
(CASE WHEN PaymentGateway.Description LIKE '%Another Event%' THEN 'Event-code2' ELSE
(CASE WHEN PaymentGateway.Description LIKE '%Another Event2%' THEN 'Event-code3' ELSE 
(CASE WHEN CMSFirst.PageID LIKE '1234' THEN (CASE WHEN CMSFirst.Company IS NULL THEN 'GENERAL' ELSE 'ORGANISATION' END) ELSE
(CASE WHEN CMSFirst.TransactionType LIKE 'merchandise' THEN 
(CASE WHEN Shop.ProductName LIKE '%Product Name%' THEN 'Categorise' ELSE 'General' END) ELSE 
(CASE WHEN CMSFirst.Category LIKE 'Page Name' THEN 'General Comms' ELSE 
(CASE WHEN Donation.EventCode LIKE '%Campaign Name%' THEN (CASE WHEN Organisations.MemberType IS NOT NULL THEN 'Campaign-code1' || Organisations.MemberType ELSE 'CAM-PSD' END)
ELSE CMSFirst.EventCode END)
END)END)END)END)END)END)END)
ELSE '' END)END)As EventCode, CMSFirst.PageName AS PageName,

(CASE WHEN CMSFirst.EventName IS NULL THEN CMSSecond.campaignName ELSE (CASE WHEN CMSSecond.campaignName IS NULL THEN CMSthird.CampaignName ELSE CMSFirst.EventName END)END) AS EventName

FROM PaymentGateway
LEFT Join CMSFirst 
ON (PaymentGateway.ID = CMSFirst.PaymentGatewayPaymentReference)
LEFT JOIN Donation
ON (PaymentGateway.ID = Donation.PaymentGatewayPaymentReference)
LEFT JOIN CMSSecond
ON (PaymentGateway.ID = CMSSecond.paymentPlatformChargeId)
LEFT JOIN CMSthird
ON (PaymentGateway.ID = CMSthird.TransactionID)
LEFT JOIN Shop
ON (PaymentGateway.ID = Shop.PaymentReference)
LEFT JOIN MainData
ON (lower(CMSFirst.EmailAddress) = lower(MainData.Email)) OR (lower(CMSFirst.EmailAddress) = lower(MainData.EmailAlt)) OR (lower(Shop.Email) =lower(MainData.Email)) 
OR (lower(Shop.Email)=lower(MainData.EmailAlt)) OR (lower(CMSSecond.email)=lower(MainData.Email)) OR (lower(CMSSecond.email)=lower(MainData.EmailAlt))
LEFT JOIN CMSFourth
ON (PaymentGateway.ID = CMSFourth.GatewayChargeID)
LEFT JOIN Organisations
ON (Donation.OrgID = Organisations.OrgID)

ORDER BY CMSFirst.EventCode