class_name Enemy
extends CharacterBody2D

# TODO: Replace with actual image
# const MODE_IMG = {
#     Enum.EnemyAction.STALKING: %Stalking,
#     Enum.EnemyAction.ATTACKING: %Attacking
# }

const MODE_COLLISION = {
	Enum.EnemyAction.STALKING: 1,
	Enum.EnemyAction.ATTACKING: 2
}

const MODE_NAVIGATION = {
	Enum.EnemyAction.STALKING: 1,
	Enum.EnemyAction.ATTACKING: 2
}

var _mode_img = {
	Enum.EnemyAction.STALKING: null,
	Enum.EnemyAction.ATTACKING: null
}
var _mode: Enum.EnemyAction = Enum.EnemyAction.STALKING

@export var attacking_range: float = State.DEFAULT_ENEMY_ATTACKING_RANGE
@export var speed_map: Dictionary[Enum.EnemyAction, float] = {
	Enum.EnemyAction.STALKING: 20.0,
	Enum.EnemyAction.ATTACKING: 30.0
}


func _ready() -> void:
	_mode_img[Enum.EnemyAction.STALKING] = %Stalking
	_mode_img[Enum.EnemyAction.ATTACKING] = %Attacking
	handle_switch_mode(_mode)
	%NavigationAgent2D.velocity_computed.connect(_on_velocity_computed)

	# TODO: Switch to MODE_IMG after assets are made
	for node in _mode_img.values():
		node.visible = false


func _physics_process(_delta: float) -> void:
	handle_navigate_to_target()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if is_instance_of(collider, Player) and _mode == Enum.EnemyAction.ATTACKING:
			Utils.goto_game_over()


func load_data(data: Wave):
	modulate = Color(data.enemy_color)
	attacking_range = data.attacking_range
	speed_map = data.speed_map


func handle_switch_mode(next_mode: Enum.EnemyAction) -> void:
	# TODO: Use MODE_IMG after assets are made

	_mode_img[_mode].visible = false

	if MODE_COLLISION[_mode] > 1:
		set_collision_layer_value(MODE_COLLISION[_mode], false)
		set_collision_mask_value(MODE_COLLISION[_mode], false)

	if MODE_NAVIGATION[_mode] > 1:
		%NavigationAgent2D.set_navigation_layer_value(MODE_NAVIGATION[_mode], false)

	_mode_img[next_mode].visible = true

	if is_instance_of(%CollisionShape, CollisionPolygon2D):
		%CollisionShape.polygon = _mode_img[next_mode].polygon

	set_collision_layer_value(MODE_COLLISION[next_mode], true)
	set_collision_mask_value(MODE_COLLISION[next_mode], true)
	%NavigationAgent2D.set_navigation_layer_value(MODE_NAVIGATION[next_mode], true)
	_mode = next_mode


func handle_switch_target_position(target_position: Vector2) -> void:
	%NavigationAgent2D.target_position = target_position


func handle_navigate_to_target() -> void:
	if %NavigationAgent2D.is_navigation_finished():

		return

	if position.distance_to(%NavigationAgent2D.target_position) / State.GRID_SIZE <= attacking_range:
		handle_switch_mode(Enum.EnemyAction.ATTACKING)
	else:
		handle_switch_mode(Enum.EnemyAction.STALKING)
	var next_position: Vector2 = %NavigationAgent2D.get_next_path_position()
	var new_velocity = global_position.direction_to(next_position) * speed_map[_mode]
	%NavigationAgent2D.velocity = new_velocity
	# sprite_holder.rotation = velocity.angle()

func handle_death() -> void:
	State.enemy_left -= 1
	GlobalSignal.enemies_left_updated.emit()
	# Play death anim here and wait
	queue_free()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	# sprite_holder.rotation = velocity.angle()
