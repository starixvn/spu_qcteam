import { BasePage } from "../BasePage";
import { MatchMonitorLocator } from "../locator/MatchMonitorLocator";


export class MatchMonitorPage {
    private page: BasePage;
    private locators: MatchMonitorLocator;
    
    constructor() {
        this.locators = new MatchMonitorLocator();
        this.page = new BasePage('Match Monitor', '/MatchMonitor');
    }

    getPageSpecificActions(): Record<string, Function> {
        return {
            // Date controls
            verifyDateControl: this.verifyDateControl.bind(this),
            setDateRange: this.setDateRange.bind(this),
            toggleDateType: this.toggleDateType.bind(this),
            
            // Sport controls
            verifySportControl: this.verifySportControl.bind(this),
            selectSport: this.selectSport.bind(this),
            verifyMainSportsControl: this.verifyMainSportsControl.bind(this),
            verifyVirtualSportsControl: this.verifyVirtualSportsControl.bind(this),
            
            // Other controls
            verifyEventControl: this.verifyEventControl.bind(this),
            verifyMarketControl: this.verifyMarketControl.bind(this),
            verifyMatchSectionControl: this.verifyMatchSectionControl.bind(this),
            verifyBetTypeControl: this.verifyBetTypeControl.bind(this),
            verifyReasonControl: this.verifyReasonControl.bind(this),
            verifyVerifiedControl: this.verifyVerifiedControl.bind(this),
            
            // Action buttons
            verifyGenerateButton: this.verifyGenerateButton.bind(this),
            verifyRefreshButton: this.verifyRefreshButton.bind(this),
            
            // Table and data
            verifyPageSizeDropdown: this.verifyPageSizeDropdown.bind(this),
            verifyMatchMonitorTable: this.verifyMatchMonitorTable.bind(this),
            verifySearchMatch: this.verifySearchMatch.bind(this),
            
            // Utility actions
            generateResults: this.generateResults.bind(this),
            clearAllFilters: this.clearAllFilters.bind(this)
        };
    }

    async verifyDateControl(fromDate: string, toDate: string): Promise<void> {        
        const dateCtrl = this.locators.dateControl;
        
        // Verify elements are visible
        await this.page.waitForVisible(dateCtrl.rbtn_EventDate);
        await this.page.waitForVisible(dateCtrl.rbtn_ScanDate);
        await this.page.waitForVisible(dateCtrl.dpk_FromDT);
        await this.page.waitForVisible(dateCtrl.dpk_ToDT);
        // Verify default state - Event Date should be selected
        await this.page.isChecked(dateCtrl.rbtn_EventDate);
        // Test both date types
        await this.page.click(dateCtrl.rbtn_ScanDate);
        await this.setDateRange(fromDate, toDate);
        await this.page.click(dateCtrl.rbtn_EventDate);
        await this.setDateRange(fromDate, toDate);

        console.log('✅ Date control verified');
    }

    async setDateRange(fromDate: string, toDate: string): Promise<void> {
        const dateCtrl = this.locators.dateControl;

        await this.page.input(dateCtrl.dpk_FromDT, fromDate);
        await this.page.input(dateCtrl.dpk_ToDT, toDate);

        console.log(`✅ Date range set: ${fromDate} - ${toDate}`);
    }

    async toggleDateType(dateType: 'event' | 'scan'): Promise<void> {
        const dateCtrl = this.locators.dateControl;
        
        if (dateType === 'event') {
            await this.page.click(dateCtrl.rbtn_EventDate);
            console.log('✅ Switched to Event Date');
        } else {
            await this.page.click(dateCtrl.rbtn_ScanDate);
            console.log('✅ Switched to Scan Date');
        }
    }

    async verifySportControl(sportBettypes: any[]): Promise<void> {        
        const sportCtrl = this.locators.sportControl;
        const mainSports = sportBettypes.filter(sport => sport.sportGroup === "Main");
        const virtualSports = sportBettypes.filter(sport => sport.sportGroup === "Virtual");
        
        // Verify main elements are visible
        await this.page.waitForVisible(sportCtrl.cbb_Sport);
        await this.page.waitForVisible(sportCtrl.optgr_MainSP);
        await this.page.waitForVisible(sportCtrl.optgr_VirtualSP);

        // Test Main Sports
        for (const sport of mainSports) {
            await this.verifyMainSportsControl(sport);
        }

        // Test Virtual Sports  
        for (const sport of virtualSports) {
            await this.verifyVirtualSportsControl(sport);
        }
        
        console.log('✅ Sport control verified');
    }

    async selectSport(sportName: string, isVirtual: boolean = false): Promise<void> {
        const sportCtrl = this.locators.sportControl;
        const sportSelector = this.locators.getSportOption(sportName, isVirtual);

        await this.page.click(sportCtrl.cbb_Sport);
        await this.page.click(sportSelector);
        
        console.log(`✅ Sport selected: ${sportName} (${isVirtual ? 'Virtual' : 'Main'})`);
    }

    async verifyMainSportsControl(sport: any): Promise<void> {
        const sportSelector = this.locators.getSportOption(sport.sportName, false);
        
        // Check default selection if applicable
        if (sport.isDefault == "1") {
            await this.page.isChecked(sportSelector);
        }

        // Verify element is visible and functional
        await this.page.waitForVisible(sportSelector);
        await this.page.check(sportSelector);
        
        console.log(`✅ Main sport verified: ${sport.sportName}`);
    }

    async verifyVirtualSportsControl(sport: any): Promise<void> {
        const sportSelector = this.locators.getSportOption(sport.sportName, true);
        
        // Check default selection if applicable
        if (sport.isDefault == "1") {
            await this.page.isChecked(sportSelector);
        }
        
        // Verify element is visible and functional
        await this.page.waitForVisible(sportSelector);
        await this.page.check(sportSelector);
        
        console.log(`✅ Virtual sport verified: ${sport.sportName}`);
    }

    async verifyEventControl(): Promise<void> {        
        const eventCtrl = this.locators.eventControl;

        await this.page.waitForVisible(eventCtrl.txt_Event);
        
        console.log('✅ Event control verified');
    }

    async verifyMarketControl(): Promise<void> {        
        const marketCtrl = this.locators.marketControl;
        
        // Verify all options are visible
        await this.page.waitForVisible(marketCtrl.cbb_Market);
        await this.page.waitForVisible(marketCtrl.opt_AllMK);
        await this.page.waitForVisible(marketCtrl.opt_LiveMK);
        await this.page.waitForVisible(marketCtrl.opt_NonLiveMK);
        // Verify default selection (All should be selected)
        await this.page.isSelected(marketCtrl.opt_AllMK);
        // Test all market options
        await this.page.click(marketCtrl.opt_LiveMK);
        await this.page.click(marketCtrl.opt_NonLiveMK);
        await this.page.click(marketCtrl.opt_AllMK);
        
        console.log('✅ Market control verified');
    }

    async verifyMatchSectionControl(): Promise<void> {        
        const matchSecCtrl = this.locators.matchSectionControl;
        
        // Verify all options are visible
        await this.page.waitForVisible(matchSecCtrl.cbb_MatchSec);
        await this.page.waitForVisible(matchSecCtrl.opt_LiveMS);
        await this.page.waitForVisible(matchSecCtrl.opt_TodayMS);
        await this.page.waitForVisible(matchSecCtrl.opt_EarlyMS);
        await this.page.waitForVisible(matchSecCtrl.opt_ClosedMS);
        // Verify default selections (all should be checked)
        await this.page.isChecked(matchSecCtrl.opt_LiveMS);
        await this.page.isChecked(matchSecCtrl.opt_TodayMS);
        await this.page.isChecked(matchSecCtrl.opt_EarlyMS);
        await this.page.isChecked(matchSecCtrl.opt_ClosedMS);
        // Test uncheck and recheck all options
        await this.page.uncheck(matchSecCtrl.opt_LiveMS);
        await this.page.uncheck(matchSecCtrl.opt_TodayMS);
        await this.page.uncheck(matchSecCtrl.opt_EarlyMS);
        await this.page.uncheck(matchSecCtrl.opt_ClosedMS);
        await this.page.check(matchSecCtrl.opt_LiveMS);
        await this.page.check(matchSecCtrl.opt_TodayMS);
        await this.page.check(matchSecCtrl.opt_EarlyMS);
        await this.page.check(matchSecCtrl.opt_ClosedMS);
        
        console.log('✅ Match section control verified');
    }
    
    async verifyBetTypeControl(sportBettypes: any[]): Promise<void> {        
        const betTypeCtrl = this.locators.betTypeControl;

        await this.page.waitForVisible(betTypeCtrl.cbb_BetType);
        
        // Test each bet type from data
        for (const sport of sportBettypes) {
            const betTypeSelector = this.locators.getBetTypeOption(sport.betTypeName);
            
            await this.page.waitForVisible(betTypeSelector);
            
            // Check default selection if applicable
            if (sport.isDefault == "1") {
                await this.page.isChecked(betTypeSelector);
            }
            
            // Test uncheck and check
            await this.page.uncheck(betTypeSelector);
            await this.page.check(betTypeSelector);
        }
        
        console.log('✅ Bet type control verified');
    }
    
    async verifyReasonControl(): Promise<void> {        
        const reasonCtrl = this.locators.reasonControl;
        
        // Verify main elements and groups
        await this.page.waitForVisible(reasonCtrl.cbb_Reason);
        await this.page.waitForVisible(reasonCtrl.optgr_BySys);
        await this.page.waitForVisible(reasonCtrl.optgr_BySysPar);
        await this.page.waitForVisible(reasonCtrl.optgr_ByAI);
        // Verify all reason options are visible
        await this.page.waitForVisible(reasonCtrl.opt_ARB);
        await this.page.waitForVisible(reasonCtrl.opt_FG);
        await this.page.waitForVisible(reasonCtrl.opt_GB);
        await this.page.waitForVisible(reasonCtrl.opt_HED);
        await this.page.waitForVisible(reasonCtrl.opt_IRR);
        await this.page.waitForVisible(reasonCtrl.opt_GBP);
        await this.page.waitForVisible(reasonCtrl.opt_LB);

        // Verify default selections (all should be checked)
        const reasonOptions = [
            reasonCtrl.opt_ARB, reasonCtrl.opt_FG, reasonCtrl.opt_GB,
            reasonCtrl.opt_HED, reasonCtrl.opt_IRR, reasonCtrl.opt_GBP, reasonCtrl.opt_LB
        ];

        for (const option of reasonOptions) {
            await this.page.isChecked(option);
            await this.page.uncheck(option);
            await this.page.check(option);
        }
        
        console.log('✅ Reason control verified');
    }

    async verifyVerifiedControl(): Promise<void> {        
        const verifiedCtrl = this.locators.verifiedControl;
        
        // Verify all options are visible
        await this.page.waitForVisible(verifiedCtrl.cbb_Verified);
        await this.page.waitForVisible(verifiedCtrl.opt_All);
        await this.page.waitForVisible(verifiedCtrl.opt_Yes);
        await this.page.waitForVisible(verifiedCtrl.opt_No);
        // Verify default selection (All should be selected)
        await this.page.isSelected(verifiedCtrl.opt_All);
        // Test all verified options
        await this.page.click(verifiedCtrl.opt_Yes);
        await this.page.click(verifiedCtrl.opt_No);
        await this.page.click(verifiedCtrl.opt_All);
        
        console.log('✅ Verified control verified');
    }

    async verifyGenerateButton(): Promise<void> {        
        const generateBtn = this.locators.actionButtons.btn_Generate;
        await this.page.waitForVisible(generateBtn);
        await this.page.click(generateBtn);
        
        console.log('✅ Generate button verified');
    }

    async generateResults(): Promise<void> {
        await this.page.click(this.locators.actionButtons.btn_Generate);
        console.log('🔄 Search results generated');
    }

    async verifyRefreshButton(): Promise<void> {        
        const refreshCtrl = this.locators.refreshControl;
        
        // Verify all elements are visible
        await this.page.waitForVisible(this.locators.actionButtons.btn_Refresh);    
        await this.page.waitForVisible(refreshCtrl.cbb_Refresh);
        await this.page.waitForVisible(refreshCtrl.opt_NoneRF);  
        await this.page.waitForVisible(refreshCtrl.opt_10RF);
        await this.page.waitForVisible(refreshCtrl.opt_30RF);
        await this.page.waitForVisible(refreshCtrl.opt_60RF);
        // Verify default selection (30 seconds should be selected)
        await this.page.isSelected(refreshCtrl.opt_30RF);
        // Test all refresh options
        await this.page.click(refreshCtrl.opt_10RF);
        await this.page.click(refreshCtrl.opt_30RF);
        await this.page.click(refreshCtrl.opt_60RF);
        await this.page.click(refreshCtrl.opt_NoneRF);
        
        console.log('✅ Refresh control verified');
    }

    async verifyPageSizeDropdown(): Promise<void> {        
        // Generate results first to show the table
        await this.generateResults();
        
        const pageSizeCtrl = this.locators.pageSizeControl;
        
        // Verify elements are visible
        await this.page.waitForVisible(pageSizeCtrl.lbl_PageSize);
        await this.page.waitForVisible(pageSizeCtrl.opt_1000PS);
        await this.page.waitForVisible(pageSizeCtrl.opt_1500PS);
        await this.page.waitForVisible(pageSizeCtrl.opt_2000PS);
        // Verify default (1000 should be selected)
        await this.page.isSelected(pageSizeCtrl.opt_1000PS);
        // Test all page size options
        await this.page.click(pageSizeCtrl.opt_1000PS);
        await this.page.click(pageSizeCtrl.opt_1500PS);
        await this.page.click(pageSizeCtrl.opt_2000PS);
        
        console.log('✅ Page size dropdown verified');
    }

    async verifyMatchMonitorTable(): Promise<void> {        
        // Generate results first to show the table
        await this.generateResults();
        
        const table = this.locators.table;
        const headers = table.headers;

        // Verify main table is visible
        await this.page.waitForVisible(table.tbl_MatchMonitor);
        // Verify all column headers are visible
        await this.page.waitForVisible(headers.coltbl_Sport);
        await this.page.waitForVisible(headers.coltbl_League);
        await this.page.waitForVisible(headers.coltbl_Match);
        await this.page.waitForVisible(headers.coltbl_Market);
        await this.page.waitForVisible(headers.coltbl_EventDate);
        await this.page.waitForVisible(headers.coltbl_BetType);
        await this.page.waitForVisible(headers.coltbl_Reason);
        await this.page.waitForVisible(headers.coltbl_TotalAmt);
        await this.page.waitForVisible(headers.coltbl_TotalAmtHome);
        await this.page.waitForVisible(headers.coltbl_TotalAmtAway);
        await this.page.waitForVisible(headers.coltbl_TotalTrans);
        await this.page.waitForVisible(headers.coltbl_TotalTransHome);
        await this.page.waitForVisible(headers.coltbl_TotalTransAway);
        await this.page.waitForVisible(headers.coltbl_Verified);
        await this.page.waitForVisible(headers.coltbl_VerifiedBy);
        
        console.log('✅ Match monitor table verified');
    }

    async verifySearchMatch(
        dateType: string,
        fromDate: string,
        toDate: string,
        sport: string = "",
        event: string = "",
        market: string = "",
        matchSection: string = "",
        betType: string = "",
        reason: string = "",
        isVerified: string = "",
        matchData: any[] = []
    ): Promise<void> {
        console.log(`🔍 Performing comprehensive search with multiple parameters...`);
        
        // Set date criteria
        await this.toggleDateType(dateType.toLowerCase() === "eventdate" ? "event" : "scan");
        await this.setDateRange(fromDate, toDate);
        
        // Set sport if specified
        if (sport) {
            await this.selectSport(sport);
        }
        
        // Set event if specified
        if (event) {
            await this.page.input(this.locators.eventControl.txt_Event, event);
        }
        
        // Set market if specified
        if (market) {
            const marketCtrl = this.locators.marketControl;

            await this.page.click(marketCtrl.cbb_Market);
            
            switch (market) {
                case "All":
                    await this.page.click(marketCtrl.opt_AllMK);
                    break;
                case "Live":
                    await this.page.click(marketCtrl.opt_LiveMK);
                    break;
                case "Non-Live":
                    await this.page.click(marketCtrl.opt_NonLiveMK);
                    break;
            }
        }
        
        // Set match section if specified
        if (matchSection) {
            const matchSecCtrl = this.locators.matchSectionControl;

            await this.page.click(matchSecCtrl.cbb_MatchSec);
            
            switch (matchSection) {
                case "Live":
                    await this.page.click(matchSecCtrl.opt_LiveMS);
                    break;
                case "Today":
                    await this.page.click(matchSecCtrl.opt_TodayMS);
                    break;
                case "Early":
                    await this.page.click(matchSecCtrl.opt_EarlyMS);
                    break;
                case "Closed":
                    await this.page.click(matchSecCtrl.opt_ClosedMS);
                    break;
            }
        }
        
        // Set bet type if specified
        if (betType) {
            const betTypeCtrl = this.locators.betTypeControl;
            const betTypeSelector = this.locators.getBetTypeOption(betType);

            await this.page.click(betTypeCtrl.cbb_BetType);
            await this.page.click(betTypeSelector);
        }
        
        // Set reason if specified
        if (reason) {
            const reasonCtrl = this.locators.reasonControl;
            const reasonMap = {
                "ARB": reasonCtrl.opt_ARB,
                "FG": reasonCtrl.opt_FG,
                "GB": reasonCtrl.opt_GB,
                "HED": reasonCtrl.opt_HED,
                "IRR": reasonCtrl.opt_IRR,
                "GB(P)": reasonCtrl.opt_GBP,
                "LB": reasonCtrl.opt_LB
            };

            await this.page.click(reasonCtrl.cbb_Reason);

            if (reasonMap[reason as keyof typeof reasonMap]) {
                await this.page.click(reasonMap[reason as keyof typeof reasonMap]);
            }
        }
        
        // Set verified status if specified
        if (isVerified) {
            const verifiedCtrl = this.locators.verifiedControl;

            await this.page.click(verifiedCtrl.cbb_Verified);
            
            switch (isVerified) {
                case "All":
                    await this.page.click(verifiedCtrl.opt_All);
                    break;
                case "Yes":
                    await this.page.click(verifiedCtrl.opt_Yes);
                    break;
                case "No":
                    await this.page.click(verifiedCtrl.opt_No);
                    break;
            }
        }

        // Verify search results if data provided
        if (matchData && matchData.length > 0) {
            await this.verifySearchResults(matchData);
        }
        
        console.log('✅ Comprehensive search completed successfully');
    }

    private async verifySearchResults(matchData: any[]): Promise<void> {        
        const headers = this.locators.table.headers;
        
        for (let i = 0; i < matchData.length; i++) {
            const currentMatch = matchData[i];
            
            // Verify each column data matches expected values
            if (currentMatch["sport"]) await this.page.assertText(headers.coltbl_Sport, currentMatch["sport"]);
            if (currentMatch["league"]) await this.page.assertText(headers.coltbl_League, currentMatch["league"]);
            if (currentMatch["match"]) await this.page.assertText(headers.coltbl_Match, currentMatch["match"]);
            if (currentMatch["market"]) await this.page.assertText(headers.coltbl_Market, currentMatch["market"]);
            if (currentMatch["eventDate"]) await this.page.assertText(headers.coltbl_EventDate, currentMatch["eventDate"]);
            if (currentMatch["betType"]) await this.page.assertText(headers.coltbl_BetType, currentMatch["betType"]);
            if (currentMatch["reason"]) await this.page.assertText(headers.coltbl_Reason, currentMatch["reason"]);
            if (currentMatch["totalAmtHome"]) await this.page.assertText(headers.coltbl_TotalAmtHome, currentMatch["totalAmtHome"]);
            if (currentMatch["totalAmtAway"]) await this.page.assertText(headers.coltbl_TotalAmtAway, currentMatch["totalAmtAway"]);
            if (currentMatch["totalTransHome"]) await this.page.assertText(headers.coltbl_TotalTransHome, currentMatch["totalTransHome"]);
            if (currentMatch["totalTransAway"]) await this.page.assertText(headers.coltbl_TotalTransAway, currentMatch["totalTransAway"]);
            if (currentMatch["verified"]) await this.page.assertText(headers.coltbl_Verified, currentMatch["verified"]);
            if (currentMatch["verifiedBy"]) await this.page.assertText(headers.coltbl_VerifiedBy, currentMatch["verifiedBy"]);
        }
        
        console.log('✅ Search results verification completed');
    }

    async clearAllFilters(): Promise<void> {   
        const marketCtrl = this.locators.marketControl;
        const verifiedCtrl = this.locators.verifiedControl;
        
        // Reset date to current date
        await this.toggleDateType("event");
        await this.setDateRange(this.page.getCurrentDate(), this.page.getCurrentDate());
        // Reset market to All
        await this.page.click(marketCtrl.cbb_Market);
        await this.page.click(marketCtrl.opt_AllMK);
        // Reset verified to All
        await this.page.click(verifiedCtrl.cbb_Verified);
        await this.page.click(verifiedCtrl.opt_All);
        
        console.log('✅ All filters cleared');
    }

    async waitForPageLoad(): Promise<void> {        
        // Wait for essential elements to be visible
        await this.page.waitForVisible(this.locators.dateControl.dpk_FromDT);
        await this.page.waitForVisible(this.locators.dateControl.dpk_ToDT);
        await this.page.waitForVisible(this.locators.sportControl.cbb_Sport);
        await this.page.waitForVisible(this.locators.actionButtons.btn_Generate);
        // Wait for page to be idle
        await this.page.waitForIdlePage();
        
        console.log(`✅ ${this.page.getPageTitle()} page loaded successfully`);
    }

    async validatePageState(): Promise<boolean> {
        try {
            // Check that we're on the right page and essential controls are ready
            await this.page.verifyPageTitle();
            
            // Verify critical controls are functional
            const dateCtrl = this.locators.dateControl;
            const isFromDateVisible = await this.page.isPresent(dateCtrl.dpk_FromDT);
            const isToDateVisible = await this.page.isPresent(dateCtrl.dpk_ToDT);
            const isGenerateVisible = await this.page.isPresent(this.locators.actionButtons.btn_Generate);
            
            if (!isFromDateVisible || !isToDateVisible || !isGenerateVisible) {
                console.error('❌ Essential match monitor elements are not present');
                return false;
            }
            
            return true;
        } catch (error) {
            console.error(`❌ Match Monitor page validation failed:`, error);
            return false;
        }
    }
}