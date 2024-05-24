/*
	Created:	20240513@Randy.Nguyen
	Task :		Create script to create CC2800 - Early Warning Members
	DB:			CTS_DataCenter
	
	Revisions:
			-   20240513@Randy.Nguyen: Created
*/
-- Step 1: Insert D.Score into table source
USE CTS_DataCenter;
-- Insert and Update Dangerous Score
DELETE FROM Customer_DangerousScore 
WHERE
    custid IN (1280 , 1282,1284,1287,1290,1295,1296,1297,1299,1301);
CALL CTS_DC_Customer_DangerousScore_Insert_xpre              -- Satisfied D.Score is between 0.45 and 0.95
(@ip_IsLicensee := 0,
@ip_CustInfo :='[
{"CustID":1301,"DangerousScore":0.45}
,{"CustID":1299,"DangerousScore":0.45}
,{"CustID":1297,"DangerousScore":0.45}
,{"CustID":1296,"DangerousScore":0.75}
,{"CustID":1295,"DangerousScore":0.44}
,{"CustID":1290,"DangerousScore":0.96}
,{"CustID":1287,"DangerousScore":0.5}
,{"CustID":1284,"DangerousScore":0.45}
,{"CustID":1282,"DangerousScore":0.50}
,{"CustID":1280,"DangerousScore":0.5}
]');

SELECT 
    C.CTSCustid, C.UserName, D.*
FROM
    Customer_DangerousScore AS D
        INNER JOIN
    CTSCustomer AS C ON D.CustID = C.CustID
ORDER BY D.LastModifiedDate DESC
LIMIT 15;

SELECT * FROM CTS_DataCenter.SystemParameter where ParameterID in (153,154);

-- Step 2: Start Job "CC.CTS_CustomerClassification_Daily_DangerousToCCScan"

-- Step 3 : Check Username in CTS



;


select cus.username ,l.* from CustomerClassification_Log (nolock) as l
inner join CustomerClassification_ScannedNewCust (nolock) as n on l.CustId = n.CustId
left join [bodb02].[dbo].[Custinfo]  (nolock) as cus on cus.custid = l.custid
where (l.CreatedTime between '2024-05-15 23:29:10.780' and '2024-05-16 00:00:00.000') and n.JobScannedType = 2;