# Changelog

All notable changes to ScriptGraph will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Cross-Reference Analysis** - Detects which files call functions in the current script
  - Shows `📞 called in file.gd` badges on function nodes
  - Full caller list in tooltips
  - Scans entire project on file load
  
- **Automatic File Loading** - Files load automatically when selected
  - 500ms polling for file selection changes
  - Instant detection when ScriptGraph tab becomes visible
  - Script editor integration for script switching
  
- **Custom Tab Icon** - ScriptGraph has its own icon in the main screen tabs
  - 16x16 optimized SVG icon
  - Dark theme friendly colors
  
- **Side Panel UI** - Redesigned interface resembling Godot's Script editor
  - Recent files history (max 10)
  - Function list with filter
  - Click to navigate to functions
  
- **Enhanced Tooltips** - Clean, formatted tooltips without BBCode
  - Function signature with separator
  - Cross-reference callers
  - Complexity metrics
  - Function calls
  - Issues detection

### Changed
- Removed manual refresh button (automatic loading makes it redundant)
- Moved from FileDialog to native file system integration
- Improved tooltip formatting for better readability
- Enhanced .gitignore for comprehensive exclusions

### Fixed
- Fixed warning object property access in `FunctionAnalyzer`
- Corrected unreachable code detection after refactoring

### Removed
- Old backup files (`scriptgraph_dock_old.gd`, `scriptgraph_dock_old.tscn`)
- System files (`.DS_Store`)
- Manual refresh button

## [0.1.0] - Previous Release

### Added
- **Component Refactoring** - Split large renderer into focused classes
  - `FunctionAnalyzer` - Analyzes function complexity and issues
  - `NodeStyler` - Handles visual styling, badges, and tooltips
  - `ConnectionBuilder` - Builds function call connections
  
- **Code Quality Warnings**
  - Untyped parameters detection
  - Missing return type hints
  - Unused parameters
  - Magic numbers detection
  - Overly long functions (>50 lines)
  - Missing `@onready` for node access
  - Incomplete branches (missing else)
  - Unreachable code detection
  
- **Functions-Only Mode** - Simplified view showing only function nodes
  - Function signatures with parameter names and types
  - Function call connections
  - Complexity metrics
  - Issue badges
  
- **Hierarchical Layout** - Automatic graph layout algorithm
  - Manual mode for custom positioning
  - Hierarchical mode for organized layout

### Changed
- Refactored from single large file to modular architecture
- Improved performance with delegated responsibilities
- Enhanced maintainability and extensibility

## [0.0.1] - Initial Release

### Added
- Basic GDScript parsing and visualization
- Flow graph generation
- Control flow analysis
- Function detection
- Main screen plugin integration

---

## Version History Location

Previous development summaries have been moved to `docs/history/`:
- `REFACTORING_SUMMARY.md` - Component refactoring details
- `REFACTOR_SUMMARY.md` - Functions-only mode implementation
- `UI_REDESIGN.md` - Side panel UI redesign

For detailed architecture information, see `docs/ARCHITECTURE.md`.
For development guidelines, see `docs/DEVELOPMENT.md`.
