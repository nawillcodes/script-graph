# Release & Repository Setup Instructions

## 🏷️ Create v0.1.0 Release Tag

Run these commands in your repository:

```bash
# Make sure you're on main branch and everything is committed
git checkout main
git pull

# Create annotated tag for v0.1.0
git tag -a v0.1.0 -m "MVP Release - Function visualization, cross-reference analysis, and code quality detection"

# Push the tag to GitHub
git push origin v0.1.0
```

Then on GitHub:
1. Go to **Releases** → **Create a new release**
2. Choose tag: `v0.1.0`
3. Title: `ScriptGraph v0.1.0 - MVP Release`
4. Description:
```markdown
## 🎉 First Public Release!

ScriptGraph is a visual flow analysis tool for GDScript that helps you understand, debug, and improve your code.

### ✨ Features
- Function-level flow visualization
- Cross-reference analysis (see which files call your functions)
- Code quality detection (unreachable code, type hints, etc.)
- Automatic file loading
- Side panel with history and function list

### 📦 Installation
1. Download `scriptgraph.zip`
2. Extract to your Godot project's `addons/` folder
3. Enable in Project Settings → Plugins

### 🐛 Known Issues
- Large files (100+ functions) may be slow
- Limited to function-level analysis

See [CHANGELOG.md](CHANGELOG.md) for full details.
```
5. Attach `scriptgraph.zip` (just zip the `addons/scriptgraph/` folder)
6. **Publish release**

---

## 🏷️ Create GitHub Issue Labels

Go to **Issues** → **Labels** → **New label** and create these:

### Priority Labels
- **bug** 
  - Color: `#d73a4a` (red)
  - Description: "Something isn't working"

- **enhancement**
  - Color: `#a2eeef` (blue)
  - Description: "New feature or request"

### Help Wanted Labels
- **good first issue**
  - Color: `#7057ff` (purple)
  - Description: "Good for newcomers"

- **help wanted**
  - Color: `#008672` (green)
  - Description: "Extra attention is needed"

### Additional Labels
- **documentation**
  - Color: `#0075ca` (blue)
  - Description: "Improvements or additions to documentation"

- **question**
  - Color: `#d876e3` (pink)
  - Description: "Further information is requested"

- **wontfix**
  - Color: `#ffffff` (white)
  - Description: "This will not be worked on"

- **duplicate**
  - Color: `#cfd3d7` (gray)
  - Description: "This issue or pull request already exists"

---

## 📊 Enable GitHub Features

### GitHub Discussions
1. Go to **Settings** → **Features**
2. Enable **Discussions**
3. Create categories:
   - General
   - Ideas & Feature Requests
   - Q&A
   - Show and Tell

### GitHub Sponsors
1. Make sure `.github/FUNDING.yml` is pushed
2. Go to your profile → **Sponsor**
3. Set up payment method
4. GitHub will review (usually 24-48 hours)

### GitHub Actions (Optional)
Consider adding CI/CD for:
- Automated testing
- Release packaging
- Documentation deployment

---

## 🔗 Update Repository Description

On GitHub main page, click ⚙️ next to "About" and set:
- **Description:** `Visual flow analysis for GDScript - Debug and understand your Godot 4 code`
- **Website:** (your docs site if you make one)
- **Topics:** `godot`, `godot-engine`, `gdscript`, `visualization`, `debugging`, `code-analysis`, `godot-plugin`, `flow-graph`
- ✅ **Include in the home page**

---

## 📝 Post-Release Checklist

After v0.1.0 is live:
- [ ] Update badges in README (they'll work after release)
- [ ] Share on Godot Forums
- [ ] Share on Reddit r/godot
- [ ] Tweet/post on social media
- [ ] Submit to Godot Asset Library
- [ ] Add to awesome-godot lists

---

## 🎯 Asset Library Submission

1. Go to https://godotengine.org/asset-library/asset
2. Click **Submit Asset**
3. Fill in:
   - **Title:** ScriptGraph
   - **Category:** Scripts
   - **Godot Version:** 4.0+
   - **Repository:** Your GitHub repo URL
   - **Version String:** v0.1.0
   - **Download URL:** Release zip URL
   - **Icon:** `docs/assets/icon.svg`
   - **Screenshots:** Add 3-4 screenshots of the graph

---

**Questions?** Check the [GitHub Docs](https://docs.github.com) or ask in Discussions!
