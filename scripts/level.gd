class_name Level
extends Resource

@export var level: int = 1

@export_category("Wave settings")
@export var waves: Array[Wave]

@export_category("Item settings")
@export var items: Array[Item]
@export var max_concurrent_items: int = 3
