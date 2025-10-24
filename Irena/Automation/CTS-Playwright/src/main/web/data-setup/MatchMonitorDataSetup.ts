export class MatchMonitorInit {
    private static prefixCode: string = 'MatchMonitor_';

    async connectAllServers(): Promise<boolean> {
        try {
            await this.database.connectServers(['ctsMain', 'custDB', 'dbTrans', 'db061']);
            return true;

        } catch (error) {
            console.error('❌ Database connection failed:', error);
            return false;
        }
    }

    async importData(
        csvFiles: {
            matches: string;
            tickets: string;
            associations: string;
            ccdanger: string;
        },
        assType: string = 'default'
    ): Promise<{
        matches: { success: number; failed: number; errors: string[] };
        tickets: { success: number; failed: number; errors: string[] };
        associationsFromCTS: { success: number; failed: number; errors: string[] };
        associationsFromMain: { success: number; failed: number; errors: string[] };
        ccdanger: { success: number; failed: number; errors: string[] };
        summary: { totalSuccess: number; totalFailed: number };
    }> {
        const commonVars = {
            CreatedBy: this.database.createdBy,
            PrefixCode: MatchMonitorPage.prefixCode
        };

        try {
            // Import matches
            const matchResults = await this.importMatches(csvFiles.matches, commonVars);
            console.log('✅ Matches imported successfully');

            // Import tickets  
            const ticketResults = await this.importTickets(csvFiles.tickets, commonVars);
            console.log('✅ Tickets imported successfully');

            // Import associations with AssType
            const associationResultsFromCTS = await this.importAssociationFromCTS(csvFiles.associations, commonVars, assType);
            const associationResultsFromMain = await this.importAssociationFromMain(csvFiles.associations, commonVars, assType);
            console.log('✅ Associations imported successfully');

            // Import CC danger
            const ccdangerResults = await this.importCCDanger(csvFiles.ccdanger, commonVars);
            console.log('✅ CC danger imported successfully');

            // Calculate summary
            const totalSuccess = matchResults.success + ticketResults.success + 
                               associationResultsFromCTS.success + associationResultsFromMain.success + ccdangerResults.success;
            const totalFailed = matchResults.failed + ticketResults.failed + 
                              associationResultsFromCTS.failed + associationResultsFromMain.failed + ccdangerResults.failed;

            const results = {
                matches: matchResults,
                tickets: ticketResults,
                associationsFromCTS: associationResultsFromCTS,
                associationsFromMain: associationResultsFromMain,
                ccdanger: ccdangerResults,
                summary: { totalSuccess, totalFailed }
            };

            console.log('🎯 Comprehensive data import completed!');
            console.log(`📊 Summary: ${totalSuccess} success, ${totalFailed} failed`);

            return results;

        } catch (error) {
            console.error('❌ Data import failed:', error);
            throw error;
        }
    }

    /**
     * Clear all test data (cleanup method)
     */
    async cleanupData(): Promise<void> {        
        try {
            const matchCodePattern = `${MatchMonitorPage.prefixCode}%`;
            // Get list of affected customers first            
            const listCustID = await this.database.executeQueryOnDBTrans(`SELECT DISTINCT CustID FROM dbo.bettrans AS b INNER JOIN dbo.match AS m ON b.matchid = m.matchid WHERE m.matchcode LIKE '${matchCodePattern}'`);
            
            // Delete in reverse order to handle foreign key constraints
            for (const custRow of listCustID) {
                const custID = custRow.CustID;
                
                await this.database.executeQueryOnDBTrans('bodb02', `DELETE FROM dbo.bettrans WHERE CustID = '${custID}'`);
                await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE ass FROM AssociationByDevice AS ass INNER JOIN CTSCustomer AS c ON c.CTSCustID = ass.CTSCustID WHERE c.CustID = '${custID}'`);
                await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE FROM AssociationByAI WHERE FromCustID IN (${custID}) OR ToCustID IN (${custID})`);
                await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE FROM AssociationByIP WHERE FromCustID IN (${custID}) OR ToCustID IN (${custID})`);
                await this.database.executeQueryOnDB061('bodb02', `DELETE FROM CTS_RawAssMatchIP WHERE FromCustID IN (${custID}) OR ToCustID IN (${custID})`);
            }

            // Clean main tables
            await this.database.executeQueryOnDBPro('bodb02', `DELETE FROM dbo.match WHERE matchcode LIKE '${matchCodePattern}'`);
            await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE FROM MatchMonitor WHERE Creator = '${this.database.createdBy}'`);
            await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE FROM MatchMonitorDetails WHERE Creator = '${this.database.createdBy}'`);
            await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE FROM MatchMonitorStagingGroupBettingLive WHERE Creator = '${this.database.createdBy}'`);
            await this.database.executeQueryOnCTSMain('CTS_DataCenter', `DELETE FROM MatchMonitorStagingGroupBettingNonLive WHERE Creator = '${this.database.createdBy}'`);         
                        
        } catch (error) {
            console.error('❌ Failed to clear test data:', error);
            throw error;
        }
    }


    /**
     * Import matches from CSV file
     */
    private async importMatches(csvFile: string, variables: Record<string, any>) {
        const sqlTemplate = `
            insert into dbo.match (
                leagueid,homeid,homeid2,awayid,awayid2,eventstatus,eventdate,kickofftime,
                GlobalShowTime,creator,matchcode,sporttype,DisplayMode,LeaguePatternID,
                HomeDisplayPatternID,AwayDisplayPatternID,IsNeutral,HasLive,ParentID,ChildMatchType
            )
            select 	\${LeagueID}
                ,	\${HomeID}
                ,	\${HomeID}
                ,	\${AwayID}
                ,	\${AwayID}
                ,	'running'
                ,	CAST('\${Date}')
                ,	CAST('\${Date}' + ' 01:00:00' AS DATETIME)
                ,	CAST('\${Date}' + ' 01:05:00' AS DATETIME)
                ,	'\${CreatedBy}'
                ,	'\${MatchCode}'
                ,	\${SportType}
                ,	1, 1, 1, 1, 0, 1
                ,   CASE WHEN \${ParentNo} <> 0 THEN \${ParentNo} ELSE NULL END
                ,	CASE WHEN \${ParentNo} <> 0 THEN \${ChildType} ELSE NULL END
            ;`;

        return await this.database.executeQueryOnDBPro('bodb02', '', csvFile, sqlTemplate, variables);
    }

    /**
     * Import tickets from CSV file
     */
    private async importTickets(csvFile: string, variables: Record<string, any>) {
        const sqlTemplate = `
            INSERT INTO dbo.bettrans (
                winlostdate,transdate,matchid,liveindicator,livehomescore,liveawayscore,statusid,status,
                bettype,betid,betcheck,betteam,betfrom,oddstype,oddsid,odds,hdp1,hdp2,stake,actualrate,
                custid,username,recommend,mrecommend,srecommend,currency,currencyName,ip,refno,creator
            )
            SELECT  '\${WinlossDate}'
                ,	'\${TransDate}'
                ,	m.MatchID
                ,	\${LiveIndicator}
                ,	\${LiveHomeScore}
                ,	\${LiveAwayScore}
                ,	\${StatusID}
                ,	'\${Status}'
                ,	\${BetType}
                ,	\${BetID}
                ,	'\${BetCheck}'
                ,	'\${BetTeam}'
                ,	'\${BetFrom}'
                ,	'\${OddsType}'
                ,	'\${OddsID}'
                ,	'\${Odds}'
                ,	'\${HDP1}'
                ,	'\${HDP2}'
                ,	\${StakeRM}
                ,	ex.actualrate
                ,	\${CustID}
                ,	cus.username
                ,	cus.recommend
                ,	cus.mrecommend
                ,	cus.srecommend
                ,	cus.currency
                ,	ex.currency
                ,	\${IP}
                ,	\${RefNo}
                ,	\${CreatedBy}'
            FROM dbo.match m with(nolock) cross join 
                (CustDB.dbo.customer cus with(nolock)
                INNER JOIN CustDB.dbo.Exchange ex with(nolock) on ex.ExchangeId = cus.currency)
            WHERE m.MatchCode = '\${MatchCode}' AND cus.CustID = \${CustID}
            ;`;

        return await this.database.executeQueryOnDBTrans('bodb02', '', csvFile, sqlTemplate, variables);
    }

    /**
     * Import associations from CSV file
     * @param csvFile - CSV file path
     * @param variables - Template variables
     * @param assType - Association type (controls which SQL script to use)
     * @returns Import results
     */
    private async importAssociationFromCTS(csvFile: string, variables: Record<string, any>, assType: string) {
        let sqlTemplate = '';

        switch (assType.toLowerCase()) {
            case 'device':
                sqlTemplate = `
                    INSERT INTO AssociationByDevice (CTSCustID, DCSDeviceID, SubscriberID, CreatedTime, InsertTime)
                    SELECT c.CTSCustID, '\${DeviceID}', c.SubscriberID, GETDATE(), GETDATE()
                    FROM CTSCustomer AS c
                    WHERE \${TypeID} = 1 AND c.CustID = \${CustID}
                    ;`;
                break;

            case 'agent':
                sqlTemplate = `
                    INSERT INTO AssociationByDevice (CTSCustID, DCSDeviceID, SubscriberID, CreatedTime, InsertTime)
                    SELECT c.CTSCustID, '\${DeviceID}', c.SubscriberID, GETDATE(), GETDATE()
                    FROM CTSCustomer AS c
                    WHERE \${TypeID} = 4 AND c.CustID = \${CustID}
                    ;`;
                break;
                
            case 'ai':
                sqlTemplate = `
                    INSERT INTO AssociationByAI (AssType, FromCustID, ToCustID, CreatedDate)
                    SELECT 1, \${CustID}, \${ToCustID}, GETDATE()
                    WHERE \${TypeID} = 2
                    ;`;
                break;
                
            case 'ip':
                sqlTemplate = `
                    INSERT INTO AssociationByAI (AssType,FromCustID,ToCustID,CreatedDate)
                    SELECT 1, \${CustID}, \${ToCustID}, GETDATE()
                    WHERE \${TypeID} = 3
                    ;`;
                break;
                
            default:
                console.warn(`⚠️ Unknown association type: ${assType}. Stop import.`);
                return { success: 0, failed: 0, errors: [`Unknown association type: ${assType}`] };
        }

        console.log(`🔗 Using association script for type: ${assType}`);
        return await this.database.executeQueryOnCTSMain('CTS_DataCenter', '', csvFile, sqlTemplate, variables);
    }

    /**
         * Import associations from CSV file
         * @param csvFile - CSV file path
         * @param variables - Template variables
         * @param assType - Association type (controls which SQL script to use)
         * @returns Import results
         */
    private async importAssociationFromMain(csvFile: string, variables: Record<string, any>, assType: string) {
        let sqlTemplate = '';

        switch (assType.toLowerCase()) {
            case 'matchlast7d':
                sqlTemplate = `
                    INSERT INTO CTS_RawAssMatchIP (AssTypeID, CustID, ToCustID)
                    SELECT \${TypeID}, \${CustID}, \${ToCustID}
                    WHERE \${TypeID} = 5
                    ;`;
                break;
            
            case 'iplast3d':
                sqlTemplate = `
                    INSERT INTO CTS_RawAssMatchIP (AssTypeID, CustID, ToCustID)
                    SELECT \${TypeID}, \${CustID}, \${ToCustID}
                    WHERE \${TypeID} = 6
                    ;`;
                break;    

            default:
                console.warn(`⚠️ Unknown association type: ${assType}. Stop import.`);
                return { success: 0, failed: 0, errors: [`Unknown association type: ${assType}`] };
        }

        console.log(`🔗 Using association script for type: ${assType}`);
        return await this.database.executeQueryOnDB061('bodb02', '', csvFile, sqlTemplate, variables);
    }

    /**
     * Import CC danger records from CSV file
     */
    private async importCCDanger(csvFile: string, variables: Record<string, any>) {
        const sqlTemplate = `
            UPDATE dbo.custinfo 
            SET CustomerClass = \${CustomerClass}, Danger3 = \${Danger3}, Danger2 = \${Danger2}, Danger = \${Danger}, Danger4 = \${Danger4}, Danger5 = \${Danger5}
            WHERE CustID = \${CustID};`;

        return await this.database.executeQueryOnDBCust('CustDB', '', csvFile, sqlTemplate, variables);
    }