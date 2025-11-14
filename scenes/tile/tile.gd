class_name Tile
extends Area2D


func _ready():
    area_entered.connect(_on_area_entered)
    body_entered.connect(_on_body_entered)
    %Ripple.handle_ripple(%CollisionShape2D)


func _on_area_entered(area: Area2D) -> void:
    pass


func _on_body_entered(body: Node2D) -> void:
    %Ripple.handle_ripple(%CollisionShape2D)

