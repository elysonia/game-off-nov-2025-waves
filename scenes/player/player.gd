class_name Player
extends CharacterBody2D

enum Status {IDLE, STANDBY, JUMPING}

var _next_position: Vector2 = Vector2.ZERO
var status: Status = Status.IDLE
var max_jump_strength: float = State.max_jumping_strength
var jump_strength: float = 0.0


func handle_jump(to: Vector2) -> void:
    var tween = create_tween().set_parallel()
    # Play start jump animation here
    tween.tween_property(self, "position", to, 0.13 * jump_strength).set_ease(Tween.EASE_OUT_IN)
    # Play mid-jump animation here
    # Play landing/drowing animation here
    await tween.finished
    tween.kill()


func _draw():
    if Input.is_action_pressed("lmb") and not Input.is_action_just_released("rmb"):
        var line_mouse_position = get_local_mouse_position()
        var next_jump_strength = Vector2.ZERO.distance_to(line_mouse_position) / State.GRID_SIZE
        jump_strength = next_jump_strength if next_jump_strength <= max_jump_strength else max_jump_strength
        var line_end_position = line_mouse_position.normalized() * (jump_strength * State.GRID_SIZE)
        draw_dashed_line(Vector2.ZERO, line_end_position, Color(1, 1, 1, 1), 5)
        _next_position = to_global(line_end_position)

    if Input.is_action_just_released("lmb"):
        draw_dashed_line(Vector2.ZERO, Vector2.ZERO, Color(1, 1, 1, 0))


func _process(_delta: float) -> void:
    if Input.is_action_pressed("lmb"):
        queue_redraw()

    if Input.is_action_just_released("lmb"):
        queue_redraw()
        if _next_position != Vector2.ZERO:
            handle_jump(_next_position)
