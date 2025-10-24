1. Go to https://cts.nexdev.net/v1/Home
2. Fill "NAS001M001A001MEM002" in input#txtInput and press Enter
3. Assert URL is https://cts.nexdev.net/v1/Account/Index/1001093244
4. Assert span.tag-text-left:has-text("Login Name:") + span.tag-text-right has text "NAS001M001A001MEM002"
5. Assert span.tag-text-left:has-text("Account Status:") + span.tag-text-right has text "Open"
6. Assert span.tag-text-left:has-text("Subscriber:") + span.tag-text-right has text "MAXBET789y"
7. Assert span.tag-text-left:has-text("Site:") + span.tag-text-right has text "y789"
8. Assert span.tag-text-left:has-text("Level:") + span.tag-text-right has text "Member"