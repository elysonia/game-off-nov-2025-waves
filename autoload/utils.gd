extends Node


func goto_game_over() -> void:
    get_tree().paused = true

    # TODO: Replace with real game over screen
    var label = Label.new()
    label.text = "Game over"
    get_tree().root.add_child(label)


func goto_game_won() -> void:
    get_tree().paused = true

    # TODO: Replace with real screen
    var label = Label.new()
    label.text = "You win!"
    get_tree().root.add_child(label)


func goto_next_wave() -> void:
    pass


## Get random value in randf_range(from, to) (inclusive) while excluding values from range(exclude_from, exclude_to) (inclusive).
func get_valid_value_in_range(from: float, to: float, exclude_from: float, exclude_to: float) -> float:
    var value = randf_range(from, to)

    if value >= exclude_from and value <= exclude_to:
        return get_valid_value_in_range(from, to, exclude_from, exclude_to)

    return value
