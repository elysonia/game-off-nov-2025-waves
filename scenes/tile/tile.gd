class_name Tile
extends Area2D

enum Status {ENABLED, DISABLED}
const COLOR = {
	Status.ENABLED: "#b9f84f",
	Status.DISABLED: "#111c02",
}
const MODULATE_COLOR = "#000000c7"

var _is_mouse_entered: bool = false
var player: Player = null

## The higher the value, the stronger the knockback
@export var knockback_dampening: float = 1.1
## Damage multiplier
@export var power: float = 1.0
@export var status: Status = Status.ENABLED
## Status duration when is_status_fixed is false
@export var status_duration: float = 10.0
## True if the status is fixed, false if modifiable by interaction
@export var is_status_fixed: bool = true


func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%Timer.wait_time = status_duration
	%Polygon2D.color = COLOR[status]

	# Make sure the collision shape of the instantiated scene is unique
	# https://forum.godotengine.org/t/collisionshape2d-changes-for-every-instance-with-every-instance/95614/2
	%CollisionShape2D.shape =  %CollisionShape2D.shape.duplicate(true)
	%Ripple.initialize(%CollisionShape2D)


func _process(_delta: float) -> void:
	var time_left: int = roundi(%Timer.time_left)

	if time_left > 0:
		%TimeLeft.text = str(time_left)


func _on_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Tile) and area.get_node("%Ripple").is_rippling and not is_status_fixed:
		status = Status.ENABLED
		%Polygon2D.color = COLOR[status]

		%Timer.start(status_duration)
		%TimeLeft.visible = true
		await %Timer.timeout
		%TimeLeft.visible = false
		status = Status.DISABLED
		%Polygon2D.color = COLOR[status]

		if player:
			player = null
			Utils.goto_game_over()


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Player):
		player = null


func _on_mouse_entered() -> void:
	_is_mouse_entered = true


func _on_mouse_exited() -> void:
	_is_mouse_entered = false
