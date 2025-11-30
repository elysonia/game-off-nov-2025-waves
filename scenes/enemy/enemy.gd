class_name Enemy
extends Area2D

const MODE_COLLISION = {
	Enum.EnemyAction.STALKING: 1,
	Enum.EnemyAction.ATTACKING: 2
}

const MODE_NAVIGATION = {
	Enum.EnemyAction.STALKING: 1,
	Enum.EnemyAction.ATTACKING: 2
}

var _mode: Enum.EnemyAction = Enum.EnemyAction.STALKING

@export var health: float = 1.0
@export var attacking_range: float = State.DEFAULT_ENEMY_ATTACKING_RANGE
@export var speed_map: Dictionary[Enum.EnemyAction, float] = {
	Enum.EnemyAction.STALKING: 20.0,
	Enum.EnemyAction.ATTACKING: 30.0
}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	handle_switch_mode(_mode)
	%NavigationAgent2D.velocity_computed.connect(_on_velocity_computed)
	%AnimationPlayer.play("spawning")


func _process(_delta: float) -> void:
	if State.is_level_end:
		process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(_delta: float) -> void:
	handle_navigate_to_target()


func load_data(data: Wave):
	attacking_range = data.attacking_range * State.enemy_wave_cycle
	speed_map = data.speed_map
	health = data.health * State.enemy_wave_cycle


func handle_switch_mode(next_mode: Enum.EnemyAction) -> void:
	if next_mode != _mode or not %AnimationPlayer.is_playing():
		if next_mode == Enum.EnemyAction.ATTACKING:
			%AnimationPlayer.play("attacking")
			var animation_length = %AnimationPlayer.get_animation("attacking").length
			%AnimationPlayer.seek(randf_range(0.0, animation_length))
			%AttackCollision.set_deferred("disabled", false)
			%AttackCollision.set_deferred("visible", true)
			%StalkCollision.set_deferred("disabled", true)
			%StalkCollision.set_deferred("visible", false)

		if next_mode == Enum.EnemyAction.STALKING:
			%AnimationPlayer.play("stalking")
			var animation_length = %AnimationPlayer.get_animation("attacking").length
			%AnimationPlayer.seek(randf_range(0.0, animation_length))
			%AttackCollision.set_deferred("disabled", true)
			%AttackCollision.set_deferred("visible", false)
			%StalkCollision.set_deferred("disabled", false)
			%StalkCollision.set_deferred("visible", true)

	var flip_h = position.direction_to(%NavigationAgent2D.target_position).x < 0
	%Attacking.flip_h = flip_h
	%Stalking.flip_h = flip_h
	%PlayerCaught.flip_h = flip_h
	%WaterSplash.flip_h = flip_h

	if flip_h:
		%PlayerCaught.offset = Vector2(-100, 0)
	else:
		%PlayerCaught.offset = Vector2(0, 0)

	if MODE_COLLISION[_mode] > 1:
		set_collision_layer_value(MODE_COLLISION[_mode], false)
		set_collision_mask_value(MODE_COLLISION[_mode], false)

	if MODE_NAVIGATION[_mode] > 1:
		%NavigationAgent2D.set_navigation_layer_value(MODE_NAVIGATION[_mode], false)

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

	var speed: float
	if _mode == Enum.EnemyAction.ATTACKING:
		speed =  randf_range(speed_map[_mode] - 3, speed_map[Enum.EnemyAction.ATTACKING] + 5)
	if _mode == Enum.EnemyAction.STALKING:
		speed =  randf_range(speed_map[_mode] - 3, speed_map[Enum.EnemyAction.ATTACKING] - 1)

	speed *= State.enemy_wave_cycle
	var next_position: Vector2 = %NavigationAgent2D.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_position) * speed
	%NavigationAgent2D.velocity = new_velocity


func handle_damage(damage: float, knockback: Vector2 = Vector2.ZERO) -> void:
	Utils.play_sound(Enum.SoundType.SFX, "hurt")
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color("#ff1e21"), 0.1)
	tween.tween_property(self, "modulate", Color("#ffffff"), 0.1)
	tween.tween_property(self, "modulate", Color("#ff1e21"), 0.1)
	tween.tween_property(self, "modulate", Color("#ffffff"), 0.1)
	await tween.finished
	tween.kill()

	health -= damage

	if health <= 0:
		handle_death()
	else:
		position += knockback * get_physics_process_delta_time()


func handle_death() -> void:
	State.enemies_left -= 1
	GlobalSignal.enemies_left_updated.emit()
	# Play death anim here and wait
	queue_free()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	position += safe_velocity * get_physics_process_delta_time()


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player) and _mode == Enum.EnemyAction.ATTACKING:
		print("caught by enemy")
		%AnimationPlayer.play("caught-player")
		Utils.play_sound(Enum.SoundType.SFX, "caught-player")
		body.visible = false
		body.process_mode = Node.PROCESS_MODE_DISABLED
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
		z_index = 100
		collision_layer = 0
		collision_mask = 0
		var tween = create_tween().set_parallel()
		tween.tween_property(self, "position", body.position, 2)
		await tween.finished
		tween.kill()
		process_mode = Node.PROCESS_MODE_DISABLED
		Utils.goto_game_over(Enum.Condition.CAPTURED)


func _on_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Tile) and area.get_node("%Ripple").is_rippling:
		var damage = area.power * area.get_node("%Ripple").ripple_strength
		var knockback = area.position.direction_to(position) * damage * area.get_node("%Ripple").knockback_force / area.knockback_dampening
		handle_damage(damage, knockback)
