class_name Game
extends Control

var _level_data: Level = null
var _spawn_positions: Array[Vector2]

@onready var _enemy = preload("res://scenes/enemy/enemy.tscn")


func _ready():
	%Player.player_landed.connect(_on_player_landed)
	%WaveTimer.timeout.connect(_on_wave_timer_timeout)
	%ItemTimer.timeout.connect(_on_item_timer_timeout)

	GlobalSignal.item_collected.connect(_on_item_collected)
	GlobalSignal.enemies_left_updated.connect(_on_enemies_left_updated)
	Utils.play_sound(Enum.SoundType.BGM, "bgm-1")
	set_physics_process(false)
	initialize()
	call_deferred("_post_ready")


func initialize() -> void:
	_level_data = LevelManager.get_level(State.level)

	State.level = _level_data.level
	State.enemy_wave = 1
	State.total_items = len(_level_data.items)

	var tiles = %Tiles.get_children()
	for tile in tiles:
		tile.add_to_group("tiles")

	var wave = _level_data.waves[State.enemy_wave - 1]

	_spawn_positions.assign(wave.get_spawn_positions(50))

	handle_load_wave(wave)
	call_deferred("handle_load_item")
	get_tree().call_group("enemies", "handle_switch_target_position", %Player.position)


func handle_load_wave(wave: Wave) -> void:
	State.enemies_left += wave.enemy_count

	for i in range(wave.enemy_count):
		var enemy_instance = _enemy.instantiate()
		enemy_instance.position = _spawn_positions.pick_random()
		enemy_instance.load_data(wave)
		enemy_instance.add_to_group("enemies")
		await %Enemies.call_deferred("add_child", enemy_instance)
		enemy_instance.call_deferred("handle_switch_target_position", %Player.position)

	%WaveTimer.start(wave.duration)
	GlobalSignal.enemies_left_updated.emit()


func handle_load_item() -> void:
	var tiles = get_tree().get_nodes_in_group("tiles").filter(
		func (tile):
			var does_tile_have_item = is_instance_valid(tile.tile_item)
			var does_tile_have_player = is_instance_valid(tile.player)
			return not does_tile_have_item and not does_tile_have_player
	)

	var item_tile = tiles.pick_random()
	var next_item = _level_data.items[State.items_spawned]
	item_tile.handle_load_item(next_item)
	State.items_spawned += 1
	%ItemTimer.start(next_item.interval_to_next_item)


func _post_ready() -> void:
	set_physics_process(true)


func _on_player_landed(player: Player) -> void:
	var tiles = get_tree().get_nodes_in_group("tiles")

	var is_game_ended = true

	for tile in tiles:
		if tile.player == player and tile.status == tile.Status.ENABLED:
			is_game_ended = false
			tile.get_node("%Ripple").handle_ripple(player.jump_strength)
			player.handle_switch_status(player.Status.LANDING)
			break

	if is_game_ended:
		print("missed the landing")
		# TODO: Play player drowning animation
		var tween = player.create_tween()
		tween.tween_property(player, "modulate", Color("#ff1e21"), 0.1)
		tween.tween_property(player, "modulate", Color("#ffffff"), 0.1)
		tween.tween_property(player, "modulate", Color("#ff1e21"), 0.1)
		tween.tween_property(player, "modulate", Color("#ffffff"), 0.1)
		await tween.finished
		tween.kill()
		Utils.goto_game_over(Enum.Condition.DROWNED)

	get_tree().call_group("enemies", "handle_switch_target_position", player.position)


func _on_wave_timer_timeout() -> void:
	if State.enemies_left >= _level_data.max_concurrent_enemies:
		return

	var next_wave: int
	var total_waves = len(_level_data.waves)

	if State.enemy_wave == total_waves:
		next_wave = 1
	else:
		next_wave = State.enemy_wave + 1

	var next_wave_index: int = next_wave - 1
	var next_wave_data: Wave = _level_data.waves[next_wave_index]
	var should_spawn_new_wave = State.enemies_left + next_wave_data.enemy_count <= _level_data.max_concurrent_enemies

	if should_spawn_new_wave:
		handle_load_wave(next_wave_data)

	if next_wave_index == total_waves:
		State.enemy_wave_cycle += 1

	State.enemy_wave = next_wave


func _on_item_timer_timeout() -> void:
	var is_all_items_spawned = State.total_items == State.items_spawned
	var is_max_concurrent_items = State.total_item_collected - State.items_spawned >= _level_data.max_concurrent_items
	var is_all_items_collected = State.total_items == State.total_item_collected

	var should_spawn_new_item = (not is_all_items_spawned and not is_max_concurrent_items) and not is_all_items_collected
	if not should_spawn_new_item:
		var current_item = _level_data.items[State.items_spawned - 1]
		%ItemTimer.start(current_item.interval_to_next_item)
		return

	handle_load_item()


func _on_enemies_left_updated() -> void:
	if State.enemies_left == 0:
		_on_wave_timer_timeout()


func _on_item_collected(_item: ItemSprite) -> void:
	if State.total_item_collected == State.total_items:
		Utils.goto_game_won()
