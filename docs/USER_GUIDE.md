# ScriptGraph User Guide

## 🎯 What is ScriptGraph?

ScriptGraph is a **visual code analysis tool** for GDScript. It automatically visualizes your code as a function graph, making it easier to understand complex logic, find code quality issues, see cross-file dependencies, and learn from existing scripts.

---

## 🚀 Getting Started

### 1. Installation

1. Copy `addons/scriptgraph/` to your project's `addons/` folder
2. Enable the plugin: **Project → Project Settings → Plugins → ScriptGraph**
3. Look for the **ScriptGraph** tab next to 2D/3D/Script/AssetLib

### 2. Opening a Script

**Automatic Loading:**
1. Click the **ScriptGraph** tab
2. Select any `.gd` file in the **FileSystem** dock
3. Graph loads automatically - no manual refresh needed!

**Alternative Methods:**
- Double-click a `.gd` file to open it in Script editor
- Switch between open scripts in the Script editor
- ScriptGraph detects changes and reloads automatically

---

## 🎨 Interface Overview

### Side Panel (Left)

**Recent Files**
- Last 10 files you viewed
- Click to quickly switch between scripts
- Automatically updated as you browse

**Function List**
- All functions in the current script
- Search/filter functions with the filter box
- Click a function to focus on it in the graph

### Main Canvas

**Header**
- File name and statistics (nodes, functions)
- Layout selector (Manual / Hierarchical)

**Graph View**
- Function nodes with connections
- Hover over functions for detailed tooltips
- Zoom with mouse wheel, pan with middle-click

**Warning Panel** (Bottom, collapsible)
- Shows all detected code quality issues
- Grouped by type
- Click to learn more

---

## 📊 Reading the Graph

### Functions-Only View (Default)

ScriptGraph shows **function nodes** with:
- Function signature (name and parameters with types)
- Complexity badges (branches, returns, calls)
- Warning badges (code quality issues)
- Cross-reference badges (which files call this function)

**Example Function Node:**
```
┌─────────────────────────────┐
│ ⚡ take_damage(amount: float)│
├─────────────────────────────┤
│ 📞 called in enemy.gd       │
│ ⚠️ Missing return type hint  │
└─────────────────────────────┘
```

### Connections

- **White lines** connect functions that call each other
- **Arrows** show the call direction
- **Hover** over a function to see what it calls and who calls it

### Colors

- **Blue nodes** = Functions
- **Red borders** = Functions with issues detected
- **White connections** = Function calls

---

## 🔍 Enhanced Tooltips

Hover over any function node to see:

```
═══════════════════════════════
⚡ func take_damage(amount: float)
═══════════════════════════════

📞 CALLED FROM:
   • enemy.gd
   • trap.gd

📊 COMPLEXITY:
   • Total statements: 8
   • Branches: 2
   • Returns: 1
   • Function length: 12 lines

📞 CALLS:
   • update_health_bar()
   • check_death()

⚠️ ISSUES:
   ⚠ Missing return type hint
   ⚠ Untyped parameter: amount
```

---

## ⚠️ Code Quality Detection

ScriptGraph automatically detects common issues:

### Type Hints

**Missing Parameter Types:**
```gdscript
func attack(target):  # ⚠️ infering variant typing for parameter: target
    target.take_damage(10)
```

**Missing Return Types:**
```gdscript
func get_health():  # ⚠️ Missing return type hint
    return health
```

### Unused Code

**Unused Parameters:**
```gdscript
func _process(delta):  # ⚠️ Unused parameter: delta
    update_position()
```

**Unreachable Code:**
```gdscript
func example():
    return 5
    print("Never runs!")  # ❌ Unreachable
```

### Code Structure

**Incomplete Branches:**
```gdscript
func check(value):
    if value > 0:
        do_something()
    # ✗ Incomplete branches (missing else)
```

**Long Functions:**
```gdscript
func very_long_function():
    # ... 60 lines of code ...
    # ⚠️ Function too long (>50 lines)
```

**Magic Numbers:**
```gdscript
func calculate():
    return value * 3.14159  # ⚠️ Magic number: 3.14159
```

### Code Comments

**TODO/FIXME Detection:**
```gdscript
func placeholder():
    # TODO: Implement this  # ⚠️ 1 TODO
    pass
```

---

## 🔗 Cross-File References

**See which files call your functions:**

When you load a script, ScriptGraph scans your entire project to find:
- Which files call each function
- Displayed as `📞 called in file.gd` badges
- Full list in tooltips

**Example:**
```gdscript
# In player.gd
func take_damage(amount):
    ...
```

ScriptGraph will show:
```
📞 called in enemy.gd & trap.gd
```

---

## 🎮 Navigation & Workflow

### Quick Navigation

1. **Filter Functions**: Type in the filter box to find functions
2. **Click to Focus**: Click a function in the sidebar → graph centers on it
3. **Recent Files**: Switch between recently viewed scripts instantly

### Layout Options

**Manual Layout** (default)
- Arrange nodes yourself
- Drag to position
- Good for custom organization

**Hierarchical Layout**
- Automatic arrangement
- Functions organized top-to-bottom
- Good for large scripts

---

## 🧪 Example Workflows

### Debugging Complex Logic

1. **Load the problematic script**
2. **View the function graph** - see overall structure
3. **Check cross-references** - understand who calls what
4. **Look for warnings** - find potential issues
5. **Hover for details** - get complexity metrics
6. **Fix in Script editor** - make changes
7. **Watch auto-reload** - see updates immediately

### Understanding Unfamiliar Code

1. **Select a script** you haven't seen before
2. **Browse the function list** - see what functions exist
3. **Click interesting functions** - focus on them in the graph
4. **Read tooltips** - understand complexity and callers
5. **Trace connections** - see how functions interact
6. **Check for issues** - spot potential problems

### Code Review

1. **Load the code** to review
2. **Check warnings panel** - any quality issues?
3. **Verify type hints** - all parameters typed?
4. **Look for magic numbers** - should they be constants?
5. **Check function length** - any functions too long?
6. **Review cross-references** - is coupling appropriate?

---

## 🛠️ Features & Limitations

### ✅ What ScriptGraph Does

- ✅ Automatic file loading when selected
- ✅ Function-level code visualization
- ✅ Code quality analysis (type hints, unused code, etc.)
- ✅ Cross-file function call detection
- ✅ Complexity metrics for each function
- ✅ Recent files history
- ✅ Function search/filter
- ✅ Rich tooltips with all details
- ✅ Auto-reload on file selection

### ❌ Current Limitations

- ❌ Read-only (cannot edit code from graph)
- ❌ Does not show runtime values (use debugger)
- ❌ Does not show variable declarations
- ❌ Does not show inline expressions
- ❌ Cross-reference scan happens on load (may be slow for large projects)

---

## 🤔 FAQ

**Q: Why isn't my file loading automatically?**  
A: Make sure you're on the ScriptGraph tab when selecting files. Check the console for debug messages.

**Q: Can I edit my code in ScriptGraph?**  
A: No. ScriptGraph is read-only. Edit in the Script tab - changes are detected automatically.

**Q: Does it work with large scripts?**  
A: Yes! The functions-only view scales well. Cross-reference scanning may take a moment on first load.

**Q: Why don't I see connections between my functions?**  
A: ScriptGraph uses regex to detect function calls. Complex dynamic calls might not be detected.

**Q: Can I export the graph?**  
A: Not yet. Planned for a future release (PNG/SVG export).

**Q: Does it work with GDScript 2.0?**  
A: Yes, ScriptGraph is designed for Godot 4 and GDScript 2.0.

**Q: What about C# or VisualScript?**  
A: ScriptGraph only supports GDScript currently.

**Q: How accurate is cross-reference detection?**  
A: Very accurate for direct function calls. Dynamic/indirect calls may be missed.

---

## 🐛 Troubleshooting

**Graph is empty**
- Ensure the `.gd` file has function definitions
- Check for syntax errors in your script
- Look at the console for error messages

**File not loading automatically**
- Check console for `[DEBUG]` messages
- Try clicking the ScriptGraph tab again
- Verify the plugin is enabled in Project Settings

**Plugin not showing**
- Verify `addons/scriptgraph/` exists in your project
- Enable in **Project Settings → Plugins → ScriptGraph**
- Restart Godot if needed

**Cross-references not showing**
- Check console for scanning progress
- Ensure other files that call functions exist
- Large projects may take time to scan

**Graph looks cluttered**
- Try the Hierarchical layout
- Use the function filter to focus on specific functions
- Close the warnings panel for more space

---

## 💡 Tips & Tricks

1. **Use function filter** to quickly find functions by name
2. **Check tooltips** for the most detailed information
3. **Recent files** make it easy to compare related scripts
4. **Red borders** instantly show which functions need attention
5. **Cross-references** help you understand code dependencies
6. **Hierarchical layout** is great for screenshots/documentation

---

## 📚 Learn More

- [Architecture Documentation](./ARCHITECTURE.md) - Technical details
- [Development Guide](./DEVELOPMENT.md) - Contributing
- [Quick Reference](./QUICK_REFERENCE.md) - Cheat sheet
- [Changelog](../CHANGELOG.md) - Version history

---

**Happy Coding! </•>**
