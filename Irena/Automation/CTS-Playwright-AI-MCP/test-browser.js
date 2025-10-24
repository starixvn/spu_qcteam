import { createContext, executeMcpTool } from './config-utils.js';

async function testWithDifferentBrowsers() {
    const browsers = ['chromium'];
    
    for (const browserType of browsers) {
        console.log(`\n=== Testing with ${browserType} ===`);
        
        const { browser, context, page } = await createContext(browserType);
        
        try {
            // Test navigate
            console.log(`Navigating with ${browserType}...`);
            await executeMcpTool('navigate', { 
                url: 'https://cts.nexdev.net/main' 
            }, context);
            
            // Test snapshot
            console.log('Taking page snapshot...');
            await executeMcpTool('snapshot', {}, context);
            console.log('Snapshot captured');
            
            // Wait a bit to see the page
            await page.waitForTimeout(2000);
            
        } catch (error) {
            console.error(`Error in ${browserType} test:`, error);
        } finally {
            console.log(`Closing ${browserType}...`);
            await browser.close();
        }
    }
}

// Run the test
console.log('Starting browser tests...');
testWithDifferentBrowsers().catch(console.error).finally(() => {
    console.log('\nAll tests completed!');
});
