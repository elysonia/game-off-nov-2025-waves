class_name ItemSprite
extends Area2D

var _tile: Tile
var item_data: Item

func _ready():
    body_entered.connect(_on_body_entered)

func initialize(item: Item, tile: Tile) -> void:
    item_data = item
    %Sprite2D.texture = load(item.texture)
    %ItemAnim.play("idle")
    _tile = tile
    GlobalSignal.item_spawned.emit(self)


func _on_body_entered(body: Node2D) -> void:
    if is_instance_of(body, Player) and _tile.status == _tile.Status.ENABLED:
        Utils.play_sound(Enum.SoundType.SFX, "item-pickup")
        State.total_item_collected += 1
        GlobalSignal.item_collected.emit(self)
        queue_free()
