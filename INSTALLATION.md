# ScriptGraph Installation Guide

## 📋 Prerequisites

Before installing ScriptGraph, ensure you have:

- **Godot 4.0 or later** installed
- A Godot project (new or existing)
- Basic familiarity with the Godot editor

---

## 🚀 Installation Methods

### Method 1: Clone from Repository (Recommended for Development)

1. **Navigate to your project directory:**
   ```bash
   cd /path/to/your/godot/project
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/script-graph.git
   ```

3. **Copy the addon folder:**
   ```bash
   cp -r script-graph/addons/scriptgraph ./addons/
   ```

4. **Open Godot** and enable the plugin (see "Enabling the Plugin" below)

---

### Method 2: Download and Install (Recommended for Users)

1. **Download the latest release** from GitHub:
   - Go to [Releases](https://github.com/yourusername/script-graph/releases)
   - Download `scriptgraph-v0.1.0.zip`

2. **Extract the archive** to get the `scriptgraph` folder

3. **Copy to your project:**
   - Navigate to your Godot project folder
   - Create an `addons/` folder if it doesn't exist
   - Copy the `scriptgraph/` folder into `addons/`

4. **Your structure should look like this:**
   ```
   YourProject/
   ├── addons/
   │   └── scriptgraph/
   │       ├── plugin.cfg
   │       ├── plugin.gd
   │       └── ... (other files)
   ├── project.godot
   └── ... (your other files)
   ```

---

### Method 3: Manual Installation (From This Repository)

If you have this repository cloned:

1. **Copy the addon folder:**
   ```bash
   cp -r addons/scriptgraph /path/to/your/project/addons/
   ```

2. **Open Godot** and enable the plugin

---

## ✅ Enabling the Plugin

After copying the addon files:

1. **Open your project** in Godot 4
2. Go to **Project → Project Settings**
3. Click the **Plugins** tab
4. Find **ScriptGraph** in the list
5. Check the **Enable** checkbox
6. Click **Close**

You should see the ScriptGraph dock appear in your editor!

---

## 🔍 Verification

To verify the installation:

1. **Look for the ScriptGraph dock** - It should appear in the right panel area
2. **Create or open a `.gd` file** in the FileSystem dock
3. **Switch to the ScriptGraph tab**
4. You should see a visual graph of your script

### Test with Sample Scripts

This repository includes test scripts in `tests/test_scripts/`:

1. Copy a test script to your project:
   ```bash
   cp tests/test_scripts/simple_function.gd /path/to/your/project/
   ```

2. Open it in Godot's FileSystem
3. View it in ScriptGraph
4. You should see a flow graph with function nodes

---

## 🐛 Troubleshooting

### Plugin doesn't appear in the list

**Problem:** ScriptGraph doesn't show up in Project Settings → Plugins

**Solution:**
- Verify the folder structure: `addons/scriptgraph/plugin.cfg` must exist
- Check that `plugin.cfg` has valid content
- Restart Godot
- Check the Godot console for error messages

### Plugin is enabled but dock doesn't appear

**Problem:** Plugin is checked but no dock visible

**Solution:**
- Look for the dock in different panel areas (try View → Docks)
- Check the Godot console for errors
- Disable and re-enable the plugin
- Restart Godot

### "Preload file does not exist" errors

**Problem:** Console shows preload errors

**Solution:**
- Ensure all files were copied correctly
- Check file permissions
- Reimport the project (Project → Reload Current Project)

### Graph is empty when viewing a script

**Problem:** ScriptGraph dock shows but graph is blank

**Solution:**
- Ensure the `.gd` file has valid GDScript syntax
- Check that the file contains functions
- Look at the Godot console for parsing errors
- Try with a simple test script first

### Warnings not showing

**Problem:** Code has issues but no warnings appear

**Solution:**
- Check that the script actually has detectable issues
- Look at test scripts for examples of issue patterns
- Warning panel may be collapsed - expand it manually

---

## 🔄 Updating ScriptGraph

To update to a new version:

1. **Disable the plugin** in Project Settings → Plugins
2. **Delete** the old `addons/scriptgraph/` folder
3. **Copy** the new version to `addons/scriptgraph/`
4. **Re-enable** the plugin
5. **Restart** Godot (recommended)

---

## 🗑️ Uninstallation

To remove ScriptGraph:

1. **Disable the plugin** in Project Settings → Plugins
2. **Close** Godot
3. **Delete** the `addons/scriptgraph/` folder
4. **Reopen** Godot

Your project files and other addons will not be affected.

---

## 📚 Next Steps

After installation:

1. **Read the [User Guide](./docs/USER_GUIDE.md)** to learn how to use ScriptGraph
2. **Try the test scripts** in `tests/test_scripts/` to see examples
3. **Visualize your own scripts** to debug and understand your code
4. **Check the [Architecture docs](./docs/ARCHITECTURE.md)** if you want to understand how it works

---

## 💬 Need Help?

- Check the [documentation](./docs/README.md)
- Look at [common issues](./docs/USER_GUIDE.md#troubleshooting)
- Open an issue on GitHub *(coming soon)*
- Ask in discussions *(coming soon)*

---

**Happy visualizing! </•>**
