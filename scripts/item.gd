class_name Item
extends Resource


@export var name: String = ""
@export_file("*.png") var texture: String = ""
@export var description: String = ""
## Time to wait before spawning the next item. Does not replace this item.
@export var interval_to_next_item: float = 10.0
