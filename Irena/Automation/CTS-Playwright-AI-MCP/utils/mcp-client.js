// MCP Client utility for interacting with Playwright MCP server
// Run CMD: node utils/mcp-client.js ENV=<env> BROWSER=<browser>

const { spawn } = require('child_process');
const readline = require('readline');
const path = require('path'); // Added missing import for path

const envArg = process.argv.find(arg => arg.includes('ENV='));
const browserArg = process.argv.find(arg => arg.includes('BROWSER='));

const env = envArg ? envArg.replace('ENV=', '') : 'local';
const browser = browserArg ? browserArg.replace('BROWSER=', '') : 'chrome';

let mcpProcess = null;

async function startMCPServer() {
  return new Promise((resolve, reject) => {
    console.log(`Starting MCP server with browser: ${browser}`);
    
    mcpProcess = spawn('npx', ['@playwright/mcp@latest', '--port', '8931', '--browser', browser], {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let isReady = false;
    
    mcpProcess.stdout.on('data', (data) => {
      const output = data.toString();
      console.log('MCP Server:', output);
      if (output.includes('Server started') || output.includes('listening')) {
        isReady = true;
        resolve();
      }
    });

    mcpProcess.stderr.on('data', (data) => {
      console.error('MCP Server Error:', data.toString());
    });

    mcpProcess.on('error', (error) => {
      console.error('Failed to start MCP server:', error);
      reject(error);
    });

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

async function interactiveMode() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log('\n=== MCP Interactive Mode ===');
  console.log('Available commands:');
  console.log('- navigate <url> - Navigate to URL');
  console.log('- snapshot - Take page snapshot');
  console.log('- click <text> - Click element with text');
  console.log('- type <selector> <text> - Type text into element');
  console.log('- screenshot [filename] - Take screenshot');
  console.log('- quit - Exit interactive mode');
  console.log('===========================\n');

  const askQuestion = () => {
    rl.question('MCP> ', async (input) => {
      const parts = input.trim().split(' ');
      const command = parts[0].toLowerCase();

      try {
        switch (command) {
          case 'navigate':
            if (parts[1]) {
              console.log(`Navigating to: ${parts[1]}`);
              await callMCPServer('browser_navigate', { url: parts[1] });
              console.log('Navigation completed');
            } else {
              console.log('Usage: navigate <url>');
            }
            break;

          case 'snapshot':
            console.log('Taking snapshot...');
            const snapshot = await callMCPServer('browser_snapshot');
            console.log('Snapshot taken:', JSON.stringify(snapshot, null, 2));
            break;

          case 'click':
            if (parts[1]) {
              const text = parts.slice(1).join(' ');
              console.log(`Clicking element with text: ${text}`);
              await callMCPServer('browser_click', { 
                element: `button with text "${text}"`,
                ref: `button:has-text("${text}")`
              });
              console.log('Click completed');
            } else {
              console.log('Usage: click <text>');
            }
            break;

          case 'type':
            if (parts.length >= 3) {
              const selector = parts[1];
              const text = parts.slice(2).join(' ');
              console.log(`Typing "${text}" into ${selector}`);
              await callMCPServer('browser_type', {
                element: `input field ${selector}`,
                ref: selector,
                text: text
              });
              console.log('Typing completed');
            } else {
              console.log('Usage: type <selector> <text>');
            }
            break;

          case 'screenshot':
            const filename = parts[1] || `screenshot-${Date.now()}.png`;
            console.log(`Taking screenshot: ${filename}`);
            await callMCPServer('browser_take_screenshot', { filename });
            console.log('Screenshot saved');
            break;

          case 'quit':
            console.log('Exiting...');
            if (mcpProcess) {
              mcpProcess.kill();
            }
            rl.close();
            process.exit(0);
            break;

          default:
            console.log('Unknown command. Type "quit" to exit.');
            break;
        }
      } catch (error) {
        console.error('Error executing command:', error.message);
      }

      askQuestion();
    });
  };

  askQuestion();
}

async function runTestScenario() {
  try {
    // Load environment config
    const envConfig = require(path.join(__dirname, `../src/${env}/config.js`));
    const baseURL = envConfig.web?.baseURL || 'https://cts.nexdev.net/v1/UserLogin/Login';
    
    console.log(`Running test scenario for environment: ${env}`);
    console.log(`Base URL: ${baseURL}`);

    // Navigate to login page
    console.log('Navigating to login page...');
    await callMCPServer('browser_navigate', { url: baseURL });

    // Take snapshot
    console.log('Taking initial snapshot...');
    const snapshot = await callMCPServer('browser_snapshot');
    console.log('Page loaded successfully');

    // Fill username
    console.log('Filling username...');
    await callMCPServer('browser_type', {
      element: 'username input field',
      ref: '#username',
      text: envConfig.web?.usr || 'sa'
    });

    // Fill password
    console.log('Filling password...');
    await callMCPServer('browser_type', {
      element: 'password input field',
      ref: '#password',
      text: envConfig.web?.pwd || '1234aa'
    });

    // Click login button
    console.log('Clicking login button...');
    await callMCPServer('browser_click', {
      element: 'Login button',
      ref: 'button:has-text("Login")'
    });

    // Wait and take final snapshot
    console.log('Waiting for navigation...');
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    const finalSnapshot = await callMCPServer('browser_snapshot');
    console.log('Test scenario completed successfully');

    return { success: true, snapshot: finalSnapshot };
  } catch (error) {
    console.error('Test scenario failed:', error);
    return { success: false, error: error.message };
  }
}

async function main() {
  try {
    await startMCPServer();
    
    // Check if we should run test scenario or interactive mode
    const args = process.argv.slice(2);
    if (args.includes('--test')) {
      await runTestScenario();
    } else {
      await interactiveMode();
    }
  } catch (error) {
    console.error('MCP Client error:', error);
    process.exit(1);
  }
}

// Handle cleanup on exit
process.on('SIGINT', () => {
  console.log('\nShutting down...');
  if (mcpProcess) {
    mcpProcess.kill();
  }
  process.exit(0);
});

if (require.main === module) {
  main();
}
