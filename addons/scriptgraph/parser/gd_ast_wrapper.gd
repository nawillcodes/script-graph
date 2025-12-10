extends RefCounted
class_name GDScriptParser

## GDScript Parser Wrapper
## MVP: Uses regex-based parsing
## Future: Integrate with gdscript-toolkit or native AST

const ScriptGraphModel = preload("res://addons/scriptgraph/core/scriptgraph_model.gd")

var _node_counter: int = 0

func parse(source_code: String) -> ScriptGraphModel:
	var model = ScriptGraphModel.new()
	
	if source_code.is_empty():
		return model
	
	# Store source code in model for function call analysis
	model.source_code = source_code
	
	var lines = source_code.split("\n")
	_node_counter = 0
	
	# Parse the script
	_parse_lines(lines, model)
	
	return model


func _parse_lines(lines: Array, model: ScriptGraphModel) -> void:
	var i = 0
	var current_parent_stack: Array = []  ## Stack of parent node IDs
	var indent_stack: Array = []  ## Stack of indentation levels
	var pending_comments: Array = []  ## Comments waiting to be attached to next node
	var pending_doc_comment: String = ""  ## Doc comment (## comment) for next item
	
	while i < lines.size():
		var line = lines[i]
		var trimmed = line.strip_edges()
		
		# Collect comments for next node
		if trimmed.begins_with("##"):
			# Doc comment
			var comment_text = trimmed.substr(2).strip_edges()
			if pending_doc_comment == "":
				pending_doc_comment = comment_text
			else:
				pending_doc_comment += " " + comment_text
			i += 1
			continue
		elif trimmed.begins_with("#"):
			# Regular comment
			var comment_text = trimmed.substr(1).strip_edges()
			pending_comments.append(comment_text)
			i += 1
			continue
		elif trimmed.is_empty():
			# Reset comment collection on empty lines (unless we have a doc comment)
			if pending_doc_comment == "":
				pending_comments.clear()
			i += 1
			continue
		
		# Calculate indentation
		var indent = _get_indentation(line)
		
		# Pop stack if we've dedented
		while indent_stack.size() > 0 and indent <= indent_stack[-1]:
			indent_stack.pop_back()
			if current_parent_stack.size() > 0:
				current_parent_stack.pop_back()
		
		# Detect node type
		var node: ScriptGraphModel.FlowNode = null
		
		# Function definition
		if trimmed.begins_with("func "):
			node = _parse_function(trimmed, i + 1)
			# Attach collected comments
			if pending_doc_comment != "":
				node.metadata["doc_comment"] = pending_doc_comment
				pending_doc_comment = ""
			if pending_comments.size() > 0:
				node.metadata["comment"] = " ".join(pending_comments)
				pending_comments.clear()
			model.add_node(node)
			model.add_root_node(node.id)
			current_parent_stack.append(node.id)
			indent_stack.append(indent)
		
		# If statement
		elif trimmed.begins_with("if "):
			node = _parse_if(trimmed, i + 1)
			# Attach inline comments
			if pending_comments.size() > 0:
				node.metadata["comment"] = " ".join(pending_comments)
				pending_comments.clear()
			model.add_node(node)
			_link_to_parent(model, current_parent_stack, node.id)
			current_parent_stack.append(node.id)
			indent_stack.append(indent)
		
		# Elif statement
		elif trimmed.begins_with("elif "):
			node = _parse_elif(trimmed, i + 1)
			model.add_node(node)
			# Link to the same parent as the previous if
			if current_parent_stack.size() > 1:
				var parent_id = current_parent_stack[-2]
				var parent = model.get_node(parent_id)
				if parent:
					parent.add_child(node.id)
			current_parent_stack.append(node.id)
			indent_stack.append(indent)
		
		# Else statement
		elif trimmed.begins_with("else:"):
			node = _parse_else(i + 1)
			model.add_node(node)
			# Link to the same parent as the previous if
			if current_parent_stack.size() > 1:
				var parent_id = current_parent_stack[-2]
				var parent = model.get_node(parent_id)
				if parent:
					parent.add_child(node.id)
			current_parent_stack.append(node.id)
			indent_stack.append(indent)
		
		# For loop
		elif trimmed.begins_with("for "):
			node = _parse_loop(trimmed, i + 1, "for")
			model.add_node(node)
			_link_to_parent(model, current_parent_stack, node.id)
			current_parent_stack.append(node.id)
			indent_stack.append(indent)
		
		# While loop
		elif trimmed.begins_with("while "):
			node = _parse_loop(trimmed, i + 1, "while")
			model.add_node(node)
			_link_to_parent(model, current_parent_stack, node.id)
			current_parent_stack.append(node.id)
			indent_stack.append(indent)
		
		# Return statement
		elif trimmed.begins_with("return"):
			node = _parse_return(trimmed, i + 1)
			model.add_node(node)
			_link_to_parent(model, current_parent_stack, node.id)
		
		i += 1


func _get_indentation(line: String) -> int:
	var count = 0
	for c in line:
		if c == '\t':
			count += 4
		elif c == ' ':
			count += 1
		else:
			break
	return count


func _link_to_parent(model: ScriptGraphModel, parent_stack: Array, child_id: String) -> void:
	if parent_stack.size() > 0:
		var parent_id = parent_stack[-1]
		var parent = model.get_node(parent_id)
		if parent:
			parent.add_child(child_id)


func _generate_id() -> String:
	_node_counter += 1
	return "node_" + str(_node_counter)


func _parse_function(line: String, line_num: int) -> ScriptGraphModel.FlowNode:
	# Extract full function signature: func name(param: Type, ...) -> ReturnType:
	# Remove leading/trailing whitespace and trailing colon
	var signature = line.strip_edges()
	if signature.ends_with(":"):
		signature = signature.substr(0, signature.length() - 1)
	
	var node = ScriptGraphModel.FlowNode.new(
		_generate_id(),
		ScriptGraphModel.FlowNodeType.FUNC,
		signature,  # Store full signature with parameters and types
		line_num
	)
	return node


func _parse_if(line: String, line_num: int) -> ScriptGraphModel.FlowNode:
	var condition = line.replace("if ", "").replace(":", "").strip_edges()
	var node = ScriptGraphModel.FlowNode.new(
		_generate_id(),
		ScriptGraphModel.FlowNodeType.IF,
		"if " + condition,
		line_num
	)
	return node


func _parse_elif(line: String, line_num: int) -> ScriptGraphModel.FlowNode:
	var condition = line.replace("elif ", "").replace(":", "").strip_edges()
	var node = ScriptGraphModel.FlowNode.new(
		_generate_id(),
		ScriptGraphModel.FlowNodeType.ELIF,
		"elif " + condition,
		line_num
	)
	return node


func _parse_else(line_num: int) -> ScriptGraphModel.FlowNode:
	var node = ScriptGraphModel.FlowNode.new(
		_generate_id(),
		ScriptGraphModel.FlowNodeType.ELSE,
		"else",
		line_num
	)
	return node


func _parse_loop(line: String, line_num: int, loop_type: String) -> ScriptGraphModel.FlowNode:
	var condition = line.replace(loop_type + " ", "").replace(":", "").strip_edges()
	var node = ScriptGraphModel.FlowNode.new(
		_generate_id(),
		ScriptGraphModel.FlowNodeType.LOOP,
		loop_type + " " + condition,
		line_num
	)
	return node


func _parse_return(line: String, line_num: int) -> ScriptGraphModel.FlowNode:
	var value = line.replace("return", "").strip_edges()
	var label = "return"
	if not value.is_empty():
		label += " " + value
	
	var node = ScriptGraphModel.FlowNode.new(
		_generate_id(),
		ScriptGraphModel.FlowNodeType.RETURN,
		label,
		line_num
	)
	return node
