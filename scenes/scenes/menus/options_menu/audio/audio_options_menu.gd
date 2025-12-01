extends AudioOptionsMenu


func _ready():
    %Back.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
    queue_free()
