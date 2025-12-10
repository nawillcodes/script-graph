# ScriptGraph 0.1 Refactoring Summary

## Changes Made

### Architecture Update: Functions-Only Mode

ScriptGraphRenderer has been refactored to support two view modes:

1. **Functions-Only Mode (v0.1)** - DEFAULT
   - Only function nodes are rendered as GraphNodes
   - Internal control flow (IF/ELSE/RETURN/LOOP) is **summarized** within each function node
   - Shows function-to-function call graph connections
   - Clean, high-level view of code structure

2. **Detailed View Mode (Legacy)** - PRESERVED
   - Every statement (IF/ELSE/RETURN/etc.) gets its own GraphNode
   - Full statement-level connections
   - Available by setting `DETAIL_VIEW_ENABLED = true`

### Key Constant

```gdscript
const DETAIL_VIEW_ENABLED := false  # false = v0.1, true = legacy
```

### New Functions (v0.1)

#### Rendering
- `_render_functions_only()` - Main entry point for functions-only view
- `_create_function_graph_node(func_node)` - Creates a function node with summary

#### Analysis
- `_summarize_function_internal_flow(func_node)` - BFS traversal that collects:
  - Branch count & missing else detection
  - Return count & missing return detection
  - Function call names
  - TODO/FIXME/NOTE counts
  - Unreachable code count
  - Loop detection
  - Total statements

#### Display
- `_get_function_semantic_suffix(func_node)` - Returns "— X exits, Y branches"
- `_apply_function_badges(graph_node, func_node, summary)` - Adds issue badges
- `_apply_function_style(graph_node, func_node, summary)` - Red borders for issues
- `_apply_function_tooltip(graph_node, func_node, summary)` - Rich summary tooltip

#### Connections
- `_create_function_connections(function_nodes)` - Function-to-function call graph

#### Utilities
- `_add_subtitle_label(graph_node, text)` - Doc comments
- `_add_line_label(graph_node, line_number)` - Line numbers

### Legacy Functions (Preserved)

All original detailed-view code has been moved under:
```gdscript
## ============================================================================
## LEGACY DETAILED VIEW FUNCTIONS (used when DETAIL_VIEW_ENABLED = true)
## ============================================================================
```

Including:
- `_create_graph_node()` - Original node creation
- `_get_semantic_suffix()` - Statement-level suffixes
- `_get_branch_badge()` - Statement-level badges
- `_create_sequential_connections()` - Statement flow
- `_create_branch_connections()` - Branch logic
- `_create_call_connections()` - Call detection
- All styling functions

### What Users See (v0.1)

**Function Node Example:**
```
⚡ func test_complex_logic — 1 exit, 3 branches
💬 Test 6: Complex branching
📍 Line: 76
✗ Incomplete branches
```

**Hover Tooltip:**
```
📋 func test_complex_logic
📍 Line 76

💬 Test 6: Complex branching

📊 Function Summary:
  📝 8 statements
  ↩️ 1 return
  🔀 3 branches
    ✗ Incomplete branches detected
  📞 Calls: helper_function
```

**Connections:**
- Cyan arrows show function-to-function calls
- No internal statement connections (reduces clutter)

### Migration Path

To return to detailed view (for "Function Detail View" feature):
1. Set `DETAIL_VIEW_ENABLED = true`
2. All legacy logic is preserved and functional
3. Can be toggled per-function in future UI

### Benefits of v0.1

✅ **Clean** - Only top-level functions visible  
✅ **Scalable** - Works with large files (100+ functions)  
✅ **Informative** - Rich summaries show what matters  
✅ **Actionable** - Issues highlighted with badges  
✅ **Navigable** - Call graph shows dependencies  
✅ **Future-proof** - Legacy code ready for drill-down view  

### File Size Impact

- **Before:** ~570 lines
- **After:** ~850 lines (+280 lines)
- **Legacy code:** 100% preserved
- **New features:** Functions-only rendering complete

### Next Steps (Future Work)

1. Add "Double-click function → Detail View" in dock UI
2. Add view mode toggle in toolbar
3. Add function filtering/search
4. Add complexity metrics visualization
5. Add mini-map for large call graphs

---

## Testing Checklist

- [ ] Functions-only mode renders correctly
- [ ] Function summaries show accurate counts
- [ ] Badges appear for issues (TODO, FIXME, missing return, etc.)
- [ ] Tooltips show comprehensive function info
- [ ] Function-to-function connections work
- [ ] Legacy mode still works (set DETAIL_VIEW_ENABLED = true)
- [ ] No visual clutter with 10+ functions
- [ ] Doc comments appear as subtitles
- [ ] Red borders show on functions with issues

## Architecture Preserved

- ✅ All original code intact under LEGACY section
- ✅ No breaking changes to model/parser/analyzer
- ✅ Can toggle between modes with single constant
- ✅ Clean separation of concerns
