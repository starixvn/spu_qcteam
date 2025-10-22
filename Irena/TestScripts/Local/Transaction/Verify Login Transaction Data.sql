-- Acc Profile
CALL CTS_DC_CustInfo_Profile_GetLoginStats(1003292476, timestamp('2025-06-20 21:58:55.897000'), timestamp('2025-09-18 21:58:55.897000'));
CALL DCS_DC_Transaction_GetHistory(35, 1003280555, 0, 500, @outParam4);
-- Latest Trans
CALL DCS_DC_Transaction_GetLatest(-1, 100);
CALL DCS_DC_Transaction_GetLatest(6, 100);
-- Ass Detection
CALL CTS_DC_Association_DetectGroup_xtest('1003273186,2704260', '[{"O":2704260,"D":12025091101,"A":1},{"O":2704261,"D":12025091101,"A":1},{"O":2704262,"D":12025091101,"A":1},{"O":1003273186,"D":10000022811,"A":1},{"O":1003273186,"D":12025091101,"A":1},{"O":1003273187,"D":12025091101,"A":1},{"O":1003273188,"D":12025091101,"A":1},{"O":1003336443,"D":10000022811,"A":1}]', '[]', '[]', '[]', '[]', '[]', true);

---- From, To
select DATE_SUB(CURDATE(), INTERVAL 90 DAY) AS FromDate, CURDATE() AS ToDate;-- 2025-07-19	2025-10-17
delete from DCS_DataCenter.MBTransaction07 where MBAccountID between 1064 and 1093;
delete from DCS_DataCenter.MBAccountIP where MBAccountID between 1064 and 1093;
delete from DCS_DataCenter.MBAssociation where MBAccountID between 1064 and 1093;
delete from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1064 and 1093;

delete from DCS_DataCenter.Transaction07 where AccountID between 21 and 50;
delete from DCS_DataCenter.AccountIP where AccountID between 21 and 50;
delete from DCS_DataCenter.AccountDevice where AccountID between 21 and 50;
delete from DCS_DataTrace.LoginTransactionSummary where AccountID between 21 and 50;
delete from DCS_DataCenter.SumAccountLogin where AccountID between 21 and 50;


---- CTSCustomer
select * from CTS_DataCenter.CTSCustomer where CTSCustID IN (
30,53,519,1929,111971,111974,111976,112002,  
112011,112034,112036,112039,112044,112046,112054,112365,112376,116417,  
118223,119817,124133,125408,126546,126547,127298,127634,127919,127998,129408,134244); 

-- From > Inserted
update CTS_DataCenter.CTSCustomer set CreatedDate=CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), ' ', '01:01:01.5990'), InsertedTime=CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), ' ', '01:01:01.5990') where CTSCustID IN (30,53,112011,112034,112036,112039,112044,118223,119817,129408);
-- Inserted > From
update CTS_DataCenter.CTSCustomer set CreatedDate=CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5990'), InsertedTime=CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5990') where CTSCustID IN (519,1929,112046,112054,112365,112376,116417,124133,125408,127298,127634,127919,127998,134244);
-- From = Inserted
update CTS_DataCenter.CTSCustomer set CreatedDate=CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '01:01:01.5990'), InsertedTime=CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '01:01:01.5990') where CTSCustID IN (112002,111971,111974,111976,126546,126547);


---- MBAccount
select * from DCS_DataCenter.MBAccount where ID between 1064 and 1093;
/*
insert into DCS_DataCenter.MBAccount (SubscriberID, LoginName, LastLoginTime, InsertedTime)
select SubscriberID, Username, InsertedTime, NOW() from CTS_DataCenter.CTSCustomer where CTSCustID IN (112365,112376,116417,  118223,119817,124133,125408,126546,126547,127298,127634,127919,127998,129408,134244) UNION ALL
select SubscriberID, SUBSTRING_INDEX(Username2, '$', -1), InsertedTime, NOW() from CTS_DataCenter.CTSCustomer where CTSCustID IN (30,53,519,1929,111971,111974,111976,112002,112011,112034,112036,112039,112044,112046,112054);
*/

---- Account
select * from DCS_DataCenter.Account where AccountID between 8 and 50;
/*
insert into DCS_DataCenter.Account (SubscriberID, SubscriberType, LoginName, LastLoginTime, InsertTime, CreatedTime, CreatedDate)
select SubscriberID, IsLicensee, Username, InsertedTime, NOW(), NOW(), NOW() from CTS_DataCenter.CTSCustomer where CTSCustID IN (112365,112376,116417,  118223,119817,124133,125408,126546,126547,127298,127634,127919,127998,129408,134244) UNION ALL
select SubscriberID, IsLicensee, SUBSTRING_INDEX(Username2, '$', -1), InsertedTime, NOW(), NOW(), NOW() from CTS_DataCenter.CTSCustomer where CTSCustID IN (30,53,519,1929,111971,111974,111976,112002,112011,112034,112036,112039,112044,112046,112054);
*/

select * from CTS_DataCenter.CustDCSAccount where AccountID between 8 and 37;
/*
insert into CTS_DataCenter.CustDCSAccount (CTSCustID, AccountID, SubscriberID, InsertTime)
select c.CTSCustID, a.AccountID, a.SubscriberID, NOW() from DCS_DataCenter.Account as a inner join CTS_DataCenter.CTSCustomer as c on c.Username = a.LoginName where c.CTSCustID IN (112365,112376,116417,  118223,119817,124133,125408,126546,126547,127298,127634,127919,127998,129408,134244)
union all
select c.CTSCustID, a.AccountID, a.SubscriberID, NOW() from DCS_DataCenter.Account as a inner join CTS_DataCenter.CTSCustomer as c on SUBSTRING_INDEX(c.Username2, '$', -1) = a.LoginName where c.CTSCustID IN (30,53,519,1929,111971,111974,111976,112002,112011,112034,112036,112039,112044,112046,112054);
*/

---- MBTransaction07
-- SC1: FromDate - CustInsertedDate
delete from DCS_DataCenter.MBTransaction07 where MBAccountID between 1079 and 1085;
insert into DCS_DataCenter.MBTransaction07 (CreatedDate, TransTime, InsertedTime, ActionResultID, Flagged, MBDeviceModelID, MBOSID, MBUserSettingID, MBAccountID, SubscriberID, MBRawTransactionID, IP, IPID,MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 1, 503, 63, 112, 1079, 6, 1001, '10.200.95.01', 28951, 28951 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 1, 503, 63, 112, 1085, 6, 1002, '10.200.95.07', 28957, 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 2, 503, 63, 112, 1080, 6, 1003, '10.200.95.02', 28952, 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 9, 503, 63, 112, 1081, 6, 1004, '10.200.95.03', 28953, 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 1, 503, 63, 112, 1082, 6, 1005, '10.200.95.04', 28954, 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 2 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 2 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 2, 503, 63, 112, 1083, 6, 1006, '10.200.95.05', 28955, 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 9, 503, 63, 112, 1084, 6, 1007, '10.200.95.06', 28956, 28956 union all
select DATE(DATE_SUB(NOW(), INTERVAL 0 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 0 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 1, 503, 63, 112, 1085, 6, 1008, '10.200.95.07', 28957, 28957; -- skip Device & IP, because cal to Yesterday
select * from DCS_DataCenter.MBTransaction07 where MBAccountID between 1079 and 1085;

delete from DCS_DataCenter.MBAccountIP where MBAccountID between 1079 and 1085;
insert into DCS_DataCenter.MBAccountIP (LastAccessedDate, InsertedTime, MBAccountID, IP, IPID)
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1079, '10.200.95.01', 28951 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), NOW(), 1080, '10.200.95.02', 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), NOW(), 1081, '10.200.95.03', 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), NOW(), 1082, '10.200.95.04', 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 2 DAY)), NOW(), 1083, '10.200.95.05', 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), NOW(), 1084, '10.200.95.06', 28956 union all
select DATE(DATE_SUB(NOW(), INTERVAL 0 DAY)), NOW(), 1085, '10.200.95.07', 28957;
select * from DCS_DataCenter.MBAccountIP where MBAccountID between 1079 and 1085;

delete from DCS_DataCenter.MBAssociation where MBAccountID between 1079 and 1085;
insert into DCS_DataCenter.MBAssociation (LastAccessedDate, CreatedTime, CreatedDate, MBAccountID, SubscriberID, MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1079, 6, 28951 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), NOW(), NOW(), 1080, 6, 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), NOW(), NOW(), 1081, 6, 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), NOW(), NOW(), 1082, 6, 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 2 DAY)), NOW(), NOW(), 1083, 6, 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), NOW(), NOW(), 1084, 6, 28956 union all
select DATE(DATE_SUB(NOW(), INTERVAL 0 DAY)), NOW(), NOW(), 1085, 6, 28957;
select * from DCS_DataCenter.MBAssociation where MBAccountID between 1079 and 1085;

delete from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1079 and 1085;
insert into DCS_DataTrace.MBLoginTransactionSummary (TransDate, MBAccountID, SubscriberID, OSType, FlaggedGroupID, TotalTrans, CreatedTime)
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1079, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1085, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), 1080, 6, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), 1081, 6, 1, 3, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), 1082, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 2 DAY)), 1083, 6, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), 1084, 6, 1, 3, 2, NOW() union all-- >total of MBTransaction07
select DATE(DATE_SUB(NOW(), INTERVAL 0 DAY)), 1085, 6, 1, 1, 2, NOW(); -- >total of MBTransaction07
select * from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1079 and 1085;

-- SC2:  FromDate - CustInsertedTime
delete from DCS_DataCenter.MBTransaction07 where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);
insert into DCS_DataCenter.MBTransaction07 (CreatedDate, TransTime, InsertedTime, ActionResultID, Flagged, MBDeviceModelID, MBOSID, MBUserSettingID, MBAccountID, SubscriberID, MBRawTransactionID, IP, IPID,MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '00:00:00.0000'), NOW(), 488, 1, 503, 63, 112, 1087, 6, 1051, '10.200.95.01', 28951, 28951 union all -- = from
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '00:00:00.0001'), NOW(), 488, 2, 503, 63, 112, 1088, 6, 1052, '10.200.95.02', 28952, 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '00:00:01.0000'), NOW(), 488, 9, 503, 63, 112, 1089, 6, 1053, '10.200.95.03', 28953, 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '00:01:00.0000'), NOW(), 488, 1, 503, 63, 112, 1090, 6, 1054, '10.200.95.04', 28954, 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '01:00:00.0000'), NOW(), 488, 2, 503, 63, 112, 1091, 6, 1055, '10.200.95.05', 28955, 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5990'), NOW(), 488, 9, 503, 63, 112, 1092, 6, 1056, '10.200.95.06', 28956, 28956 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5991'), NOW(), 488, 1, 503, 63, 112, 1093, 6, 1057, '10.200.95.07', 28957, 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:02.5990'), NOW(), 488, 2, 503, 63, 112, 1064, 2, 1058, '10.200.95.08', 28958, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:02:01.5990'), NOW(), 488, 9, 503, 63, 112, 1065, 2, 1059, '10.200.95.09', 28959, 28959 union all 
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '02:01:01.5990'), NOW(), 488, 1, 503, 63, 112, 1066, 2, 1060, '10.200.95.10', 28960, 28960 union all 
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), ' ', '00:00:00.0000'), NOW(), 488, 1, 503, 63, 112, 1087, 6, 1151, '10.200.95.01', 28951, 28951 union all -- > from, dup IP & IP
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), ' ', '00:00:00.0000'), NOW(), 488, 1, 503, 63, 112, 1088, 6, 1152, '10.200.95.02', 28952, 0 union all -- > from, dup IP
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '00:00:00.0000'), NOW(), 488, 1, 503, 63, 112, 1089, 6, 1153, null, -1, 28953 -- > from, dup Device
;
select * from DCS_DataCenter.MBTransaction07 where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);

delete from DCS_DataCenter.MBAccountIP where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);
insert into DCS_DataCenter.MBAccountIP (LastAccessedDate, InsertedTime, MBAccountID, IP, IPID)
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), 1089, '10.200.95.03', 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), 1090, '10.200.95.04', 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), 1091, '10.200.95.05', 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1092, '10.200.95.06', 28956 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1093, '10.200.95.07', 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1064, '10.200.95.08', 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1065, '10.200.95.09', 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1066, '10.200.95.10', 28960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), NOW(), 1088, '10.200.95.02', 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), NOW(), 1087, '10.200.95.01', 28951
;
select * from DCS_DataCenter.MBAccountIP where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);

delete from DCS_DataCenter.MBAssociation where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);
insert into DCS_DataCenter.MBAssociation (LastAccessedDate, CreatedTime, CreatedDate, MBAccountID, SubscriberID, MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), NOW(), 1090, 6, 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), NOW(), 1091, 6, 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), NOW(), 1088, 6, 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1089, 6, 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1092, 6, 28956 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1093, 6, 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1064, 2, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1065, 2, 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1066, 2, 28960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), NOW(), NOW(), 1087, 6, 28951
;
select * from DCS_DataCenter.MBAssociation where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);

delete from DCS_DataTrace.MBLoginTransactionSummary where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);
insert into DCS_DataTrace.MBLoginTransactionSummary (TransDate, MBAccountID, SubscriberID, OSType, FlaggedGroupID, TotalTrans, CreatedTime)
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), 1087, 6, 1, 1, 2, NOW() union all-- >total of MBTransaction07
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), 1088, 6, 1, 2, 2, NOW() union all-- >total of MBTransaction07
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), 1089, 6, 1, 3, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), 1090, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), 1091, 6, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1089, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1092, 6, 1, 3, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1093, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1064, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1065, 2, 1, 3, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1066, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 88 DAY)), 1088, 6, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 87 DAY)), 1087, 6, 1, 1, 1, NOW()
;
select * from DCS_DataTrace.MBLoginTransactionSummary where (MBAccountID between 1087 and 1093) or MBAccountID IN (1064, 1065, 1066);

-- SC3: Invalid case
delete from DCS_DataCenter.MBTransaction07 where MBAccountID between 1067 and 1078;
insert into DCS_DataCenter.MBTransaction07 (CreatedDate, TransTime, InsertedTime, ActionResultID, Flagged, MBDeviceModelID, MBOSID, MBUserSettingID, MBAccountID, SubscriberID, MBRawTransactionID, IP, IPID,MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 2, 503, 63, 112, 1068, 2, 1102, '10.200.95.02', 28952, 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 9, 503, 63, 112, 1069, 2, 1103, '10.200.95.03', 28953, 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 92 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 1, 503, 63, 112, 1067, 2, 1101, '10.200.95.01', 28951, 28951 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 1, 503, 63, 112, 1070, 2, 1104, '10.200.95.04', 28954, 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 2, 503, 63, 112, 1077, 2, 1111, null, -1, 0 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '00:01:01.5990'), NOW(), 488, 1, 503, 63, 112, 1073, 2, 1107, '10.200.95.07', 28957, 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:00:01.5990'), NOW(), 488, 2, 503, 63, 112, 1074, 2, 1108, '10.200.95.08', 28958, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:00.5990'), NOW(), 488, 9, 503, 63, 112, 1075, 2, 1109, '10.200.95.09', 28959, 28959 union all 
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5989'), NOW(), 488, 1, 503, 63, 112, 1076, 2, 1110, '10.200.95.10', 28960, 28960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 2, 503, 63, 112, 1078, 2, 1112, null, -1, 0 union all
select DATE(DATE_SUB(NOW(), INTERVAL -1 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL -1 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 2, 503, 63, 112, 1071, 2, 1105, '10.200.95.05', 28955, 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL -2 DAY)), CONCAT(DATE(DATE_SUB(NOW(), INTERVAL -2 DAY)), ' ', '01:01:01.5999'), NOW(), 488, 9, 503, 63, 112, 1072, 2, 1106, '10.200.95.06', 28956, 28956
;
select * from DCS_DataCenter.MBTransaction07 where MBAccountID between 1067 and 1078;

delete from DCS_DataCenter.MBAccountIP where MBAccountID between 1067 and 1078;
insert into DCS_DataCenter.MBAccountIP (LastAccessedDate, InsertedTime, MBAccountID, IP, IPID)
select DATE(DATE_SUB(NOW(), INTERVAL 92 DAY)), NOW(), 1067, '10.200.95.01', 28951 union all
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), NOW(), 1068, '10.200.95.02', 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), NOW(), 1069, '10.200.95.03', 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), 1070, '10.200.95.04', 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1073, '10.200.95.07', 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1074, '10.200.95.08', 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1075, '10.200.95.09', 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), 1076, '10.200.95.10', 28960 union all
select DATE(DATE_SUB(NOW(), INTERVAL -1 DAY)), NOW(), 1071, '10.200.95.05', 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL -2 DAY)), NOW(), 1072, '10.200.95.06', 28956
;
select * from DCS_DataCenter.MBAccountIP where MBAccountID between 1067 and 1078;

delete from DCS_DataCenter.MBAssociation where MBAccountID between 1067 and 1078;
insert into DCS_DataCenter.MBAssociation (LastAccessedDate, CreatedTime, CreatedDate, MBAccountID, SubscriberID, MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 92 DAY)), NOW(), NOW(), 1067, 2, 28951 union all
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), NOW(), NOW(), 1068, 2, 28952 union all
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), NOW(), NOW(), 1069, 2, 28953 union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), NOW(), NOW(), 1070, 2, 28954 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1073, 2, 28957 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1074, 2, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1075, 2, 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), NOW(), NOW(), 1076, 2, 28960 union all
select DATE(DATE_SUB(NOW(), INTERVAL -1 DAY)), NOW(), NOW(), 1071, 2, 28955 union all
select DATE(DATE_SUB(NOW(), INTERVAL -2 DAY)), NOW(), NOW(), 1072, 2, 28956
;
select * from DCS_DataCenter.MBAssociation where MBAccountID between 1067 and 1078;

delete from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1067 and 1078;
insert into DCS_DataTrace.MBLoginTransactionSummary (TransDate, MBAccountID, SubscriberID, OSType, FlaggedGroupID, TotalTrans, CreatedTime)
select DATE(DATE_SUB(NOW(), INTERVAL 92 DAY)), 1067, 2, 1, 1, 2, NOW() union all-- >total of MBTransaction07
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), 1068, 2, 1, 2, 2, NOW() union all-- >total of MBTransaction07
select DATE(DATE_SUB(NOW(), INTERVAL 91 DAY)), 1069, 2, 1, 3, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 90 DAY)), 1070, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1073, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1074, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1075, 2, 1, 3, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 89 DAY)), 1076, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL -1 DAY)), 1071, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL -2 DAY)), 1072, 2, 1, 3, 1, NOW()
;
select * from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1067 and 1078;

-- SC04: Transaction History
delete from DCS_DataCenter.MBTransaction07 where MBAccountID between 1064 and 1066;
insert into DCS_DataCenter.MBTransaction07 (CreatedDate, TransTime, InsertedTime, ActionResultID, Flagged, MBDeviceModelID, MBOSID, MBUserSettingID, MBAccountID, SubscriberID, MBRawTransactionID, IP, IPID,MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 36 DAY)), DATE_SUB(NOW(), INTERVAL 36 DAY), NOW(), 488, 1, 503, 63, 112, 1064, 2, 1151, '10.200.95.08', 28958, 28958 union all -- not show
select DATE(DATE_SUB(NOW(), INTERVAL 35 DAY)), DATE_SUB(NOW(), INTERVAL 35 DAY), NOW(), 488, 1, 503, 63, 112, 1064, 2, 1152, '10.200.95.08', 28958, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 34 DAY)), DATE_SUB(NOW(), INTERVAL 34 DAY), NOW(), 488, 1, 503, 63, 112, 1064, 2, 1153, '10.200.95.08', 28958, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 33 DAY)), DATE_SUB(NOW(), INTERVAL 33 DAY), NOW(), 488, 1, 503, 63, 112, 1064, 2, 1154, '10.200.95.08', 28958, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 32 DAY)), DATE_SUB(NOW(), INTERVAL 32 DAY), NOW(), 488, 1, 503, 63, 112, 1064, 2, 1155, '10.200.95.08', 28958, 28958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 31 DAY)), DATE_SUB(NOW(), INTERVAL 31 DAY), NOW(), 488, 1, 503, 63, 112, 1064, 2, 1156, '10.200.95.08', 28958, 28958 union all

select DATE(DATE_SUB(NOW(), INTERVAL 15 DAY)), DATE_SUB(NOW(), INTERVAL 15 DAY), NOW(), 488, 2, 503, 63, 112, 1065, 2, 1161, '10.200.95.29', 29959, 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 14 DAY)), DATE_SUB(NOW(), INTERVAL 14 DAY), NOW(), 488, 2, 503, 63, 112, 1065, 2, 1162, '10.200.95.29', 29959, 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 13 DAY)), DATE_SUB(NOW(), INTERVAL 13 DAY), NOW(), 488, 2, 503, 63, 112, 1065, 2, 1163, '10.200.95.29', 29959, 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 12 DAY)), DATE_SUB(NOW(), INTERVAL 12 DAY), NOW(), 488, 2, 503, 63, 112, 1065, 2, 1164, '10.200.95.29', 29959, 28959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), DATE_SUB(NOW(), INTERVAL 11 DAY), NOW(), 488, 2, 503, 63, 112, 1065, 2, 1165, '10.200.95.29', 29959, 28959 union all

select DATE(DATE_SUB(NOW(), INTERVAL 25 HOUR)), DATE_SUB(NOW(), INTERVAL 25 HOUR), NOW(), 488, 9, 503, 63, 112, 1066, 2, 1171, '10.200.95.10', 28960, 29960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 24 HOUR)), DATE_SUB(NOW(), INTERVAL 24 HOUR), NOW(), 488, 9, 503, 63, 112, 1066, 2, 1172, '10.200.95.10', 28960, 29960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 23 HOUR)), DATE_SUB(NOW(), INTERVAL 23 HOUR), NOW(), 488, 9, 503, 63, 112, 1066, 2, 1173, '10.200.95.10', 28960, 29960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 22 HOUR)), DATE_SUB(NOW(), INTERVAL 22 HOUR), NOW(), 488, 9, 503, 63, 112, 1066, 2, 1174, '10.200.95.10', 28960, 29960 union all
select DATE(DATE_SUB(NOW(), INTERVAL 21 HOUR)), DATE_SUB(NOW(), INTERVAL 21 HOUR), NOW(), 488, 9, 503, 63, 112, 1066, 2, 1175, '10.200.95.10', 28960, 29960 ;
select * from DCS_DataCenter.MBTransaction07 where MBAccountID between 1064 and 1066;

delete from DCS_DataCenter.MBAccountIP where MBAccountID between 1064 and 1066;
insert into DCS_DataCenter.MBAccountIP (LastAccessedDate, InsertedTime, MBAccountID, IP, IPID)
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), NOW(), 1065, '10.200.95.29', 29959;
select * from DCS_DataCenter.MBAccountIP where MBAccountID between 1064 and 1066;

delete from DCS_DataCenter.MBAssociation where MBAccountID between 1064 and 1066;
insert into DCS_DataCenter.MBAssociation (LastAccessedDate, CreatedTime, CreatedDate, MBAccountID, SubscriberID, MBDeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), NOW(), NOW(), 1066, 2, 29960;
select * from DCS_DataCenter.MBAssociation where MBAccountID between 1064 and 1066;

delete from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1064 and 1066;
insert into DCS_DataTrace.MBLoginTransactionSummary (TransDate, MBAccountID, SubscriberID, OSType, FlaggedGroupID, TotalTrans, CreatedTime)
select DATE(DATE_SUB(NOW(), INTERVAL 36 DAY)), 1064, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 35 DAY)), 1064, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 34 DAY)), 1064, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 33 DAY)), 1064, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 32 DAY)), 1064, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 31 DAY)), 1064, 2, 1, 1, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 15 DAY)), 1065, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 14 DAY)), 1065, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 13 DAY)), 1065, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 12 DAY)), 1065, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), 1065, 2, 1, 2, 1, NOW() union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), 1066, 2, 1, 3, 5, NOW() ;
select * from DCS_DataTrace.MBLoginTransactionSummary where MBAccountID between 1064 and 1066;

-- SC05: Mix Data with Mb Web and Desktop
delete from DCS_DataCenter.Transaction07 where AccountID between 8 and 10; 
insert into DCS_DataCenter.Transaction07 (CreatedDate, TransTime, InsertTime, LoginName, SubscriberID, AccountID, IP, IPID, ActionResultID, Flagged, URLID, DeviceID, DeviceStatus, DeviceCodeID, FirstDeviceCode, UserAgentKey)
select DATE(DATE_SUB(NOW(), INTERVAL 36 DAY)), DATE_SUB(NOW(), INTERVAL 36 DAY), NOW(), 'MCCM', 2, 8, '10.18.96.08', 38958, 488, 9, 1, 38958, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 35 DAY)), DATE_SUB(NOW(), INTERVAL 35 DAY), NOW(), 'MCCM', 2, 8, '10.18.96.08', 38958, 488, 9, 1, 38958, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 34 DAY)), DATE_SUB(NOW(), INTERVAL 34 DAY), NOW(), 'MCCM', 2, 8, '10.18.96.08', 38958, 488, 9, 1, 38958, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 33 DAY)), DATE_SUB(NOW(), INTERVAL 33 DAY), NOW(), 'MCCM', 2, 8, '10.18.96.08', 38958, 488, 9, 1, 38958, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 32 DAY)), DATE_SUB(NOW(), INTERVAL 32 DAY), NOW(), 'MCCM', 2, 8, '10.18.96.08', 38958, 488, 9, 1, 38958, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 31 DAY)), DATE_SUB(NOW(), INTERVAL 31 DAY), NOW(), 'MCCM', 2, 8, '10.18.96.08', 38958, 488, 9, 1, 38958, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all

select DATE(DATE_SUB(NOW(), INTERVAL 15 DAY)), DATE_SUB(NOW(), INTERVAL 15 DAY), NOW(), 'MCCM03', 2, 9, null, 0, 488, 1, 1, 38959, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 14 DAY)), DATE_SUB(NOW(), INTERVAL 14 DAY), NOW(), 'MCCM03', 2, 9, null, 0, 488, 1, 1, 38959, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 13 DAY)), DATE_SUB(NOW(), INTERVAL 13 DAY), NOW(), 'MCCM03', 2, 9, null, 0, 488, 1, 1, 38959, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 12 DAY)), DATE_SUB(NOW(), INTERVAL 12 DAY), NOW(), 'MCCM03', 2, 9, null, 0, 488, 1, 1, 38959, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), DATE_SUB(NOW(), INTERVAL 11 DAY), NOW(), 'MCCM03', 2, 9, null, 0, 488, 1, 1, 38959, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d1' union all

select DATE(DATE_SUB(NOW(), INTERVAL 25 HOUR)), DATE_SUB(NOW(), INTERVAL 25 HOUR), NOW(), 'SBR83F2', 2, 10, '10.18.96.10', 38960, 488, 2, 1, 0, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d2' union all
select DATE(DATE_SUB(NOW(), INTERVAL 24 HOUR)), DATE_SUB(NOW(), INTERVAL 24 HOUR), NOW(), 'SBR83F2', 2, 10, '10.18.96.10', 38960, 488, 2, 1, 0, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d2' union all
select DATE(DATE_SUB(NOW(), INTERVAL 23 HOUR)), DATE_SUB(NOW(), INTERVAL 23 HOUR), NOW(), 'SBR83F2', 2, 10, '10.18.96.10', 38960, 488, 2, 1, 0, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d2' union all
select DATE(DATE_SUB(NOW(), INTERVAL 22 HOUR)), DATE_SUB(NOW(), INTERVAL 22 HOUR), NOW(), 'SBR83F2', 2, 10,'10.18.96.10', 38960, 488, 2, 1, 0, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d2' union all
select DATE(DATE_SUB(NOW(), INTERVAL 21 HOUR)), DATE_SUB(NOW(), INTERVAL 21 HOUR), NOW(), 'SBR83F2', 2, 10, '10.18.96.10', 38960, 488, 2, 1, 0, 0, 1, '3e0194afb7c9497dab3a6a9b1cc6fc81', 'a3cd26ab23c712eef564759b8a7889d2'
;
select * from DCS_DataCenter.Transaction07 where AccountID between 8 and 10; 

delete from DCS_DataCenter.AccountIP where AccountID between 8 and 10;
insert into DCS_DataCenter.AccountIP (LastTransDate, Created, AccountID, IP)
select DATE(DATE_SUB(NOW(), INTERVAL 31 DAY)), NOW(), 8, '10.200.96.08' union all
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), NOW(), 9, '' union all 
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), NOW(), 10, '10.200.96.10';
select * from DCS_DataCenter.AccountIP where AccountID between 2078 and 2080;

delete from DCS_DataCenter.AccountDevice where AccountID between 8 and 10;
insert into DCS_DataCenter.AccountDevice (LastTransDate, Created, AccountID, DeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 31 DAY)), NOW(), 8, 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), NOW(), 9, 38959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), NOW(), 10, 0
;
select * from DCS_DataCenter.AccountDevice where AccountID between 8 and 10;

delete from DCS_DataTrace.LoginTransactionSummary where AccountID between 8 and 10;
insert into DCS_DataTrace.LoginTransactionSummary (TransDate, AccountID, SubscriberID, Flagged, FlaggedGroupID, TotalTrans, CreatedTime, DeviceID)
select DATE(DATE_SUB(NOW(), INTERVAL 36 DAY)), 8, 2, 9, 3, 1, NOW(), 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 35 DAY)), 8, 2, 9, 3, 1, NOW(), 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 34 DAY)), 8, 2, 9, 3, 1, NOW(), 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 33 DAY)), 8, 2, 9, 3, 1, NOW(), 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 32 DAY)), 8, 2, 9, 3, 1, NOW(), 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 31 DAY)), 8, 2, 9, 3, 1, NOW(), 38958 union all
select DATE(DATE_SUB(NOW(), INTERVAL 15 DAY)), 9, 2, 1, 1, 1, NOW(), 38959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 14 DAY)), 9, 2, 1, 1, 1, NOW(), 38959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 13 DAY)), 9, 2, 1, 1, 1, NOW(), 38959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 12 DAY)), 9, 2, 1, 1, 1, NOW(), 38959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 11 DAY)), 9, 2, 1, 1, 1, NOW(), 38959 union all
select DATE(DATE_SUB(NOW(), INTERVAL 1 DAY)), 10, 2, 2, 2, 5, NOW(), 38960;
select * from DCS_DataTrace.LoginTransactionSummary where AccountID between 8 and 10;

-- SC01: PASSED
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(30, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 0, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(53, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 0, Invalid: 1, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(519, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 1, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(1929, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 0, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(111971, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 0, Invalid: 1, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(111974, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 2, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(111976, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- Bot: 0, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 2, IP: 1, Device: 1, Login: 2
-- SC02: PASSED
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112011, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 0, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 2, IP: 1, Device: 1, Login: 2
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112034, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 0, Invalid: 2, Desktop: 0, MBWeb: 0, MBApp: 2, IP: 1, Device: 1, Login: 2
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112036, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 1, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 2, IP: 1, Device: 1, Login: 2
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112039, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 0, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112044, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 0, Invalid: 1, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112046, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 1, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112054, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- Bot: 0, Invalid: 0, Desktop: 0, MBWeb: 0, MBApp: 1, IP: 1, Device: 1, Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112365, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- SC02: same CTSCustID=112044; SC04, SC05: Bot: 6, Invalid Browser Info: 1, Desktop/Mb Web/Mb App: 6/0/7, IP / Device: 2/2, Total Login: 13
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(112376, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- SC02: same CTSCustID=112046; SC04, SC05: Bot: 1, Invalid Browser Info: 5, Desktop/Mb Web/Mb App: 5/0/6, IP / Device: 3/2, Total Login: 11
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(116417, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());-- SC02: same CTSCustID=112054; SC04, SC05: Bot: 5, Invalid Browser Info: 5, Desktop/Mb Web/Mb App: 0/5/6, IP / Device: 2/3, Total Login: 11
-- SC03: PASSED
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(118223, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(119817, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(124133, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(125408, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(126546, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(126547, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(127298, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE());
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(127634, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- TransDate = InsertedDate, TransTime < InsertedTime, Flagged = 2 --> Invalid Browser: 1, Total Login: 0
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(127919, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- TransDate = InsertedDate, TransTime < InsertedTime, Flagged = 9 --> Bot: 1, Total Login: 0
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(127998, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); 
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(129408, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- TransDate = From, IPID = -1, Device = null --> IP/Device: 0/0, Total Login: 1
call CTS_DataCenter.CTS_DC_CustInfo_Profile_GetLoginStats_xtest(134244, DATE_SUB(CURDATE(), INTERVAL 90 DAY), CURDATE()); -- TransDate = InsertedDate, TransTime >= InsertedDate, IPID = -1, Device = null --> IP/Device: 0/0, Total Login: 1
