# ScriptGraph Roadmap

This document outlines the planned features and improvements for ScriptGraph.

## 🎯 Vision

Make ScriptGraph the go-to visual debugging and code exploration tool for GDScript developers.

---

## Phase 1: MVP ✅ (v0.1.0)

**Status:** Complete

- [x] Basic flow visualization for functions
- [x] Simple GDScript parser
- [x] Warning detection (unreachable code, empty blocks, magic numbers, etc.)
- [x] Read-only GraphEdit interface
- [x] Cross-reference analysis (show which files call each function)
- [x] Automatic file loading from FileSystem dock
- [x] Side panel with file history and function list
- [x] Clean tooltip formatting
- [x] Code quality detection (type hints, constants, etc.)

---

## Phase 2: Enhanced Analysis 🚧

**Target:** v0.2.0

### Core Features
- [ ] **Variable scope tracking** - Visualize variable lifecycles and scope boundaries
- [ ] **Function call graph** - Show complete call chains across entire project
- [ ] **Click to jump to code** - Navigate from graph nodes directly to source code
- [ ] **Export graphs** - Save visualizations as PNG/SVG for documentation

### Code Quality
- [ ] **Complexity metrics** - Cyclomatic complexity, nesting depth
- [ ] **Performance hints** - Flag potential performance issues
- [ ] **Best practices** - Suggest GDScript idioms and patterns

### UI Improvements
- [ ] **Search/filter functions** - Quick navigation in large files
- [ ] **Minimap enhancement** - Better overview of large graphs
- [ ] **Node grouping** - Collapse/expand related functions

---

## Phase 3: Performance 🔮

**Target:** v0.3.0

### Optimization
- [ ] **Large file optimization** - Handle scripts with 100+ functions smoothly
- [ ] **Incremental parsing** - Parse only changed portions of code
- [ ] **Caching** - Store parsed results for faster reloading
- [ ] **Async parsing** - Non-blocking UI during analysis

### Memory Management
- [ ] **Lazy loading** - Load graph nodes on-demand
- [ ] **Memory profiling** - Optimize memory usage for large projects

---

## Phase 4: Advanced Features 🌟

**Target:** v0.4.0+

### Real-time Analysis
- [ ] **Live updates** - Automatically refresh graph as code changes
- [ ] **Debug integration** - Show execution path during debugging
- [ ] **Breakpoint visualization** - Display breakpoints on graph nodes

### Multi-file Analysis
- [ ] **Project-wide call graph** - Visualize entire codebase structure
- [ ] **Dependency analysis** - Show script dependencies
- [ ] **Class hierarchy** - Display inheritance relationships

### Customization
- [ ] **Custom themes** - User-defined color schemes
- [ ] **Layout templates** - Save and restore graph layouts
- [ ] **Plugin API** - Allow third-party extensions
- [ ] **Custom analyzers** - User-defined code quality rules

### Export & Documentation
- [ ] **Documentation generation** - Auto-generate docs from graph
- [ ] **Interactive HTML export** - Share graphs as web pages
- [ ] **Annotation system** - Add notes to graph nodes

---

## Community Requests

Features requested by the community will be tracked here:

- [ ] GDScript 2.0 full support (Godot 4.x features)
- [ ] Integration with external documentation tools
- [ ] Mobile-friendly graph export
- [ ] Collaboration features (shared annotations)

---

## Contributing

Want to help implement these features? Check out our [Contributing Guide](CONTRIBUTING.md)!

Issues labeled [`help wanted`](https://github.com/nawillcodes/scriptgraph/labels/help%20wanted) are great places to start.

---

## Feedback

Have ideas for the roadmap? [Open a discussion](https://github.com/nawillcodes/scriptgraph/discussions) or [create an issue](https://github.com/nawillcodes/scriptgraph/issues)!
