# ScriptGraph UI Redesign - Side Panel

## 🎯 Changes Made

Redesigned the ScriptGraph UI to match Godot's Script editor style with a side panel.

### **Before (Old UI):**
- FileDialog popup for opening files
- "Open GDScript..." button
- Manual file selection

### **After (New UI):**
- **Left Sidebar** with Script editor style:
  - 📂 **Recent Files** - History of opened scripts (max 10)
  - 🔍 **Function Filter** - Search/filter functions
  - ⚡ **Function List** - All functions in current script
- **Native FileSystem Integration** - Automatically loads when you select a .gd file
- **Click to Jump** - Click function in sidebar to center it in graph

---

## 📋 New Features

### **1. Side Panel**
```
┌──────────────┬────────────────────┐
│ Recent Files │                    │
│ • file1.gd   │   Graph View       │
│ • file2.gd   │                    │
├──────────────┤                    │
│ Filter...    │                    │
│ Functions:   │                    │
│ • _process   │                    │
│ • die        │                    │
│ • reset      │                    │
└──────────────┴────────────────────┘
```

### **2. File History**
- Tracks last 10 opened scripts
- Click any file to reload
- Shows file name with Script icon
- Tooltip shows full path

### **3. Function List**
- Shows all functions in current script
- **Filter box** to search functions
- Click to jump/center node in graph
- Shows line numbers in tooltip

### **4. Native FileSystem Integration**
- No more FileDialog popup!
- Automatically loads when you:
  - Select a `.gd` file in FileSystem dock
  - Switch scripts in Script editor
  - Click Refresh button

---

## 🔧 Technical Changes

### **File Structure:**
```
addons/scriptgraph/ui/
├── scriptgraph_dock.tscn       # NEW layout with HSplitContainer
├── scriptgraph_dock.gd         # NEW with sidebar logic
├── scriptgraph_dock_old.tscn   # BACKUP of old version
└── scriptgraph_dock_old.gd     # BACKUP of old version
```

### **New UI Hierarchy:**
```
ScriptGraphDock
└── HSplitContainer
    ├── Sidebar (VBoxContainer)
    │   ├── FileHistoryPanel
    │   │   ├── Label "Recent Files"
    │   │   └── Tree (file_history)
    │   └── FunctionPanel
    │       ├── Label "Functions"
    │       ├── LineEdit (function_filter)
    │       └── Tree (function_list)
    └── MainContent (VBoxContainer)
        ├── HeaderPanel
        ├── ContentSplit (VSplitContainer)
        │   ├── GraphEdit
        │   └── WarningPanel
        └── LegendPanel
```

### **Key New Functions:**

#### **_setup_sidebar()**
Sets up file history and function list trees.

#### **_connect_to_file_system()**
Connects to:
- `FileSystemDock.file_removed` - Remove deleted files from history
- `ScriptEditor.editor_script_changed` - Auto-load on script switch

#### **_add_to_history(path)**
Manages file history (max 10 files, most recent first).

#### **_update_function_list_ui(filter)**
Populates function list with filtering support.

#### **_focus_on_node(node_id)**
Centers GraphEdit on selected function with highlight flash.

---

## 🚀 How to Use

### **1. Select a Script**
- In **FileSystem dock**, click any `.gd` file
- OR switch to any script in **Script editor**
- ScriptGraph automatically loads it!

### **2. Navigate Functions**
- Type in **"Filter Methods"** box to search
- Click any function to jump to it in the graph
- Function list shows all functions with line numbers

### **3. Recent Files**
- Recently opened scripts appear in **"Recent Files"**
- Click to quickly switch between scripts
- History persists during session

### **4. Refresh**
- Click **🔄 Refresh Current** to reload active script
- Useful after making changes

---

## 📊 Benefits

✅ **Native Integration** - Works like built-in Godot tools  
✅ **No Popups** - No more FileDialog interruptions  
✅ **Quick Navigation** - Jump to functions instantly  
✅ **History** - Easy access to recent files  
✅ **Filter** - Find functions fast  
✅ **Clean UX** - Matches Godot's design language  

---

## 🔄 Migration

Old files are backed up:
- `scriptgraph_dock_old.tscn`
- `scriptgraph_dock_old.gd`

To revert (if needed):
```bash
cd addons/scriptgraph/ui/
mv scriptgraph_dock.tscn scriptgraph_dock_new.tscn
mv scriptgraph_dock.gd scriptgraph_dock_new.gd
mv scriptgraph_dock_old.tscn scriptgraph_dock.tscn
mv scriptgraph_dock_old.gd scriptgraph_dock.gd
```

---

## ✨ Next Steps

**Reload the plugin** and:
1. Select a `.gd` file in FileSystem
2. See it load automatically
3. Try the function filter
4. Click functions to jump

Enjoy the new workflow! 🎉
