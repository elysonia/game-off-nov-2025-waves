extends Node


func goto_game_over() -> void:
    get_tree().paused = true

    # TODO: Replace with real game over screen
    var label = Label.new()
    label.text = "Game over"
    get_tree().root.add_child(label)
