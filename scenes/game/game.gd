class_name Game
extends Control

var _level_data: Level = null
var _spawn_positions: Array[Vector2]

@onready var _enemy = preload("res://scenes/enemy/enemy.tscn")


func _ready():
	%Player.player_landed.connect(_on_player_landed)
	%WaveTimer.timeout.connect(_on_wave_timer_timeout)
	GlobalSignal.enemies_left_updated.connect(_on_enemies_left_updated)

	set_physics_process(false)
	initialize()
	call_deferred("_post_ready")


func initialize() -> void:
	_level_data = LevelManager.get_level(State.level)

	State.level = _level_data.level
	State.enemy_wave = 1
	State.max_enemy_wave = len(_level_data.waves)

	var tiles = %Tiles.get_children()
	for tile in tiles:
		tile.add_to_group("tiles")

	var wave = _level_data.waves[State.enemy_wave - 1]

	_spawn_positions.assign(wave.get_spawn_positions(50))

	handle_load_wave(wave)
	get_tree().call_group("enemies", "handle_switch_target_position", %Player.position)


func handle_load_wave(wave: Wave) -> void:
	State.enemy_left += wave.enemy_count

	for i in range(wave.enemy_count):
		var enemy_instance = _enemy.instantiate()
		enemy_instance.position = _spawn_positions.pick_random()
		enemy_instance.load_data(wave)
		enemy_instance.add_to_group("enemies")
		await %GameArea.call_deferred("add_child", enemy_instance)
		enemy_instance.call_deferred("handle_switch_target_position", %Player.position)

	%WaveTimer.start(wave.duration)
	GlobalSignal.enemies_left_updated.emit()


func _on_player_landed(player: Player) -> void:
	var tiles = get_tree().get_nodes_in_group("tiles")
	get_tree().call_group("enemies", "handle_switch_target_position", player.position)

	var is_game_ended = true

	for tile in tiles:
		if tile.player == player and tile.status == tile.Status.ENABLED:
			is_game_ended = false
			tile.get_node("%Ripple").handle_ripple(player.jump_strength)
			player.handle_switch_status(player.Status.IDLE)
			# Play player landing animation
			break

	if is_game_ended:
		print("missed the landing")
		# Play player drowning animation
		Utils.goto_game_over()


func _on_wave_timer_timeout() -> void:
	if State.enemy_wave == State.max_enemy_wave:
		return

	State.enemy_wave += 1
	handle_load_wave(_level_data.waves[State.enemy_wave - 1])


func _on_enemies_left_updated() -> void:
	%EnemiesLeft.text = str(State.enemy_left)
	if State.enemy_left == 0:
		if State.enemy_wave == State.max_enemy_wave:
			Utils.goto_game_won()
		else:
			State.enemy_wave += 1
			handle_load_wave(_level_data.waves[State.enemy_wave - 1])


func _post_ready() -> void:
	set_physics_process(true)

