class_name LevelsScreen
extends Control


var _previewed_level: int = 0
var _level_map_instance = null


func _ready():
	%Play.disabled = true
	%Play.pressed.connect(_on_play_pressed)
	%Back.pressed.connect(_on_back_pressed)
	%PreviewDetailContainer.visible = false


func initialize() -> void:
	for i in range(LevelManager.MAX_LEVEL):
		create_level_button(i + 1)


func create_level_button(level: int) -> void:
	var button = Button.new()
	button.custom_minimum_size = Vector2(0.0, 100.0)
	button.text = "Level " + str(level)
	%Levels.add_child(button)
	button.pressed.connect(_on_level_pressed.bind(level))


func _on_level_pressed(level: int) -> void:
	if _previewed_level == level:
		_previewed_level = 0
		%Play.disabled = true
		%PreviewDetailContainer.visible = false

		if is_instance_valid(_level_map_instance):
			_level_map_instance.queue_free()
		return

	_previewed_level = level
	%PreviewDetailContainer.visible = true

	for child in %PreviewDetails.get_children():
		child.queue_free()

	var level_map_instance = LevelManager.get_level_map(level).instantiate()

	_level_map_instance = level_map_instance
	%Play.disabled = false
	%Preview.add_child(level_map_instance)
	level_map_instance.preview()
	var preview_details = level_map_instance.get_preview_details(_previewed_level)

	for detail in preview_details:
		%PreviewDetails.add_child(detail)


func _on_play_pressed() -> void:
	if _previewed_level == 0:
		return

	Utils.goto_level(_previewed_level)


func _on_back_pressed() -> void:
	queue_free()
