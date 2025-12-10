@tool
extends Control

## ScriptGraph Dock UI - With Side Panel
## Main interface for visualizing GDScript flow

const ScriptGraphModel = preload("res://addons/scriptgraph/core/scriptgraph_model.gd")
const GDScriptParser = preload("res://addons/scriptgraph/parser/gd_ast_wrapper.gd")
const ScriptGraphAnalyzer = preload("res://addons/scriptgraph/analyzer/scriptgraph_analyzer.gd")
const ScriptGraphRenderer = preload("res://addons/scriptgraph/core/scriptgraph_renderer.gd")
const CrossReferenceAnalyzer = preload("res://addons/scriptgraph/analyzer/cross_reference_analyzer.gd")

# Main content
@onready var file_label: Label = $HSplitContainer/MainContent/HeaderPanel/MarginContainer/HeaderBox/FileLabel
@onready var graph_edit: GraphEdit = $HSplitContainer/MainContent/ContentSplit/GraphEdit
@onready var warning_panel: PanelContainer = $HSplitContainer/MainContent/ContentSplit/WarningPanel
@onready var warning_list: RichTextLabel = $HSplitContainer/MainContent/ContentSplit/WarningPanel/MarginContainer/WarningList

# Sidebar
@onready var file_history: Tree = $HSplitContainer/Sidebar/FileHistoryPanel/FileHistory
@onready var function_filter: LineEdit = $HSplitContainer/Sidebar/FunctionPanel/FunctionFilter
@onready var function_list: Tree = $HSplitContainer/Sidebar/FunctionPanel/FunctionList

var current_model: ScriptGraphModel = null
var parser: GDScriptParser = null
var analyzer: ScriptGraphAnalyzer = null
var renderer: ScriptGraphRenderer = null
var cross_ref_analyzer: CrossReferenceAnalyzer = null

var file_history_data: Array[String] = []
const MAX_HISTORY = 10

# Polling for file selection
var last_selected_path: String = ""
var poll_timer: Timer = null

# Cross-reference data
var function_callers: Dictionary = {}


func _ready() -> void:
	print("ScriptGraph: [DEBUG] _ready() called")
	
	# Initialize components
	print("ScriptGraph: [DEBUG] Initializing parser, analyzer, renderer...")
	parser = GDScriptParser.new()
	analyzer = ScriptGraphAnalyzer.new()
	renderer = ScriptGraphRenderer.new()
	cross_ref_analyzer = CrossReferenceAnalyzer.new()
	print("ScriptGraph: [DEBUG] ✓ Cross-reference analyzer initialized")
	
	# Setup GraphEdit
	print("ScriptGraph: [DEBUG] Setting up GraphEdit...")
	_setup_graph_edit()
	
	# Setup sidebar
	print("ScriptGraph: [DEBUG] Setting up sidebar...")
	_setup_sidebar()
	
	# Hide warning panel initially
	if warning_panel:
		warning_panel.visible = false
	
	# Listen to EditorInterface for file selections
	print("ScriptGraph: [DEBUG] Connecting to file system...")
	_connect_to_file_system()
	
	# Setup polling timer for file selection detection
	print("ScriptGraph: [DEBUG] Setting up file selection polling...")
	_setup_file_polling()
	
	print("ScriptGraph: [INFO] ========================================")
	print("ScriptGraph: [INFO] Dock ready - Select a .gd file to begin")
	print("ScriptGraph: [INFO] ========================================")


func _exit_tree() -> void:
	# Cleanup timer when dock is removed
	if poll_timer:
		poll_timer.stop()
		poll_timer.queue_free()
		print("ScriptGraph: [DEBUG] Polling timer stopped and cleaned up")


func _notification(what: int) -> void:
	# Poll immediately when tab becomes visible
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		print("ScriptGraph: [DEBUG] Tab became visible, checking for file selection...")
		# Small delay to ensure editor state is updated
		await get_tree().create_timer(0.1).timeout
		_poll_file_selection()


func _setup_graph_edit() -> void:
	graph_edit.show_zoom_label = true
	graph_edit.minimap_enabled = false
	graph_edit.right_disconnects = false
	graph_edit.connection_request.connect(_on_connection_request_blocked)


func _setup_sidebar() -> void:
	# Setup file history tree
	if file_history:
		file_history.item_selected.connect(_on_history_item_selected)
		file_history.columns = 1
		file_history.hide_root = true
		file_history.create_item()  # Hidden root
	
	# Setup function list tree
	if function_list:
		function_list.item_selected.connect(_on_function_item_selected)
		function_list.columns = 1
		function_list.hide_root = true
		function_list.create_item()  # Hidden root
	
	# Setup function filter
	if function_filter:
		function_filter.text_changed.connect(_on_function_filter_changed)


func _setup_file_polling() -> void:
	# Create timer to poll for file selection changes
	poll_timer = Timer.new()
	poll_timer.wait_time = 0.5  # Check every 500ms
	poll_timer.timeout.connect(_poll_file_selection)
	add_child(poll_timer)
	poll_timer.start()
	print("ScriptGraph: [DEBUG] ✓ File polling timer started (500ms interval)")


func _poll_file_selection() -> void:
	# Poll EditorInterface for selected file path
	var editor_interface = Engine.get_singleton("EditorInterface")
	if not editor_interface:
		return
	
	var selected_path = editor_interface.get_selected_paths()
	if selected_path.is_empty():
		return
	
	# Get first selected path
	var current_path = selected_path[0] if selected_path.size() > 0 else ""
	
	# Check if selection changed
	if current_path != last_selected_path and not current_path.is_empty():
		print("ScriptGraph: [DEBUG] File selection changed: ", current_path)
		last_selected_path = current_path
		
		# Only auto-load .gd files
		if current_path.ends_with(".gd"):
			print("ScriptGraph: [INFO] ✨ Auto-loading selected .gd file...")
			_load_script_from_path(current_path)


func _connect_to_file_system() -> void:
	print("ScriptGraph: [DEBUG] Attempting to connect to file system...")
	
	# Connect to EditorInterface to listen for file selections
	var editor_interface = Engine.get_singleton("EditorInterface")
	if not editor_interface:
		print("ScriptGraph: [ERROR] Could not get EditorInterface")
		return
	
	print("ScriptGraph: [DEBUG] Got EditorInterface: ", editor_interface)
	
	var filesystem = editor_interface.get_file_system_dock()
	if filesystem:
		print("ScriptGraph: [DEBUG] Got FileSystemDock: ", filesystem)
		
		# Connect to file selection signal
		if not filesystem.is_connected("file_removed", _on_filesystem_file_removed):
			filesystem.file_removed.connect(_on_filesystem_file_removed)
			print("ScriptGraph: [DEBUG] Connected to file_removed signal")
		
		# Try to connect to files_moved signal if it exists
		if filesystem.has_signal("files_moved"):
			if not filesystem.is_connected("files_moved", _on_filesystem_files_moved):
				filesystem.files_moved.connect(_on_filesystem_files_moved)
				print("ScriptGraph: [DEBUG] Connected to files_moved signal")
		
		print("ScriptGraph: ✓ Connected to FileSystem dock")
	else:
		print("ScriptGraph: [ERROR] Could not get FileSystemDock")
	
	# Also connect to script editor
	var script_editor = editor_interface.get_script_editor()
	if script_editor:
		print("ScriptGraph: [DEBUG] Got ScriptEditor: ", script_editor)
		script_editor.editor_script_changed.connect(_on_script_changed_in_editor)
		print("ScriptGraph: ✓ Connected to ScriptEditor")
	else:
		print("ScriptGraph: [ERROR] Could not get ScriptEditor")


func _on_script_changed_in_editor(script: Script) -> void:
	print("ScriptGraph: [DEBUG] Script changed in editor signal received")
	if not script:
		print("ScriptGraph: [DEBUG] Script is null, ignoring")
		return
	
	var path = script.resource_path
	print("ScriptGraph: [DEBUG] Script path: ", path)
	
	if path.ends_with(".gd"):
		print("ScriptGraph: [INFO] ✓ Loading .gd file from editor - ", path)
		_load_script_from_path(path)
	else:
		print("ScriptGraph: [DEBUG] Not a .gd file, ignoring")


func _on_filesystem_file_removed(path: String) -> void:
	print("ScriptGraph: [DEBUG] File removed: ", path)
	# Remove from history if file was deleted
	if path in file_history_data:
		file_history_data.erase(path)
		_update_file_history_ui()


func _on_filesystem_files_moved(old_file: String, new_file: String) -> void:
	print("ScriptGraph: [DEBUG] File moved: ", old_file, " -> ", new_file)
	# Update history if file was moved
	if old_file in file_history_data:
		var index = file_history_data.find(old_file)
		file_history_data[index] = new_file
		_update_file_history_ui()


func _on_connection_request_blocked(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	pass  # Block connection creation (read-only)


func _on_history_item_selected() -> void:
	if not file_history:
		return
	
	var selected = file_history.get_selected()
	if not selected:
		return
	
	var path = selected.get_metadata(0)
	if path:
		print("ScriptGraph: Loading from history - ", path)
		_load_script_from_path(path)


func _on_function_item_selected() -> void:
	if not function_list:
		return
	
	var selected = function_list.get_selected()
	if not selected:
		return
	
	var node_id = selected.get_metadata(0)
	if node_id:
		print("ScriptGraph: Function selected - ", node_id)
		_focus_on_node(node_id)


func _on_function_filter_changed(new_text: String) -> void:
	_update_function_list_ui(new_text)


func _focus_on_node(node_id: String) -> void:
	# Find and center the node in GraphEdit
	var node = graph_edit.get_node_or_null(NodePath(node_id))
	if node and node is GraphNode:
		# Center the graph on this node
		var node_center = node.position_offset + node.size / 2
		var viewport_center = graph_edit.size / 2
		graph_edit.scroll_offset = node_center - viewport_center / graph_edit.zoom
		
		# Flash/highlight effect (optional)
		node.modulate = Color(1.5, 1.5, 1.5)
		await get_tree().create_timer(0.3).timeout
		node.modulate = Color(1, 1, 1)


func _load_script_from_path(path: String) -> void:
	print("ScriptGraph: [DEBUG] _load_script_from_path called with: ", path)
	
	if not path.ends_with(".gd"):
		print("ScriptGraph: [WARNING] Not a .gd file: ", path)
		file_label.text = "Not a GDScript file"
		return
	
	print("ScriptGraph: [DEBUG] Opening file: ", path)
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("ScriptGraph: [ERROR] Could not open file: " + path)
		file_label.text = "Error: Could not open file"
		return
	
	print("ScriptGraph: [DEBUG] Reading file content...")
	var content = file.get_as_text()
	file.close()
	
	print("ScriptGraph: [DEBUG] Content length: ", content.length(), " chars")
	
	if content.is_empty():
		print("ScriptGraph: [WARNING] File is empty")
		file_label.text = "File is empty"
		return
	
	# Add to history
	print("ScriptGraph: [DEBUG] Adding to history...")
	_add_to_history(path)
	
	# Visualize
	print("ScriptGraph: [DEBUG] Calling load_script...")
	load_script(path, content)


func _add_to_history(path: String) -> void:
	# Remove if already exists
	if path in file_history_data:
		file_history_data.erase(path)
	
	# Add to front
	file_history_data.insert(0, path)
	
	# Limit history size
	if file_history_data.size() > MAX_HISTORY:
		file_history_data.resize(MAX_HISTORY)
	
	_update_file_history_ui()


func _update_file_history_ui() -> void:
	if not file_history:
		return
	
	file_history.clear()
	var root = file_history.create_item()
	
	for path in file_history_data:
		var item = file_history.create_item(root)
		item.set_text(0, path.get_file())
		item.set_tooltip_text(0, path)
		item.set_metadata(0, path)
		item.set_icon(0, get_theme_icon("Script", "EditorIcons"))


func _update_function_list_ui(filter_text: String = "") -> void:
	if not function_list or not current_model:
		return
	
	function_list.clear()
	var root = function_list.create_item()
	
	var filter_lower = filter_text.to_lower()
	
	# Add functions from model
	for node_id in current_model.root_nodes:
		var node = current_model.get_node(node_id)
		if not node or node.type != ScriptGraphModel.FlowNodeType.FUNC:
			continue
		
		# Extract function name
		var func_name = node.label.replace("func ", "").split("(")[0].strip_edges()
		
		# Apply filter
		if not filter_lower.is_empty() and not func_name.to_lower().contains(filter_lower):
			continue
		
		var item = function_list.create_item(root)
		item.set_text(0, func_name)
		item.set_metadata(0, node_id)
		item.set_icon(0, get_theme_icon("MemberMethod", "EditorIcons"))
		item.set_tooltip_text(0, "Line %d" % node.line_number)


func load_script(path: String, content: String) -> void:
	print("ScriptGraph: [DEBUG] ========== load_script START ==========")
	print("ScriptGraph: [DEBUG] Path: ", path)
	print("ScriptGraph: [DEBUG] Content length: ", content.length())
	
	# Parse the script
	print("ScriptGraph: [DEBUG] Parsing script...")
	current_model = parser.parse(content)
	current_model.script_path = path
	print("ScriptGraph: [DEBUG] ✓ Parse complete. Nodes: ", current_model.nodes.size())
	
	# Analyze for warnings
	print("ScriptGraph: [DEBUG] Analyzing for warnings...")
	var warnings = analyzer.analyze(current_model)
	print("ScriptGraph: [DEBUG] ✓ Analysis complete. Warnings: ", warnings.size())
	
	# Analyze cross-references (find which files call these functions)
	print("ScriptGraph: [DEBUG] Analyzing cross-references...")
	var function_names: Array[String] = []
	for node_id in current_model.root_nodes:
		var node = current_model.get_node(node_id)
		if node and node.type == ScriptGraphModel.FlowNodeType.FUNC:
			var func_name = node.label.replace("func ", "").split("(")[0].strip_edges()
			function_names.append(func_name)
	
	function_callers = cross_ref_analyzer.find_callers(path, function_names)
	print("ScriptGraph: [DEBUG] ✓ Cross-reference analysis complete")
	
	# Render the graph
	print("ScriptGraph: [DEBUG] Rendering graph...")
	renderer.render(current_model, graph_edit, warnings, function_callers)
	print("ScriptGraph: [DEBUG] ✓ Render complete")
	
	# Display warnings
	print("ScriptGraph: [DEBUG] Displaying warnings...")
	_display_warnings(warnings)
	
	# Update function list
	print("ScriptGraph: [DEBUG] Updating function list...")
	_update_function_list_ui()
	
	# Update file label with stats
	var node_count = current_model.nodes.size()
	var func_count = current_model.root_nodes.size()
	file_label.text = "%s  |  📊 %d nodes  |  ⚡ %d functions" % [
		path.get_file(), node_count, func_count
	]
	
	print("ScriptGraph: [INFO] ✓✓✓ Successfully loaded: ", path)
	print("ScriptGraph: [DEBUG] ========== load_script END ==========")


func _display_warnings(warnings: Array) -> void:
	if warnings.is_empty():
		warning_panel.visible = false
		return
	
	warning_panel.visible = true
	
	# Group warnings by type
	var grouped_warnings = {}
	for warning in warnings:
		var msg_key = warning.message
		if not grouped_warnings.has(msg_key):
			grouped_warnings[msg_key] = {
				"count": 0,
				"lines": [],
				"severity": warning.severity
			}
		grouped_warnings[msg_key]["count"] += 1
		grouped_warnings[msg_key]["lines"].append(warning.line_number)
	
	# Build summarized warning text
	var warning_text = "[b]⚠️ Code Issues Found: %d[/b]\n\n" % warnings.size()
	
	for msg in grouped_warnings:
		var data = grouped_warnings[msg]
		var icon = ""
		match data["severity"]:
			1: icon = "ℹ️"
			2: icon = "⚠️"
			3: icon = "❌"
		
		var line_preview = str(data["lines"][0])
		if data["count"] > 1:
			line_preview += " (+" + str(data["count"] - 1) + " more)"
		
		warning_text += "[color=#F44336]%s[/color] [b]×%d[/b] Line %s\n%s\n\n" % [
			icon, data["count"], line_preview, msg
		]
	
	warning_list.text = warning_text
