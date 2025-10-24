// Run CMD: node utils/generate_mcp_script.js ENV=<env> BROWSER=<browser>
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function startMCPServer(browserType = 'chrome') {
  return new Promise((resolve, reject) => {
    const mcpProcess = spawn('npx', ['@playwright/mcp@latest', '--port', '8931', '--browser', browserType], {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let isReady = false;
    
    mcpProcess.stdout.on('data', (data) => {
      const output = data.toString();
      console.log('MCP Server:', output);
      if (output.includes('Server started') || output.includes('listening')) {
        isReady = true;
        resolve(mcpProcess);
      }
    });

    mcpProcess.stderr.on('data', (data) => {
      console.error('MCP Server Error:', data.toString());
    });

    mcpProcess.on('error', (error) => {
      console.error('Failed to start MCP server:', error);
      reject(error);
    });

    // Timeout after 10 seconds
    setTimeout(() => {
      if (!isReady) {
        mcpProcess.kill();
        reject(new Error('MCP server startup timeout'));
      }
    }, 10000);
  });
}

async function callMCPServer(action, params = {}) {
  const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
  
  try {
    const response = await fetch('http://localhost:8931/sse', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: Date.now(),
        method: action,
        params: params
      })
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data.result || data;
  } catch (error) {
    console.error('MCP Server call failed:', error);
    throw error;
  }
}

async function generateScriptWithMCP(prompt, browserType) {
  try {
    // Start MCP server
    console.log(`Starting MCP server with browser: ${browserType}`);
    const mcpProcess = await startMCPServer(browserType);
    
    // Wait for server to be ready
    await delay(2000);

    // Parse the prompt to extract URL and steps
    const urlMatch = prompt.match(/Go to (https?:\/\/[^\s]+)/);
    const url = urlMatch ? urlMatch[1] : 'https://cts.nexdev.net/v1/UserLogin/Login';

    // Navigate to the page
    console.log(`Navigating to: ${url}`);
    await callMCPServer('browser_navigate', { url });

    // Take a snapshot to understand the page structure
    console.log('Taking page snapshot...');
    const snapshot = await callMCPServer('browser_snapshot');
    
    // Parse steps from prompt
    const stepRegex = /^\s*\d+\.\s*(.+)$/gm;
    let match;
    let steps = [];
    while ((match = stepRegex.exec(prompt)) !== null) {
      steps.push(match[1].trim());
    }

    // Generate Playwright code based on MCP snapshot and steps
    let playwrightCode = '';
    
    for (const step of steps) {
      if (step.includes('Fill') && step.includes('input#')) {
        // Handle input filling
        const inputMatch = step.match(/Fill "([^"]+)" in input#([^\s]+)/);
        if (inputMatch) {
          const value = inputMatch[1];
          const selector = inputMatch[2];
          playwrightCode += `await page.fill('#${selector}', '${value}');\n`;
        }
      } else if (step.includes('Click button:has-text')) {
        // Handle button clicking
        const buttonMatch = step.match(/Click button:has-text\("([^"]+)"\)/);
        if (buttonMatch) {
          const buttonText = buttonMatch[1];
          playwrightCode += `await page.click('button:has-text("${buttonText}")');\n`;
        }
      } else if (step.includes('Assert URL')) {
        // Handle URL assertion
        const urlMatch = step.match(/Assert URL is (https?:\/\/[^\s]+)/);
        if (urlMatch) {
          const expectedUrl = urlMatch[1];
          playwrightCode += `await expect(page).toHaveURL('${expectedUrl}');\n`;
        }
      } else if (step.includes('Go to')) {
        // Handle navigation
        const navMatch = step.match(/Go to (https?:\/\/[^\s]+)/);
        if (navMatch) {
          const navUrl = navMatch[1];
          playwrightCode += `await page.goto('${navUrl}');\n`;
        }
      } else {
        // Generic step handling
        playwrightCode += `// ${step}\n`;
      }
    }

    // Clean up MCP server
    mcpProcess.kill();
    
    return playwrightCode;
  } catch (error) {
    console.error('Error generating script with MCP:', error);
    throw error;
  }
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
  const browserArg = process.argv.find(arg => arg.includes('BROWSER='));
  
  const env = envArg ? envArg.replace('ENV=', '') : 'local';
  const browser = browserArg ? browserArg.replace('BROWSER=', '') : 'chrome';

  console.log(`**********Generating MCP-enhanced scripts for environment: ${env}**********`);
  console.log(`**********Using browser: ${browser}**********`);

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
    if (prefix == 'login') {
      testHeader = `import { test, expect } from '@playwright/test';\nimport { writeTestResults } from '../../../utils/helpers';\n\ntest('Execute Test Scripts by Playwright MCP Enhanced', async ({ page }) => { \n let result = 'PASSED';\n try {\n`;
    } else {
      testHeader = `import { test as base, expect } from '@playwright/test';\nimport { writeTestResults, executeQuery } from '../../../utils/helpers';\n\nimport fs from 'fs';\nconst sessionPath = \`./src/${env}/session.json\`;\nconst test = base.extend({\n  storageState: fs.existsSync(sessionPath) ? sessionPath :undefined\n});\n\ntest('Execute Test Scripts by Playwright MCP Enhanced', async ({ page }) => { \n let result = 'PASSED';\n try {\n`;
    }

    testFooter = `\n     } catch (e) {\n       result = 'FAILED';\n       throw e;\n     } finally {\n       await writeTestResults('${env}', '${module}', '${codeVal}', result);\n     }\n});`;

    console.log(`Processing: ${file}`);
    
    try {
      // Try MCP-enhanced generation first
      let stepCode = await generateScriptWithMCP(prompt, browser);
      
      if (!stepCode || !stepCode.trim()) {
        console.log('MCP generation failed, falling back to Gemini...');
        
        // Fallback to original Gemini approach
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
          await delay(3000);
        }
        
        if (stepCodeRaw && stepCodeRaw.trim()) {
          const tsBlock = stepCodeRaw.match(/```typescript([\s\S]*?)```/);
          if (tsBlock && tsBlock[1].trim()) {
            stepCode = tsBlock[1].trim();
          } else {
            stepCode = stepCodeRaw;
          }
        }
      }

      let codeLines = stepCode.split('\n').filter(line =>
        line.trim() && !line.trim().startsWith('//')
      );

      if (codeLines.length > 0) {
        stepCode = codeLines.join('\n');
        testScript = testHeader + '\n' + stepCode + '\n' + testFooter;

        const testFileName = file.replace(/\.md$/, '.test.ts');
        const testFilePath = path.join(testsDir, testFileName);
        fs.writeFileSync(testFilePath, testScript, 'utf8');
        console.log('Generated MCP-enhanced script:', testFilePath);
      }
    } catch (error) {
      console.error(`Error processing ${file}:`, error);
      continue;
    }
    
    await delay(2000); // Delay between files
  }
  
  console.log('MCP-enhanced script generation completed!');
})();


