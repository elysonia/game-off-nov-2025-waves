class_name Notification
extends Label


func initialize(new_text: String) -> void:
    text = new_text
    # await get_tree().create_timer(State.NOTIFICATION_DURATION).timeout

    # var tween = create_tween().set_parallel()
    # tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 3)
    # tween.tween_property(self, "position", Vector2(position.x, -10), 3)
    # await tween.finished
    # tween.kill()
    # queue_free()
