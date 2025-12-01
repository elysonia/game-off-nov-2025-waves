extends Node

var _level_end_instance: Control = null
var _pause_screen_instance: Control = null
var _levels_screen_instance: Control = null
var _options_screen_instance: Control = null

@onready var _main_menu = preload("res://scenes/main_menu/main_menu.tscn")
@onready var _level_end = preload("res://scenes/level_end/level_end.tscn")
@onready var _game_scene = preload("res://scenes/game/game.tscn")
@onready var _pause_screen = preload("res://scenes/pause_screen/pause_screen.tscn")
@onready var _levels_screen = preload("res://scenes/levels_screen/levels_screen.tscn")
@onready var _options_screen = preload("res://scenes/scenes/menus/options_menu/audio/audio_options_menu.tscn")


func _ready():
	play_sound(Enum.SoundType.BGM, "bgm-1")


func goto_game_over(condition: Enum.Condition) -> void:
	get_tree().paused = true
	State.is_level_end = true
	play_sound(Enum.SoundType.BGS, "game-over")
	var level_end_instance = _level_end.instantiate()
	level_end_instance.initialize(Enum.Result.LOSE, condition)
	_level_end_instance = level_end_instance
	get_tree().current_scene.add_child(level_end_instance)


func goto_game_won() -> void:
	get_tree().paused = true
	State.is_level_end = true
	play_sound(Enum.SoundType.BGS, "win")
	var level_end_instance = _level_end.instantiate()
	level_end_instance.initialize(Enum.Result.WIN)
	_level_end_instance = level_end_instance
	get_tree().current_scene.add_child(level_end_instance)


func goto_level(level: int) -> void:
	get_tree().paused = false

	State.level = level
	State.enemy_wave = 0
	State.enemies_left = 0
	State.total_items = 0
	State.enemy_wave_cycle = 0
	State.total_items = 0
	State.total_item_collected = 0
	State.items_spawned = 0

	State.is_pause_enabled = true
	print("gotolevel")
	reset_overlays()
	# var main_menu = get_main_menu()
	# if is_instance_valid(main_menu):
	#     main_menu.queue_free()
	print(get_tree().current_scene)
	SceneManager.change_scene(_game_scene)


func get_main_menu() -> MainMenu:
	var children = get_tree().root.get_children().filter(
		func(child):
			return is_instance_of(child, MainMenu)
	)

	if len(children) == 1:
		return children[0]

	return null

func goto_main_menu() -> void:
	get_tree().paused = false
	State.is_pause_enabled = false

	State.level = 1
	State.enemy_wave = 0
	State.enemies_left = 0
	State.total_items = 0
	State.enemy_wave_cycle = 0
	State.total_items = 0
	State.total_item_collected = 0
	State.items_spawned = 0

	SceneManager.change_scene(_main_menu)


func goto_levels() -> void:
	_levels_screen_instance = _levels_screen.instantiate()
	_levels_screen_instance.initialize()
	get_tree().current_scene.add_child(_levels_screen_instance)


func goto_options() -> void:
	_options_screen_instance = _options_screen.instantiate()
	get_tree().current_scene.add_child(_options_screen_instance)


func goto_pause() -> void:
	if is_instance_valid(_pause_screen_instance):
		get_tree().paused = false
		_pause_screen_instance.queue_free()
		return

	_pause_screen_instance = _pause_screen.instantiate()
	get_tree().current_scene.add_child(_pause_screen_instance)
	get_tree().paused = true


func play_sound(type: Enum.SoundType, sound_name: String) -> void:
	if SoundManager.is_playing(sound_name):
		SoundManager.stop(sound_name)

	match (type):
		Enum.SoundType.BGM:
			SoundManager.play_bgm(sound_name)
		Enum.SoundType.BGS:
			SoundManager.play_bgs(sound_name)
		Enum.SoundType.SFX:
			SoundManager.play_sfx(sound_name)
		Enum.SoundType.MFX:
			SoundManager.play_mfx(sound_name)


## Get random value in randf_range(from, to) (inclusive) while excluding values from range(exclude_from, exclude_to) (inclusive).
func get_valid_value_in_range(from: float, to: float, exclude_from: float, exclude_to: float) -> float:
	var value = randf_range(from, to)

	if value >= exclude_from and value <= exclude_to:
		return get_valid_value_in_range(from, to, exclude_from, exclude_to)

	return value


## Remove all overlays
func reset_overlays() -> void:
	if is_instance_valid(_level_end_instance):
		_level_end_instance.queue_free()

	if is_instance_valid(_levels_screen_instance):
		_levels_screen_instance.queue_free()

	if is_instance_valid(_options_screen_instance):
		_options_screen_instance.queue_free()

func remove_next_overlay() -> void:
	if is_instance_valid(_level_end_instance):
		_level_end_instance.queue_free()
		return

	if is_instance_valid(_levels_screen_instance):
		_levels_screen_instance.queue_free()
		return

	if is_instance_valid(_options_screen_instance):
		_options_screen_instance.queue_free()

## Check if non-pause screen overlays are active
func check_overlays() -> bool:
	if is_instance_valid(_level_end_instance):
		return true

	if is_instance_valid(_levels_screen_instance):
		return true

	if is_instance_valid(_options_screen_instance):
		return true

	return false


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if check_overlays():
			remove_next_overlay()
			return

		if State.is_pause_enabled:
			print("should pause")
			goto_pause()
