class_name Game
extends Control

var _level_map_instance: LevelTemplate
@onready var _enemy_and_tiles = preload("res://scenes/level_template/enemy_and_tiles_mechanic.tscn")


func _ready():
	GlobalSignal.item_collected.connect(_on_item_collected)

	set_physics_process(false)
	initialize()
	call_deferred("_post_ready")


func _process(_delta: float):
	if is_instance_valid(_level_map_instance):
		handle_update_item_timer()


func initialize() -> void:
	State.is_level_end = false
	var level_map = LevelManager.get_level_map(State.level)
	var level_map_instance = level_map.instantiate()
	%GameArea.add_child(level_map_instance)
	%Overlay.transparent_bg = true
	_level_map_instance = level_map_instance
	%Items.text = "Items Collected: 0/" + str(State.total_items)

	if level_map_instance.is_tutorial_mode:
		var last_tutorial = _enemy_and_tiles.instantiate()
		add_child(last_tutorial)
		await last_tutorial.node_freed
	level_map_instance.initialize()



func handle_update_item_timer() -> void:
	var status = _level_map_instance.get_item_status()
	%NextItemCountDown.text = status

func _post_ready() -> void:
	set_physics_process(true)


func _on_item_collected(_item: ItemSprite) -> void:
	%Items.text = "Items Collected: " + str(State.total_item_collected) + "/" + str(State.total_items)
