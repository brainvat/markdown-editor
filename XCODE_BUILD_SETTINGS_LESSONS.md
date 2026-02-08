# Xcode Build Settings Configuration Lessons

**Date:** 2026-02-08
**Context:** Attempting to configure platform-specific entitlements for Mac vs iOS in a single target

## The Problem

We needed to use different entitlement files for different platforms in a single Xcode target:
- **Mac**: `Markdown_Editor.entitlements` (includes `com.apple.security.files.user-selected.read-write` for NSSavePanel)
- **iOS/iPad**: `Markdown_Editor_iOS.entitlements` (without Mac-specific sandbox entitlements)

## Why This Was Needed

The Mac native app uses `NSSavePanel()` for file exports, which requires the sandbox entitlement:
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

iOS uses SwiftUI's `.fileExporter()` which handles permissions automatically and doesn't need (or allow) this entitlement.

Having the Mac entitlement in the iOS build caused build errors:
```
Entitlements file was modified during the build, which is not supported.
```

## Attempted Solutions (What DIDN'T Work)

### Attempt 1: Xcode UI - Add Conditional Setting
**Tried:** Build Settings → Code Signing Entitlements → Add Conditional Setting
**Result:** "Add Conditional Setting" was **greyed out** in the UI
**Why it failed:** Xcode's UI doesn't properly support conditional entitlements for unified targets

### Attempt 2: Double-click to Add Platform Conditions
**Tried:** Double-clicking the entitlements path value in Build Settings
**Result:** No platform options appeared, no "+" button to add conditions
**Why it failed:** UI limitation in Xcode 16 for this specific build setting

### Attempt 3: Hover for "+" Button
**Tried:** Hovering over "Code Signing Entitlements" row to find "+" button
**Result:** No "+" button appeared on hover
**Why it failed:** This pattern works for some build settings but not for entitlements

### Attempt 4: Shell Script with `sed` (FIRST CORRUPTION)
**Tried:**
```bash
sed -i.bak 's/CODE_SIGN_ENTITLEMENTS = "path";/CODE_SIGN_ENTITLEMENTS[sdk=macosx*] = "path1";\
CODE_SIGN_ENTITLEMENTS[sdk=iphone*] = "path2";/g' project.pbxproj
```
**Result:** **XCODE CRASHED** - Project file became unparseable
**Why it failed:** The multiline replacement with `\` broke the pbxproj format, likely due to incorrect escaping or line ending issues

### Attempt 5: Python Script (SECOND CORRUPTION)
**Tried:**
```python
import re
content = re.sub(old_pattern, new_text_with_dict_format, content)
```
**Result:** **XCODE CRASHED AGAIN** - Project file corrupted
**Why it failed:** Used incorrect pbxproj syntax (dictionary format) instead of the flat key-value format Xcode expects

### Attempt 6: Shell Script with `sed` Using Google's Format (THIRD CORRUPTION)
**Tried:** Google's recommended format:
```
CODE_SIGN_ENTITLEMENTS[sdk=macosx*] = "Markdown Editor/Markdown_Editor.entitlements";
CODE_SIGN_ENTITLEMENTS[sdk=iphone*] = "Markdown Editor/Markdown_Editor_iOS.entitlements";
```
Applied with sed command
**Result:** **XCODE PROJECT DISAPPEARED** - Files still exist but Xcode shows empty project
**Why it failed:** Unknown - possibly whitespace/formatting issue in pbxproj even though syntax looked correct

## What We Learned

### 1. The pbxproj Format is EXTREMELY Fragile
- It's a NeXTSTEP-style plist format with very specific whitespace requirements
- Tabs vs spaces matter
- Line endings matter (must be Unix LF, not CRLF)
- One wrong character breaks the entire project

### 2. Xcode Caches Project File State
- Even correct edits can fail if Xcode is open during modification
- **ALWAYS close Xcode before editing project.pbxproj**
- Sometimes need to clear DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### 3. The UI Has Limitations
- Not all build settings support conditional configuration through the UI
- "Add Conditional Setting" being greyed out is a known Xcode limitation for certain settings
- Entitlements configuration is one of those problematic settings

### 4. Git is Your Only Safety Net
- Every attempt to modify the project file programmatically failed catastrophically
- `git reset --hard HEAD` was the only way to recover
- **ALWAYS commit before attempting project file modifications**

## The Correct Solution (Theoretical)

According to Google and Stack Overflow, the correct format in project.pbxproj should be:

```
CODE_SIGN_ENTITLEMENTS[sdk=macosx*] = "Markdown Editor/Markdown_Editor.entitlements";
CODE_SIGN_ENTITLEMENTS[sdk=iphone*] = "Markdown Editor/Markdown_Editor_iOS.entitlements";
```

However, getting this into the file without corrupting it is the challenge.

## Alternative Solutions We Should Consider

### Option 1: .xcconfig Files
Create separate configuration files:

**MacOS.xcconfig:**
```
CODE_SIGN_ENTITLEMENTS = Markdown Editor/Markdown_Editor.entitlements
```

**iOS.xcconfig:**
```
CODE_SIGN_ENTITLEMENTS = Markdown Editor/Markdown_Editor_iOS.entitlements
```

Then assign these in Project → Info → Configurations

**Pros:**
- Safer than editing pbxproj directly
- Version control friendly
- Xcode-native approach

**Cons:**
- Requires per-configuration setup (Debug/Release must each be assigned)
- Adds complexity to project structure

### Option 2: Separate Targets
Create two targets:
- "Markdown Editor Mac" - Mac only
- "Markdown Editor iOS" - iOS/iPad only

**Pros:**
- Complete separation of concerns
- Each target has its own entitlements
- No conditional logic needed
- This is how most professional multi-platform apps work

**Cons:**
- More complex project structure
- Need to manage shared code carefully
- Two schemes to maintain

### Option 3: Disable Mac App Sandbox
Remove the Mac sandbox entitlement and rely on non-sandboxed permissions.

**Pros:**
- Single entitlements file works for all platforms
- Simple solution

**Cons:**
- Can't distribute on Mac App Store
- Less secure
- Not recommended for production apps

### Option 4: Manual Xcode Project File Editing in Text Editor
Close Xcode, edit project.pbxproj **very carefully** in a proper text editor (VSCode, not sed/python).

**Process:**
1. Close Xcode completely
2. Create git commit point
3. Open project.pbxproj in VSCode
4. Search for `CODE_SIGN_ENTITLEMENTS =`
5. Manually replace both occurrences (Debug and Release)
6. Use exact format from Google
7. Save with Unix line endings (LF)
8. Verify with `git diff` that changes look reasonable
9. Open in Xcode and test

**Critical Requirements:**
- Must maintain exact indentation (tabs, not spaces in this file)
- Must use correct quote characters (straight quotes, not smart quotes)
- Must not introduce any extra whitespace
- Line endings must be LF (Unix), not CRLF (Windows)

## Recommendations for Future

### DO:
✅ Use .xcconfig files for complex build configurations
✅ Consider separate targets for truly different platforms
✅ Always commit before modifying project files
✅ Close Xcode before any external project file modifications
✅ Use `git diff` to verify changes before reopening Xcode
✅ Manual editing in proper text editor > automated scripts for pbxproj

### DON'T:
❌ Use `sed` on project.pbxproj files
❌ Use Python/Ruby/automated scripts to modify pbxproj
❌ Trust Xcode's UI for advanced build configurations
❌ Modify project files while Xcode is open
❌ Assume the format is forgiving (it's not)

## Status After This Session

**Files Created:**
- ✅ `Markdown_Editor_iOS.entitlements` - iOS-specific entitlements (no Mac sandbox)
- ✅ `Markdown_Editor.entitlements` - Mac entitlements (includes sandbox permission)

**What Works:**
- ✅ Mac exports work (Markdown, PDF, HTML) when using Mac entitlements
- ✅ iOS HTML export works
- ⚠️  iOS PDF/Markdown exports have issues (not triggering file picker)

**What's Broken:**
- ❌ Can't configure platform-specific entitlements without corrupting project
- ❌ Mac build fails on iOS (needs Mac entitlement)
- ❌ iOS build fails on Mac (doesn't allow Mac entitlement)

## Next Steps

1. **Try Xcode restart** - Sometimes fixes mysterious project issues
2. **If that fails:** `git reset --hard HEAD` to restore working state
3. **Then choose:** Separate targets OR .xcconfig files approach
4. **Test thoroughly** before considering v0.2.0 complete

## For Future Skills/Documentation

This should be incorporated into:
- **CLAUDE.md** - Project configuration guidelines
- **Journal.md** - As a "war story" about platform-specific configuration
- **Potential Skill** - "Xcode multi-platform configuration" skill for Claude agents

Key lesson: **Xcode project configuration for multi-platform apps is a minefield. Use the safest, most explicit approach (separate targets or .xcconfig files) rather than trying to be clever with build setting conditions.**
