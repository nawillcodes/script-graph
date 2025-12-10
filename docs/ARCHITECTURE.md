# ScriptGraph Architecture

## 📁 Folder Structure

```
addons/scriptgraph/
├── plugin.cfg                          # Addon metadata
├── plugin.gd                           # EditorPlugin entry point (main screen)
├── icon.svg                            # Custom tab icon
├── ui/
│   ├── scriptgraph_dock.tscn          # Main dock UI (with side panel)
│   └── scriptgraph_dock.gd            # Dock logic + file polling
├── core/
│   ├── scriptgraph_model.gd           # Flow model (data structure)
│   ├── scriptgraph_renderer.gd        # GraphEdit rendering coordinator
│   ├── function_analyzer.gd           # Function analysis & metrics
│   ├── node_styler.gd                 # Visual styling & tooltips
│   └── connection_builder.gd          # Function call connections
├── parser/
│   └── gd_ast_wrapper.gd              # GDScript AST parser wrapper
└── analyzer/
    ├── scriptgraph_analyzer.gd        # Code issue detection
    └── cross_reference_analyzer.gd    # Cross-file function calls
```

---

## 🧩 Component Breakdown

### 1. `plugin.gd` (EditorPlugin)

**Responsibility:** Register the addon with Godot editor

- Extends `EditorPlugin`
- Adds dock to editor
- Listens for script file selection
- Routes `.gd` file content to parser

**Key Methods:**
- `_enter_tree()` - Initialize dock
- `_exit_tree()` - Cleanup dock
- `_on_file_selected(path)` - Handle file selection

---

### 2. `ui/scriptgraph_dock` (Control)

**Responsibility:** Main UI panel with side panel navigation

**Components:**
- **HSplitContainer** - Main layout
  - **Sidebar:**
    - Recent files history (Tree)
    - Function list with filter (Tree + LineEdit)
  - **Main Content:**
    - Header with ScriptGraph branding
    - File info label
    - Layout selector (Manual/Hierarchical)
    - GraphEdit canvas
    - Warning panel (collapsible)

**Automatic File Loading:**
- Polls `EditorInterface.get_selected_paths()` every 500ms
- Instant check when tab becomes visible
- Script editor integration via `editor_script_changed` signal

**Navigation:**
- Click function in sidebar → focus on node in graph
- Recent files → quick file switching

---

### 3. `core/scriptgraph_model.gd` (Resource)

**Responsibility:** Data model for code flow

**Node Types:**
```gdscript
enum FlowNodeType {
    FUNC,       # Function definition
    IF,         # If statement
    ELIF,       # Elif branch
    ELSE,       # Else branch
    LOOP,       # For/While loop
    RETURN,     # Return statement
    CALL,       # Function call hint
    EMPTY       # Empty block (for warnings)
}
```

**Structure:**
```gdscript
class FlowNode:
    var id: String
    var type: FlowNodeType
    var label: String
    var line_number: int
    var children: Array[String]  # IDs of child nodes
    var metadata: Dictionary
```

---

### 4. `core/scriptgraph_renderer.gd` (Object)

**Responsibility:** Coordinate rendering pipeline

**Delegates to:**
- `FunctionAnalyzer` - Analysis & metrics
- `NodeStyler` - Visual styling & tooltips
- `ConnectionBuilder` - Function call connections

**View Modes:**
- **Functions-Only** (default) - Clean, simplified view
- **Detailed** (legacy) - Node per statement

**Process:**
1. Receive `FlowModel` + `warnings` + `function_callers`
2. Initialize components (analyzer, styler, connection_builder)
3. Create `GraphNode` for each function
4. Analyze function complexity
5. Apply styling & badges
6. Build connections
7. Apply layout (manual or hierarchical)

**Color Scheme:**
- Function: Godot Blue `#478CBF`
- Conditional: Orange `#FF8C00`
- Loop: Green `#4CAF50`
- Return: Purple `#9C27B0`
- Warning: Red `#F44336`

---

### 5. `parser/gd_ast_wrapper.gd` (Object)

**Responsibility:** Parse GDScript → FlowModel

**External Dependency:**
Uses gdscript-toolkit for AST parsing (Python-based)

**Fallback (MVP):**
Since gdscript-toolkit is Python-based and Godot doesn't have direct Python integration, we use a **simplified regex-based parser** for MVP:

- Detect function definitions (`func name():`)
- Detect if/elif/else (`if condition:`)
- Detect loops (`for`, `while`)
- Detect returns (`return`)
- Track indentation for nesting

**Future:** Shell out to Python gdscript-toolkit or implement native GDScript parser

**Parse Flow:**
```
GDScript text
  ↓
Tokenize & detect blocks
  ↓
Build FlowModel hierarchy
  ↓
Return FlowModel
```

---

### 6. `core/function_analyzer.gd` (Object)

**Responsibility:** Analyze function complexity & code quality

**Metrics:**
- Total statements
- Branch count
- Return count
- Function length (lines)
- Has loops
- Function calls

**Detections:**
1. **Untyped parameters** - Missing type hints
2. **Unused parameters** - Never referenced
3. **Missing return type** - No return type hint
4. **Magic numbers** - Hardcoded numeric literals
5. **Long functions** - >50 lines
6. **Incomplete branches** - Missing else
7. **Unreachable code** - Code after return
8. **TODO/FIXME** comments

**Output:** Dictionary with all metrics and detected issues

---

### 7. `core/node_styler.gd` (Object)

**Responsibility:** Visual styling, badges, and tooltips

**Functions:**
- `style_function_node()` - Complete styling
- `apply_badges()` - Warning/info badges
- `apply_style()` - Colors & borders
- `apply_tooltip()` - Rich tooltips

**Badge Examples:**
- `📞 called in file.gd` - Cross-references
- `⚠️ infering variant typing for parameter: x`
- `✗ Incomplete branches`
- `❌ 2 unreachable`

**Tooltip Format:**
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

📞 CALLS:
   • other_func()

⚠️ ISSUES:
   ⚠ Missing return type hint
```

---

### 8. `core/connection_builder.gd` (Object)

**Responsibility:** Build function-to-function connections

**Process:**
1. For each function, scan source code
2. Find function calls using regex
3. Match calls to known functions
4. Create GraphEdit connections

**Features:**
- Smart call detection (regex-based)
- Filters keywords (if, for, while, etc.)
- Debug logging for troubleshooting

---

### 9. `analyzer/scriptgraph_analyzer.gd` (Object)

**Responsibility:** Detect code flow issues

**Checks:**
1. **Unreachable code** - Code after `return`
2. **Empty blocks** - `if` with no body
3. **Deep nesting** - >3 levels of indentation
4. **Missing return paths** - Function missing returns

**Output:**
```gdscript
class AnalysisWarning:
    var node_id: String
    var type: WarningType
    var message: String
    var severity: int  # 1=info, 2=warning, 3=error
```

---

### 10. `analyzer/cross_reference_analyzer.gd` (Object)

**Responsibility:** Find cross-file function calls

**Process:**
1. Receive script path + function names
2. Scan all `.gd` files in project
3. Search for function calls using regex
4. Return mapping: `function_name → [caller_files]`

**Features:**
- Recursive directory scanning
- Excludes `.godot`, `addons`, hidden folders
- Max depth limit (5 levels)
- Fast regex-based detection

**Example Output:**
```gdscript
{
    "reset": ["res://game_manager.gd"],
    "take_damage": ["res://enemy.gd", "res://trap.gd"]
}
```

---

## 🔄 Data Flow

```
User selects .gd file in FileSystem
  ↓
File polling detects change (500ms)
  ↓
Read file content
  ↓
gd_ast_wrapper.parse(content)
  ↓
FlowModel created
  ↓
scriptgraph_analyzer.analyze(model)
  ↓
Warnings generated
  ↓
cross_reference_analyzer.find_callers(path, functions)
  ↓
Function callers mapped
  ↓
scriptgraph_renderer.render(model, warnings, callers)
  ↓
function_analyzer.analyze_function()
  ↓
node_styler.style_function_node()
  ↓
connection_builder.build_connections()
  ↓
GraphEdit displayed in dock
  ↓
Sidebar updated (history + function list)
```

---

## 🎨 UI Layout

```
┌──────────────┬──────────────────────────────────────┐
│ Recent Files │ </•> ScriptGraph                     │
│              │ player.gd | 📊 15 nodes | ⚡ 8 funcs│
│ ◉ player.gd  ├──────────────────────────────────────┤
│   enemy.gd   │                                      │
│   ui.gd      │   [GraphEdit Canvas]                │
│              │                                      │
│ Functions    │   ┌──────────────────┐              │
│ [Filter...]  │   │ _ready()         │              │
│              │   │ 📞 called in:    │              │
│ ⚡ _ready    │   │ game_manager.gd  │              │
│ ⚡ _process  │   └────────┬─────────┘              │
│ ⚡ die       │            │                         │
│ ⚡ reset     │   ┌────────▼─────────┐              │
│              │   │ take_damage(amt) │              │
│              │   │ 📞 called in:    │              │
│              │   │ enemy.gd         │              │
│              │   └──────────────────┘              │
│              │                                      │
│              ├──────────────────────────────────────┤
│              │ ⚠️ Warnings (2):                    │
│              │ • Missing return type hint: _ready  │
│              │ • Untyped parameter: amt            │
└──────────────┴──────────────────────────────────────┘
```

---

## 🛠️ Technical Decisions

### Why GraphEdit?
- Native Godot UI component
- Built-in zoom, pan, connections
- Customizable GraphNode styling
- Familiar to Godot developers

### Why Read-Only?
- Prevents "visual scripting" scope creep
- Code remains source of truth
- Reduces complexity
- Focuses on debugging/learning use case

### Why AST over Regex?
- AST is more robust (handles edge cases)
- Properly understands scope/nesting
- Future-proof for complex analysis
- MVP uses regex as bootstrap, AST as goal

---

## 🧪 Testing Strategy

### Manual Testing
1. Create test scripts with various control flows
2. Verify graph accuracy
3. Check warning detection
4. Test edge cases (empty files, syntax errors)

### Test Scripts (in `tests/` folder)
- `simple_func.gd` - Basic function
- `nested_if.gd` - Deep conditionals
- `unreachable.gd` - Code after return
- `empty_blocks.gd` - Empty if/else

---

## 🚀 Future Architecture

### Phase 2: Enhanced Analysis
- Variable scope tracking
- Type inference
- Call graph (function → function)

### Phase 3: Performance
- Lazy loading for large files
- Incremental parsing
- Caching parsed models

### Phase 4: Export
- PNG/SVG export
- Markdown report generation
- HTML interactive export

---

## 📚 References

- [Godot EditorPlugin Docs](https://docs.godotengine.org/en/stable/classes/class_editorplugin.html)
- [GraphEdit API](https://docs.godotengine.org/en/stable/classes/class_graphedit.html)
- [GDScript Grammar](https://github.com/godotengine/godot/blob/master/modules/gdscript/gdscript_parser.cpp)
