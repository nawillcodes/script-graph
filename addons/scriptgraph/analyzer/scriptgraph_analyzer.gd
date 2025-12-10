extends RefCounted
class_name ScriptGraphAnalyzer

## ScriptGraph Analyzer
## Detects potential code issues in the flow model

const ScriptGraphModel = preload("res://addons/scriptgraph/core/scriptgraph_model.gd")

enum WarningType {
	UNREACHABLE_CODE,
	EMPTY_BLOCK,
	DEEP_NESTING,
	MISSING_RETURN
}

class AnalysisWarning:
	var node_id: String
	var type: WarningType
	var message: String
	var severity: int  ## 1=info, 2=warning, 3=error
	var line_number: int
	
	func _init(_node_id: String, _type: WarningType, _message: String, _severity: int, _line: int) -> void:
		node_id = _node_id
		type = _type
		message = _message
		severity = _severity
		line_number = _line


func analyze(model: ScriptGraphModel) -> Array[AnalysisWarning]:
	var warnings: Array[AnalysisWarning] = []
	
	# Run all checks
	warnings.append_array(check_unreachable_code(model))
	warnings.append_array(check_empty_blocks(model))
	warnings.append_array(check_deep_nesting(model))
	warnings.append_array(check_return_paths(model))
	
	return warnings


func check_unreachable_code(model: ScriptGraphModel) -> Array[AnalysisWarning]:
	var warnings: Array[AnalysisWarning] = []
	
	# Check if there are nodes after a return statement in the same block
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		if node.type == ScriptGraphModel.FlowNodeType.RETURN:
			# Check if this return has siblings after it
			# This is a simplified check - we look for nodes with higher line numbers
			# that share the same indentation
			for other_id in model.nodes:
				var other: ScriptGraphModel.FlowNode = model.get_node(other_id)
				if other.line_number > node.line_number and other.indentation == node.indentation:
					# Found potentially unreachable code
					var warning = AnalysisWarning.new(
						other.id,
						WarningType.UNREACHABLE_CODE,
						"Code after return statement may be unreachable",
						2,
						other.line_number
					)
					warnings.append(warning)
					break  # Only warn once per return
	
	return warnings


func check_empty_blocks(model: ScriptGraphModel) -> Array[AnalysisWarning]:
	var warnings: Array[AnalysisWarning] = []
	
	# Check if control flow nodes have no children
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		if node.type in [
			ScriptGraphModel.FlowNodeType.IF,
			ScriptGraphModel.FlowNodeType.ELIF,
			ScriptGraphModel.FlowNodeType.ELSE,
			ScriptGraphModel.FlowNodeType.LOOP
		]:
			if node.children.is_empty():
				var warning = AnalysisWarning.new(
					node.id,
					WarningType.EMPTY_BLOCK,
					"Empty %s block" % _get_type_name(node.type),
					2,
					node.line_number
				)
				warnings.append(warning)
	
	return warnings


func check_deep_nesting(model: ScriptGraphModel) -> Array[AnalysisWarning]:
	var warnings: Array[AnalysisWarning] = []
	const MAX_DEPTH = 3
	
	# Check indentation depth
	for node_id in model.nodes:
		var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
		var depth = _calculate_depth(model, node_id)
		
		if depth > MAX_DEPTH:
			var warning = AnalysisWarning.new(
				node.id,
				WarningType.DEEP_NESTING,
				"Deeply nested block (level %d). Consider refactoring." % depth,
				1,
				node.line_number
			)
			warnings.append(warning)
	
	return warnings


func check_return_paths(model: ScriptGraphModel) -> Array[AnalysisWarning]:
	var warnings: Array[AnalysisWarning] = []
	
	# For each function, check if all paths have returns
	for root_id in model.root_nodes:
		var func_node: ScriptGraphModel.FlowNode = model.get_node(root_id)
		if func_node.type == ScriptGraphModel.FlowNodeType.FUNC:
			# Check if function has at least one return
			var has_return = _has_return_in_tree(model, root_id)
			
			# Check if function has conditional branches without returns
			var has_conditional = _has_conditional_without_return(model, root_id)
			
			if not has_return:
				var warning = AnalysisWarning.new(
					func_node.id,
					WarningType.MISSING_RETURN,
					"Function '%s' has no return statement" % func_node.label,
					1,
					func_node.line_number
				)
				warnings.append(warning)
			elif has_conditional:
				var warning = AnalysisWarning.new(
					func_node.id,
					WarningType.MISSING_RETURN,
					"Function '%s' may be missing return in some branches" % func_node.label,
					2,
					func_node.line_number
				)
				warnings.append(warning)
	
	return warnings


func _calculate_depth(model: ScriptGraphModel, node_id: String, current_depth: int = 0) -> int:
	var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
	
	if node.type in [
		ScriptGraphModel.FlowNodeType.IF,
		ScriptGraphModel.FlowNodeType.ELIF,
		ScriptGraphModel.FlowNodeType.ELSE,
		ScriptGraphModel.FlowNodeType.LOOP
	]:
		current_depth += 1
	
	var max_child_depth = current_depth
	for child_id in node.children:
		var child_depth = _calculate_depth(model, child_id, current_depth)
		max_child_depth = max(max_child_depth, child_depth)
	
	return max_child_depth


func _has_return_in_tree(model: ScriptGraphModel, node_id: String) -> bool:
	var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
	
	if node.type == ScriptGraphModel.FlowNodeType.RETURN:
		return true
	
	for child_id in node.children:
		if _has_return_in_tree(model, child_id):
			return true
	
	return false


func _has_conditional_without_return(model: ScriptGraphModel, node_id: String) -> bool:
	var node: ScriptGraphModel.FlowNode = model.get_node(node_id)
	
	if node.type in [
		ScriptGraphModel.FlowNodeType.IF,
		ScriptGraphModel.FlowNodeType.ELIF,
		ScriptGraphModel.FlowNodeType.ELSE
	]:
		# Check if this branch has a return
		if not _has_return_in_tree(model, node_id):
			return true
	
	for child_id in node.children:
		if _has_conditional_without_return(model, child_id):
			return true
	
	return false


func _get_type_name(type: ScriptGraphModel.FlowNodeType) -> String:
	match type:
		ScriptGraphModel.FlowNodeType.IF: return "if"
		ScriptGraphModel.FlowNodeType.ELIF: return "elif"
		ScriptGraphModel.FlowNodeType.ELSE: return "else"
		ScriptGraphModel.FlowNodeType.LOOP: return "loop"
		_: return "block"
