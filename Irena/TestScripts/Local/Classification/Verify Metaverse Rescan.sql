#PASS: @KeepTheFaith2209#
#DATA:
/*
(1) IF Role = Member --> Both Credit & Licensee
    ELSE --> Only Credit

(2) Priority CC (DESC):
VVIP: Super, Master, Agent, Member 
SpecialCC: Member
LicVIP: Member 
PA: Super, Master, Agent, Member 
CC3101: Member
CC305: Member 
CC2600: Member 
CC2700: Member
CC2800: Member
Robot: Super, Master, Agent, Member   
OCRD: Member 
TW - Group Betting: Member
TW - High Rejected: Member
Ass Linked PA: Member
Ass Linked GB: Member
Ass Linked Robot: Member
LicBA: Member
Risky/Smart/Prob: Agent, Member 
Normal/Good/New: Agent, Member 
Inactive: Agent, Member 

(3) Show coexist together on WEB
SpecialCC + each CC (excl VVIP)
LicVIP + each CC
PA + CC3101 + CC305 + CC2600 + CC2700 + CC2800 + Robot + OCRD
CC2600 + CC2700 + CC2800
CC2600 + CC2700 + CC2800 + Robot + OCRD

(4) Case
- Super (5 cust): 
VVIP 
PA 
Robot 
PA&Robot 
VVIP&PA&Robot 
- Master (5 cust): 
VVIP
PA
Robot
PA&Robot
VVIP&PA&Robot  
- Agent (12 cust):  
VVIP  
PA 
Robot 
PA&Robot 
VVIP&PA&Robot 
Risky 
Smart
Prob
Normal
Good 
New
Inactive  
- Member (53 cust):  
VVIP  
PA 
CC3101 (only licensee)
CC305 
CC2600 (only licensee)
CC2700 (only licensee)
CC2800
Robot
OCRD 
PA&CC3101 (only licensee)
PA&CC305 
PA&CC2600 (only licensee)
PA&CC2700 (only licensee)
PA&CC2800 
PA&Robot 
PA&OCRD  
PA&CC305&CC2800&Robot&OCRD
PA&CC3101&CC305&CC2600&CC2700&CC2800&Robot&OCRD (only licensee)
CC2600&CC2700&CC2800 (only licensee)
VVIP&PA&CC305&CC2800&Robot&OCRD 
VVIP&PA&CC3101&CC305&CC2600&CC2700&CC2800&Robot&OCRD (only licensee)
TW - Group Betting (both 7,8) 
TW - High Rejected (only 8) 
Ass Linked PA (both 10,13) 
Ass Linked GB (both 8,13) 
Ass Linked Robot (only 13) 
Risky 
Smart 
VVIP&Risky&Smart 
Prob 
Normal
Good 
New 
Inactive
SpecialCC&PA 
SpecialCC&CC2800
SpecialCC&Robot 
SpecialCC&TW - Group Betting 
SpecialCC&Ass Linked PA 
SpecialCC&Risky 
SpecialCC&New 
SpecialCC&Inactive
LicVIP&PA 
LicVIP&CC2700 (only licensee)
LicVIP&Robot 
LicVIP&TW - High Rejected 
LicVIP&Ass Linked GB 
LicVIP&Smart 
LicVIP&Normal 
LicVIP&Inactive
LicBA&Prob
LicBA&Good 
LicBA&Inactive
*/
/*CHOOSE*/
select * from CTS_DataCenter.CTSCustomer where roleid=4 and custsubid = 0 and islicensee = 0 and currencyid <> 20 and SubscriberID is not null order by custid asc limit 100; -- super
select * from CTS_DataCenter.CTSCustomer where roleid=3 and custsubid = 0 and islicensee = 0 and currencyid <> 20 and SubscriberID is not null order by custid asc limit 100; -- master
select * from CTS_DataCenter.CTSCustomer where roleid=2 and custsubid = 0 and islicensee = 0 and currencyid <> 20 and SubscriberID is not null order by custid asc limit 100; -- agent
select * from CTS_DataCenter.CTSCustomer where roleid=1 and custsubid = 0 and islicensee = 0 and currencyid <> 20 and SubscriberID is not null order by custid asc limit 100; -- member credit
select * from CTS_DataCenter.CTSCustomer where roleid=1 and custsubid = 0 and islicensee = 1 and currencyid <> 20 and SubscriberID is not null order by custid asc limit 100; -- member licensee
select * from CTS_DataCenter.SystemParameter where ParameterID IN (7,8,92,93); 

/*CLEAN UP*/
DROP TEMPORARY TABLE IF EXISTS Temp_Customers;
CREATE TEMPORARY TABLE 		Temp_Customers (
		CustID BIGINT UNSIGNED, CTSCustID BIGINT UNSIGNED, SubscriberID INT UNSIGNED, RoleID  INT UNSIGNED
);
set @ListCustID = '211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056';
SET @sql = 	CONCAT("INSERT IGNORE INTO Temp_Customers (CustID) VALUES ('", REPLACE(@ListCustID, ",", "'),('"),"');");
PREPARE stmt1 FROM @sql;
EXECUTE stmt1;      

update Temp_Customers temp
	inner join CTS_DataCenter.CTSCustomer c on temp.CustID = c.CustID
set temp.CTSCustID = c.CTSCustID, temp.SubscriberID = c.SubscriberID, temp.RoleID  = c.RoleID;

delete c from CTS_DataCenter.CTSCustomerClassification_BySport c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassification c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassificationAgency c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassification_BySport_History c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassification_History c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassificationAgency_History c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassification_BySport_Log c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassification_Log c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassificationAgency_Log c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSCustomerClassificationQueue c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.RobotDetection c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSRobotUser c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.TWRobotUser c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.TVSVoidRequest c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.SpecialCustomerClass c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.CTSRobotUser c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.Customer_DangerousScore c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.Customer_InitialSmart c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete c from CTS_DataCenter.Customer_InitialGroupBetting c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
delete e from CTS_DataCenter.CustEvidence as e where exists (select 1 from CTS_DataCenter.CTSCustomer as c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID) and e.CTSCustID = c.CTSCustID);

/*CHECK RESULT*/
select * from CTS_DataCenter.CTSCustomer c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassification_BySport c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassification c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassificationAgency c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassification_BySport_History c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassification_History c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassificationAgency_History c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassification_BySport_Log c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassification_Log c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassificationAgency_Log c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSCustomerClassificationQueue c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.RobotDetection c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSRobotUser c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.TWRobotUser c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.TVSVoidRequest c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.SpecialCustomerClass c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CTSRobotUser c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.Customer_DangerousScore c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.Customer_InitialSmart c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.Customer_InitialGroupBetting c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
select * from CTS_DataCenter.CustEvidence as e where exists (select 1 from CTS_DataCenter.CTSCustomer as c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID) and e.CTSCustID = c.CTSCustID);

/*Option 1: Insert New Customer */
-- import CustID
delete from CTS_DataCenter.CTSCustomer c where exists (select 1 from Temp_Customers temp where temp.CustID = c.CustID);
-- run metaverse

/*Option 2: Member - Push Customer Classification*/
-- import CustID (member)
-- run metaverse

/*Option 100: Agency - Push Customer Classification*/
-- import CustID (sma)
-- run metaverse

/*Option 3: Member - Rescan Customer Classification*/
-- import CustID (member)
-- prepare existing category
insert into CTS_DataCenter.CTSCustomerClassification (CustID,ParentID,CategoryID,CreatedDate,CreatedBy,LastScannedDate,IsMarkedDirectly,IsFromCTS,IsFromTVS,IsFromAI,IsFromTW,IsFromImperva) values
(1275,1000,1010,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1277,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1280,20000,21000,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1282,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),
(1284,20000,21200,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),
(1287,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1287,20000,21000,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1290,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1290,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),
(1295,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1295,20000,21100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1296,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1296,20000,21000,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1296,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),(1296,20000,21100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1296,20000,21200,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),
(1297,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1297,20000,21000,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1297,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),(1297,20000,21100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1297,20000,21200,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),(1297,1000,1010,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1299,40000,40404,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1301,40000,40403,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1302,40000,40500,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1304,40000,40500,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1304,1000,1010,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1305,40000,40400,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1306,40000,40300,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1307,40000,40100,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1308,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1308,10000,10300,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1309,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,1,0,0),(1309,10000,10300,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),
(1310,20000,21100,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1310,10000,10300,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1311,40000,40504,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1311,10000,10300,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1312,40000,40303,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1312,10000,10300,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1313,40000,40600,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1313,10000,10300,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1314,40000,40100,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1314,10000,10300,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1315,40000,40700,current_timestamp(),10278938,current_date(),1,0,0,0,0,0),(1315,10000,10300,current_timestamp(),10278938,current_date(),1,1,0,0,0,0);
insert into CTS_DataCenter.CTSCustomerClassification (CustID,ParentID,CategoryID,CreatedDate,CreatedBy,LastScannedDate,IsMarkedDirectly,IsFromCTS,IsFromTVS,IsFromAI,IsFromTW,IsFromImperva) values
(791050,20000,20900,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(791054,20000,30300,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),
(832131,20000,30200,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),
(832132,20000,21100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(832134,20000,30300,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),(832134,20000,30200,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),(832134,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),
(832138,20000,30200,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),(832138,20000,30200,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),
(835062,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),(835062,20000,30100,current_timestamp(),10278938,current_date(),1,0,0,0,1,0),
(835064,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835064,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(835067,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835067,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(835068,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835068,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835097,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(835098,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(835262,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(875429,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(876080,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(888234,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(888250,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1032813,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1033999,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1033999,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1038085,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1038085,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1038566,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1038566,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1039302,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1039302,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1039304,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1039304,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1048466,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1048466,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1051599,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1051599,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1051601,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1051601,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1051603,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),(1051603,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0),
(1053056,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0)(1053056,20000,20100,current_timestamp(),10278938,current_date(),1,1,0,0,0,0);



from Temp_Customers temp;
-- run metaverse



-- Existing category
insert into CTS_DataCenter.CTSCustomerClassification (CTSCustID,CustID,SubscriberID,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,LastScannedDate,IsMarkedDirectly,IsFromCTS,RoleID,ParentID,CategoryID) 
select CTSCustID,CustID,SubscriberID,current_timestamp(),8,current_timestamp(),8,current_timestamp(),1,1,RoleID
       ,case when CustID IN (15, 5120527, 1574117, 4183, 6087105, 1574121, 31987, 7467827, 1574129) then 20000
             when CustID IN (8228116, 1574136, 1574143, 1574147) then 30000 
             when CustID IN (19542865, 1603807, 1574178, 1598461) then 10000
             when CustID IN (20661862, 1605594) then 1000
        end as  ParentID
       ,case when CustID IN (15, 5120527, 1574117) then 20100 -- gb
             when CustID IN (4183, 6087105, 1574121) then 20200 -- hed
             when CustID = 31987 then 20400 -- fg
             when CustID IN (7467827, 1574129) then 21100 -- robot
             when CustID IN (8228116, 1574136) then 30100 -- 2800
             when CustID = 1574143 then 30200 -- 2700
             when CustID = 1574147 then 30300 -- 2600
             when CustID = 1574178 then 10100 -- licba
             when CustID = 1598461 then 10201 -- licvip
             when CustID IN (19542865, 1603807) then 10300 -- special 
             when CustID IN (20661862, 1605594) then 1010 -- vvip
        end as CategoryID
from CTS_DataCenter.CTSCustomer
where custid in (15,4183,31987,5120527,6087105,7467827,8228116,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574178,1598461,1603807,1605594);

insert into CTS_DataCenter.CTSCustomerClassification (CTSCustID,CustID,SubscriberID,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,LastScannedDate,RoleID,ParentID,CategoryID) 
select CTSCustID,CustID,SubscriberID,current_timestamp(),10278938,current_timestamp(),10278938,current_timestamp(),RoleID
       ,40000 as  ParentID
       ,case when CustID IN (8590039, 1574152) then 40100 -- new
             when CustID IN (11668266, 1574158) then 40200 -- good
             when CustID IN (12228758, 1574165) then 40400 -- prob
             when CustID IN (18327723, 1574171) then 40600 -- risky
        end as CategoryID
from CTS_DataCenter.CTSCustomer
where custid in (8590039,11668266,12228758,18327723,1574152,1574158,1574165,1574171);

insert into CTS_DataCenter.SpecialCustomerClass(CTSCustID,CustID,RootCTSCustID,SubscriberID,CustomerClass,CreatedBy,CreatedDate,CreatedFromFunction)
select CTSCustID,CustID,CTSCustID,SubscriberID,11111,8,current_timestamp(),1 from CTS_DataCenter.CTSCustomer where custid in (19542865, 1603807);

insert into CTS_DataCenter.CTSRobotUser(CustID,CategoryID,IsDisabled,CreatedDate,InsertedTime)
select CustID,21100,0,current_timestamp(),current_timestamp() from CTS_DataCenter.CTSCustomer where CustID IN (7467827, 1574129);

insert into CTS_DataCenter.Customer_DangerousScore(CustID,IsLicensee,DangerousScore,CreatedDate,LastModifiedDate,ClassifiedScore,ClassifiedDate)
select CustID,IsLicensee,'0.9511',current_timestamp(),current_timestamp(),'0.9511',current_timestamp() from CTS_DataCenter.CTSCustomer where CustID IN (8228116, 1574136);

insert into CTS_DataCenter.Customer_InitialSmart(CustID,Probability,SourceCreatedDate,InsertedTime)
select CustID,'0.71',current_timestamp(),current_timestamp() from CTS_DataCenter.CTSCustomer where custid in (1574143);

insert into CTS_DataCenter.Customer_InitialGroupBetting(CustID,GBTicketCount,SportType,SourceCreatedDate,CreatedDate)
select CustID,4,1,current_timestamp(),current_timestamp() from CTS_DataCenter.CTSCustomer where custid in (1574147);

/* sp: CTS_ProblemAccountsClassification_Daily
 DELETE a WITH (ROWLOCK)  
 FROM #tmpCustomerAccummulatedInfo AS a  
where CustID IN (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594
);

 INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,-15000,11,5   
 FROM #tmpCustomers  
where CustID IN (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594
);
*/

/* sp: CTS_GeneralNormalClassification_NormalPool_Classify
 DELETE a WITH (ROWLOCK)  
 FROM #tmpRawData AS a  
where CustID IN (8590039,11668266,12228758,18327723,1574152,1574158,1574165,1574171
);

 INSERT INTO #tmpRawData (CustId, SportGroup, TurnoverRM, WinlossRM, TurnoverORG, WinlossORG, BetCount, ActiveDaysCustID, ActiveDaysSportGroup, WindaysCustID, WinDaysSportGroup, ProcessedTime)  
 SELECT CustID,1,300000,-5000,300000,-5000,400,10,10,10,10,@CurrentDateTime   
 FROM #tmpCustomers  
where CustID IN (8590039,11668266,12228758,18327723,1574152,1574158,1574165,1574171
);

normal: 300000,-5000,300000,-5000,400,10,10,10,10
good: 300000,-50000,300000,-50000,400,10,10,10,10
risky: 300000,25000,300000,25000,30,10,10,10,10

*/

insert into CTS_DataCenter.CTSCustomerClassification_BySport (CTSCustID,CustID,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,LastScannedDate,SportID,ParentID,CategoryID) 
select CTSCustID,CustID,current_timestamp(),10278938,current_timestamp(),10278938,current_timestamp()
       ,43 as  SportID
       ,40000 as ParentID
       ,case when CustID IN (8590039, 1574152) then 40100 -- new
             when CustID IN (11668266, 1574158) then 40200 -- good
             when CustID IN (12228758, 1574165) then 40400 -- prob
             when CustID IN (18327723, 1574171) then 40600 -- risky
        end as CategoryID
from CTS_DataCenter.CTSCustomer
where custid in (8590039,11668266,12228758,18327723,1574152,1574158,1574165,1574171);

/* sp: CTS_BySportNormalClassification_NormalPool_Classify
 DELETE a WITH (ROWLOCK)  
 FROM #tmpRawData AS a  
where CustID IN (8590039,11668266,12228758,18327723,1574152,1574158,1574165,1574171
);

 INSERT INTO #tmpRawData (CustId, SportGroup, TurnoverRM, WinlossRM, TurnoverORG, WinlossORG, BetCount, ActiveDaysCustID, ActiveDaysSportGroup, WindaysCustID, WinDaysSportGroup, ProcessedTime)  
 SELECT CustID,1,300000,-5000,300000,-5000,400,10,10,10,10,@CurrentDateTime   
 FROM #tmpCustomers  
where CustID IN (8590039,11668266,12228758,18327723,1574152,1574158,1574165,1574171
);

normal: 300000,-5000,300000,-5000,400,10,10,10,10
good: 300000,-50000,300000,-50000,400,10,10,10,10
risky: 300000,25000,300000,25000,30,10,10,10,10

*/

#B. Scenarios
-- R1: Rescan and checked affect to downlines 
-- R2: Rescan and no checked affect to downlines
-- R3: Only rescan General data 

#C. Result
-- only option 2: SMA exist direct PA.
select * from CTS_DataCenter.CTSCustomerClassificationQueue where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);

select * from CTS_DataCenter.CTSCustomerClassification_DailyPAQueue where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);
select * from CTS_DataCenter.CTSCustomerClassification where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);
select * from CTS_DataCenter.CTSCustomerClassification_History where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);
select * from CTS_DataCenter.CTSCustomerClassification_Log where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);
select * from CTS_DataCenter.CTSCustomerClassification_BySport where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);
select * from CTS_DataCenter.CTSCustomerClassification_BySport_History where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);
select * from CTS_DataCenter.CTSCustomerClassification_BySport_Log where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);

/*
delete from bodb_VR2Model.dbo.CustomerClassification_LatestActiveDay
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
;
insert into bodb_VR2Model.dbo.CustomerClassification_LatestActiveDay
select CustID, GETDATE(), GETDATE(), GETDATE()
from bodb02.dbo.custinfo with(nolock)
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
;
delete
FROM [bodb_VR2Model].[dbo].[CustomerClassification]
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
;
SELECT *
FROM [bodb_VR2Model].[dbo].[CustomerClassification]
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
order by CreatedDate desc;
  
delete from bodb_VR2Model.dbo.CustomerClassification_BySport_LatestActiveDay
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
;
insert into bodb_VR2Model.dbo.CustomerClassification_BySport_LatestActiveDay
select CustID, 43, GETDATE(), GETDATE(), GETDATE()
from bodb02.dbo.custinfo with(nolock)
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
;
delete
FROM [bodb_VR2Model].[dbo].[CustomerClassification_BySport]
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
;
SELECT *
FROM [bodb_VR2Model].[dbo].[CustomerClassification_BySport]
where custid in (5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594)
order by CreatedDate desc;  
  
  
select CustId, CustomerClass, danger2, CCEsports
from CustDB.dbo.custinfo
where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);

update CustDB.dbo.custinfo
set CustomerClass=null, danger2=0, CCEsports=null
where custid in (15,4183,31987,5120527,6087105,7467827,8228116,8590039,11668266,12228758,18327723,19542865,20661862, 1574117,1574121,1574129,1574136,1574143,1574147,1574152,1574158,1574165,1574171,1574178,1598461,1603807,1605594);



select custid, customerclass, CCSoccer, CCBasketball, CCEsports, CCOtherSports, CCNonSports, Danger, Danger2
from custdb.dbo.custinfo with(nolock)
where custid in (211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056);
select *
from custdb.dbo.CustomerClassSetting_Agent with(nolock)
where custid in (211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056);
select *
from CustDB.dbo.ProblemAccountClassification with(nolock)
where custid in (211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056);


update CustDB.dbo.custinfo
set CustomerClass = null, CCSoccer = null, CCBasketball = null, CCEsports = null, CCOtherSports = null, CCNonSports = null, Danger=0, Danger2=0
where custid in (211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056);
delete
from CustDB.dbo.CustomerClassSetting_Agent
where custid in (211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056);
delete
from CustDB.dbo.ProblemAccountClassification
where custid in (211566,324557,356942,365483,398467,4175,4176,4177,4178,4179,1262,1264,1265,1266,1267,1269,1270,1412,1653,2415,2417,2631,1275,1277,1280,1282,1284,1287,1290,1295,1296,1297,1299,1301,1302,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,835262,875429,876080,888234,888250,1032813,1033999,1038085,1038566,1039302,1039304,1048466,1051599,1051601,1051603,1053056);

*/