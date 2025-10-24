// Run CMD: node utils/generate_script.js ENV=<env>
require('dotenv').config();
const fs = require('fs');
const path = require('path');

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function callGemini(prompt) {
  const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
  const apiKey = process.env.LLM_KEY;
  const apiUrl = process.env.LLM_URL;
  const response = await fetch(`${apiUrl}?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }]
    })
  });
  const data = await response.json();
  return data.candidates?.[0]?.content?.parts?.[0]?.text || '';
}

(async () => {
  const envArg = process.argv.find(arg => arg.includes('ENV='));
  const env = envArg ? envArg.replace('ENV=', '') : 'local';

  const envDir = path.join(__dirname, '../src', env);
  const promptsDir = path.join(envDir, 'prompts');
  const testsDir = path.join(envDir, 'tests');
  
  if (!fs.existsSync(promptsDir)) {
    console.error('Prompts folder for env not found:', promptsDir);
    process.exit(1);
  }

  if (!fs.existsSync(testsDir)) fs.mkdirSync(testsDir, { recursive: true });

  const promptFiles = fs.readdirSync(promptsDir).filter(f => f.endsWith('.md'));

  for (const file of promptFiles) {
    let module = '', codeVal = '', testHeader = '', testFooter = '', testScript = '';
    const promptPath = path.join(promptsDir, file);
    const prompt = fs.readFileSync(promptPath, 'utf8');
    const base = file.replace(/\.md$/, '');
    const parts = base.split('__');
    if (parts.length >= 3) {
      module = parts[parts.length - 2];
      codeVal = parts[parts.length - 1];
    } else {
      console.warn('Filename does not match expected pattern:', file);
    }

    const prefix = file.split('__')[0];
    if (prefix == 'login') { // Only test Login Functionality
      testHeader = `import { test, expect } from '@playwright/test';\nimport { writeTestResults } from '../../../utils/helpers';\n\ntest('Execute Test Scripts by Playwright Test Gemini', async ({ page }) => { \n let result = 'PASSED';\n try {\n`;
    } else {
      testHeader = `import { test as base, expect } from '@playwright/test';\nimport { writeTestResults, executeQuery } from '../../../utils/helpers';\n\nimport fs from 'fs';\nconst sessionPath = \`./src/${env}/session.json\`;\nconst test = base.extend({\n  storageState: fs.existsSync(sessionPath) ? sessionPath :undefined\n});\n\ntest('Execute Test Scripts by Playwright Test Gemini', async ({ page }) => { \n let result = 'PASSED';\n try {\n`;
    }

    testFooter = `\n     } catch (e) {\n       result = 'FAILED';\n       throw e;\n     } finally {\n       await writeTestResults('${env}', '${module}', '${codeVal}', result);\n     }\n});`;

    const stepRegex = /^\s*\d+\.\s*(.+)$/gm;
    let match;
    let allSteps = [];
    while ((match = stepRegex.exec(prompt)) !== null) {
      allSteps.push(match[0]);
    }
    const allStepsText = allSteps.join('\n');
    const stepPrompt = `Generate Playwright typescript code for the following steps. 
    - If a step contains IF and ELSE, generate TypeScript if and else code blocks accordingly, using variable names as in the prompt.
    - Only use lines that start with 'await page', 'await expect(page.locator(...))', 'await expect(', or TypeScript if and else blocks.
    - Do not include any comments, explanations, or any other code.

    ${allStepsText}`;    
    let stepCodeRaw = '';
    let retryCount = 0;
    while (retryCount < 3) {
      stepCodeRaw = await callGemini(stepPrompt);
      if (stepCodeRaw && stepCodeRaw.trim()) break;
      retryCount++;
      console.warn(`Gemini did not return code. Retrying (${retryCount}/3)...`);
      await delay(3000); // Delay 3s between retries
    }
    if (!stepCodeRaw || !stepCodeRaw.trim()) {
      console.error(`Gemini failed to return code after 3 attempts for file: ${file}`);
      continue;
    }

    //console.log('Gemini raw output:', stepCodeRaw);

    let stepCode = stepCodeRaw;
    const tsBlock = stepCodeRaw.match(/```typescript([\s\S]*?)```/);
    if (tsBlock && tsBlock[1].trim()) {
      stepCode = tsBlock[1].trim();
    }
    let codeLines = stepCode.split('\n').filter(line =>
      line.trim() && !line.trim().startsWith('//')
    );

    //console.log(codeLines);

    if (codeLines.length > 0) {
      stepCode = codeLines.join('\n');
      testScript = testHeader + '\n' + stepCode + '\n' + testFooter;

      const testFileName = file.replace(/\.md$/, '.test.ts');
      const testFilePath = path.join(testsDir, testFileName);
      fs.writeFileSync(testFilePath, testScript, 'utf8');
      console.log('Generated script:', testFilePath);
    }
    await delay(5000); // Delay 5s after successful Gemini call
  }
  /*
  for (const file of promptFiles) {
    fs.unlinkSync(path.join(promptsDir, file));
  }
  console.log('All prompts deleted in', promptsDir);
  */
})();