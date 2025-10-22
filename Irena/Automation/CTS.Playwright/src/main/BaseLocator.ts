export class BaseLocator {
    header = {
        title_CTS: 'head > title:has-text("Customer Tracking System")',
        icon_CTS: 'head > link:nth-child(6)[href="/{subDomain}/favicon.ico"]',
        logo_CTS: 'body > header > a.logo[href="/{subDomain}/] > svg > image[src="/{subDomain}/Content/scss/images/logo-header.png"]',
        txt_Search: '#txtInput[placeholder="Search"]'
    };
  
    navigation = {
        mngr_Home: '#menu-home > a:has-text("Home")[href="/{subDomain}"]',
        
        mngr_Controller: '#Controller > a:has-text("Controller")[href="#Controller"]',
        mn_AssGroupMtr: '#Controller > ul > li:nth-child(1) > a:has-text("Association Group Monitor")[href="/{subDomain}/AssociationGroupMonitor"]',
        mn_SpecialCC: '#Controller > ul > li:nth-child(2) > a:has-text("Special Customer Class")[href="/{subDomain}/SpecialCustomerClass"]',
        mn_AssDetection: '#Controller > ul > li:nth-child(3) > a:has-text("Association Detection")[href="/{subDomain}/AssociationDetection"]',
        mn_ProblemAccMng: '#Controller > ul > li:nth-child(4) > a:has-text("Problem Account Management")[href="/{subDomain}/ProblemAccountManagement"]',
  
        mngr_Report: '#Report > a:has-text("Report")[href="#Report"]',
        mn_LatestTrans: '#Report > ul > li:nth-child(1) > a:has-text("Latest Transaction")[href="/{subDomain}/LatestTransaction"]',
        mn_TransRpt: '#Report > ul > li:nth-child(2) > a:has-text("Transaction Report")[href="/{subDomain}/TransactionReport"]',
        mn_RobotRpt: '#Report > ul > li:nth-child(3) > a:has-text("Robot Report")[href="/{subDomain}/RobotReport"]',
  
        mngr_Monitor: '#Monitor > a:has-text("Monitor")[href="#Monitor"]',
        mn_MatchMtr: '#Monitor > ul > li:nth-child(1) > a:has-text("Match Monitor")[href="/{subDomain}/MatchMonitor"]',
        mn_DangerMtr: '#Monitor > ul > li:nth-child(2) > a:has-text("Danger Monitor")[href="/{subDomain}/DangerMonitor"]',
  
        mngr_User: 'body > header > div.header-right > div > div.username > span:has-text("{username}")',
        mn_Logout: 'body > header > div.header-right > div > div.username > ul > li:nth-child(2) > a:has-text("Logout")[href="/{subDomain}/UserLogin/Login/Logout"]'
    };
  
    page = {
        title_Page: 'body > section > div > section > div.content > h2:has-text("{pageTitle}")'
    };
}