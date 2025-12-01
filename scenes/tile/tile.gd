class_name Tile
extends Area2D

## Enabled: Is active by default, causes ripples when jumped on
## Disabled: Activated by other ripples, causes ripples when jumped on
enum Status {ENABLED, DISABLED}
const COLOR = {
	Status.ENABLED: ["#ffffff", "#d39ed6", "#fcbcc0", "#ffffd1", "#cfe5db"],
	Status.DISABLED: ["#111c02"],
}
const MODULATE_COLOR = "#000000c7"

var _origin_status: Status
var _lilypad_animation_player: AnimationPlayer

var _textures_normal: Array = ["res://assets/lilypad1.png", "res://assets/lilypad2.png"]
var _textures_broken: Array = ["res://assets/lilypad1_broken.png", "res://assets/lilypad2_broken.png"]

var tile_item: ItemSprite = null
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

@onready var _item_sprite = preload("res://scenes/item/item.tscn")


func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_origin_status = status
	%Timer.wait_time = status_duration

	# Make sure the collision shape of the instantiated scene is unique
	# https://forum.godotengine.org/t/collisionshape2d-changes-for-every-instance-with-every-instance/95614/2
	%CollisionShape2D.shape =  %CollisionShape2D.shape.duplicate(true)
	%Ripple.initialize(%CollisionShape2D)
	var texture_index = randi_range(0, 1)
	var animation_players = [%LilypadAnim1, %LilypadAnim2]
	_lilypad_animation_player = animation_players[texture_index]

	if _origin_status == Status.DISABLED and not is_status_fixed:
		_lilypad_animation_player.play("flower-timer-disabled")
		%WaterAnim.play("water-surface-still")
	else:
		_lilypad_animation_player.play("flower-decor")
		%WaterAnim.play("RESET")

	var is_enabled_not_fixed = _origin_status == Status.ENABLED and not is_status_fixed
	var is_disabled_fixed = _origin_status == Status.DISABLED and is_status_fixed
	var should_have_broken_texture = is_enabled_not_fixed or is_disabled_fixed

	if should_have_broken_texture:
		%LilypadSprite.texture = load(_textures_broken[texture_index])
	else:
		%LilypadSprite.texture = load(_textures_normal[texture_index])

	%LilyFlowerDecor.modulate = COLOR[_origin_status].pick_random()
	%LilypadSprite.modulate = COLOR[_origin_status].pick_random()
	_lilypad_animation_player.seek(randf_range(0.0, _lilypad_animation_player.current_animation_length), true)


func _process(_delta: float) -> void:
	if State.is_level_end:
		process_mode = Node.PROCESS_MODE_DISABLED

	var time_left: int = roundi(%Timer.time_left)

	if time_left > 0:
		%TimeLeft.text = str(time_left)


func handle_load_item(item: Item) -> void:
	var item_sprite_instance = _item_sprite.instantiate()
	item_sprite_instance.initialize(item, self)
	add_child(item_sprite_instance)
	item_sprite_instance.position = position + Vector2(0, -10)
	tile_item = item_sprite_instance


func check_can_hold_item() -> bool:
	var is_disabled_fixed = _origin_status == Status.DISABLED and is_status_fixed

	return not is_disabled_fixed


func _on_area_entered(area: Area2D) -> void:
	if not is_instance_of(area, Tile):
		return

	if is_instance_of(area, Tile) and area.get_node("%Ripple").is_rippling and not is_status_fixed:
		_lilypad_animation_player.stop()
		_lilypad_animation_player.clear_queue()

		var water_surface_emerge_animation: Animation = %WaterAnim.get_animation("water-surface-emerge")
		if _origin_status == Status.DISABLED and status == Status.DISABLED:
			%WaterAnim.stop()
			%WaterAnim.clear_queue()
			status = Status.ENABLED
			var enabled_tween = create_tween().set_parallel()
			%WaterAnim.play("water-surface-emerge")
			enabled_tween.tween_property(%LilyFlowerDecor, "modulate", Color(COLOR[Status.ENABLED].pick_random()), water_surface_emerge_animation.length)
			enabled_tween.tween_property(%LilypadSprite, "modulate",  Color(COLOR[Status.ENABLED].pick_random()), water_surface_emerge_animation.length)
			Utils.play_sound(Enum.SoundType.SFX, "lilypad-emerge")
			await enabled_tween.finished
			enabled_tween.kill()


		if _origin_status == Status.DISABLED and status == Status.ENABLED:
			%WaterAnim.play("RESET")
			status = Status.ENABLED
			_lilypad_animation_player.play("flower-timer")
			%Timer.start(status_duration)

			await %Timer.timeout

			%WaterAnim.animation_set_next("water-surface-emerge", "water-surface-still")
			%WaterAnim.play("water-surface-emerge", 1.0, true)
			var timer_tween = create_tween().set_parallel()
			timer_tween.tween_property(%LilyFlowerDecor, "modulate", Color(COLOR[Status.DISABLED].pick_random()), water_surface_emerge_animation.length)
			timer_tween.tween_property(%LilypadSprite, "modulate", Color(COLOR[Status.DISABLED].pick_random()), water_surface_emerge_animation.length)
			Utils.play_sound(Enum.SoundType.SFX, "lilypad-submerge")

			await timer_tween.finished
			status = Status.DISABLED
			timer_tween.kill()
			_lilypad_animation_player.animation_set_next("flower-timer", "flower-timer-disabled")
			_lilypad_animation_player.play("flower-timer", 1.0, true)

		if _origin_status == Status.ENABLED and status == Status.ENABLED:
			%WaterAnim.stop()
			%WaterAnim.clear_queue()
			status = Status.DISABLED
			var disabled_tween = create_tween().set_parallel()
			%WaterAnim.play("water-surface-emerge", 1.0, true)
			disabled_tween.tween_property(%LilyFlowerDecor, "modulate", Color(COLOR[Status.DISABLED].pick_random()), water_surface_emerge_animation.length)
			disabled_tween.tween_property(%LilypadSprite, "modulate",  Color(COLOR[Status.DISABLED].pick_random()), water_surface_emerge_animation.length)
			Utils.play_sound(Enum.SoundType.SFX, "lilypad-submerge")
			await disabled_tween.finished
			disabled_tween.kill()

		if _origin_status == Status.ENABLED and status == Status.DISABLED:
			%WaterAnim.play("water-surface-still")
			status = Status.DISABLED
			_lilypad_animation_player.play("flower-timer")
			%Timer.start(status_duration)

			await %Timer.timeout

			%WaterAnim.play("water-surface-emerge")
			var timer_tween = create_tween().set_parallel()
			timer_tween.tween_property(%LilyFlowerDecor, "modulate", Color(COLOR[Status.ENABLED].pick_random()), water_surface_emerge_animation.length)
			timer_tween.tween_property(%LilypadSprite, "modulate", Color(COLOR[Status.ENABLED].pick_random()), water_surface_emerge_animation.length)
			Utils.play_sound(Enum.SoundType.SFX, "lilypad-emerge")

			await timer_tween.finished
			status = Status.ENABLED
			timer_tween.kill()
			_lilypad_animation_player.animation_set_next("flower-timer", "flower-decor")
			_lilypad_animation_player.play("flower-timer", 1.0, true)


		if is_instance_valid(player):
			player = null
			print("Fell on unstable ground")
			# Play player drowning animation
			Utils.goto_game_over(Enum.Condition.COLLAPSED_TILE)


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Player):
		player = null
