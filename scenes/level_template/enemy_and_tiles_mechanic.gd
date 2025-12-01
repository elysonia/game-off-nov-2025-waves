extends Panel

signal node_freed

func _ready() -> void:
	# get_tree().paused = true
	%Close.pressed.connect(_on_close_pressed)


func _on_close_pressed() -> void:
	node_freed.emit()
	queue_free()
