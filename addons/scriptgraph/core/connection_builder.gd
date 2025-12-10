extends RefCounted
class_name ConnectionBuilder

## Builds function-to-function connections in the call graph
## Extracted from ScriptGraphRenderer for better separation of concerns

const FunctionAnalyzer = preload("res://addons/scriptgraph/core/function_analyzer.gd")

var graph_edit: GraphEdit
var analyzer: FunctionAnalyzer
var model

func _init(p_graph_edit: GraphEdit, p_analyzer: FunctionAnalyzer):
	graph_edit = p_graph_edit
	analyzer = p_analyzer


## Create all function-to-function connections
func build_connections(function_nodes: Array, p_model) -> void:
	model = p_model
	print("\n=== ScriptGraph: Creating Function Connections ===")
	print("Total functions: %d" % function_nodes.size())
	
	# Build function name -> node ID mapping
	var func_by_label := {}
	for f in function_nodes:
		var func_name = _extract_function_name(f.label)
		func_by_label[func_name] = f.id
		print("  Registered: '%s' -> ID: %s" % [func_name, f.id])
	
	# Create connections
	var total_connections = 0
	for f in function_nodes:
		var summary := analyzer.analyze_function(f, model)
		var func_name = _extract_function_name(f.label)
		
		if summary.call_names.size() > 0:
			for called_name in summary.call_names:
				if func_by_label.has(called_name):
					var target_id = func_by_label[called_name]
					if _connect_nodes(f.id, target_id, Color.WHITE):
						total_connections += 1
						print("  ✓ Connected: %s() -> %s()" % [func_name, called_name])
	
	print("\n=== Total Connections Created: %d ===" % total_connections)


## Connect two nodes in the graph
func _connect_nodes(from_node: String, to_node: String, color: Color) -> bool:
	# Validate nodes exist in GraphEdit
	var from_graph_node = graph_edit.get_node_or_null(NodePath(from_node))
	var to_graph_node = graph_edit.get_node_or_null(NodePath(to_node))
	
	if not from_graph_node:
		print("      [SKIP] Source node not in graph: %s" % from_node)
		return false
	
	if not to_graph_node:
		print("      [SKIP] Target node not in graph: %s (external/built-in function)" % to_node)
		return false
	
	# Create connection
	var error = graph_edit.connect_node(from_node, 0, to_node, 0)
	if error != OK:
		print("      [WARN] Connection already exists or failed: %s -> %s" % [from_node, to_node])
		return false
	
	return true


## Extract function name from signature
func _extract_function_name(label: String) -> String:
	return label.replace("func ", "").split("(")[0].strip_edges()
