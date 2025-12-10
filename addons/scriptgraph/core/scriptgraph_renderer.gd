extends RefCounted
class_name ScriptGraphRenderer

## ScriptGraph Renderer
## Converts flow model into GraphEdit visualization
## Refactored for better separation of concerns

const ScriptGraphModel = preload("res://addons/scriptgraph/core/scriptgraph_model.gd")
const FunctionAnalyzer = preload("res://addons/scriptgraph/core/function_analyzer.gd")
const NodeStyler = preload("res://addons/scriptgraph/core/node_styler.gd")
const ConnectionBuilder = preload("res://addons/scriptgraph/core/connection_builder.gd")

# View mode toggle: false = functions-only (0.1), true = detailed node view (legacy)
const DETAIL_VIEW_ENABLED := false

const COLOR_PRIMARY = Color("#478CBF")  # Godot Blue
const COLOR_BACKGROUND = Color("#363D47")  # Dark Gray
const COLOR_FUNC = Color("#478CBF")  # Blue
const COLOR_CONDITIONAL = Color("#FF8C00")  # Orange
const COLOR_LOOP = Color("#4CAF50")  # Green
const COLOR_RETURN = Color("#9C27B0")  # Purple
const COLOR_WARNING = Color("#F44336")  # Red

var graph_edit: GraphEdit
var warnings: Array
var model: ScriptGraphModel
var function_callers: Dictionary = {}

# Extracted components
var analyzer: FunctionAnalyzer
var styler: NodeStyler
var connection_builder: ConnectionBuilder


func render(p_model: ScriptGraphModel, p_graph: GraphEdit, p_warnings: Array = [], p_function_callers: Dictionary = {}) -> void:
	model = p_model
	graph_edit = p_graph
	warnings = p_warnings
	function_callers = p_function_callers
	
	# Initialize components
	analyzer = FunctionAnalyzer.new()
	styler = NodeStyler.new()
	connection_builder = ConnectionBuilder.new(graph_edit, analyzer)
	
	_clear_graph()
	
	if DETAIL_VIEW_ENABLED:
		_render_full_detail()      # Legacy node-per-statement behavior
	else:
		_render_functions_only()   # New 0.1 functions-only behavior


func _clear_graph() -> void:
	# Remove all existing nodes
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()
	
	# Clear connections
	graph_edit.clear_connections()


## LEGACY: Full detail view - shows every IF/ELSE/RETURN as a separate node
func _render_full_detail() -> void:
	# Create all nodes (no automatic positioning)
	for node_id in model.nodes:
		var flow_node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		_create_graph_node(flow_node, flow_node.type == ScriptGraphModel.FlowNodeType.FUNC)
	
	# Wait one frame for nodes to be ready in the tree
	await graph_edit.get_tree().process_frame
	
	# Create connections to show flow relationships
	_create_sequential_connections(model)
	_create_branch_connections(model)


## NEW 0.1: Functions-only view - summarizes internal flow within each function node
func _render_functions_only() -> void:
	if model == null or graph_edit == null:
		return
	
	var function_nodes: Array[ScriptGraphModel.FlowNode] = []
	for node_id in model.nodes:
		var flow_node = model.get_node(node_id)
		if flow_node and flow_node.type == ScriptGraphModel.FlowNodeType.FUNC:
			function_nodes.append(flow_node)
	
	for func_node in function_nodes:
		_create_function_graph_node(func_node)
	
	await graph_edit.get_tree().process_frame
	connection_builder.build_connections(function_nodes, model)


## Step 5: Create function-only graph node (summarizes internal flow)
func _create_function_graph_node(func_node: ScriptGraphModel.FlowNode) -> void:
	var graph_node := GraphNode.new()
	# CRITICAL: Set name BEFORE adding to tree
	# Godot may auto-assign names if the node is in the tree
	graph_node.name = func_node.id
	print("    [CREATE] Setting GraphNode.name to: '%s'" % func_node.id)
	
	var icon := _get_node_icon(ScriptGraphModel.FlowNodeType.FUNC)
	# Extract function name with parameters: "func name(params)" -> "name(params)"
	var func_signature = func_node.label.replace("func ", "").strip_edges()
	graph_node.title = "%s %s" % [icon, func_signature]
	
	# Doc comment as subtitle
	var doc_comment := func_node.metadata.get("doc_comment", "")
	if doc_comment != "":
		_add_subtitle_label(graph_node, "💬 " + doc_comment)
	
	# Line number
	_add_line_label(graph_node, func_node.line_number)
	
	# Enable connection ports for function-to-function connections
	# Port 0: left input, right output, both enabled
	graph_node.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
	
	# Analyze function and apply styling (delegated to components)
	var summary := analyzer.analyze_function(func_node, model, warnings)
	
	# Get callers for this function
	var func_name = func_node.label.replace("func ", "").split("(")[0].strip_edges()
	var callers = function_callers.get(func_name, [])
	
	styler.style_function_node(graph_node, func_node, summary, callers)
	
	graph_node.draggable = true
	graph_node.resizable = false
	
	# DEBUG: Check name before adding
	print("    [CREATE] GraphNode.name before add_child: '%s'" % graph_node.name)
	
	graph_edit.add_child(graph_node)
	
	# DEBUG: Check name after adding
	print("    [CREATE] GraphNode.name after add_child: '%s'" % graph_node.name)
	print("    [CREATE] Expected ID: '%s'" % func_node.id)


## ============================================================================
## HELPER FUNCTIONS
## ============================================================================

func _add_subtitle_label(graph_node: GraphNode, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	label.add_theme_font_size_override("font_size", 10)
	graph_node.add_child(label)


func _add_line_label(graph_node: GraphNode, line_number: int) -> void:
	var label = Label.new()
	label.text = "📍 Line: %d" % line_number
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	label.add_theme_font_size_override("font_size", 11)
	graph_node.add_child(label)


## ============================================================================
## LEGACY DETAILED VIEW FUNCTIONS (used when DETAIL_VIEW_ENABLED = true)
## ============================================================================

func _create_graph_node(flow_node: ScriptGraphModel.FlowNode, is_top_level: bool = false) -> void:
	var graph_node = GraphNode.new()
	graph_node.name = flow_node.id
	
	# Add icon to title based on type
	var icon = _get_node_icon(flow_node.type)
	var semantic_suffix = _get_semantic_suffix(flow_node)
	var branch_badge = _get_branch_badge(flow_node)
	
	graph_node.title = icon + " " + flow_node.label + semantic_suffix + branch_badge
	
	# All nodes are compact - auto-fit to content
	graph_node.custom_minimum_size = Vector2(0, 0)
	
	# Add line number with icon
	var line_label = Label.new()
	line_label.text = "📍 Line: %d" % flow_node.line_number
	line_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	line_label.add_theme_font_size_override("font_size", 11)
	graph_node.add_child(line_label)
	
	# Add doc comment or inline comment as subtitle
	var comment = flow_node.metadata.get("comment", "")
	var doc_comment = flow_node.metadata.get("doc_comment", "")
	
	if doc_comment != "":
		var doc_label = Label.new()
		doc_label.text = "💬 " + doc_comment
		doc_label.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
		doc_label.add_theme_font_size_override("font_size", 10)
		graph_node.add_child(doc_label)
	elif comment != "":
		var comment_label = Label.new()
		comment_label.text = "💭 " + comment
		comment_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		comment_label.add_theme_font_size_override("font_size", 10)
		graph_node.add_child(comment_label)
	
	# Add TODO/FIXME/NOTE badges
	var todo_badge = _get_todo_badge(flow_node)
	if todo_badge != "":
		var todo_label = Label.new()
		todo_label.text = todo_badge
		todo_label.add_theme_font_size_override("font_size", 10)
		graph_node.add_child(todo_label)
	
	# Enable connection ports on the label slot
	# Left port = input (can receive connections)
	# Right port = output (can send connections)
	graph_node.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
	
	# Apply styling based on type
	_apply_node_styling(graph_node, flow_node)
	
	# Check for warnings
	_apply_warnings(graph_node, flow_node)
	
	# Build rich tooltip
	_apply_rich_tooltip(graph_node, flow_node)
	
	# Make it draggable for manual layout adjustment
	graph_node.draggable = true
	graph_node.resizable = false
	
	graph_edit.add_child(graph_node)


func _get_node_icon(type: ScriptGraphModel.FlowNodeType) -> String:
	match type:
		ScriptGraphModel.FlowNodeType.FUNC:
			return "⚡"  # Function
		ScriptGraphModel.FlowNodeType.IF:
			return "❓"  # If
		ScriptGraphModel.FlowNodeType.ELIF:
			return "❔"  # Elif
		ScriptGraphModel.FlowNodeType.ELSE:
			return "💭"  # Else
		ScriptGraphModel.FlowNodeType.LOOP:
			return "🔄"  # Loop
		ScriptGraphModel.FlowNodeType.RETURN:
			return "↩️"  # Return
		_:
			return "•"


func _get_semantic_suffix(flow_node: ScriptGraphModel.FlowNode) -> String:
	# Add semantic meaning to node titles
	match flow_node.type:
		ScriptGraphModel.FlowNodeType.RETURN:
			return " — exits function"
		ScriptGraphModel.FlowNodeType.IF:
			# Check if it has an else branch
			var has_else = false
			for child_id in flow_node.children:
				if child_id.contains("else"):
					has_else = true
					break
			if not has_else and flow_node.children.size() == 1:
				return " — no else branch"
			return ""
		ScriptGraphModel.FlowNodeType.LOOP:
			return " — iterates"
		_:
			return ""
	
	return ""


func _get_branch_badge(flow_node: ScriptGraphModel.FlowNode) -> String:
	# Add branch quality badges
	if flow_node.type == ScriptGraphModel.FlowNodeType.IF or flow_node.type == ScriptGraphModel.FlowNodeType.ELIF:
		# Check branch completeness
		var has_else = false
		for child_id in flow_node.children:
			if child_id.contains("else"):
				has_else = true
				break
		
		if has_else:
			return " ✓"  # Both branches present
		else:
			return " ✗"  # Missing else
	
	return ""


func _get_todo_badge(flow_node: ScriptGraphModel.FlowNode) -> String:
	# Check for TODO/FIXME/NOTE in comments
	var comment = flow_node.metadata.get("comment", "")
	var doc_comment = flow_node.metadata.get("doc_comment", "")
	var full_text = comment + " " + doc_comment
	
	if "TODO" in full_text.to_upper():
		return "⚠️ TODO"
	elif "FIXME" in full_text.to_upper():
		return "🔴 FIXME"
	elif "NOTE" in full_text.to_upper() or "INFO" in full_text.to_upper():
		return "ℹ️ NOTE"
	
	return ""


func _apply_node_styling(graph_node: GraphNode, flow_node: ScriptGraphModel.FlowNode) -> void:
	var color: Color
	
	match flow_node.type:
		ScriptGraphModel.FlowNodeType.FUNC:
			color = COLOR_FUNC
		ScriptGraphModel.FlowNodeType.IF, ScriptGraphModel.FlowNodeType.ELIF, ScriptGraphModel.FlowNodeType.ELSE:
			color = COLOR_CONDITIONAL
		ScriptGraphModel.FlowNodeType.LOOP:
			color = COLOR_LOOP
		ScriptGraphModel.FlowNodeType.RETURN:
			color = COLOR_RETURN
		_:
			color = Color.WHITE
	
	# Set the title bar color with rounded corners
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.border_color = color.darkened(0.3)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	
	graph_node.add_theme_stylebox_override("titlebar", style_box)
	graph_node.add_theme_stylebox_override("titlebar_selected", style_box)
	
	# Add subtle shadow effect for panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = color.darkened(0.5)
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	
	graph_node.add_theme_stylebox_override("panel", panel_style)
	graph_node.add_theme_stylebox_override("panel_selected", panel_style)


func _apply_rich_tooltip(graph_node: GraphNode, flow_node: ScriptGraphModel.FlowNode) -> void:
	# Build a comprehensive tooltip with merged information
	var tooltip_lines = []
	
	# Node type and label
	tooltip_lines.append("📋 " + flow_node.label)
	tooltip_lines.append("📍 Line " + str(flow_node.line_number))
	tooltip_lines.append("")
	
	# Doc comment
	var doc_comment = flow_node.metadata.get("doc_comment", "")
	if doc_comment != "":
		tooltip_lines.append("💬 " + doc_comment)
		tooltip_lines.append("")
	
	# Comment
	var comment = flow_node.metadata.get("comment", "")
	if comment != "":
		tooltip_lines.append("💭 " + comment)
		tooltip_lines.append("")
	
	# Branch information
	if flow_node.type == ScriptGraphModel.FlowNodeType.IF or flow_node.type == ScriptGraphModel.FlowNodeType.ELIF:
		var has_else = false
		for child_id in flow_node.children:
			if child_id.contains("else"):
				has_else = true
				break
		
		if has_else:
			tooltip_lines.append("🔀 Branches: Both paths present ✓")
		else:
			tooltip_lines.append("🔀 Branches: Missing else branch ✗")
		tooltip_lines.append("")
	elif flow_node.type == ScriptGraphModel.FlowNodeType.FUNC:
		# Count returns and branches
		var return_count = 0
		var branch_count = 0
		_count_function_info(flow_node, return_count, branch_count)
		
		if return_count > 0 or branch_count > 0:
			tooltip_lines.append("📊 Function Info:")
			if return_count > 0:
				tooltip_lines.append("  ↩️ %d return%s" % [return_count, "s" if return_count > 1 else ""])
			if branch_count > 0:
				tooltip_lines.append("  🔀 %d branch%s" % [branch_count, "es" if branch_count > 1 else ""])
			tooltip_lines.append("")
	
	# Return info
	if flow_node.type == ScriptGraphModel.FlowNodeType.RETURN:
		tooltip_lines.append("⚠️ Exits function immediately")
		tooltip_lines.append("")
	
	# Set tooltip (if we have useful info beyond the basics)
	if tooltip_lines.size() > 3:  # More than just label + line
		graph_node.tooltip_text = "\n".join(tooltip_lines)


func _count_function_info(node: ScriptGraphModel.FlowNode, return_count: int, branch_count: int) -> void:
	# Recursively count returns and branches in a function
	if node.type == ScriptGraphModel.FlowNodeType.RETURN:
		return_count += 1
	elif node.type == ScriptGraphModel.FlowNodeType.IF or node.type == ScriptGraphModel.FlowNodeType.ELIF:
		branch_count += 1
	
	# Recurse through children
	for child_id in node.children:
		pass  # Would need model reference to recurse properly


func _apply_warnings(graph_node: GraphNode, flow_node: ScriptGraphModel.FlowNode) -> void:
	# Check if this node has warnings
	var warning_count = 0
	var warning_messages = []
	
	for warning in warnings:
		if warning.node_id == flow_node.id:
			warning_count += 1
			var severity_icon = ""
			match warning.severity:
				1: severity_icon = "ℹ️"
				2: severity_icon = "⚠️"
				3: severity_icon = "❌"
			warning_messages.append("%s Line %d: %s" % [severity_icon, warning.line_number, warning.message])
	
	if warning_count > 0:
		# Add compact warning indicator (just icon + count)
		var warning_label = Label.new()
		warning_label.text = "⚠️ %d issue%s" % [warning_count, "s" if warning_count > 1 else ""]
		warning_label.add_theme_color_override("font_color", COLOR_WARNING)
		warning_label.add_theme_font_size_override("font_size", 11)
		graph_node.add_child(warning_label)
		
		# Add tooltip with full warning details
		var tooltip_text = "⚠️ Code Issues:\n\n" + "\n".join(warning_messages)
		graph_node.tooltip_text = tooltip_text
		
		# Add red border to highlight
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.2, 0.2, 0.2)
		style_box.border_width_left = 3
		style_box.border_width_right = 3
		style_box.border_width_top = 3
		style_box.border_width_bottom = 3
		style_box.border_color = COLOR_WARNING
		style_box.corner_radius_bottom_left = 6
		style_box.corner_radius_bottom_right = 6
		
		graph_node.add_theme_stylebox_override("panel", style_box)
		graph_node.add_theme_stylebox_override("panel_selected", style_box)


func _create_sequential_connections(model: ScriptGraphModel) -> void:
	# Connect nodes in sequential execution order (top to bottom)
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		
		# Functions and loops ALWAYS connect to their first child
		if node.type == ScriptGraphModel.FlowNodeType.FUNC or node.type == ScriptGraphModel.FlowNodeType.LOOP:
			if node.children.size() > 0:
				var first_child = node.children[0]
				_connect_nodes(node.id, first_child, Color.WHITE)
		
		# Return nodes have no children (leaf nodes)
		elif node.type == ScriptGraphModel.FlowNodeType.RETURN:
			pass
		
		# IF/ELIF/ELSE are handled by branch connections
		elif node.type == ScriptGraphModel.FlowNodeType.IF or node.type == ScriptGraphModel.FlowNodeType.ELIF or node.type == ScriptGraphModel.FlowNodeType.ELSE:
			pass
		
		# Other nodes (statements) connect to next sibling
		# This handles sequential statements within a function body
		else:
			if node.children.size() > 0:
				var first_child = node.children[0]
				_connect_nodes(node.id, first_child, Color.WHITE)


func _create_branch_connections(model: ScriptGraphModel) -> void:
	# Create visual branch connections for IF/ELSE
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		
		# IF/ELIF nodes have multiple children - show branching
		if node.type == ScriptGraphModel.FlowNodeType.IF or node.type == ScriptGraphModel.FlowNodeType.ELIF:
			# Connect to all children with branch colors
			for i in range(node.children.size()):
				var child_id = node.children[i]
				var child = model.get_node(child_id)
				
				# Color code: green for THEN path, orange for ELSE path
				var color = Color.GREEN if child.type != ScriptGraphModel.FlowNodeType.ELSE else Color.ORANGE
				_connect_nodes(node.id, child_id, color)
		
		# ELSE nodes connect to their body
		elif node.type == ScriptGraphModel.FlowNodeType.ELSE:
			for child_id in node.children:
				_connect_nodes(node.id, child_id, Color.ORANGE)


func _create_call_connections(model: ScriptGraphModel) -> void:
	# Detect function calls and create call graph connections
	var function_map = {}  # Map function names to their node IDs
	
	# Build function map
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		if node.type == ScriptGraphModel.FlowNodeType.FUNC:
			# Extract function name from label like "func test_simple_condition"
			var func_name = node.label.replace("func ", "").split("(")[0].strip_edges()
			function_map[func_name] = node.id
	
	# Scan for function calls
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		
		# Simple regex-like detection: look for word followed by (
		var label = node.label
		var regex = RegEx.new()
		regex.compile("\\b([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(")
		var matches = regex.search_all(label)
		
		for match in matches:
			var called_func = match.get_string(1)
			
			# If this function exists in our map, connect them
			if function_map.has(called_func):
				var target_func_id = function_map[called_func]
				# Don't connect a function to itself
				if target_func_id != node_id:
					# Use cyan/blue for call connections
					_connect_nodes(node.id, target_func_id, Color.CYAN)


func _connect_nodes(from_id: String, to_id: String, color: Color = Color.WHITE) -> void:
	# Get the nodes
	var from_node = graph_edit.get_node_or_null(NodePath(from_id))
	var to_node = graph_edit.get_node_or_null(NodePath(to_id))
	
	if not from_node:
		print("      [ERROR] Source node not found: %s" % from_id)
		print("        Tried NodePath: %s" % NodePath(from_id))
		var child_names = []
		for child in graph_edit.get_children():
			if child is GraphNode:
				child_names.append(child.name)
		print("        Available GraphNode names: %s" % str(child_names))
		return
	if not to_node:
		print("      [ERROR] Target node not found: %s" % to_id)
		print("        Tried NodePath: %s" % NodePath(to_id))
		return
	
	# GraphEdit.connect_node(from, from_port, to, to_port)
	var error = graph_edit.connect_node(from_id, 0, to_id, 0)
	if error != OK:
		print("      [ERROR] Connection failed with error code: %d" % error)
	else:
		print("      [SUCCESS] Connection created!")


func apply_hierarchical_layout(model: ScriptGraphModel, target_graph: GraphEdit) -> void:
	# Sugiyama-style hierarchical layout
	# Places nodes in layers based on hierarchy depth
	
	graph_edit = target_graph
	
	var layers: Array[Array] = []  # Array of layers, each containing node IDs
	var node_layer: Dictionary = {}  # Map node ID to layer index
	
	# Step 1: Assign nodes to layers based on parent-child relationships
	_assign_layers(model, layers, node_layer)
	
	# Step 2: Position nodes within each layer
	_position_layers(model, layers, node_layer)
	
	# Step 3: Redraw connections after repositioning
	graph_edit.clear_connections()
	await graph_edit.get_tree().process_frame
	_create_sequential_connections(model)
	_create_branch_connections(model)
	
	print("ScriptGraph: Hierarchical layout applied - %d layers" % layers.size())


func _assign_layers(model: ScriptGraphModel, layers: Array[Array], node_layer: Dictionary) -> void:
	# Assign each node to a layer based on its depth in the hierarchy
	var visited = {}
	
	# Start with root nodes (functions) at layer 0
	for root_id in model.root_nodes:
		_assign_layer_recursive(model, root_id, 0, layers, node_layer, visited)


func _assign_layer_recursive(model: ScriptGraphModel, node_id: String, layer: int, layers: Array[Array], node_layer: Dictionary, visited: Dictionary) -> void:
	if node_id in visited:
		return
	
	visited[node_id] = true
	
	# Ensure layer array exists
	while layers.size() <= layer:
		layers.append([])
	
	# Add node to this layer
	layers[layer].append(node_id)
	node_layer[node_id] = layer
	
	# Process children at next layer
	var node = model.get_node(node_id)
	if node:
		for child_id in node.children:
			_assign_layer_recursive(model, child_id, layer + 1, layers, node_layer, visited)


func _position_layers(model: ScriptGraphModel, layers: Array[Array], node_layer: Dictionary) -> void:
	# Position nodes within each layer
	var layer_height = 120  # Vertical spacing between layers
	var node_spacing = 180  # Horizontal spacing between nodes
	var start_x = 100
	var start_y = 80
	
	for layer_idx in range(layers.size()):
		var layer_nodes = layers[layer_idx]
		var y = start_y + (layer_idx * layer_height)
		
		# Center the layer horizontally
		var total_width = layer_nodes.size() * node_spacing
		var layer_start_x = start_x
		
		for i in range(layer_nodes.size()):
			var node_id = layer_nodes[i]
			var graph_node = graph_edit.get_node_or_null(NodePath(node_id))
			
			if graph_node:
				var x = layer_start_x + (i * node_spacing)
				graph_node.position_offset = Vector2(x, y)


func _apply_nested_layout(model: ScriptGraphModel) -> void:
	# Layout with visual nesting - children positioned inside function containers
	var x_base = 100
	var y_base = 80
	var function_spacing = 450
	
	# Layout each function and its children as a visual group
	for i in range(model.root_nodes.size()):
		var func_id = model.root_nodes[i]
		var func_node: ScriptGraphModel.FlowNode = model.get_node(func_id)
		var func_graph = graph_edit.get_node_or_null(NodePath(func_id))
		
		if not func_graph:
			continue
		
		# Position function node
		var func_x = x_base + (i * function_spacing)
		var func_y = y_base
		func_graph.position_offset = Vector2(func_x, func_y)
		
		# Layout children inside the function's visual space
		var child_start_y = func_y + 90  # Start children below function header
		var child_x = func_x + 20  # Indent children inside
		
		_layout_children_nested(model, func_node, child_x, child_start_y)


func _layout_children_nested(model: ScriptGraphModel, parent: ScriptGraphModel.FlowNode, x: float, y: float) -> float:
	# Recursively layout children with proper nesting
	for child_id in parent.children:
		var child: ScriptGraphModel.FlowNode = model.get_node(child_id)
		var child_graph = graph_edit.get_node_or_null(NodePath(child_id))
		
		if not child_graph:
			continue
		
		# Position child node
		child_graph.position_offset = Vector2(x, y)
		y += 60  # Tight vertical spacing
		
		# If this child has children, indent them further
		if child.children.size() > 0:
			y = _layout_children_nested(model, child, x + 40, y)
			y += 5  # Small gap after nested group
	
	return y
