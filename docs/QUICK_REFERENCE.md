# ScriptGraph Quick Reference

## 🚀 Quick Start

```bash
# 1. Copy addon to your project
cp -r addons/scriptgraph /path/to/your/project/addons/

# 2. Open Godot and enable plugin
Project → Project Settings → Plugins → Enable ScriptGraph

# 3. Click ScriptGraph tab, select a .gd file - auto-loads!
```

---

## 🎯 Core Features

| Feature | Description |
|---------|-------------|
| ⚡ Auto-Loading | Files load automatically when selected (500ms polling) |
| 📂 Side Panel | Recent files + function list with filter |
| 📞 Cross-References | Shows which files call each function |
| ⚠️ Code Quality | 8+ types of warnings (type hints, unused code, etc.) |
| 💡 Rich Tooltips | Complexity metrics, callers, calls, issues |
| 🔗 Function Calls | Visual connections between functions |
| 📊 Metrics | Statements, branches, returns, length |

---

## 🎨 UI Elements

### Side Panel (Left)

**Recent Files**
- Last 10 visited files
- Click to switch

**Function List**
- All functions in current file
- Type to filter
- Click to focus in graph

### Main Panel (Right)

**Header**
- File stats (nodes, functions)
- Layout selector (Manual/Hierarchical)

**Graph**
- Function nodes with badges
- Hover for detailed tooltips
- Zoom/pan controls

**Warnings Panel** (Collapsible)
- Grouped by type
- Shows all detected issues

---

## 🔍 Function Node Badges

```
┌────────────────────────────┐
│ ⚡ take_damage(amt: float) │
├────────────────────────────┤
│ 📞 called in enemy.gd      │  ← Cross-reference
│ ⚠️ Missing return type hint│  ← Type hint warning
│ ✗ Incomplete branches      │  ← Structure warning
│ ❌ 2 unreachable           │  ← Unreachable code
└────────────────────────────┘
```

---

## ⚠️ Detected Issues

### Type Hints
- `⚠️ infering variant typing for parameter: x` - Missing parameter type
- `⚠️ Missing return type hint` - Missing return type

### Unused Code
- `⚠️ Unused parameter: delta` - Never referenced
- `❌ X unreachable` - Code after return

### Structure
- `✗ Incomplete branches` - Missing else
- `⚠️ Function too long (>50 lines)` - Overly long function

### Code Quality
- `⚠️ Magic number: 3.14` - Hardcoded number
- `⚠️ X TODO` - TODO comments
- `🔴 X FIXME` - FIXME comments

---

## 📞 Cross-Reference Badges

**Single Caller:**
```
📞 called in game_manager.gd
```

**Two Callers:**
```
📞 called in enemy.gd & trap.gd
```

**Many Callers:**
```
📞 called in enemy.gd, trap.gd & 3 more
```

---

## 💡 Tooltip Format

```
═══════════════════════════════
⚡ func name(param: Type)
═══════════════════════════════

📞 CALLED FROM:
   • file1.gd
   • file2.gd

📊 COMPLEXITY:
   • Total statements: 15
   • Branches: 3
   • Returns: 2
   • Function length: 25 lines
   • Contains loops

📞 CALLS:
   • other_function()
   • helper_method()

⚠️ ISSUES:
   ⚠ Missing return type hint
   ⚠ Untyped parameter: param

✅ No issues detected (if clean)
```

---

## 🎮 Controls

| Action | Control |
|--------|---------|
| Zoom In/Out | Mouse Wheel |
| Pan Graph | Middle Click + Drag |
| Select Node | Left Click |
| Focus Function | Click in sidebar |
| Filter Functions | Type in filter box |
| Switch Layout | Layout dropdown |

---

## 📁 Updated File Structure

```
addons/scriptgraph/
├── plugin.cfg                      # Plugin metadata
├── plugin.gd                       # Main screen plugin
├── icon.svg                        # Custom tab icon
├── ui/
│   ├── scriptgraph_dock.tscn      # UI with side panel
│   └── scriptgraph_dock.gd        # Dock + auto-loading
├── core/
│   ├── scriptgraph_model.gd       # Data model
│   ├── scriptgraph_renderer.gd    # Rendering coordinator
│   ├── function_analyzer.gd       # Function analysis
│   ├── node_styler.gd             # Visual styling
│   └── connection_builder.gd      # Function connections
├── parser/
│   └── gd_ast_wrapper.gd          # GDScript parser
└── analyzer/
    ├── scriptgraph_analyzer.gd    # Flow analysis
    └── cross_reference_analyzer.gd # Cross-file calls
```

---

## 🔧 Component API

### FunctionAnalyzer
```gdscript
func analyze_function(func_node, model, warnings) -> Dictionary
# Returns: {
#   total_statements, branch_count, return_count,
#   function_length, has_loops, call_names,
#   untyped_params, unused_params, magic_numbers,
#   missing_return_type, missing_else, unreachable_count
# }
```

### NodeStyler
```gdscript
func style_function_node(graph_node, func_node, summary, callers)
# Applies: badges, colors, borders, tooltips
```

### ConnectionBuilder
```gdscript
func build_connections(function_nodes, model)
# Creates GraphEdit connections for function calls
```

### CrossReferenceAnalyzer
```gdscript
func find_callers(script_path, function_names) -> Dictionary
# Returns: { "func_name": ["caller1.gd", "caller2.gd"] }
```

---

## 🧪 Test Scripts

Located in `tests/test_scripts/`:

**Basic Examples:**
- `simple_function.gd` - Basic function
- `unreachable_code.gd` - Unreachable code tests

**Cross-Reference Tests:**
- `game_manager.gd` - Calls player + UI
- `player_movement.gd` - Called by game manager & enemy
- `ui_manager.gd` - Called by game manager
- `enemy.gd` - Calls player
- `CROSS_REFERENCE_TEST.md` - Test guide

---

## ⌨️ Keyboard Shortcuts (Future)

| Shortcut | Action |
|----------|--------|
| `Ctrl+F` | Focus function filter |
| `Ctrl+R` | Reload current file |
| `F` | Frame selected function |
| `H` | Toggle hierarchical layout |

*(Not yet implemented)*

---

## 🐛 Troubleshooting

### File Not Auto-Loading
```bash
# Check console for debug messages
# Expected output:
[DEBUG] File selection changed: res://player.gd
[DEBUG] Analyzing cross-references...
[INFO] ✓✓✓ Successfully loaded: res://player.gd
```

### Cross-References Missing
```bash
# Check console:
[DEBUG] Finding callers for functions in: res://player.gd
[DEBUG] Scanning 15 .gd files for function calls...
[DEBUG] Function 'reset' called from 1 file(s)
```

### Plugin Not Showing
- Verify `addons/scriptgraph/plugin.cfg` exists
- Check **Project Settings → Plugins → ScriptGraph** is enabled
- Look for ScriptGraph icon next to 2D/3D/Script tabs
- Restart Godot if needed

### Graph Empty
- Ensure script has `func` definitions
- Check for syntax errors
- Try with test scripts first

---

## 📊 Performance Notes

| Operation | Time | Notes |
|-----------|------|-------|
| File Loading | <100ms | Parse + analyze |
| Cross-Reference Scan | 1-3s | Full project scan |
| Layout Algorithm | <500ms | Hierarchical layout |
| Function Filter | Instant | Client-side search |

**Optimization Tips:**
- Cross-reference scan happens once per file load
- Large projects (100+ files) may take longer to scan
- Use function filter for large scripts

---

## 🔗 Code Quality Standards

ScriptGraph promotes these best practices:

✅ **Type all parameters:** `func move(speed: float)`  
✅ **Type all returns:** `func get_health() -> int`  
✅ **Avoid magic numbers:** Use `const` instead  
✅ **Keep functions short:** <50 lines  
✅ **Complete branches:** Always include `else`  
✅ **Remove dead code:** No unreachable statements  
✅ **Use all parameters:** Remove unused ones  

---

## 📚 Documentation

- [User Guide](./USER_GUIDE.md) - Complete user manual
- [Architecture](./ARCHITECTURE.md) - Technical deep dive
- [Development](./DEVELOPMENT.md) - Contributing guide
- [README](./README.md) - Project overview
- [Changelog](../CHANGELOG.md) - Version history

---

## 🔗 External Resources

- [Godot EditorPlugin Docs](https://docs.godotengine.org/en/stable/classes/class_editorplugin.html)
- [GraphEdit API](https://docs.godotengine.org/en/stable/classes/class_graphedit.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

---

**ScriptGraph - Visualize, Analyze, Improve 🚀**
