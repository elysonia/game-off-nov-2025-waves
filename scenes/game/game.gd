class_name Game
extends Control


func _ready():
	%Player.player_landed.connect(_on_player_landed)
	call_deferred("setup_entities")


func setup_entities() -> void:
	var tiles = %GameArea.get_children().filter(
		func(child):
			return is_instance_of(child, Tile)
	)

	for tile in tiles:
		tile.add_to_group("tiles")

	var enemies = %GameArea.get_children().filter(
		func(child):
			return is_instance_of(child, Enemy)
	)

	for enemy in enemies:
		enemy.add_to_group("enemies")

	get_tree().call_group("enemies", "handle_switch_target_position", %Player.position)


func _on_player_landed(player: Player) -> void:
	var tiles = get_tree().get_nodes_in_group("tiles")
	get_tree().call_group("enemies", "handle_switch_target_position", player.position)

	var is_game_ended = true

	for tile in tiles:
		if tile.player == player and tile.status == tile.Status.ENABLED:
			is_game_ended = false
			tile.get_node("%Ripple").handle_ripple(player.jump_strength)
			break

	if is_game_ended:
		Utils.goto_game_over()
