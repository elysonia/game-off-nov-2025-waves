extends Node

const MAX_LEVEL = 1
const LEVEL_PATH_FORMAT_STRING = "res://resources/levels/{level}.tres"


func get_level(level: int) -> Level:
    var level_resource_path = LEVEL_PATH_FORMAT_STRING.format({"level": str(level)})

    if not FileAccess.file_exists(level_resource_path):
        print("Level " + str(level) + " does not exist.")
        return

    var data = load(level_resource_path)
    return data
