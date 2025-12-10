# ScriptGraph Documentation

**Visual Code Analysis & Quality Assurance for Godot 4**

---

## 📖 Documentation Index

### For Users
- **[User Guide](./USER_GUIDE.md)** - Complete user manual with examples
- **[Quick Reference](./QUICK_REFERENCE.md)** - Cheat sheet for quick lookup

### For Developers
- **[Architecture](./ARCHITECTURE.md)** - Technical design and components
- **[Development Guide](./DEVELOPMENT.md)** - Contributing guidelines
- **[Implementation Summary](./IMPLEMENTATION_SUMMARY.md)** - Implementation details

### Historical Documentation
- **[History Folder](./history/)** - Past refactoring summaries and design decisions

---

## 🎯 Overview

ScriptGraph is a **main screen plugin** for Godot 4 that automatically visualizes GDScript functions and their relationships. It provides:

- **📊 Function Graphs** - Visual representation of your code structure
- **📞 Cross-References** - See which files call each function
- **⚠️ Code Quality Analysis** - Detect 8+ types of common issues
- **🔍 Complexity Metrics** - Understand function complexity at a glance
- **⚡ Automatic Loading** - Files load instantly when selected

---

## ✨ Key Features

### Automatic File Loading
- **500ms Polling** - Detects file selection changes automatically
- **Instant Response** - Loads immediately when ScriptGraph tab becomes visible
- **Script Editor Integration** - Works with script switching
- **No Manual Refresh** - Everything happens automatically

### Side Panel Navigation
- **Recent Files History** - Last 10 files you viewed
- **Function List** - All functions with search/filter
- **Click to Navigate** - Jump to functions in the graph
- **Quick Switching** - Fast file and function access

### Cross-File Analysis
- **Function Call Detection** - Scans entire project
- **Caller Display** - Shows which files call each function
- **Badge System** - `📞 called in file.gd` on function nodes
- **Tooltip Details** - Full caller list on hover

### Code Quality Detection
- **Type Hint Analysis** - Missing parameter/return types
- **Unused Code Detection** - Unused parameters, unreachable code
- **Structure Warnings** - Incomplete branches, long functions
- **Magic Numbers** - Hardcoded numeric literals
- **Comment Tracking** - TODO/FIXME detection

### Rich Visualization
- **Function-Only View** - Clean, simplified graphs
- **Complexity Badges** - Visual indicators of issues
- **Rich Tooltips** - Detailed metrics and callers
- **Hierarchical Layout** - Automatic organization
- **Custom Tab Icon** - Distinctive ScriptGraph icon

---

## 🚀 Quick Start

```bash
# 1. Install
cp -r addons/scriptgraph /path/to/project/addons/

# 2. Enable in Godot
Project → Project Settings → Plugins → ScriptGraph ✓

# 3. Use
Click ScriptGraph tab → Select .gd file → Auto-loads!
```

---

## 🎨 What You'll See

### Function Nodes with Badges
```
┌─────────────────────────────┐
│ ⚡ take_damage(amt: float)  │
├─────────────────────────────┤
│ 📞 called in enemy.gd       │  ← Which files call this
│ ⚠️ Missing return type hint  │  ← Code quality issues
└─────────────────────────────┘
```

### Rich Tooltips
```
═══════════════════════════════
⚡ func take_damage(amt: float)
═══════════════════════════════

📞 CALLED FROM:
   • enemy.gd
   • trap.gd

📊 COMPLEXITY:
   • Total statements: 8
   • Branches: 2
   • Returns: 1

⚠️ ISSUES:
   ⚠ Missing return type hint
   ⚠ Untyped parameter: amt
```

---

## ⚠️ Detected Issues

| Issue | Example |
|-------|---------|
| **Untyped Parameters** | `func move(speed)` → `func move(speed: float)` |
| **Missing Return Type** | `func get_hp()` → `func get_hp() -> int` |
| **Unused Parameters** | `func _process(delta):` ← delta never used |
| **Unreachable Code** | Code after `return` statement |
| **Incomplete Branches** | `if` without `else` |
| **Magic Numbers** | `speed * 3.14` → use `const PI = 3.14` |
| **Long Functions** | Functions >50 lines |
| **TODO/FIXME** | Comment tracking |

---

## 🏗️ Architecture Highlights

### Modular Design
- **FunctionAnalyzer** - Analyzes function metrics
- **NodeStyler** - Handles visual styling
- **ConnectionBuilder** - Creates function connections
- **CrossReferenceAnalyzer** - Finds cross-file calls

### Clean Separation
- Parser → Model → Analyzer → Renderer → UI
- Each component has single responsibility
- Easy to extend and maintain

See [ARCHITECTURE.md](./ARCHITECTURE.md) for details.

---

## 📊 Current Status

### ✅ Implemented (Latest)
- ✅ Automatic file loading (polling + signals)
- ✅ Side panel with history & function list
- ✅ Cross-file reference detection
- ✅ 8+ code quality checks
- ✅ Rich tooltips with all details
- ✅ Custom tab icon
- ✅ Function-to-function connections
- ✅ Complexity metrics
- ✅ Hierarchical layout
- ✅ Component-based architecture

### 🚧 Future Enhancements
- [ ] Variable tracking across functions
- [ ] Type inference for variant parameters
- [ ] Performance hotspot detection
- [ ] Export graph as PNG/SVG
- [ ] Keyboard shortcuts
- [ ] Click function → jump to line in editor
- [ ] Real-time updates on code changes
- [ ] Project-wide statistics

---

## 🤝 Contributing

ScriptGraph welcomes contributions! See [DEVELOPMENT.md](./DEVELOPMENT.md) for:
- Code style guidelines
- Architecture overview
- Testing procedures
- Pull request process

**Philosophy:** Maintain read-only visualization focus. No code generation or editing.

---

## 📄 License

MIT License - See [LICENSE](../LICENSE) file

---

## 🔗 Resources

### Godot Documentation
- [EditorPlugin](https://docs.godotengine.org/en/stable/classes/class_editorplugin.html)
- [GraphEdit](https://docs.godotengine.org/en/stable/classes/class_graphedit.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

### External Tools
- [gdscript-toolkit](https://github.com/Scony/gdscript-toolkit) - AST parsing reference

---

## 📝 Changelog

See [CHANGELOG.md](../CHANGELOG.md) for version history and recent changes.

---

**ScriptGraph - Visualize, Analyze, Improve Your GDScript 🚀**
