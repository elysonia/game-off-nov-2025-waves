class_name Player
extends CharacterBody2D

var max_jump_strength: int = 5
var jump_strength: int = 0


func _draw():
    if Input.is_action_pressed("lmb"):
        var mouse_position = get_global_mouse_position()
        jump_strength = roundi(position.distance_to(mouse_position))
        draw_dashed_line(position, mouse_position, Color(1, 1, 1, 1), 3)


func _process(_delta: float):
    if Input.is_action_pressed("lmb"):
        queue_redraw()

