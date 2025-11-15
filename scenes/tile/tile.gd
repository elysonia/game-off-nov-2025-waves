class_name Tile
extends Area2D

enum Status {ENABLED, DISABLED}
const COLOR = {
    Status.ENABLED: "#b9f84f",
    Status.DISABLED: "#111c02",
}

var _is_mouse_entered: bool = false

@export var status: Status = Status.ENABLED

@export var is_status_fixed: bool = true


func _ready():
    area_entered.connect(_on_area_entered)
    body_entered.connect(_on_body_entered)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    %Polygon2D.color = COLOR[status]

    # Make sure the collision shape of the instantiated scene is unique
    # https://forum.godotengine.org/t/collisionshape2d-changes-for-every-instance-with-every-instance/95614/2
    %CollisionShape2D.shape =  %CollisionShape2D.shape.duplicate(true)
    %Ripple.initialize(%CollisionShape2D)


func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("lmb") and _is_mouse_entered:
        if status == Status.ENABLED and is_status_fixed:
            %Ripple.handle_ripple()


func _on_area_entered(area: Area2D) -> void:
    if not is_instance_of(area, Tile) or status == Status.ENABLED:
        return

    status = Status.ENABLED
    %Polygon2D.color = COLOR[status]


func _on_body_entered(body: Node2D) -> void:
    pass


func _on_mouse_entered() -> void:
    _is_mouse_entered = true


func _on_mouse_exited() -> void:
    _is_mouse_entered = false
