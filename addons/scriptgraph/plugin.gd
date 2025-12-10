@tool
extends EditorPlugin

## ScriptGraph EditorPlugin - Main Screen Plugin
## Appears as a tab alongside 2D/3D/Script/AssetLib

var dock: Control
var current_script_path: String = ""

func _enter_tree() -> void:
	# Load and instantiate the dock
	dock = preload("res://addons/scriptgraph/ui/scriptgraph_dock.tscn").instantiate()
	dock.name = "ScriptGraph"  # Set explicit name for the main screen tab
	
	# Add to main screen (appears as tab next to 2D/3D/Script/AssetLib)
	get_editor_interface().get_editor_main_screen().add_child(dock)
	
	# Hide by default until user clicks the tab
	_make_visible(false)
	
	var editor_interface = get_editor_interface()
	
	# Connect to script editor signals - this is the most reliable method
	var script_editor = editor_interface.get_script_editor()
	if script_editor:
		script_editor.editor_script_changed.connect(_on_script_changed)
		print("ScriptGraph: ✓ Connected to ScriptEditor signals")
	else:
		print("ScriptGraph: ✗ Could not connect to ScriptEditor")
	
	# Also try to get current script on load
	_check_current_script()
	
	print("ScriptGraph: Plugin initialized as main screen")
	print("ScriptGraph: Click 'ScriptGraph' tab to open, then load a .gd file")


func _exit_tree() -> void:
	# Clean up the main screen control
	if dock:
		get_editor_interface().get_editor_main_screen().remove_child(dock)
		dock.queue_free()
	
	print("ScriptGraph: Plugin removed")


## Main screen plugin interface
func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "ScriptGraph"


func _get_plugin_icon() -> Texture2D:
	# Custom ScriptGraph icon
	return preload("res://addons/scriptgraph/icon.svg")


func _make_visible(visible: bool) -> void:
	if dock:
		dock.visible = visible


func _check_current_script() -> void:
	# Check if there's already a script open
	var editor_interface = get_editor_interface()
	var script_editor = editor_interface.get_script_editor()
	
	if not script_editor:
		return
	
	var current_script = script_editor.get_current_script()
	if current_script:
		print("ScriptGraph: Found open script on load")
		_on_script_changed(current_script)


func _on_script_changed(script: Script) -> void:
	if not script:
		return
	
	var path = script.resource_path
	print("ScriptGraph: Script changed - ", path)
	
	_load_script_from_path(path)


func _load_script_from_path(path: String) -> void:
	# Only process .gd files
	if not path.ends_with(".gd"):
		print("ScriptGraph: Not a .gd file (", path.get_extension(), "), ignoring")
		return
	
	current_script_path = path
	
	# Read the script content from file
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("ScriptGraph: Could not open file: " + path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	if content.is_empty():
		print("ScriptGraph: File is empty: ", path)
		return
	
	print("ScriptGraph: ✓ Parsing script - ", path.get_file(), " (", content.length(), " chars)")
	
	# Send to dock for processing
	if dock and dock.has_method("load_script"):
		dock.load_script(path, content)
		print("ScriptGraph: ✓ Graph should now be visible!")
	else:
		push_error("ScriptGraph: ERROR - Dock not ready or missing load_script method")
