extends Node

var _level_end_instance = null
@onready var _level_end = preload("res://scenes/level_end/level_end.tscn")

func _ready():
    play_sound(Enum.SoundType.BGM, "bgm-1")

func goto_game_over(condition: Enum.Condition) -> void:
    get_tree().paused = true
    State.is_level_end = true
    play_sound(Enum.SoundType.BGS, "game-over")
    var level_end_instance = _level_end.instantiate()
    level_end_instance.initialize(Enum.Result.LOSE, condition)
    _level_end_instance = level_end_instance
    get_tree().root.add_child(level_end_instance)


func goto_game_won() -> void:
    get_tree().paused = true
    State.is_level_end = true
    play_sound(Enum.SoundType.BGS, "win")
    var level_end_instance = _level_end.instantiate()
    level_end_instance.initialize(Enum.Result.WIN)
    _level_end_instance = level_end_instance
    get_tree().root.add_child(level_end_instance)


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

    reset_overlays()
    SceneManager.change_scene(State.GAME_SCENE_PATH)


func goto_main_menu() -> void:
    pass


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
