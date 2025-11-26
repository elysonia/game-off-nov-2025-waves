class_name Tile
extends Area2D

enum Status {ENABLED, DISABLED}
const COLOR = {
	Status.ENABLED: "#ffffff",
	Status.DISABLED: "#111c02",
}
const MODULATE_COLOR = "#000000c7"

var _is_water_anim_playing: bool = false
var _is_lilypad_anim_playing: bool = false
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

	# Make sure the collision shape of the instantiated scene is unique
	# https://forum.godotengine.org/t/collisionshape2d-changes-for-every-instance-with-every-instance/95614/2
	%CollisionShape2D.shape =  %CollisionShape2D.shape.duplicate(true)
	%Ripple.initialize(%CollisionShape2D)

	if status == Status.DISABLED and not is_status_fixed:
		%LilypadAnim.play("flower-timer-disabled")
		%WaterAnim.play("water-surface-still")
		%LilyFlowerDecor.modulate = COLOR[status]
		%LilypadSprite.modulate = COLOR[status]
	else:
		%LilypadAnim.play("flower-decor")
		%WaterAnim.play("RESET")

	%LilypadAnim.seek(randf_range(0.0, %LilypadAnim.current_animation_length), true)


func _process(_delta: float) -> void:
	var time_left: int = roundi(%Timer.time_left)

	if time_left > 0:
		%TimeLeft.text = str(time_left)


func _on_area_entered(area: Area2D) -> void:
	if not is_instance_of(area, Tile):
		return

	if is_instance_of(area, Tile) and area.get_node("%Ripple").is_rippling and not is_status_fixed:
		%LilypadAnim.stop()
		%LilypadAnim.clear_queue()

		var transition_animation: Animation = %WaterAnim.get_animation("water-surface-emerge")
		if status == Status.DISABLED:
			%WaterAnim.stop()
			%WaterAnim.clear_queue()
			status = Status.ENABLED
			var enabled_tween = create_tween().set_parallel()
			%WaterAnim.play("water-surface-emerge")
			enabled_tween.tween_property(%LilyFlowerDecor, "modulate", Color("#fdd2aeff"), transition_animation.length)
			enabled_tween.tween_property(%LilypadSprite, "modulate",  Color("#fdd2aeff"), transition_animation.length)
			Utils.play_sound(Enum.SoundType.SFX, "lilypad-emerge")
			await enabled_tween.finished
			enabled_tween.kill()

		%WaterAnim.play("RESET")
		status = Status.ENABLED
		%LilypadAnim.play("flower-timer")
		%Timer.start(status_duration)

		await %Timer.timeout

		%WaterAnim.animation_set_next("water-surface-emerge", "water-surface-still")
		%WaterAnim.play("water-surface-emerge", 1.0, true)
		var timer_tween = create_tween().set_parallel()
		timer_tween.tween_property(%LilyFlowerDecor, "modulate", Color(COLOR[Status.DISABLED]), transition_animation.length)
		timer_tween.tween_property(%LilypadSprite, "modulate", Color(COLOR[Status.DISABLED]), transition_animation.length)
		Utils.play_sound(Enum.SoundType.SFX, "lilypad-submerge")

		await timer_tween.finished
		status = Status.DISABLED
		timer_tween.kill()
		%LilypadAnim.animation_set_next("flower-timer", "flower-timer-disabled")
		%LilypadAnim.play("flower-timer", 1.0, true)


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
