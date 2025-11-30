class_name Game
extends Control


func _ready():
	initialize()


func initialize() -> void:
	State.is_level_end = false
	var level_map = LevelManager.get_level_map(State.level)
	var level_map_instance = level_map.instantiate()
	%GameArea.add_child(level_map_instance)
