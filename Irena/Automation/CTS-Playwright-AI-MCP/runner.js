// Run CMD: node runner.js ENV=<env> BROWSER=<browser> MODE=<mode> 

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const envArg = process.argv.find(arg => arg.includes('ENV='));
const browserArg = process.argv.find(arg => arg.includes('BROWSER='));
const modeArg = process.argv.find(arg => arg.includes('MODE='));

const env = envArg ? envArg.replace('ENV=', '') : 'local';
const browser = browserArg ? browserArg.replace('BROWSER=', '') : 'chrome';
const mode = modeArg ? modeArg.replace('MODE=', '') : '';

try {
  console.log(`**********Generating all prompts for environment: ${env}**********`);
  execSync(`node utils/generate_prompt.js ENV=${env}`, { stdio: 'inherit' });

  console.log(`**********Generating all scripts for environment: ${env}**********`);
  execSync(`node utils/generate_script.js ENV=${env}`, { stdio: 'inherit' });

  console.log(`**********Saving login authentication in the first time for environment: ${env}**********`); 
  execSync(`npx playwright test src/auth-login.test.ts ENV=${env} --project=${browser} --max-failures=3`, { stdio: 'inherit' });
  
  const testDir = path.join(__dirname, `src/${env}/tests`);
  const allFiles = fs.readdirSync(testDir).filter(f => f.endsWith('.test.ts'));
  console.log('All test files:', allFiles);

  const pageFunctionOrder = [
    'login__login',
    'home__search',
    'account-profile__mark-category',
    //'account-profile__unmark-category',
    //'account-profile__check-general-info',
    //'account-profile__check-betting-statistic-tab',
    //'account-profile__check-associated-accounts-tab',
    //'account-profile__check-evidence-exceptions-tab',
    //'account-profile__check-customer-classification-tab',
    //'account-profile__check-transaction-history-tab',
    //'account-profile__check-robot-betting-tab',
    //'account-profile__check-sport-details-category',
    //'association-detection__detect',
    //'association-detection__check-tablegrid',
  ];

  for (const prefix of pageFunctionOrder) {
    const filesForPrefix = allFiles
      .filter(f => f.startsWith(prefix))
      .sort()
      .map(f => `src/${env}/tests/${f}`);
    if (filesForPrefix.length > 0) {
      console.log(`**********Running tests for Page__Function: ${prefix}**********`);
      execSync(`npx playwright test ${filesForPrefix.join(' ')} --project=${browser} ${mode} --max-failures=3`, { stdio: 'inherit' });
    }
  }
  
  execSync(`npx playwright show-report`, { stdio: 'inherit' });
  
} catch (e) {
  process.exit(1);
}