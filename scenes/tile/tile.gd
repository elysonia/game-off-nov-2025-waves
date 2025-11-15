class_name Tile
extends Area2D

enum Status {ENABLED, DISABLED}
const COLOR = {
    Status.ENABLED: "#b9f84f",
    Status.DISABLED: "#111c02",
}

var _is_mouse_entered: bool = false
var _default_status: Status = Status.ENABLED

@export var status: Status = Status.ENABLED
## Status duration when is_status_fixed is false
@export var status_duration: float = 10.0

## True if the status is fixed, false if modifiable by interaction
@export var is_status_fixed: bool = true


func _ready():
    area_entered.connect(_on_area_entered)
    body_entered.connect(_on_body_entered)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

    _default_status = status
    %Polygon2D.color = COLOR[status]

    # Make sure the collision shape of the instantiated scene is unique
    # https://forum.godotengine.org/t/collisionshape2d-changes-for-every-instance-with-every-instance/95614/2
    %CollisionShape2D.shape =  %CollisionShape2D.shape.duplicate(true)
    %Ripple.initialize(%CollisionShape2D)


func _on_area_entered(area: Area2D) -> void:
    var should_change_status = status == _default_status and not is_status_fixed
    if not is_instance_of(area, Tile) or not should_change_status:
        return

    status = Status.ENABLED
    %Polygon2D.color = COLOR[status]

    if not is_status_fixed:
        await get_tree().create_timer(status_duration).timeout
        status = _default_status
        %Polygon2D.color = COLOR[status]


func _on_body_entered(body: Node2D) -> void:
    if not is_instance_of(body, Player):
        return

    %Ripple.handle_ripple(body.jump_strength)


func _on_mouse_entered() -> void:
    _is_mouse_entered = true


func _on_mouse_exited() -> void:
    _is_mouse_entered = false
