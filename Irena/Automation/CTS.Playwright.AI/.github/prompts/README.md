# Demo: Generating tests for Playwright Movies App

1. Make sure the server is running. You can press start in the server in the .vscode/settings.json file

2. Add the prompts/generate:test.md file to the chat context

3. Paste the following code into Copilot using Agent mode and Claude 3.5
```md
Generate a Playwright test for the following scenario:
1. Navigate to https://cts.nexdev.net/v1/UserLogin/Login
2. Input sa in Username
3. Input 1234aa in Password
4. Click Login button
```