extends "res://addons/gd-plug/plug.gd"

# Usage instructions: https://github.com/imjp94/gd-plug?tab=readme-ov-file
func _plugging():
	# Declare plugins with plug(repo, args)
	# For example, clone from github repo("user/repo_name")
	# plug("imjp94/gd-YAFSM") # By default, gd-plug will only install anything from "addons/" directory
	# Or you can explicitly specify which file/directory to include
	# plug("imjp94/gd-YAFSM", {"include": ["addons/"]}) # By default, gd-plug will only install anything from "addons/" directory
	plug("don-tnowe/godot-resources-as-sheets-plugin/tree/Godot-4")
