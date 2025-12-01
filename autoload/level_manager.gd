extends Node

const MAX_LEVEL = 2
const LEVEL_DATA_PATH_FORMAT_STRING = "res://resources/levels/{level}.tres"
const LEVEL_MAP_PATH_FORMAT_STRING = "res://scenes/level_maps/{level}.tscn"

func get_level_data(level: int) -> Level:
	var level_resource_path = LEVEL_DATA_PATH_FORMAT_STRING.format({"level": str(level)})

	if not FileAccess.file_exists(level_resource_path):
		print("Level " + str(level) + " does not exist.")
		return

	var data = load(level_resource_path)
	return data


func get_level_map(level: int) -> PackedScene:
	var level_map_path = LEVEL_MAP_PATH_FORMAT_STRING.format({"level": str(level)})

	if not FileAccess.file_exists(level_map_path):
		print("Map for level " + str(level) + " does not exist.")
		return

	var level_map = load(level_map_path)
	return level_map
