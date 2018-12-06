# SizeAndMove
Easy app moving and resizing using modifier keys and mouse movement for macOS

## Improvement ideas
- Start on login

## Notes

- Doesn't work with Preview PDFs, and neither does any other app I tried, even paid ones from AppStore
- Cannot be placed on AppStore, because now all apps must be sandboxed, and sandboxed app cannot control other apps. Why are there apps on AppStore that do this? Because they were there before the restriction came to power, and apparently some could get special permission from Apple to keep a non-sandbox app on the store even after the rules changed.
- Resizing Xcode messes up one of the Xcode's toolbars. This is same for other apps of this kind. Assume cannot be fixed.
- Really laggy wth some apps, such as Slack. This is the same for other apps of this kind. Assume cannot be fixed.
- It kinda works when moving from one monitor to another, but not always (LOL). Competitor apps act the same, so, probably nothing can be done about this.

## Accessibility perimissions checker

1. see if has permissions (no system popup). If yes, proceed to launching app. If no, proceed to 2
2. display a window that explains the issue and have a "Open accessibility..." button
3. Open system preferences
4. display step-by-step instructions
