# For global signals
extends Node

signal wave_completed
signal enemies_left_updated

signal item_spawned(item: ItemSprite)
signal item_collected(item: ItemSprite)

signal notification_shown(text: String)
