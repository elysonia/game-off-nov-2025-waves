class_name Ripple
extends Node2D

const SPEED = 3.0
const DEFAULT_WIDTH = 3.0
const STARTING_RIPPLE = 1.0

var _collision_shape: CollisionShape2D

var ripple_strength: float = 0.0
var knockback_force = 1000

@export var speed: float = SPEED
@export var width: float = DEFAULT_WIDTH
@export var radius: float = 0.0
@export var current_ripple: float = STARTING_RIPPLE

@export var is_rippling: bool = false


func initialize(collision_shape: CollisionShape2D) -> void:
	_collision_shape = collision_shape
	radius = collision_shape.shape.radius


func handle_ripple(strength: float = 0.0) -> void:
	ripple_strength = strength
	current_ripple = 1.0
	is_rippling = true
	visible = true
	Utils.play_sound(Enum.SoundType.SFX, "ripples")


func _draw():
	if is_rippling:
		var ripple_radius = radius + (radius * current_ripple)
		var ripple_width = width * (ripple_strength / current_ripple)
		var alpha = 1 - (current_ripple / ripple_strength)
		draw_circle(position, ripple_radius, Color(1, 1, 1, alpha), false, ripple_width)

		if _collision_shape:
			_collision_shape.shape.radius = ripple_radius


func _process(delta: float):
	if current_ripple >= ripple_strength:
		is_rippling = false
		visible = false
		current_ripple = STARTING_RIPPLE
		ripple_strength = 0.0

		if _collision_shape:
			_collision_shape.shape.radius = radius

	if is_rippling:
		current_ripple += speed * delta
		queue_redraw()
