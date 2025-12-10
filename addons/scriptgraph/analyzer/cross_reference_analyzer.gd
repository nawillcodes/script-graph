extends RefCounted
class_name CrossReferenceAnalyzer

## Analyzes cross-file function calls
## Detects which scripts call functions in the current script

## Find which files call functions in the given script
func find_callers(script_path: String, function_names: Array[String]) -> Dictionary:
	print("ScriptGraph: [DEBUG] Finding callers for functions in: ", script_path)
	
	# Result: function_name -> [list of caller file paths]
	var callers := {}
	for func_name in function_names:
		callers[func_name] = []
	
	# Get project directory
	var project_dir = "res://"
	var files_to_scan = _get_all_gdscript_files(project_dir)
	
	print("ScriptGraph: [DEBUG] Scanning %d .gd files for function calls..." % files_to_scan.size())
	
	# Scan each file for function calls
	for file_path in files_to_scan:
		# Don't scan the current file
		if file_path == script_path:
			continue
		
		var calls = _scan_file_for_calls(file_path, function_names)
		for func_name in calls:
			if func_name in callers:
				callers[func_name].append(file_path)
	
	# Log results
	for func_name in callers:
		if callers[func_name].size() > 0:
			print("ScriptGraph: [DEBUG] Function '%s' called from %d file(s)" % [func_name, callers[func_name].size()])
	
	return callers


## Get all .gd files in project
func _get_all_gdscript_files(dir_path: String, max_depth: int = 5) -> Array[String]:
	var files: Array[String] = []
	
	if max_depth <= 0:
		return files
	
	var dir = DirAccess.open(dir_path)
	if not dir:
		return files
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = dir_path.path_join(file_name)
		
		if dir.current_is_dir():
			# Skip hidden/system directories
			if not file_name.begins_with(".") and file_name != "addons" and file_name != ".godot":
				# Recursively scan subdirectories
				files.append_array(_get_all_gdscript_files(full_path, max_depth - 1))
		elif file_name.ends_with(".gd"):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return files


## Scan a single file for function calls
func _scan_file_for_calls(file_path: String, target_functions: Array[String]) -> Array[String]:
	var found_calls: Array[String] = []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return found_calls
	
	var content = file.get_as_text()
	file.close()
	
	# Simple regex to find function calls
	var regex = RegEx.new()
	regex.compile("\\b([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(")
	
	var lines = content.split("\n")
	for line in lines:
		var trimmed = line.strip_edges()
		
		# Skip comments and function definitions
		if trimmed.begins_with("#") or trimmed.begins_with("func "):
			continue
		
		var matches = regex.search_all(line)
		for match in matches:
			var called_func = match.get_string(1)
			
			# Check if this is one of our target functions
			if called_func in target_functions and called_func not in found_calls:
				found_calls.append(called_func)
	
	return found_calls
