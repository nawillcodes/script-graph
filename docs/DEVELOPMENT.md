# ScriptGraph Development Guide

## 🛠️ For Developers

This guide is for contributors or those who want to understand ScriptGraph's internals.

---

## 🏗️ Setup

### Prerequisites
- Godot 4.0+
- Basic GDScript knowledge
- Understanding of AST concepts (helpful)

### Development Environment
1. Clone the repository
2. Open in Godot 4
3. Enable the plugin in Project Settings
4. Create test scripts in `tests/` folder

---

## 📁 Project Structure

```
script-graph/
├── addons/
│   └── scriptgraph/           # The addon itself
│       ├── plugin.cfg
│       ├── plugin.gd
│       ├── ui/
│       ├── core/
│       ├── parser/
│       └── analyzer/
├── docs/                      # Documentation
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── USER_GUIDE.md
│   └── DEVELOPMENT.md
├── tests/                     # Test GDScript files
│   └── test_scripts/
└── project.godot
```

---

## 🧩 Core Components

### 1. Parser (`parser/gd_ast_wrapper.gd`)

**Current Implementation:** Regex-based pattern matching

**Key Functions:**
```gdscript
func parse(source_code: String) -> FlowModel
func _detect_functions(lines: Array) -> Array
func _detect_control_flow(lines: Array) -> Array
func _build_hierarchy(blocks: Array) -> FlowModel
```

**Improvement Roadmap:**
- Phase 1: Regex (MVP) ✅
- Phase 2: Shell to Python gdscript-toolkit
- Phase 3: Native GDScript AST parser

### 2. Renderer (`core/scriptgraph_renderer.gd`)

**Responsibility:** FlowModel → GraphEdit

**Key Functions:**
```gdscript
func render(model: FlowModel, graph_edit: GraphEdit) -> void
func _create_node(flow_node: FlowNode) -> GraphNode
func _apply_styling(node: GraphNode, type: FlowNodeType) -> void
func _connect_nodes(model: FlowModel, graph_edit: GraphEdit) -> void
```

**Styling Details:**
- Colors defined in constants
- Icons (future) for node types
- Layout algorithm: top-to-bottom hierarchical

### 3. Analyzer (`analyzer/scriptgraph_analyzer.gd`)

**Checks Implemented:**
- `check_unreachable_code()`
- `check_empty_blocks()`
- `check_deep_nesting()`
- `check_return_paths()`

**Adding New Checks:**
1. Add method: `check_your_rule(model: FlowModel) -> Array[Warning]`
2. Call from `analyze()` method
3. Add warning type to enum

---

## 🧪 Testing

### Manual Test Scripts

Create test cases in `tests/test_scripts/`:

**simple.gd**
```gdscript
func _ready():
    print("Hello")
```

**nested_conditions.gd**
```gdscript
func check(a, b, c):
    if a:
        if b:
            if c:
                return true
    return false
```

**unreachable.gd**
```gdscript
func example():
    return 5
    print("Never runs")
```

### Testing Workflow
1. Create test script
2. Load in ScriptGraph
3. Verify graph structure
4. Check for expected warnings
5. Document results

---

## 🎨 UI Customization

### Colors (Brand Guidelines)

```gdscript
const COLOR_PRIMARY = Color("#478CBF")  # Godot Blue
const COLOR_BACKGROUND = Color("#363D47")  # Dark Gray
const COLOR_FUNC = Color("#478CBF")  # Blue
const COLOR_CONDITIONAL = Color("#FF8C00")  # Orange
const COLOR_LOOP = Color("#4CAF50")  # Green
const COLOR_RETURN = Color("#9C27B0")  # Purple
const COLOR_WARNING = Color("#F44336")  # Red
```

### Icon System (Future)

ScriptGraph will use SVG icons:
- `icon_function.svg`
- `icon_conditional.svg`
- `icon_loop.svg`
- `icon_return.svg`
- `icon_warning.svg`

---

## 🚀 Feature Roadmap

### MVP (v0.1.0) ✅
- Basic flow visualization
- Simple parser
- Warning detection
- Read-only GraphEdit

### v0.2.0 (Planned)
- Click node → jump to line in editor
- Export graph as PNG
- Improved layout algorithm
- Minimap for large scripts

### v0.3.0 (Planned)
- Variable tracking
- Function call graph
- Multi-file analysis
- Performance metrics

### v1.0.0 (Future)
- Full AST integration
- Real-time updates
- Customizable themes
- Plugin API for extensions

---

## 🐛 Known Issues

### Current Limitations

1. **Parser:** Regex-based, may miss edge cases
2. **Layout:** Simple top-down, can overlap
3. **Performance:** Large files (>1000 lines) may be slow
4. **Expressions:** Only shows control flow, not expressions

### To Be Fixed

- [ ] Better error handling for malformed scripts
- [ ] Support for lambdas
- [ ] Support for inner classes
- [ ] Performance optimization for large files

---

## 📝 Coding Standards

### GDScript Style

Follow [Godot's GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html):

```gdscript
# Class name (if needed)
class_name ScriptGraphExample

# Constants
const MAX_DEPTH = 3

# Signals
signal graph_updated

# Exported variables
@export var show_warnings: bool = true

# Public variables
var flow_model: FlowModel

# Private variables
var _internal_state: Dictionary

# Functions
func public_method() -> void:
    pass

func _private_method() -> void:
    pass
```

### Documentation

Use doc comments:
```gdscript
## Parses GDScript source code into a flow model.
## 
## @param source_code: The GDScript source as a string
## @return: A FlowModel representing the script structure
func parse(source_code: String) -> FlowModel:
    pass
```

---

## 🤝 Contributing

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch
3. **Implement** your feature
4. **Test** thoroughly
5. **Submit** a pull request

### Contribution Guidelines

- Maintain read-only philosophy
- Follow coding standards
- Add tests for new features
- Update documentation
- Keep it simple (KISS principle)

---

## 📚 Resources

### Godot Documentation
- [EditorPlugin](https://docs.godotengine.org/en/stable/classes/class_editorplugin.html)
- [GraphEdit](https://docs.godotengine.org/en/stable/classes/class_graphedit.html)
- [GraphNode](https://docs.godotengine.org/en/stable/classes/class_graphnode.html)

### Parsing Resources
- [gdscript-toolkit](https://github.com/Scony/gdscript-toolkit)
- [GDScript Grammar](https://github.com/godotengine/godot/blob/master/modules/gdscript/gdscript_parser.cpp)
- [Abstract Syntax Trees](https://en.wikipedia.org/wiki/Abstract_syntax_tree)

### Graph Visualization
- [Graphviz](https://graphviz.org/)
- [Dagre (JS layout library)](https://github.com/dagrejs/dagre)

---

## 💬 Communication

- **Issues:** GitHub Issues (coming soon)
- **Discussions:** GitHub Discussions (coming soon)
- **Discord:** (coming soon)

---

**Happy Coding! </•>**
