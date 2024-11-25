#PASS: @KeepTheFaith2209#
#DATA:
/*Install Dot Net.5 --> Import data (folder import/data.csv) --> Adjust config & version SP (folder App_data/SPNames.txt) --> Run SPU.CustomerClass.exe*/
-- Prepare data
SELECT * FROM CTS_DataCenter.CTSCustomer where IsInternal = 0 and roleid = 2 and CustSubID = 0 and SiteID = 16;
SELECT * FROM CTS_DataCenter.CTSCustomer where IsInternal = 0 and roleid = 1 and CustSubID = 0 and SiteID = 16;
SELECT * FROM CTS_DataCenter.CTSCustomer where IsInternal = 0 and roleid = 1 and CustSubID = 0 and SiteID = 457; 

SELECT * FROM CTS_DataCenter.CTSCustomer where IsInternal = 0 and roleid = 2 and CustSubID > 0 and SiteID = 16; 
SELECT * FROM CTS_DataCenter.CTSCustomer
where CustID <> Recommend and RoleID = 1 and CustSubID = 0 and IsInternal = 0 and Recommend IN (3695361,4120970);
SELECT * FROM CTS_DataCenter.CTSCustomer
where CustID IN (5858,1068024,5939) ; -- 5858-->3695361,4120970; 1068024-->4194893

-- Clean data
DELETE FROM CTS_DataCenter.CTSCustomerClassification where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
DELETE FROM CTS_DataCenter.CTSCustomerClassificationVVIP where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
DELETE FROM CTS_DataCenter.PinCustomerCategory where CTSCustID IN (1368797,1338648,1338649,1368800,1371328,2474660,1338222,2474653,1465198,1465199,1465200,1465201,2474652,2474655,
1465203,1465206,1465207,397168,397169,2474654,2474658,2474659,1462615,2588714,2844066,2472235);
DELETE FROM CTS_DataCenter.CTSCustomerClassificationQueue where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
DELETE FROM CTS_DataCenter.ProbationAccountMonitor where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
DELETE FROM CTS_DataCenter.CustEvidence where CTSCustID IN (1368797,1338648,1338649,1368800,1371328,2474660,1338222,2474653,1465198,1465199,1465200,1465201,2474652,2474655,
1465203,1465206,1465207,397168,397169,2474654,2474658,2474659,1462615,2588714,2844066,2472235);
DELETE FROM CTS_DataCenter.SpecialCustomerClass where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
DELETE FROM CTS_DataCenter.RobotDetection where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
DELETE FROM CTS_DataCenter.Customer_DangerousScore where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);

-- Check result
SELECT * FROM CTS_DataCenter.CTSCustomer where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.CTSCustomerClassification where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.CTSCustomerClassificationVVIP where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.PinCustomerCategory where CTSCustID IN (1368797,1338648,1338649,1368800,1371328,2474660,1338222,2474653,1465198,1465199,1465200,1465201,2474652,2474655,
1465203,1465206,1465207,397168,397169,2474654,2474658,2474659,1462615,2588714,2844066,2472235);
SELECT * FROM CTS_DataCenter.CTSCustomerClassificationOldPA where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.CTSCustomerClassificationQueue where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.ProbationAccountMonitor where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.CustEvidence where CTSCustID IN (1368797,1338648,1338649,1368800,1371328,2474660,1338222,2474653,1465198,1465199,1465200,1465201,2474652,2474655,
1465203,1465206,1465207,397168,397169,2474654,2474658,2474659,1462615,2588714,2844066,2472235);
SELECT * FROM CTS_DataCenter.SpecialCustomerClass where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.RobotDetection where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
SELECT * FROM CTS_DataCenter.Customer_DangerousScore where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);

-- Action on metaverse
/*1. Push customer class */  
case 1:  pa, agent, credit -- 3695361
case 2:  pa, member, credit -- 3925483
case 3:  pa losing, member, licensee -- 40290204
case 4:  robot, member, licensee -- 40290235
case 5:  robot losing, member, credit -- 3925486
case 6:	 2800, member, credit -- 3925488
case 7:  2801, member, credit -- 3925489
case 8:  2700, member, credit -- 3925490
case 9:  2701, member, licensee -- 40290236
case 10:  2600, member, licensee -- 40290237
case 11:  2601, member, licensee -- 40290238
case 12:  probation (57), member, credit -- 64075283
case 13:  probation (52), member, licensee -- 40290239
case 14:  probation, member, licensee -- 40290240


-- Prepare data for rescan flows (2->7)
-- PA for uplines
CALL CTS_DC_CustClassification_PA_Insert('Category', true, '[
{"CustID":5858,"CTSCustID":1368797,"RoleID":3,"SubscriberID":2,"IsLicensee":false,"Remark":"from master","CreatedBy":8,"WinlossStatus":null,"TurnoverRM":0,"WinlossRM":0,"BetCount":0,"ActiveDays":0,"CategoryID":52,"CategoryGroup":52,"IsDirectPA":true,"IsFromTVS":false,"IsFromTW":false,"IsFromCTS":true,"IsDataChanged":false},
{"CustID":5939,"CTSCustID":1368800,"RoleID":2,"SubscriberID":2,"IsLicensee":false,"Remark":"from agent","CreatedBy":8,"WinlossStatus":null,"TurnoverRM":0,"WinlossRM":0,"BetCount":0,"ActiveDays":0,"CategoryID":53,"CategoryGroup":53,"IsDirectPA":true,"IsFromTVS":false,"IsFromTW":false,"IsFromCTS":true,"IsDataChanged":false}
]');
-- PA for member. 
-- Add WL = Losing (VR2Model): 40290204,3925486,3925489,40290236,40290238
-- Add Robot (AI)
insert into CTS_DataCenter.RobotDetection (CustID, PeriodRangeType, CreatedDate, LastModifiedDate, IsDisabled) values
(40290235,200,current_timestamp(),current_timestamp(),0),
(3925486,200,current_timestamp(),current_timestamp(),0);
-- Add 2800 (AI)
insert into CTS_DataCenter.Customer_DangerousScore (CustID, IsLicensee, DangerousScore, CreatedDate, LastModifiedDate, ClassifiedScore, ClassifiedDate) values
(3925488,0,'0.51',current_timestamp(),current_timestamp(),'0.51',current_timestamp()),
(3925489,0,'0.73',current_timestamp(),current_timestamp(),'0.73',current_timestamp());
-- Add 2700 (CTS)
-- Add 2600 (VR2Model)
/*
  insert into [bodb_VR2Model].[dbo].[CustomerClassification_ScannedNewCust] (CustId,TotalTicketCount,GBTicketCount,SportType,CreatedTime,JobScannedType,LastJobScannedTime,IsServiceScanned,LastServiceScannedTime) values
(40290237,6,3,1,current_timestamp,2,current_timestamp,0,current_timestamp),
(40290238,7,4,2,current_timestamp,2,current_timestamp,0,current_timestamp);
*/
/*2. Rescan customer class (PA & Normal) - <If SMA will affect to downline> --> Expect: Both classify to PA & Normal Category for each customers. Affect to downlines (PA)  */ 
/* round 1: insert PA directy to DB then mark VVIP for CustID = 5858, 5939 --> no affected PA for downlines */
/* round 2: insert PA directy to DB for CustID = 5858, 5939 --> affected PA for downlines. 
CustID = 4120970, 3925486, 3925489 are inserted more 1 category to DB */
case 1:  single pa, agent -- 3695361 have affected: ok, upline is VVIP (no affected): ok
case 2:  multiple pa, agent -- 4120970  have affected: ok, upline is VVIP (no affected): ok
case 3:  single pa, member --  3925483 have affected: ok, upline is VVIP (no affected): ok
case 4:  multiple pa, member -- 3925486 have affected: ok, upline is VVIP (no affected): ok
case 5:  single pa losing, member --  3925488 have affected: ok, upline is VVIP (no affected): ok
case 6:  multiple pa losing, member -- 3925489 have affected: ok, upline is VVIP (no affected): ok
case 7:  robot, member -- 40290204 ok 
case 8:  robot losing, member -- 40290235 ok 
case 9:  probation, member -- 40290236 ok 
case 10:  probation (58), member -- 40290237 ok
case 11:  probation (52), member -- 40290238 ok

/*3. Rescan customer class (PA & Normal) --> Expect: Both classify to PA & Normal Category for each customers. But no affect to downlines (PA) */ 
case 1:  single pa, agent -- 3695361 no affected PA from upline ok
case 2:  multiple pa, agent -- 4120970 no affected PA from upline ok
case 3:  single pa, member --  3925483 ok
case 4:  multiple pa,  member -- 3925486 ok
case 5:  single pa losing, member --  3925488 ok
case 6:  multiple pa losing,  member -- 3925489 ok
case 7:  robot, member -- 40290204 ok
case 8:  robot losing, member -- 40290235 ok
case 9:  probation, member -- 40290236 
case 10:  probation (57), member -- 40290237 
case 11:  probation (52), member -- 40290238 

/*4. Rescan customer class (Normal) --> Expect: Only classify to Normal Category for each customers */ 
case 1:  single pa, agent -- 3695361
case 2:  multiple pa, agent -- 4120970
case 3:  single pa, member --  3925483  --> if active then auto mark New Member, else inactive then auto mark Normal Inactive x
case 4:  multiple pa  member -- 3925486  --> if active then auto mark New Member, else inactive then auto mark Normal Inactive x
case 5:  single pa losing, member --  3925488  --> if active then auto mark New Member, else inactive then auto mark Normal Inactive x
case 6:  multiple pa losing,  member -- 3925489  --> if active then auto mark New Member, else inactive then auto mark Normal Inactive x
case 7:  robot, member -- 40290204  --> if active then auto mark New Member, else inactive then auto mark Normal Inactive x
case 8:  robot losing, member -- 40290235  --> if active then auto mark New Member, else inactive then auto mark Normal Inactive x
case 9:  probation, member -- 40290236 x

case 10:  probation (57), member -- 40290237 
case 11:  probation (52), member -- 40290238 

/*5. Insert new customer + Must turn on service Classify Category for new cust. Will be delayed time if concurrency by metaverse and Pro service.*/ 
case 1:  main acc, single pa from master, agent --  3695361 - R: 5858 x
case 2:  main acc, multiple pa from master, agent --  4120970 - R: 5858 x
case 3:  main acc, vvip from master, agent --  4120970 - R: 5858 x
case 4:  main acc, NULL, agent --  4194893 - R: 1068024 x
case 5:  main acc, single pa from agent, member --  64075283 - R: 3695361 x
case 6:  main acc, multiple pa from agent, member --  64075284 - R: 3695361 x
case 7:  main acc, single pa losing from agent, member --  64075285 - R: 3695361 x
case 8:  main acc, multiple pa losing from agent, member --  64075286 - R: 3695361 x
case 9:  main acc, vvip from agent, member --  64075287 - R: 3695361 x
case 10:  main acc, probation, member --  40290235 x
case 11:  main acc, probation (57), member --  40290236 x
case 12: sub acc (only SMA and no classify Category) -- 387214, Sub = 5483 x

/*6. Push Customer Classification By Sport*/ 
case 1:  soccer - new , member -- 3925483
case 2:  basketball - normal, member -- 3925486
case 3:  esports - good, member -- 3925488
case 4:  othersports - probation, member -- 3925489 
case 5:  nonsports - smart, member -- 3925490
case 6:  saba soccer - risky, member -- 40290234
case 7:  saba basketball - new, member -- 40290235
case 8:  soccer - normal & othersports - good, member -- 40290236
case 9:  esports - probation & saba basketball - smart, member -- 40290237
case 10:  basketball - risky & nonsports - new & saba soccer - normal, member -- 40290238

/*7. Rescan Performance PA Win/lose Daily Scan*/ 
case 1:  pa, agent, credit -- 3695361
case 2:  pa, member, credit -- 3925483, win->lose
case 3:  pa losing, member, licensee -- 40290204, lose->win
case 4:  robot, member, licensee -- 40290235, win->win
case 5:  robot losing, member, credit -- 3925486, lose->lose
case 6:	 2800, member, credit -- 3925488, win->lose
case 7:  2801, member, credit -- 3925489, lose->win
case 8:  2700, member, credit -- 3925490, win->win
case 9:  2701, member, licensee -- 40290236, lose->win
case 10:  2600, member, licensee -- 40290237, win->lose
case 11:  2601, member, licensee -- 40290238, lose->lose
case 12:  probation (57), member, credit -- 64075283
case 13:  probation (52), member, licensee -- 40290239
case 14:  probation, member, licensee -- 40290240
/*
select custid, customerclass, danger, danger2, username
from CustDB.dbo.custinfo
where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
select * from CustDB.dbo.ProblemAccountClassification
where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
select * from CustDB.dbo.CustCategoryHistory
where custid in (3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290206,40290207,40290235,40290236,  64075283,64075284,64075285,64075286);
select * from CustDB.dbo.Dep_CustCategoryHistory
where custid in (3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290206,40290207,40290235,40290236,  64075283,64075284,64075285,64075286);


update CustDB.dbo.custinfo 
set customerclass = 0, danger = 0, danger2 =0
where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
delete from CustDB.dbo.ProblemAccountClassification
where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
delete from CustDB.dbo.CustCategoryHistory
where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);
delete from CustDB.dbo.Dep_CustCategoryHistory
where custid in (5858,5939,3695361,4120970,4194893,
3925483,3925486,3925488,3925489,3925490,   40290204,40290235,40290236,40290237,40290238,40290239,40290240, 387214,  64075283,64075284,64075285,64075286,64075288);

*/