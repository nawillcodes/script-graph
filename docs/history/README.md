# Development History

This folder contains historical documentation of major development milestones and refactoring efforts in the ScriptGraph project.

## Documents

### **REFACTORING_SUMMARY.md**
Details the major refactoring effort to split the large `scriptgraph_renderer.gd` file (1045+ lines) into modular components:
- **FunctionAnalyzer** - Function analysis and complexity metrics
- **NodeStyler** - Visual styling, badges, and tooltips  
- **ConnectionBuilder** - Function call connections

This refactoring improved maintainability and enabled easier feature additions.

---

### **REFACTOR_SUMMARY.md**
Documents the transition from detailed node-per-statement view to a simplified **functions-only mode**:
- Only function nodes are rendered
- Internal flow is summarized with metrics
- Function calls create connections between nodes
- Cleaner, more performant visualization

This became the default view in version 0.1.

---

### **UI_REDESIGN.md**
Chronicles the complete UI overhaul from FileDialog-based to native file system integration:
- Side panel with recent files history
- Function list with search/filter
- Automatic file loading via polling
- Script editor integration
- Removal of manual refresh button

This modernized the plugin to match Godot's Script editor workflow.

---

## Current Documentation

For current documentation, see:
- **`/README.md`** - Project overview and features
- **`/CHANGELOG.md`** - Version history and changes
- **`/docs/`** - Comprehensive documentation
  - `ARCHITECTURE.md` - System architecture
  - `DEVELOPMENT.md` - Development guidelines
  - `USER_GUIDE.md` - User instructions
  - `QUICK_REFERENCE.md` - Quick start guide

---

These historical documents are preserved for reference but may contain outdated information. Always refer to the current documentation for accurate, up-to-date details.
