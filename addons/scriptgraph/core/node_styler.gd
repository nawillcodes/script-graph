extends RefCounted
class_name NodeStyler

## Handles visual styling, badges, and tooltips for GraphNodes
## Extracted from ScriptGraphRenderer for better separation of concerns

# Color scheme
const COLOR_FUNC = Color("#478CBF")
const COLOR_WARNING = Color("#F44336")

## Apply complete styling to a function node
func style_function_node(graph_node: GraphNode, func_node, summary: Dictionary, callers: Array = []) -> void:
	apply_badges(graph_node, func_node, summary, callers)
	apply_style(graph_node, summary)
	apply_tooltip(graph_node, func_node, summary, callers)


## Add warning/info badges to node
func apply_badges(graph_node: GraphNode, func_node, summary: Dictionary, callers: Array = []) -> void:
	var badges := []
	
	# Show callers if any
	if callers.size() > 0:
		var caller_files = []
		for caller_path in callers:
			caller_files.append(caller_path.get_file())
		
		var caller_text = ""
		if callers.size() == 1:
			caller_text = "📞 called in %s" % caller_files[0]
		elif callers.size() == 2:
			caller_text = "📞 called in %s & %s" % [caller_files[0], caller_files[1]]
		else:
			caller_text = "📞 called in %s, %s & %d more" % [caller_files[0], caller_files[1], callers.size() - 2]
		
		badges.append(caller_text)
	
	# Code quality warnings
	if summary.todo_count > 0:
		badges.append("⚠️ %d TODO" % summary.todo_count)
	if summary.fixme_count > 0:
		badges.append("🔴 %d FIXME" % summary.fixme_count)
	
	# Type checking warnings
	for param_name in summary.untyped_params:
		badges.append("⚠️ infering variant typing for parameter: %s" % param_name)
	
	if summary.missing_return_type and summary.return_count > 0:
		badges.append("⚠️ missing return type hint")
	
	# Unused parameter warnings
	for param_name in summary.unused_params:
		badges.append("⚠️ unused parameter: %s" % param_name)
	
	# Magic number warnings (show count, not all numbers)
	if summary.magic_numbers.size() > 0:
		badges.append("⚠️ %d magic number%s detected" % [summary.magic_numbers.size(), "s" if summary.magic_numbers.size() > 1 else ""])
	
	# Function length warning
	if summary.function_length > 50:
		badges.append("⚠️ function too long (%d lines)" % summary.function_length)
	
	# Control flow warnings
	if summary.missing_else:
		badges.append("✗ Incomplete branches")
	if summary.missing_return:
		badges.append("⚠️ Missing return")
	if summary.unreachable_count > 0:
		badges.append("❌ %d unreachable" % summary.unreachable_count)
	
	# Add badge labels
	for badge in badges:
		var label = Label.new()
		label.text = badge
		label.add_theme_font_size_override("font_size", 10)
		graph_node.add_child(label)


## Apply color styling and borders
func apply_style(graph_node: GraphNode, summary: Dictionary) -> void:
	var color := COLOR_FUNC
	
	# Determine if node has issues
	var has_issues = (
		summary.unreachable_count > 0 or 
		summary.fixme_count > 0 or 
		summary.missing_return or 
		summary.untyped_params.size() > 0 or
		summary.unused_params.size() > 0 or
		summary.magic_numbers.size() > 0 or
		summary.function_length > 50
	)
	
	# Titlebar style
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.border_color = COLOR_WARNING if has_issues else color.darkened(0.3)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	
	graph_node.add_theme_stylebox_override("titlebar", style_box)
	graph_node.add_theme_stylebox_override("titlebar_selected", style_box)
	
	# Panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = COLOR_WARNING if has_issues else color.darkened(0.5)
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	
	graph_node.add_theme_stylebox_override("panel", panel_style)
	graph_node.add_theme_stylebox_override("panel_selected", panel_style)


## Add informative tooltip
func apply_tooltip(graph_node: GraphNode, func_node, summary: Dictionary, callers: Array = []) -> void:
	var lines := []
	
	# Function signature (using Unicode box drawing for emphasis)
	lines.append("═══════════════════════════════")
	lines.append("⚡ %s" % func_node.label)
	lines.append("═══════════════════════════════")
	lines.append("")
	
	# Callers information
	if callers.size() > 0:
		lines.append("📞 CALLED FROM:")
		for caller in callers:
			lines.append("   • %s" % caller.get_file())
		lines.append("")
	
	# Complexity metrics
	lines.append("📊 COMPLEXITY:")
	lines.append("   • Total statements: %d" % summary.total_statements)
	lines.append("   • Branches: %d" % summary.branch_count)
	lines.append("   • Returns: %d" % summary.return_count)
	lines.append("   • Function length: %d lines" % summary.function_length)
	if summary.has_loops:
		lines.append("   • Contains loops")
	lines.append("")
	
	# Function calls
	if summary.call_names.size() > 0:
		lines.append("📞 CALLS:")
		for call in summary.call_names:
			lines.append("   • %s()" % call)
		lines.append("")
	
	# Issues
	var issues := []
	if summary.untyped_params.size() > 0:
		issues.append("Untyped parameters: %s" % ", ".join(summary.untyped_params))
	if summary.unused_params.size() > 0:
		issues.append("Unused parameters: %s" % ", ".join(summary.unused_params))
	if summary.missing_return_type:
		issues.append("Missing return type hint")
	if summary.magic_numbers.size() > 0:
		issues.append("Magic numbers: %s" % ", ".join(summary.magic_numbers))
	if summary.function_length > 50:
		issues.append("Function too long (>50 lines)")
	if summary.missing_else:
		issues.append("Incomplete branches")
	if summary.missing_return:
		issues.append("Missing return statement")
	if summary.unreachable_count > 0:
		issues.append("%d unreachable statements" % summary.unreachable_count)
	
	if issues.size() > 0:
		lines.append("⚠️  ISSUES:")
		for issue in issues:
			lines.append("   ⚠ %s" % issue)
	else:
		lines.append("✅ No issues detected")
	
	graph_node.tooltip_text = "\n".join(lines)
