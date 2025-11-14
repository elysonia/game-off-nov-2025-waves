class_name Ripple
extends Node2D

const SPEED = 3
const DEFAULT_WIDTH = 3
const DEFAULT_RADIUS = 32
const MAX_STRENGTH = 5
const DEFAULT_STRENGTH = 3

@export var speed: int = SPEED
@export var width: int = DEFAULT_WIDTH
@export var radius: int = DEFAULT_RADIUS
@export var ripple_strength: int = DEFAULT_STRENGTH
@export var current_ripple: float = 1.0
@export var is_rippling: bool = false


func handle_ripple(strength: int = DEFAULT_STRENGTH) -> void:
    ripple_strength = strength
    current_ripple = 1.0
    is_rippling = true


func _draw():
    if is_rippling:
        var ripple_radius = radius * current_ripple
        var ripple_width = width * (ripple_strength / current_ripple)
        var alpha = 1 - (current_ripple / ripple_strength)
        draw_circle(position, ripple_radius, Color(1, 1, 1, alpha), false, ripple_width)


func _process(delta: float):
    if current_ripple >= ripple_strength:
        is_rippling = false
        # TODO: Decide:
        # queue_free()
        # or
        # visible = false
    else:
        current_ripple += speed * delta

    if is_rippling:
        queue_redraw()
