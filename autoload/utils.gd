extends Node

@onready var _game_over_screen = preload("res://scenes/game_over_screen/game_over_screen.tscn")


func goto_game_over() -> void:
    play_sound(Enum.SoundType.BGS, "game-over")
    get_tree().paused = true
    var game_over_screen_instance = _game_over_screen.instantiate()
    get_tree().root.add_child(game_over_screen_instance)


func goto_game_won() -> void:
    get_tree().paused = true

    # TODO: Replace with real screen
    var label = Label.new()
    label.text = "You win!"
    get_tree().root.add_child(label)


func goto_next_wave() -> void:
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
