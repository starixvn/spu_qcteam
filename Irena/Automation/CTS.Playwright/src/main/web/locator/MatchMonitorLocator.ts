export class MatchMonitorLocator {
    public readonly dateControl = {
        rbtn_ScanDate: '#rbtnScanDate[value="1"] > label:has-text("Scan Date")',
        rbtn_EventDate: '#rbtnEventDate[value="2"] > label:has-text("Event Date")',
        dpk_FromDT: '#dpkFromDate',
        dpk_ToDT: '#dpkToDate'
    };

    public readonly sportControl = {
        cbb_Sport: '#cbbSport',
        cbb_Sportms: '#cbbSport_ms > span:nth-child(2):has-text("{checkedOpt} of {totalOpt} select")',
        optgr_MainSP: '#cbbSport > optgroup:nth-child(1)[label="Main Sport"]',
        opt_MainSP: '#cbbSport > optgroup:nth-child(1) > option:has-text("{sportName}")',
        optgr_VirtualSP: '#cbbSport > optgroup:nth-child(2)[label="Virtual Sport"]',
        opt_VirtualSP: '#cbbSport > optgroup:nth-child(2) > option:has-text("{sportName}")'
    };

    public readonly eventControl = {
        txt_Event: '#txtEvent:has-text("Event")[placeholder="League/Match"]'
    };

    public readonly marketControl = {
        cbb_Market: '#cbbMarket',
        opt_AllMK: '#cbbMarket > option:nth-child(1):has-text("All")',
        opt_LiveMK: '#cbbMarket > option:nth-child(2):has-text("Live")',
        opt_NonLiveMK: '#cbbMarket > option:nth-child(3):has-text("Non-Live")'
    };

    public readonly matchSectionControl = {
        cbb_MatchSec: '#cbbMatchSection',
        cbb_MatchSecms: '#cbbMatchSection_ms > span:nth-child(2):has-text("{checkedOpt} of {totalOpt} select")',
        opt_LiveMS: '#cbbMatchSection > option:nth-child(1):has-text("Live")',
        opt_TodayMS: '#cbbMatchSection > option:nth-child(2):has-text("Today")',
        opt_EarlyMS: '#cbbMatchSection > option:nth-child(3):has-text("Early")',
        opt_ClosedMS: '#cbbMatchSection > option:nth-child(4):has-text("Closed")'
    };

    public readonly betTypeControl = {
        cbb_BetType: '#cbbBetType',
        cbb_BetTypems: '#cbbBetType_ms > span:nth-child(2):has-text("{checkedOpt} of {totalOpt} selected")',
        opt_BetType: '#cbbBetType > option:has-text("{betTypeName}")'
    };

    public readonly reasonControl = {
        cbb_Reason: '#cbbReason',
        cbb_Reasonms: '#cbbReason_ms > span:nth-child(2):has-text("{checkedOpt} of {totalOpt} selected")',
        optgr_BySys: '#cbbReason > optgroup:nth-child(1)[label="Detect By System"]',
        opt_ARB: '#cbbReason > optgroup:nth-child(1) > option:nth-child(1):has-text("ARB")',
        opt_FG: '#cbbReason > optgroup:nth-child(1) > option:nth-child(2):has-text("FG")',
        opt_GB: '#cbbReason > optgroup:nth-child(1) > option:nth-child(3):has-text("GB")',
        opt_HED: '#cbbReason > optgroup:nth-child(1) > option:nth-child(4):has-text("HED")',
        opt_IRR: '#cbbReason > optgroup:nth-child(1) > option:nth-child(5):has-text("IRR")',
        optgr_BySysPar: '#cbbReason > optgroup:nth-child(2)[label="Detect By System Parlay"]',
        opt_GBP: '#cbbReason > optgroup:nth-child(2) > option:nth-child(1):has-text("GB(P)")',
        optgr_ByAI: '#cbbReason > optgroup:nth-child(3)[label="Detect By AI"]',
        opt_LB: '#cbbReason > optgroup:nth-child(3) > option:nth-child(1):has-text("LB")'
    };

    public readonly verifiedControl = {
        cbb_Verified: '#cbbVerified',
        opt_All: '#cbbVerified > option:nth-child(1):has-text("All")',
        opt_Yes: '#cbbVerified > option:nth-child(2):has-text("Yes")',
        opt_No: '#cbbVerified > option:nth-child(3):has-text("No")'
    };

    public readonly actionButtons = {
        btn_Generate: '#btnGenerate',
        btn_Refresh: '#btnRefresh'
    };

    public readonly refreshControl = {
        cbb_Refresh: '#refreshList',
        opt_NoneRF: '#refreshList > li:nth-child(1):has-text("None")',
        opt_10RF: '#refreshList > li:nth-child(2):has-text("Refresh(15)")',
        opt_30RF: '#refreshList > li:nth-child(3):has-text("Refresh(30)")[id="#selectedRefresh"]',
        opt_60RF: '#refreshList > li:nth-child(4):has-text("Refresh(60)")'
    };

    public readonly pageSizeControl = {
        lbl_PageSize: '#tblMonitor_length > label:has-text("Page Size")',
        opt_1000PS: '#tblMonitor_length > option:nth-child(1):has-text("1,000")',
        opt_1500PS: '#tblMonitor_length > option:nth-child(2):has-text("1,500")',
        opt_2000PS: '#tblMonitor_length > option:nth-child(3):has-text("2,000")'
    };

    public readonly table = {
        tbl_MatchMonitor: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table',
        
        headers: {
            coltbl_Sport: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(1):has-text("Sport")',
            coltbl_League: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(2):has-text("League")',
            coltbl_Match: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(3):has-text("Match")',
            coltbl_Market: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(4):has-text("League")',
            coltbl_EventDate: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(5):has-text("Event Date")',
            coltbl_BetType: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(6):has-text("Bet Type")',
            coltbl_Reason: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(7):has-text("Reason")',
            coltbl_TotalAmt: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(8):has-text("Total Amt (RM)")',
            coltbl_TotalAmtHome: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(2) > th:nth-child(1):has-text("Home")',
            coltbl_TotalAmtAway: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(2) > th:nth-child(2):has-text("Away")',
            coltbl_TotalTrans: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(9):has-text("Total Ticket")',
            coltbl_TotalTransHome: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(2) > th:nth-child(3):has-text("Home")',
            coltbl_TotalTransAway: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(2) > th:nth-child(4):has-text("Away")',
            coltbl_Verified: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(10):has-text("Verified")',
            coltbl_VerifiedBy: '#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table > thead > tr:nth-child(1) > th:nth-child(11):has-text("Verified By")'
        }
    };
}