-- MBAccount (main)
select * from DCS_DataCenter.MBAccount where ID in (976,977,978,979,980,981,982,983,984,985); -- Credit: 4 cust, Licensee: 6 cust
select * from CTS_DataCenter.CTSCustomer where CustID IN (5,4178,1262,1275,  4345449,4345527,4345531,4356533,27965350,27965639) AND CustSubID = 0;

delete from DCS_DataCenter.MBAccount where ID in (976,977,978,979,980,981,982,983,984,985); -- Credit: 4 cust, Licensee: 6 cust
insert into DCS_DataCenter.MBAccount (SubscriberID, LoginName, LastLoginTime, InsertedTime, CreatedDate, CreatedTime) 
select SubscriberID, Username, DATE_ADD(LastLoginTime, INTERVAL 1 HOUR), DATE_ADD(InsertedTime, INTERVAL 1 HOUR), DATE_ADD(InsertedTime, INTERVAL 1 HOUR), DATE_ADD(InsertedTime, INTERVAL 1 HOUR)
from CTS_DataCenter.CTSCustomer where CustID IN (5,4178,1262,1275) AND CustSubID = 0
UNION ALL
select SubscriberID, SUBSTRING_INDEX(Username2, '$', -1), DATE_ADD(LastLoginTime, INTERVAL 1 HOUR), DATE_ADD(LastLoginTime, INTERVAL 1 HOUR), DATE_ADD(LastLoginTime, INTERVAL 1 HOUR), DATE_ADD(LastLoginTime, INTERVAL 1 HOUR)
from CTS_DataCenter.CTSCustomer where CustID IN (4345449,4345527,4345531,4356533,27965350,27965639)  AND CustSubID = 0;

-- MBDeviceCodeMachine, MBDeviceCodeMachineAccount xxx
delete from DCS_DataCenter.MBDeviceCodeMachine where Code like 'na%'; 
select * from DCS_DataCenter.MBDeviceCodeMachine where Code like 'na%'; 
insert into DCS_DataCenter.MBDeviceCodeMachine (Code, MachineOSType, InsertedTime, LastAccessedDate, CreatedDate) values 
('na001abcdef',1,NOW(),NOW(),NOW()),('na002abcdef',0,NOW(),NOW(),NOW()),('na003abcdef',1,NOW(),NOW(),NOW()),('na004abcdef',0,NOW(),NOW(),NOW()),('na005abcdef',1,NOW(),NOW(),NOW()),
('na006abcdef',0,NOW(),NOW(),NOW()),('na007abcdef',1,NOW(),NOW(),NOW()),('na008abcdef',0,NOW(),NOW(),NOW()),('na009abcdef',1,NOW(),NOW(),NOW()),('na010abcdef',0,NOW(),NOW(),NOW());

delete from DCS_DataCenter.MBDeviceCodeMachineAccount where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
select * from DCS_DataCenter.MBDeviceCodeMachineAccount where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
insert into DCS_DataCenter.MBDeviceCodeMachineAccount (MBDeviceCodeMachineID, MBAccountID, CreatedDate, InsertedTime) values
(839,784,NOW(),NOW()),(840,785,NOW(),NOW()),(841,786,NOW(),NOW()),(842,787,NOW(),NOW()),(843,788,NOW(),NOW()),
(844,789,NOW(),NOW()),(845,790,NOW(),NOW()),(846,791,NOW(),NOW()),(847,792,NOW(),NOW()),(848,793,NOW(),NOW());

-- MBDeviceCodeTagging xxx
delete from DCS_DataCenter.MBDeviceCodeTagging where Code like 'ta%'; 
select * from DCS_DataCenter.MBDeviceCodeTagging where Code like 'ta%'; 
insert into DCS_DataCenter.MBDeviceCodeTagging (Code, InsertedTime, LastAccessedDate, CreatedDate) values 
('ta001abcdef',NOW(),NOW(),NOW()),('ta002abcdef',NOW(),NOW(),NOW()),('ta003abcdef',NOW(),NOW(),NOW()),('ta004abcdef',NOW(),NOW(),NOW()),('ta005abcdef',NOW(),NOW(),NOW()),
('ta006abcdef',NOW(),NOW(),NOW()),('ta007abcdef',NOW(),NOW(),NOW()),('ta008abcdef',NOW(),NOW(),NOW()),('ta009abcdef',NOW(),NOW(),NOW()),('ta010abcdef',NOW(),NOW(),NOW());

-- MBDeviceCodeMediaDRM
delete from DCS_DataCenter.MBDeviceCodeMediaDRM where Code like 'ya%'; 
select * from DCS_DataCenter.MBDeviceCodeMediaDRM where Code like 'ya%'; 
insert into DCS_DataCenter.MBDeviceCodeMediaDRM (Code, InsertedTime, LastAccessedDate, CreatedDate) values 
('ya001abcdef',NOW(),NOW(),NOW()),('ya002abcdef',NOW(),NOW(),NOW()),('ya003abcdef',NOW(),NOW(),NOW()),('ya004abcdef',NOW(),NOW(),NOW()),('ya005abcdef',NOW(),NOW(),NOW()),
('ya006abcdef',NOW(),NOW(),NOW()),('ya007abcdef',NOW(),NOW(),NOW()),('ya008abcdef',NOW(),NOW(),NOW()),('ya009abcdef',NOW(),NOW(),NOW()),('ya010abcdef',NOW(),NOW(),NOW());

-- MBDeviceCodeMachineMedia
delete from DCS_DataCenter.MBDeviceCodeMachineMedia where ID IN (890,891,892,893,894,895,896,897,898,899); 
select * from DCS_DataCenter.MBDeviceCodeMachineMedia where ID IN (890,891,892,893,894,895,896,897,898,899); 
insert into DCS_DataCenter.MBDeviceCodeMachineMedia (MBDeviceCodeMachineID,MBDeviceCodeMediaDRMID,CreatedDate,InsertedTime) values 
(829,778,NOW(),NOW()),(830,779,NOW(),NOW()),(831,780,NOW(),NOW()),(832,781,NOW(),NOW()),(833,782,NOW(),NOW()),
(834,783,NOW(),NOW()),(835,784,NOW(),NOW()),(836,785,NOW(),NOW()),(837,786,NOW(),NOW()),(838,787,NOW(),NOW());

-- MBDevice xxx
delete from DCS_DataCenter.MBDevice where ID IN (734,735,736,737,738,739,740,741,742,743);
select * from DCS_DataCenter.MBDevice where ID IN (734,735,736,737,738,739,740,741,742,743);
insert into DCS_DataCenter.MBDevice (FirstMBRawTransactionID, InsertedTime,LastAccessedDate,CreatedDate,CreatedTime) values 
(10000,NOW(),NOW(),NOW(),NOW()), (10500,NOW(),NOW(),NOW(),NOW()), (11000,NOW(),NOW(),NOW(),NOW()), (11500,NOW(),NOW(),NOW(),NOW()), (12000,NOW(),NOW(),NOW(),NOW()),
(20000,NOW(),NOW(),NOW(),NOW()), (20500,NOW(),NOW(),NOW(),NOW()), (21000,NOW(),NOW(),NOW(),NOW()), (21500,NOW(),NOW(),NOW(),NOW()), (22000,NOW(),NOW(),NOW(),NOW());

-- MBDeviceMapping xxx
delete from DCS_DataCenter.MBDeviceMapping where ID IN (51431,51432,51433,51434,51435,51436,51437,51438,51439,51440);
select * from DCS_DataCenter.MBDeviceMapping where ID IN (51431,51432,51433,51434,51435,51436,51437,51438,51439,51440);
insert into DCS_DataCenter.MBDeviceMapping (MBDeviceCodeTaggingID, MBDeviceCodeMachineAccountID, MBDeviceCodeMachineMediaID, MBDeviceID, FirstMBRawTransactionID, RecoverType, InsertedTime, CreatedDate) values
(829,979,890,734,10000,1,NOW(),NOW()), (830,980,891,735,10500,0,NOW(),NOW()), (831,981,892,736,11000,1,NOW(),NOW()), (832,982,893,737,11500,0,NOW(),NOW()), (833,983,894,738,12000,1,NOW(),NOW()),
(834,984,895,739,20000,0,NOW(),NOW()), (835,985,896,740,20500,1,NOW(),NOW()), (836,986,897,741,21000,0,NOW(),NOW()), (837,987,898,742,21500,1,NOW(),NOW()), (838,988,899,743,22000,0,NOW(),NOW());

-- MBTransaction07 (source)
select * from DCS_DataCenter.ActionResult; -- ID=488,490
select * from DCS_DataCenter.MBDeviceModel; -- ID=503,504
select * from DCS_DataCenter.MBOS;-- ID=63,64
select * from DCS_DataCenter.MBUserSetting;-- ID=112,113
select * from DCS_DataCenter.StaticList; -- ItemID=1,2,9
select * from DCS_DataCenter.MBDeviceMapping where ID IN (51431,51432,51433,51434,51435,51436,51437,51438,51439,51440);
select * from DCS_DataCenter.MBTransaction07 where MBAccountID in (977,978);

delete from DCS_DataCenter.MBTransaction07 where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
set @MBAccountID=976, @MBDeviceMappingID=51431, @IP='10.18.95.01', @IPID=28951,  -- @IP='10.18.95.01', @IPID=28951
@ActionResultID=488, @Flagged=1, @MBDeviceModelID=503, @MBOSID=63, @MBUserSettingID=112, @Deviation=60;

insert into DCS_DataCenter.MBTransaction07 (CreatedDate, TransTime, InsertedTime, SubscriberID, MBAccountID, IP, IPID, ActionResultID, Flagged, MBDeviceModelID, MBOSID, MBUserSettingID, 
MBRawTransactionID, MBDeviceMappingID, MBDeviceID, DeviceStatus)
select distinct DATE(DATE_ADD(NOW(), INTERVAL -35 DAY)), DATE_ADD(NOW(), INTERVAL -35 DAY), DATE_ADD(NOW(), INTERVAL -35 DAY), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 1, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -34 DAY)), DATE_ADD(NOW(), INTERVAL -34 DAY), DATE_ADD(NOW(), INTERVAL -34 DAY), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 2, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -33 DAY)), DATE_ADD(NOW(), INTERVAL -33 DAY), DATE_ADD(NOW(), INTERVAL -33 DAY), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 3, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -14 DAY)), DATE_ADD(NOW(), INTERVAL -14 DAY), DATE_ADD(NOW(), INTERVAL -14 DAY), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 4, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -13 DAY)), DATE_ADD(NOW(), INTERVAL -13 DAY), DATE_ADD(NOW(), INTERVAL -13 DAY), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 5, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -12 DAY)), DATE_ADD(NOW(), INTERVAL -12 DAY), DATE_ADD(NOW(), INTERVAL -12 DAY), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 6, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -24 HOUR)), DATE_ADD(NOW(), INTERVAL -24 HOUR), DATE_ADD(NOW(), INTERVAL -24 HOUR), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 7, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -23 HOUR)), DATE_ADD(NOW(), INTERVAL -23 HOUR), DATE_ADD(NOW(), INTERVAL -23 HOUR), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 8, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID union all
select distinct DATE(DATE_ADD(NOW(), INTERVAL -22 HOUR)), DATE_ADD(NOW(), INTERVAL -22 HOUR), DATE_ADD(NOW(), INTERVAL -22 HOUR), acc.SubscriberID, acc.ID, 
@IP, @IPID, @ActionResultID, @Flagged, @MBDeviceModelID, @MBOSID, @MBUserSettingID, dmp.FirstMBRawTransactionID + @Deviation + 9, dmp.ID, dmp.MBDeviceID,dmp.RecoverType
from DCS_DataCenter.MBAccount as acc cross join DCS_DataCenter.MBDeviceMapping as dmp where acc.ID = @MBAccountID and dmp.ID = @MBDeviceMappingID
;

-- MBAssociation (main, source)
delete from DCS_DataCenter.MBAssociation where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
select * from DCS_DataCenter.MBAssociation where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
insert into DCS_DataCenter.MBAssociation (MBAccountID, MBDeviceID, SubscriberID, LastAccessedDate, InsertedTime) values
(784,734,2,'2025-09-26',NOW()), (785,735,2,'2025-09-26',NOW()), (786,736,130,'2025-09-26',NOW()), (786,737,130,'2025-09-26',NOW()), (787,738,2,'2025-09-26',NOW()),
(788,739,104,'2025-09-26',NOW()), (789,740,104,'2025-09-26',NOW()), (790,741,104,'2025-09-26',NOW()), (791,742,104,'2025-09-26',NOW()), (791,743,104,'2025-09-26',NOW());

-- MBAccountIP (main, after cook data)
delete from DCS_DataCenter.MBAccountIP where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
select * from DCS_DataCenter.MBAccountIP where MBAccountID in (976,977,978,979,980,981,982,983,984,985);
insert into DCS_DataCenter.MBAccountIP (MBAccountID, IPID, IP, LastAccessedDate, InsertedTime) values
(784,228951,'10.18.95.01', '2025-09-26',NOW()), (786,228951,'10.18.95.01','2025-09-26',NOW()), (787,228952,'10.18.95.02','2025-09-26',NOW()), (788,228952,'10.18.95.02','2025-09-26',NOW()),
(789,228951,'10.18.95.01','2025-09-26',NOW()), (791,228951,'10.18.95.01','2025-09-26',NOW()), (792,228952,'10.18.95.02','2025-09-26',NOW()), (793,228952,'10.18.95.02','2025-09-26',NOW());



-- sp: DCS_DC_ArchiveData_MBLastAccessedDate_Update
select * from DCS_DataCenter.MBDeviceModel; -- ID=503,504 skip
select * from DCS_DataCenter.MBOS;-- ID=63,64 skip
select * from DCS_DataCenter.MBUserSetting;-- ID=112,113 skip

select * from DCS_DataCenter.MBAccount where LoginName= '12BETAUD01S524';   ID in (976,977,978,979,980,981,982,983,984,985); -- Credit: 4 cust, Licensee: 6 cust
select * from DCS_DataCenter.MBAssociation where MBAccountID in (992,  976,977,978,979,980,981,982,983,984,985);
select * from DCS_DataCenter.MBDeviceCodeMachine where Code like 'na%'; -- today, yesterday, yesterday-1
select * from DCS_DataCenter.MBDeviceCodeTagging where Code like 'ta%'; -- today, yesterday, yesterday-1
select * from DCS_DataCenter.MBDeviceCodeMediaDRM where Code like 'ya%'; -- today, yesterday, yesterday-1
select * from DCS_DataCenter.MBDevice where ID in (734,735,736,737,738,739,740,741,742,743);
select * from DCS_DataCenter.MBAccountIP where MBAccountID in (992,  976,977,978,979,980,981,982,983,984,985); -- update data

update DCS_DataCenter.MBAccount set LastLoginTime = '2025-09-26 00:00:00' where ID in (784,785,786,787, 788,789,790,791,792,793);
update DCS_DataCenter.MBAssociation set LastAccessedDate = '2025-09-26' where MBAccountID in (784,785,786,787, 788,789,790,791,792,793);
update DCS_DataCenter.MBAccountIP set LastAccessedDate = '2025-09-26' where MBAccountID in (784,785,786,787, 788,789,790,791,792,793);
update DCS_DataCenter.MBDeviceCodeMachine set LastAccessedDate = '2025-05-19' where Code like 'na%'; -- today, yesterday, yesterday-1
update DCS_DataCenter.MBDeviceCodeTagging set LastAccessedDate = '2025-05-19' where Code like 'ta%'; -- today, yesterday, yesterday-1
update DCS_DataCenter.MBDeviceCodeMediaDRM set LastAccessedDate = '2025-05-19' where Code like 'ya%'; -- today, yesterday, yesterday-1
update DCS_DataCenter.MBDevice set LastAccessedDate = '2025-05-19' where ID in (734,735,736,737,738,739,740,741,742,743);

-- sp: DCS_DT_Summary_MBLoginTransaction_CookData
select * from DCS_DataCenter.MBAccountIP where MBAccountID in (977,978);
select * from DCS_DataCenter.MBTransaction07 where MBAccountID in (977,978);
select * from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID in (977,978);

SELECT CAST(VValue AS UNSIGNED) FROM DCS_DataCenter.SystemSetting WHERE ID = 30; -- lastscan into batch
SELECT CAST(VValue AS UNSIGNED) FROM DCS_DataCenter.SystemSetting WHERE ID = 4; -- max value to cook data

update DCS_DataCenter.SystemSetting  set VValue = 83470 WHERE ID = 30;
update DCS_DataCenter.SystemSetting  set VValue = 99999 WHERE ID = 4;
    
CALL DCS_DataCenter.DCS_DC_ArchiveData_MBLastAccessedDate_Update(10);
  call DCS_DataTrace.DCS_DT_Summary_MBLoginTransaction_CookData_xtest(100);

SELECT max(ID) FROM DCS_DataCenter.MBTransaction07 AS trans;


CALL DCS_DataCenter.DCS_DC_Transaction_GetLatest_xtest(-1, 1000);

select * from DCS_DataCenter.URL;
select * from DCS_DataCenter.Device;
select * from DCS_DataCenter.DeviceCode; 
select * from DCS_DataCenter.DeviceType; 
select * from DCS_DataCenter.DeviceFingerprint; 
select * from DCS_DataCenter.Browser; 
select * from DCS_DataCenter.ActionResult; 
select * from DCS_DataCenter.UserAgent;

select * from CTS_DataCenter.CTSCustomer where CTSCustID in (1003343762);		
select * from DCS_DataCenter.Account where AccountID in (1964);		
select * from CTS_DataCenter.CustDCSAccount where CTSCustID in (1003343762);
select * from DCS_DataCenter.Transaction07 where AccountID in (1003418832, 1964);
select * from DCS_DataCenter.SumAccountLogin where AccountID in (1003418832, 1964);		
select * from DCS_DataCenter.AccountDevice where AccountID in (1003418832, 1964); 
select * from DCS_DataCenter.AccountIP where AccountID in (1003418832, 1964); 
select * from DCS_DataTrace.LoginTransactionSummary where AccountID in (1003418832, 1964); 

SELECT CAST(VValue AS UNSIGNED) FROM DCS_DataTrace.SystemSetting WHERE ID = 5; -- lastscan into batch
SELECT CAST(VValue AS UNSIGNED) FROM DCS_DataCenter.SystemSetting WHERE ID = 3; -- max value to cook data
SELECT CAST(VValue AS UNSIGNED) FROM DCS_DataTrace.SystemSetting WHERE ID = 3; -- max value to cook data

SELECT * FROM DCS_DataTrace.SystemSetting WHERE ID = 5; -- lastscan
SELECT * FROM DCS_DataCenter.SystemSetting WHERE ID = 3; -- max completed
SELECT * FROM DCS_DataTrace.SystemSetting WHERE ID = 3; -- lastscan into batch 2024-09-24

set @op_MaxTransID = 0;
set @op_DateScan = '0';
set @op_AccountID = 0;
call DCS_DataCenter.DCS_DC_SumTransaction_Get(@op_MaxTransID, @op_DateScan, @op_AccountID);
select @op_MaxTransID, @op_DateScan, @op_AccountID;

call DCS_DataTrace.DCS_DT_Summary_LoginTransaction_CookData(500);


set @op_TotalItem = 0;
call DCS_DataCenter.DCS_DC_Transaction_GetHistory_xtest(35, 1003343762, 0, 500, @op_TotalItem);
select @op_TotalItem;
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(1003343762, '2025-07-01', '2025-09-29');

1003343762	SA-HK$	
1003273831	wsrm	
1003273186	338HK	
1003274684	mhk	MKNick
1003294431	HAIFASuperUUS	haifa$NaSuper
1003294433	HAIFAUUS	haifa$NaMaster
1003294434	HAIFAUUS01	haifa$NaAgent
1003273290	HAIFAUUS01001	haifa$NaMember
111969	AB88INH0146982	asiabet88$kimson114
111971	12BETTB0141367	12Bet$Ri22zz1111

delete from DCS_DataCenter.Transaction07 where AccountID in (964,965,966,967,968,969,970,971,972,973);
set @AccountID=1964, @DeviceMappingID=51431, @IP='10.18.95.01', @IPID=28951,  -- @IP='10.18.95.01', @IPID=28951
@ActionResultID=488, @Flagged=1, @DeviceModelID=504, @OSID=64, @UserSettingID=113

, @Deviation=0;

insert into DCS_DataCenter.Transaction07 (CreatedDate, InsertTime, TransTime, LoginName, SubscriberID, AccountID, IP, IPID, ActionResultID, Flagged, URLID, DeviceID, DeviceStatus, DeviceCodeID, FirstDeviceCode, UserAgentKey)
select '2025-09-28', NOW(),'2025-09-28 23:10:00', 'SA-HK$', 2, 1964, '10.18.95.01', 28951, 488, 1, 1, 1, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc83', '07290c38d14d1f587d0c243655f45ea6' union all
select '2025-09-28', NOW(),'2025-09-28 23:01:00', 'SA-HK$', 2, 1964, '10.18.95.02', 28951, 488, 2, 1, 1, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc83', '07290c38d14d1f587d0c243655f45ea6'  union all
select '2025-09-28', NOW(),'2025-09-28 23:05:00', 'SA-HK$', 2, 1964, '10.18.95.03', 28951, 488, 9, 1, 1, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc83', '07290c38d14d1f587d0c243655f45ea6';


insert into DCS_DataCenter.Transaction07 (CreatedDate, InsertTime, TransTime, LoginName, SubscriberID, AccountID, IP, IPID, ActionResultID, Flagged, URLID, DeviceID, DeviceStatus, DeviceCodeID, FirstDeviceCode, UserAgentKey)
select '2025-09-29', NOW(),'2025-09-29 23:00:00', 'SA-HK$', 2, 1964, '10.18.95.01', 28951, 488, 1, 1, 1, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc83', 'x3cd26ab23c712eef564759b8a788y82' union all
select '2025-09-29', NOW(),'2025-09-29 23:01:00', 'SA-HK$', 2, 1964, '10.18.95.02', 28951, 488, 2, 1, 1, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc83', 'x3cd26ab23c712eef564759b8a788y82' union all
select '2025-09-29', NOW(),'2025-09-29 23:05:00', 'SA-HK$', 2, 1964, '10.18.95.03', 28951, 488, 2, 1, 1, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc83', 'x3cd26ab23c712eef564759b8a788y82' ;


select * 
from CTS_DataCenter.CTSCustomerClassification as cc 
inner join CTS_DataCenter.CustomerLoginInfoDetection as c305 on c305.CustID = cc.CustID;