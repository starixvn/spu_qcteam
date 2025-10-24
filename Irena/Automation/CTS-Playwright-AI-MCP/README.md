In here, I will introduce you action step by step to testing CTS web through Playwright Test and LLM (Gemini Flash 2.5)

# Step 1. Prepare prompt

Prefix file: core-prompts/{page}__{function}.txt

Example: login__login.txt

            1. Go to {{baseURL}}/UserLogin/Login

            2. Fill "{{ip_username}}" in input#username

            3. Fill "{{ip_password}}" in input#password

            4. Click button:has-text("Login")

            5. Assert URL is {{baseURL}}/{{op_endpoint}}

# Step 2. Prepare test data

Prefix file: src/{environment}/test-data/{page}__{function}.json

Example: login__login.json

        [

            {"module":"Common","code":"C-00001","ip_username":"sa","ip_password":"1234aa","op_endpoint":"Home"},

            {"module":"Common","code":"C-00002","ip_username":"sa000","ip_password":"1234aa","op_endpoint":"UserLogin/Login"},

            {"module":"Common","code":"C-00003","ip_username":"sa","ip_password":"1234aa000","op_endpoint":"UserLogin/Login"},

            {"module":"Common","code":"C-00004","ip_username":"sa000","ip_password":"1234aa000","op_endpoint":"UserLogin/Login"}

        ]

# Step 3. Config function testing priority order

File: runner.js

Example: const pageFunctionOrder = [

            'login__login',

            'home__search',

            'account-profile__mark-category'

        ];

# Step 4. Run test

# Option 1. Run all by Gitlab CI

Only adjust any files --> Auto push Git and trigger pipeline

# Option 2. Run all by manual

CMD: node runner.js ENV=${env} BROWSER=${browser} MODE=${mode}

     node runner.js local chrome --headed

# Option 3. Run specfific file by manual 

CMD: node utils/generate_prompt.js ENV=${env}

     node utils/generate_prompt.js ENV=local

CMD: node utils/generate_script.js ENV=${env}

     node utils/generate_script.js ENV=local

CMD: npx playwright test src/auth-login.test.ts ENV=${env} --project=${browser}

     npx playwright test src/local/tests/account-profile__mark-category__AccProfile__AP-00001.test.ts --project=firefox --headed --max-failures=1

# Step 5. Config others

Install libraries (In case not existing):
npm install -D @playwright/test@latest ts-node typescript @types/node mysql2 mssql googleapis @types/js-yaml csv-parse luxon xml2js dotenv
npx playwright install chromium firefox msedge --with-deps

