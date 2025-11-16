class_name Game
extends Control

func _ready():
	%Player.player_landed.connect(_on_player_landed)

	var tiles = %GameArea.get_children().filter(
		func(child):
			return is_instance_of(child, Tile)
	)

	for tile in tiles:
		tile.add_to_group("tiles")


func _on_player_landed(player: Player) -> void:
	var tiles = get_tree().get_nodes_in_group("tiles")
	var is_game_ended = true

	for tile in tiles:
		if tile.player == player:
			is_game_ended = false
			player.is_on_tile = true
			tile.get_node("%Ripple").handle_ripple(player.jump_strength)
			break

	if is_game_ended:
		GlobalSignal.game_ended.emit()
		get_tree().paused = true

		# TODO: Replace with real game over screen
		var label = Label.new()
		label.text = "Game over"
		get_tree().root.add_child(label)
