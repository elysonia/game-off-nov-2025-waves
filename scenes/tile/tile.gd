class_name Tile
extends Area2D

enum Status {ENABLED, DISABLED}
const COLOR = {
	Status.ENABLED: "#ffffff",
	Status.DISABLED: "#111c02",
}
const MODULATE_COLOR = "#000000c7"

var player: Player = null

## The higher the value, the stronger the knockback
@export var knockback_dampening: float = 1.1
## Damage multiplier
@export var power: float = 1.0
@export var status: Status = Status.ENABLED
## Status duration when is_status_fixed is false
@export var status_duration: float = 12.0
## True if the status is fixed, false if modifiable by interaction
@export var is_status_fixed: bool = true


func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	%Timer.wait_time = status_duration
	modulate = COLOR[status]

	# Make sure the collision shape of the instantiated scene is unique
	# https://forum.godotengine.org/t/collisionshape2d-changes-for-every-instance-with-every-instance/95614/2
	%CollisionShape2D.shape =  %CollisionShape2D.shape.duplicate(true)
	%Ripple.initialize(%CollisionShape2D)

	if status == Status.DISABLED and not is_status_fixed:
		%AnimationPlayer.play("flower-timer-disabled")
	else:
		%AnimationPlayer.play("flower-decor")

	%AnimationPlayer.seek(randf_range(0.0, %AnimationPlayer.current_animation_length), true)


func _process(_delta: float) -> void:
	var time_left: int = roundi(%Timer.time_left)

	if time_left > 0:
		%TimeLeft.text = str(time_left)


func _on_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Tile) and area.get_node("%Ripple").is_rippling and not is_status_fixed:
		status = Status.ENABLED
		modulate = COLOR[status]
		%LilyFlowerDecor.modulate = Color("#fdd2aeff")
		%LilypadSprite.modulate = Color("#fdd2aeff")

		%Timer.start(status_duration)
		%AnimationPlayer.stop()
		%AnimationPlayer.play("flower-timer")

		%TimeLeft.visible = true
		await %Timer.timeout

		%TimeLeft.visible = false
		status = Status.DISABLED
		modulate = COLOR[status]

		%AnimationPlayer.animation_set_next("flower_timer", "flower-timer-disabled")
		%AnimationPlayer.play_backwards("flower-timer")

		if is_instance_valid(player):
			player = null
			print("Fell on unstable ground")
			# Play player drowning animation
			Utils.goto_game_over()


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Player):
		player = null
