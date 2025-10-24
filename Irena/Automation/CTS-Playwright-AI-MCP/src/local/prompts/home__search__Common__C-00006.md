1. Go to https://cts.nexdev.net/v1/Home
2. Fill "NAS001M001" in input#txtInput and press Enter
3. Assert URL is https://cts.nexdev.net/v1/Account/Index/1001093076
4. Assert span.tag-text-left:has-text("Login Name:") + span.tag-text-right has text "NAS001M001"
5. Assert span.tag-text-left:has-text("Account Status:") + span.tag-text-right has text "Open"
6. Assert span.tag-text-left:has-text("Subscriber:") + span.tag-text-right has text "Alpha789y"
7. Assert span.tag-text-left:has-text("Site:") + span.tag-text-right has text "y789"
8. Assert span.tag-text-left:has-text("Level:") + span.tag-text-right has text "Master"