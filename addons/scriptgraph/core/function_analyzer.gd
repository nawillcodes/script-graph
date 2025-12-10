extends RefCounted
class_name FunctionAnalyzer

## Analyzes function nodes for complexity, issues, and code quality
## Extracted from ScriptGraphRenderer for better separation of concerns

const ScriptGraphModel = preload("res://addons/scriptgraph/core/scriptgraph_model.gd")

## Analyze a function node and return complete summary
func analyze_function(func_node: ScriptGraphModel.FlowNode, model: ScriptGraphModel, warnings: Array = []) -> Dictionary:
	var summary := {
		"branch_count": 0,
		"missing_else": false,
		"return_count": 0,
		"missing_return": false,
		"call_names": [],
		"todo_count": 0,
		"fixme_count": 0,
		"note_count": 0,
		"unreachable_count": 0,
		"has_loops": false,
		"total_statements": 0,
		"untyped_params": [],
		"missing_return_type": false,
		"unused_params": [],
		"magic_numbers": [],
		"function_length": 0
	}
	
	# Run all checks
	check_parameter_types(func_node, summary)
	check_return_type(func_node, summary)
	scan_function_calls_from_source(func_node, model, summary)
	check_unused_parameters(func_node, model, summary)
	detect_magic_numbers(func_node, model, summary)
	calculate_function_length(func_node, model, summary)
	analyze_control_flow(func_node, model, summary, warnings)
	
	return summary


## Check if function parameters have type hints
func check_parameter_types(func_node: ScriptGraphModel.FlowNode, summary: Dictionary) -> void:
	var signature = func_node.label
	var param_start = signature.find("(")
	var param_end = signature.find(")")
	
	if param_start == -1 or param_end == -1 or param_end <= param_start + 1:
		return
	
	var params_str = signature.substr(param_start + 1, param_end - param_start - 1).strip_edges()
	if params_str.is_empty():
		return
	
	var params = params_str.split(",")
	for param in params:
		var param_clean = param.strip_edges()
		if param_clean.is_empty():
			continue
		
		if ":" not in param_clean:
			var param_name = param_clean.split("=")[0].strip_edges()
			if not param_name.is_empty():
				summary.untyped_params.append(param_name)


## Check if function has return type hint
func check_return_type(func_node: ScriptGraphModel.FlowNode, summary: Dictionary) -> void:
	var signature = func_node.label
	# Check if function has "->" for return type
	if "->" not in signature:
		# Check if function actually returns something (will be checked later)
		summary.missing_return_type = true


## Scan source code for function calls within function body
func scan_function_calls_from_source(func_node: ScriptGraphModel.FlowNode, model: ScriptGraphModel, summary: Dictionary) -> void:
	if not model or model.source_code.is_empty():
		return
	
	var lines = model.source_code.split("\n")
	if func_node.line_number <= 0 or func_node.line_number > lines.size():
		return
	
	var start_line = func_node.line_number
	var end_line = lines.size()
	
	var func_indent = _get_source_line_indent(lines[start_line - 1])
	for i in range(start_line, lines.size()):
		var line = lines[i]
		var trimmed = line.strip_edges()
		
		if trimmed.begins_with("func ") and i > start_line - 1:
			var this_indent = _get_source_line_indent(line)
			if this_indent <= func_indent:
				end_line = i
				break
	
	var regex = RegEx.new()
	regex.compile("\\b([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(")
	
	for i in range(start_line - 1, end_line - 1):
		if i >= lines.size():
			break
		
		var line = lines[i]
		var trimmed = line.strip_edges()
		
		if trimmed.begins_with("#") or trimmed.begins_with("func "):
			continue
		
		var matches = regex.search_all(line)
		for match in matches:
			var called_func = match.get_string(1)
			
			# Filter out keywords and common built-in methods
			var keywords = ["if", "elif", "else", "for", "while", "return", "func", "var", "const", "class", "extends", "signal", "enum", "match", "when", "await", "super", "self", "assert", "break", "continue", "pass", "is", "as", "in", "not", "and", "or"]
			
			if called_func in keywords:
				continue
			
			if called_func not in summary.call_names:
				summary.call_names.append(called_func)


## Check for unused parameters
func check_unused_parameters(func_node: ScriptGraphModel.FlowNode, model: ScriptGraphModel, summary: Dictionary) -> void:
	if not model or model.source_code.is_empty():
		return
	
	# Extract parameter names
	var params = _extract_parameter_names(func_node.label)
	if params.is_empty():
		return
	
	# Get function body
	var lines = model.source_code.split("\n")
	var start_line = func_node.line_number
	var end_line = _find_function_end(lines, start_line)
	
	# Check each parameter for usage
	for param_name in params:
		var used = false
		for i in range(start_line, end_line - 1):
			if i >= lines.size():
				break
			var line = lines[i]
			# Skip the function definition line
			if i == start_line - 1:
				continue
			# Check if parameter name appears in the line
			if _contains_identifier(line, param_name):
				used = true
				break
		
		if not used:
			summary.unused_params.append(param_name)


## Detect magic numbers (numeric literals that should be constants)
func detect_magic_numbers(func_node: ScriptGraphModel.FlowNode, model: ScriptGraphModel, summary: Dictionary) -> void:
	if not model or model.source_code.is_empty():
		return
	
	var lines = model.source_code.split("\n")
	var start_line = func_node.line_number
	var end_line = _find_function_end(lines, start_line)
	
	# Regex to find numeric literals (excluding 0, 1, -1, 2 which are usually OK)
	var regex = RegEx.new()
	regex.compile("\\b(\\d{2,}|\\d+\\.\\d+)\\b")
	
	for i in range(start_line, end_line - 1):
		if i >= lines.size():
			break
		var line = lines[i]
		var trimmed = line.strip_edges()
		
		# Skip comments and const definitions
		if trimmed.begins_with("#") or trimmed.begins_with("const "):
			continue
		
		var matches = regex.search_all(line)
		for match in matches:
			var number = match.get_string(1)
			if number not in summary.magic_numbers:
				summary.magic_numbers.append(number)


## Calculate function length in lines
func calculate_function_length(func_node: ScriptGraphModel.FlowNode, model: ScriptGraphModel, summary: Dictionary) -> void:
	if not model or model.source_code.is_empty():
		return
	
	var lines = model.source_code.split("\n")
	var start_line = func_node.line_number
	var end_line = _find_function_end(lines, start_line)
	
	summary.function_length = end_line - start_line


## Analyze control flow (BFS through children nodes)
func analyze_control_flow(func_node: ScriptGraphModel.FlowNode, model: ScriptGraphModel, summary: Dictionary, warnings: Array = []) -> void:
	var queue: Array[String] = func_node.children.duplicate()
	var visited := {}
	
	while queue.size() > 0:
		var node_id = queue.pop_front()
		if node_id in visited:
			continue
		visited[node_id] = true
		
		var node = model.get_node(node_id)
		if not node:
			continue
		
		summary.total_statements += 1
		
		match node.type:
			ScriptGraphModel.FlowNodeType.IF, ScriptGraphModel.FlowNodeType.ELIF:
				summary.branch_count += 1
				# Check for missing else branch
				var has_else = false
				for child_id in node.children:
					var child_node = model.get_node(child_id)
					if child_node and child_node.type == ScriptGraphModel.FlowNodeType.ELSE:
						has_else = true
						break
				if not has_else:
					summary.missing_else = true
			
			ScriptGraphModel.FlowNodeType.ELSE:
				pass
			
			ScriptGraphModel.FlowNodeType.LOOP:
				summary.has_loops = true
			
			ScriptGraphModel.FlowNodeType.RETURN:
				summary.return_count += 1
			
			ScriptGraphModel.FlowNodeType.EMPTY:
				pass  # Empty nodes are handled by warnings
		
		# Check for unreachable code warnings
		for warning in warnings:
			if warning and warning.node_id == node.id:
				summary.unreachable_count += 1
		
		# Check TODO/FIXME comments
		var comment = node.metadata.get("comment", "")
		var doc_comment = node.metadata.get("doc_comment", "")
		var text = (comment + " " + doc_comment).to_upper()
		
		if "TODO" in text:
			summary.todo_count += 1
		if "FIXME" in text:
			summary.fixme_count += 1
		if "NOTE" in text or "INFO" in text:
			summary.note_count += 1
		
		for child_id in node.children:
			queue.append(child_id)
	
	# Check if function is missing a return
	if summary.return_count == 0 and func_node.label.find("->") != -1:
		summary.missing_return = true


## ============================================================================
## PRIVATE HELPER METHODS
## ============================================================================

func _get_source_line_indent(line: String) -> int:
	var count = 0
	for c in line:
		if c == '\t':
			count += 4
		elif c == ' ':
			count += 1
		else:
			break
	return count


func _find_function_end(lines: Array, start_line: int) -> int:
	var end_line = lines.size()
	var func_indent = _get_source_line_indent(lines[start_line - 1])
	
	for i in range(start_line, lines.size()):
		var line = lines[i]
		var trimmed = line.strip_edges()
		
		if trimmed.begins_with("func ") and i > start_line - 1:
			var this_indent = _get_source_line_indent(line)
			if this_indent <= func_indent:
				end_line = i
				break
	
	return end_line


func _extract_parameter_names(signature: String) -> Array:
	var params := []
	var param_start = signature.find("(")
	var param_end = signature.find(")")
	
	if param_start == -1 or param_end == -1:
		return params
	
	var params_str = signature.substr(param_start + 1, param_end - param_start - 1).strip_edges()
	if params_str.is_empty():
		return params
	
	var param_list = params_str.split(",")
	for param in param_list:
		var param_clean = param.strip_edges()
		# Extract name before ":" or "="
		var name = param_clean.split(":")[0].split("=")[0].strip_edges()
		if not name.is_empty():
			params.append(name)
	
	return params


func _contains_identifier(line: String, identifier: String) -> bool:
	# Use word boundary regex to match whole identifiers only
	var regex = RegEx.new()
	regex.compile("\\b" + identifier + "\\b")
	return regex.search(line) != null
