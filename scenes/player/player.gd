class_name Player
extends CharacterBody2D

signal player_jumped(player: Player)
signal player_landed(player: Player)

enum Status {IDLE, READY, JUMPING, LANDING, MIDAIR_DOWN, MIDAIR_UP}

const STATUS_ANIMATION = {
	Status.IDLE: "idle",
	Status.READY: "ready",
	Status.JUMPING: "jumping",
	Status.LANDING: "landing",
	Status.MIDAIR_DOWN: "midair-down",
	Status.MIDAIR_UP: "midair-up"
}

var _next_position: Vector2 = Vector2.ZERO

var status: Status = Status.IDLE
var max_jump_strength: float = State.max_jumping_strength
var jump_strength: float = 0.0

func _ready():
	handle_switch_status(Status.IDLE)


func handle_switch_status(next_status: Status) -> void:
	status = next_status

	if next_status == Status.LANDING:
		Utils.play_sound(Enum.SoundType.SFX, "player-landing")
		%AnimationPlayer.animation_set_next(STATUS_ANIMATION[next_status], STATUS_ANIMATION[Status.IDLE])
		status = Status.IDLE

	if next_status == Status.JUMPING:
		var sound_name = "jump-{number}".format({"number": randi_range(1, 3)})
		Utils.play_sound(Enum.SoundType.SFX, sound_name)
		%AnimationPlayer.animation_set_next(STATUS_ANIMATION[next_status], STATUS_ANIMATION[Status.MIDAIR_DOWN])

	%AnimationPlayer.play(STATUS_ANIMATION[next_status])


func handle_jump(to: Vector2) -> void:
	var tween = create_tween().set_parallel()
	player_jumped.emit(self)
	handle_switch_status(Status.JUMPING)
	%AnimationPlayer.speed_scale = 2
	tween.tween_property(self, "position", to, 0.13 * jump_strength).set_ease(Tween.EASE_OUT_IN)
	await tween.finished
	%AnimationPlayer.speed_scale = 1
	tween.kill()
	player_landed.emit(self)
	_next_position = Vector2.ZERO


func _draw():
	if Input.is_action_pressed("lmb"):
		var line_mouse_position = get_local_mouse_position()
		var next_jump_strength = Vector2.ZERO.distance_to(line_mouse_position) / State.GRID_SIZE
		jump_strength = next_jump_strength if next_jump_strength <= max_jump_strength else max_jump_strength
		var line_end_position = line_mouse_position.normalized() * (jump_strength * State.GRID_SIZE)
		draw_dashed_line(Vector2.ZERO, line_end_position, Color(0,0,0, 1), 5)
		_next_position = to_global(line_end_position)

	if Input.is_action_just_released("lmb"):
		draw_dashed_line(Vector2.ZERO, Vector2.ZERO, Color(1, 1, 1, 0))


func _process(_delta: float) -> void:
	if Input.is_action_pressed("lmb"):
		if status == Status.IDLE:
			handle_switch_status(Status.READY)
		if status == Status.READY:
			queue_redraw()

	if Input.is_action_just_released("lmb"):
		queue_redraw()
		if _next_position != Vector2.ZERO:
			handle_jump(_next_position)
		else:
			handle_switch_status(Status.IDLE)
