// start-mcp.js
const config = {
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    }
  }
};

import { spawn } from 'child_process';

// Get server config
const server = config.mcpServers.playwright;

// Start MCP process
const mcpProcess = spawn(
    process.platform === 'win32' ? `${server.command}.cmd` : server.command,
    server.args,
    { stdio: 'inherit' }
);

// Handle process events
mcpProcess.on('close', (code) => {
    console.log(`MCP server process exited with code ${code}`);
});

mcpProcess.on('error', (err) => {
    console.error('Failed to start MCP server:', err);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
    console.log('\nGracefully shutting down MCP server...');
    mcpProcess.kill('SIGINT');
});

process.on('SIGTERM', () => {
    console.log('\nGracefully shutting down MCP server...');
    mcpProcess.kill('SIGTERM');
});

console.log('MCP Server started. Waiting for connections...');
