# Install library
npm uninstall @playwright/mcp@latest @playwright/test@latest ts-node typescript @types/node mysql2 mssql googleapis @types/js-yaml csv-parse luxon dotenv
npx playwright uninstall

npm install -D @playwright/mcp@latest @playwright/test@latest ts-node typescript @types/node mysql2 mssql googleapis @types/js-yaml csv-parse luxon dotenv
npx playwright install --with-deps

# Generate Prompt
node utils/generate_prompt.js ENV=${env}

# Generate Code
node utils/generate_script.js ENV=${env}

# Run tests
node runner.js <env> <browser> <mode>
node runner.js local chrome --headed

npx playwright test src/auth-login.test.ts ENV=local --project=firefox
npx playwright test src/local/tests/account-profile__mark-category__AccProfile__AP-00001.test.ts --project=firefox --headed --max-failures=1

# Open Terminal = Git Bash or Run Docker
chmod +x runner.sh
./runner.sh

# Account Test (select * from CTSCustomer where srecommend = 179806989;)
NAS001
NAS001M001
NAS001M001A001
NAS001M001A001MEM001
NAS001M001A001MEM002
NAS001M001A001MEM003
NAS001M001A001MEM004
NAS001M001A001MEM005
NAS001M001A001MEM006
NAS001M001A001MEM007
NAS001M001A001MEM008
NAS001M001A001MEM009
NAS001M001A001MEM010
NAS001M001A001MEM011
NAS001M001A001MEM012
NAS001M001A002
NAS001M001A002MEM001
NAS001M001A002MEM002
NAS001M001A002MEM003
NAS001M001A002MEM004
NAS001M001A002MEM005
NAS001M001A002MEM006
NAS001M001A002MEM007
NAS001M001A002MEM008
NAS001M001A002MEM009
NAS001M001A002MEM010
NAS001M001A002MEM011
NAS001M001A002MEM012
NAS001M001A003
NAS001M001A003MEM001
NAS001M001A003MEM002
NAS001M001A003MEM003
NAS001M001A003MEM004
NAS001M001A003MEM005
NAS001M001A003MEM006
NAS001M001A003MEM007
NAS001M001A003MEM008
NAS001M001A003MEM009
NAS001M001A003MEM010
NAS001M002
NAS001M003

delete from CTSCustomerClassification where custid in (179806989,179806990,179807022,179807027,179807094,179807095,179807096,179807097,187909775,187909776,187909777,187909778,187909779,187909780,187909781,179807023,179807029,179807098,179807099,179807100,187910807,187910808,187910809,187910810,187910811,187910812,187910813,187910814,179807024,179807030,179807101,179807102,239087070,239087071,239087072,239087073,239087074,239087075,239087076,239087068,239087069);

791050	12BETMBankUS$	12Bet	US$
791054	12BETMBankEURO	12Bet	EURO		
835097	12BetMBGBP	12Bet	GBP			
835262	Charges1PayRMB	12Bet	RMB
858252	12BETUUS01001	12Bet	IND
932263	AB88EcapayUS$	asiabet88	US$						
932275	AB88EcapayEURO	asiabet88	EURO						
932286	AB88EcapayTB	asiabet88	TB						
932294	AB88EcapayGBP	asiabet88	GBP						
932304	AB88EcapayRM	asiabet88	RM



# Gemini
Requests per minute (RPM)
Tokens per minute (input) (TPM)
Requests per day (RPD)

https://ai.google.dev/gemini-api/docs/rate-limits

Models                              (RPM  TPM   RPD)
gemini-2.5-flash                    (10	  250k	250)
gemini-2.5-flash-lite-preview-06-17 (15	  250k	1k)
gemini-2.0-flash                    (15	  1tr	200)
gemini-2.0-flash-lite               (30	  1tr	200)
gemma-3-27b-it                      (60   500k   15k)
gemma-3n-e4b-it                     (30   100k    15k)



demo sql:
npx playwright test src/local/tests/account-profile__mark-category__AccProfile__AP-00002.test.ts --project=chrome