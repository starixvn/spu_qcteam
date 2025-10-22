DECLARE @CustIDList VARCHAR(MAX); SET @CustIDList = '4798,1412,127884,170498643,104972,38456,897790,89128604,128867,142719,56939,2932971,170498632,1014376,57922,13534560,89128567,1035081,1136640,664114,17060641,89128542';
EXEC   bodb_dwrs.dbo.[Acc_Rpt_CTS_GetSMAAccumulatedInfo]
@ListCustID = @CustIDList,
@RangeDays = N'60,365',
@IsAccumulated = 1;
IF OBJECT_ID('tempdb..#tmpCustIDList') IS NOT NULL
BEGIN
	DROP TABLE	#tmpCustIDList;
END
CREATE TABLE #tmpCustIDList(CustID INT PRIMARY KEY);
INSERT INTO #tmpCustIDList 	SELECT DISTINCT CAST(value AS INT) CustId FROM STRING_SPLIT(@CustIDList, ',');
select * from bodb_Account.dbo.FactSMAStatsInfo_Active f where exists (select 1 from #tmpCustIDList t where t.CustID = f.CustID); 
select * from bodb_ODS.dbo.ODS_bettrans_final_SiteDB01_batch01 bt where exists (select 1 from #tmpCustIDList t where t.CustID = bt.recommend); 
select * from bodb_ODS.dbo.ODS_bettrans_final_SiteDB02_batch01 bt where exists (select 1 from #tmpCustIDList t where t.CustID = bt.recommend); 
select * from bodb_VR2Model.dbo.CustomerClassificationAgency_LatestActiveDay l where exists (select 1 from #tmpCustIDList t where t.CustID = l.CustID); 	


-- rule NEW: 
--4798,1412,127884,170498643,104972,38456,897790,89128604,128867
--142719,56939,2932971,170498632,1014376,57922,13534560,89128567,1035081
--1136640,664114,17060641,89128542
--delete from bodb_VR2Model.dbo.CustomerClassificationAgency ;
select * from bodb_VR2Model.dbo.CustomerClassificationAgency where CustID in (4798,1412,127884,170498643,104972,38456,897790,89128604,128867) order by id desc;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassificationAgency_NormalPool_Classify_xpre @CustomersXML = N'<Root>
<r CustId="4798" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="1412" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="127884" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="170498643" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="104972" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="38456" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="897790" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="89128604" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="128867" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="142719" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="56939" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="2932971" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="170498632" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="1014376" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="57922" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13534560" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="89128567" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="1035081" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="1136640" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="664114" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="17060641" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="89128542" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
</Root>';


-- rule GOOD: 
--7166236,1670085,36649143,170498621,21631004,1771015,36649145,81199342,30143280,7215954,7166261,7166262  
--7166267,7166279,7166281,7166283,2954209,36649168,170498619,7166268,3035648,36649170,77090865,7166275  
--7166284,3121944,36649189,72957389  
--7181125,7181200,7181206,7181207,4055143,36649191,170498326,7181126,4065612,40182231,71975455,7181140  
--7181211,7181223,7181236,7181237,5937941,41876372,170466762,7181213,7166269,43143069,71760995,7181215  
--7181240,7181255,7181260,7181273,7166287,43143072,170466757,7181248,7181128,43511284,70745116,7181249  
--7181274,7181286,7181310,7181311,7181138,46576737,170464779,7181275,7181145,47854312,70498579,7181285  
--7181315,7181323,7181329,7181330,7181146,47854316,148737168,7181318,7181197,47854333,70498543,7181320
--delete from bodb_VR2Model.dbo.CustomerClassificationAgency;
select * from bodb_VR2Model.dbo.CustomerClassificationAgency where CustID in (7166236,1670085,36649143,170498621,21631004,1771015,36649145,81199342,30143280,7215954,7166261,7166262) order by id desc;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassificationAgency_NormalPool_Classify_xpre @CustomersXML = N'<Root>
<r CustId="7166236" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="1670085" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="36649143" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="170498621" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="21631004" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="1771015" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="36649145" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="81199342" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="30143280" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7215954" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7166261" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7166262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="7166267" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7166279" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7166281" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7166283" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="2954209" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="36649168" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="170498619" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7166268" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="3035648" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="36649170" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="77090865" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7166275" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="7166284" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="3121944" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="36649189" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="72957389" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />

<r CustId="7181125" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181200" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181206" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181207" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="4055143" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="36649191" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="170498326" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181126" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="4065612" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="40182231" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="71975455" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181140" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="7181211" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181223" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181236" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181237" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="5937941" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41876372" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="170466762" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181213" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7166269" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="43143069" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="71760995" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181215" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="7181240" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181255" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181260" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181273" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7166287" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="43143072" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="170466757" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181248" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181128" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="43511284" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="70745116" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181249" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="7181274" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181286" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181310" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181311" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181138" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="46576737" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="170464779" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181275" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181145" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="47854312" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="70498579" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181285" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="7181315" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181323" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181329" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181330" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181146" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="47854316" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="148737168" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181318" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7181197" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="47854333" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="70498543" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7181320" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
</Root>';


-- rule NORMAL: 
--7205649,7181287,63849893,148734326,7205652,7181308,65482080,70264762,7215932,15293270,  
--7216053,7216685,7181312,65811655,148734062,7216063,7181317,66892333,70264680,7216684,  
--7216695,7181322,67189752,70264656,  
--7216705,7372346,7181327,67496926,148625734,7216706,7181333,69214399,70264628,7280062,  
--7372491,7372661,7181350,69855389,148625733,7372526,7181354,70259874,70264522,7372556,  
--7373051,8072568,7181359,70443969,148625732,8072565,7181387,70443973,70264501,8072566,  
--8072569,8658881,7181429,70662293,148625731,8072571,7181438,71060393,70264488,8078083,  
--10179021,10382585,7205630,71437016,148625704,10181957,7205645,71580277,70264468,10380198,
--delete from bodb_VR2Model.dbo.CustomerClassificationAgency;
select * from bodb_VR2Model.dbo.CustomerClassificationAgency where CustID in (7205649,7181287,63849893,148734326,7205652,7181308,65482080,70264762,7215932,15293270) order by id desc;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassificationAgency_NormalPool_Classify_xpre @CustomersXML = N'<Root>
<r CustId="7205649" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7181287" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="63849893" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="148734326" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7205652" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7181308" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="65482080" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="70264762" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7215932" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="15293270" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="7216053" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="7216695" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216695" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216695" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="7216695" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />

<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7216705" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7372491" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="7373051" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="8072569" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="10179021" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
</Root>';


-- rule PROB:
--13738312,7216686,78520816,148625673,13746027,7216704,78840518,68416762,13768868
--13785179,7372530,84702552,136859398,13785184,7372630,85199605,68078567,13854050,
--13893923,7372852,85695471,68077459,
--14054449,7662773,85200468,136857073,14054468,7662800,85700080,67447500,14060063,
--14062415,7949589,85706740,136857072,14062418,8072573,86253481,65471193,14062423,
--14104712,10491480,86355046,136857040,14134087,10491500,86361934,64475813,14177346,
--14227072,10491504,86775638,136856825,14271358,11185253,88497811,64475484,14382520,
--14390042,14105617,88810772,136856821,14390834,14172560,88967347,64475120,14440007,
--delete from bodb_VR2Model.dbo.CustomerClassificationAgency ;
select * from bodb_VR2Model.dbo.CustomerClassificationAgency where CustID in (13738312,7216686,78520816,148625673,13746027,7216704,78840518,68416762,13768868) order by id desc;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassificationAgency_NormalPool_Classify_xpre @CustomersXML = N'<Root>
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13738312" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13785179" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="13893923" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13893923" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13893923" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="13893923" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />

<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14054449" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14062415" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14104712" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14227072" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="14390042" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
</Root>';


-- rule SMART: 
--14664262,14534484,89591130,136855872,14672626,14568474,89606862,64471663,14677053,15293270
--15267293,15321150,14603485,94236405,119276899,15290138,14624652,94282618,64469835,15293143
--15302167,14767112,94961586,64350022,
--15300695,15608713,14772115,94399295,119276056,15343640,14898339,95244006,61181476,15304920,
--15374844,15612564,14965795,95253696,119275171,15470389,15012258,95489085,61181473,15540051,
--15612234,15631372,15484111,95780020,119275170,15612548,15818587,95815435,61181468,15612555,
--15620675,15702196,15920285,96202802,119275169,15624324,16168803,96372910,61181458,15624347,
--15676238,15919919,16170964,96375309,119272938,15692996,16493450,96525239,60722152,15699989,
--delete from bodb_VR2Model.dbo.CustomerClassificationAgency ;
select * from bodb_VR2Model.dbo.CustomerClassificationAgency where CustID in (14664262,14534484,89591130,136855872,14672626,14568474,89606862,64471663,14677053,15293270) order by id desc;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassificationAgency_NormalPool_Classify_xpre @CustomersXML = N'<Root>
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="14664262" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="15267293" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="15302167" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15302167" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15302167" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="15302167" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />

<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15300695" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15374844" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15612234" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15620675" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="15676238" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
</Root>';


-- rule RISKY: 
--16115762,17305771,97473304,119272724,17526905,17305775,98223862,60365998,17961466,31647508
--30417528,36490703,17423305,101432256,117835721,31380419,17469496,101461502,60365990,31647418,
--34054844,17672605,101899725,60365892,
--33920734,39396774,17832634,101874141,117835096,37995555,17843966,101986911,60076366,35550610,
--38504352,41534530,17927875,102043275,108777951,38766610,18004043,102248717,59595193,39247582,
--41048208,41747664,18010900,102249421,100588113,41433611,18011445,102406619,59424776,41534476,
--41534563,43247116,18012377,102984392,96394276,41552062,18012409,103205268,59088923,41647726,
--41912311,43450903,18012446,103542592,93558369,42208189,18012501,103655822,58685916,42533997,
--delete from bodb_VR2Model.dbo.CustomerClassificationAgency ;
select * from bodb_VR2Model.dbo.CustomerClassificationAgency where CustID in (16115762,17305771,97473304,119272724,17526905,17305775,98223862,60365998,17961466,31647508) order by id desc;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassificationAgency_NormalPool_Classify_xpre @CustomersXML = N'<Root>
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="16115762" RoleId="2" CategoryId="0" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />
<r CustId="30417528" RoleId="2" CategoryId="140100" IsNewCreated="1" IsRealtimeOnly= "1" />

<r CustId="34054844" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="34054844" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="34054844" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />
<r CustId="34054844" RoleId="2" CategoryId="140700" IsNewCreated="0" IsRealtimeOnly= "1" />

<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="33920734" RoleId="2" CategoryId="140200" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="38504352" RoleId="2" CategoryId="140300" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41048208" RoleId="2" CategoryId="140800" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41534563" RoleId="2" CategoryId="140500" IsNewCreated="1" IsRealtimeOnly= "0" />

<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="0" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
<r CustId="41912311" RoleId="2" CategoryId="140600" IsNewCreated="1" IsRealtimeOnly= "0" />
</Root>';