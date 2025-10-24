import { chromium, firefox } from 'playwright';
import navigateTool from '@playwright/mcp/tool-navigate';
import snapshotTool from '@playwright/mcp/tool-snapshot';

class MockTab {
    constructor(page) {
        this.page = page;
    }

    async navigate(url) {
        await this.page.goto(url);
    }

    async snapshot() {
        return await this.page.accessibility.snapshot();
    }
}

class MockContext {
    constructor(page) {
        this.page = page;
        this.currentTab = new MockTab(page);
        this.tabs = [this.currentTab];
    }

    async ensureTab() {
        if (!this.currentTab) {
            this.currentTab = this.tabs[0];
        }
        return this.currentTab;
    }

    async getCurrentTab() {
        return await this.ensureTab();
    }
}

async function createContext(browserType = 'chromium', options = { headless: false }) {
    let browser;
    switch (browserType.toLowerCase()) {
        case 'firefox':
            browser = await firefox.launch(options);
            break;
        case 'msedge':
            browser = await chromium.launch({
                ...options,
                channel: 'msedge'
            });
            break;
        default:
            browser = await chromium.launch(options);
    }
    
    const page = await browser.newPage();
    const context = new MockContext(page);
    return { browser, context, page };
}

async function executeMcpTool(name, params, context) {
    try {
        let toolCreator;
        switch(name) {
            case 'navigate':
                toolCreator = navigateTool;
                break;
            case 'snapshot':
                toolCreator = snapshotTool;
                break;
            default:
                throw new Error(`Unknown tool: ${name}`);
        }
        
        // toolCreator is a function that returns an array of tool objects
        // Each tool object has a handle method
        const tools = toolCreator(true);  // Call toolCreator to get array of tools
        const tool = tools[0];  // Get first tool from array
        return await tool.handle(context, params);  // Call handle method with context and params
    } catch (error) {
        throw new Error(`Failed to execute MCP tool ${name}: ${error.message}`);
    }
}

export {
    createContext,
    executeMcpTool,
    MockContext,
    MockTab
};