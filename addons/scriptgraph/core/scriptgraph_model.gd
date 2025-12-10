extends RefCounted
class_name ScriptGraphModel

## Flow Model for ScriptGraph
## Represents the structure of a GDScript file as a flow graph

enum FlowNodeType {
	FUNC,       ## Function definition
	IF,         ## If statement
	ELIF,       ## Elif branch
	ELSE,       ## Else branch
	LOOP,       ## For/While loop
	RETURN,     ## Return statement
	CALL,       ## Function call hint
	EMPTY       ## Empty block (for warnings)
}

## Represents a single node in the flow graph
class FlowNode:
	var id: String
	var type: FlowNodeType
	var label: String
	var line_number: int
	var children: Array[String] = []  ## IDs of child nodes
	var metadata: Dictionary = {}
	var indentation: int = 0
	
	func _init(_id: String, _type: FlowNodeType, _label: String, _line: int) -> void:
		id = _id
		type = _type
		label = _label
		line_number = _line
	
	func add_child(child_id: String) -> void:
		if child_id not in children:
			children.append(child_id)


## The complete flow model of a script
var script_path: String = ""
var source_code: String = ""  ## Original source code for analysis
var nodes: Dictionary = {}  ## id -> FlowNode
var root_nodes: Array[String] = []  ## IDs of top-level nodes (functions)

func _init() -> void:
	pass

func add_node(node: FlowNode) -> void:
	nodes[node.id] = node

func get_node(id: String) -> FlowNode:
	return nodes.get(id)

func add_root_node(id: String) -> void:
	if id not in root_nodes:
		root_nodes.append(id)

func get_all_nodes() -> Array:
	return nodes.values()

func clear() -> void:
	nodes.clear()
	root_nodes.clear()
	script_path = ""
	source_code = ""
