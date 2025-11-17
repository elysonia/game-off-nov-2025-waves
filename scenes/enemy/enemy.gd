class_name Enemy
extends CharacterBody2D

enum Mode {STALKING, ATTACKING}

const DEFAULT_ATTACKING_RANGE = 5.0

# TODO: Replace with actual image
# const MODE_IMG = {
#     Mode.STALKING: %Stalking,
#     Mode.ATTACKING: %Attacking
# }

const MODE_COLLISION = {
    Mode.STALKING: 1,
    Mode.ATTACKING: 2
}

const MODE_SPEED = {
    Mode.STALKING: 20,
    Mode.ATTACKING: 30
}

var _mode_img = {
    Mode.STALKING: null,
    Mode.ATTACKING: null
}
var _mode: Mode = Mode.STALKING

@export var attacking_range: float = DEFAULT_ATTACKING_RANGE
@export var speed: float = 20


func _ready() -> void:
    _mode_img[Mode.STALKING] = %Stalking
    _mode_img[Mode.ATTACKING] = %Attacking
    %NavigationAgent2D.velocity_computed.connect(_on_velocity_computed)


func _physics_process(_delta: float) -> void:
    handle_navigate_to_target()


func handle_switch_mode(next_mode: Mode) -> void:
    # TODO: Use MODE_IMG after assets are made
    _mode_img[_mode].visible = false
    _mode = next_mode
    _mode_img[_mode].visible = true
    collision_layer = MODE_COLLISION[_mode]
    collision_mask = MODE_COLLISION[_mode]


func handle_switch_target_position(target_position: Vector2) -> void:
    %NavigationAgent2D.target_position = target_position


func handle_navigate_to_target() -> void:
    # if %NavigationAgent2D.is_navigation_finished():
        # TODO: Check if it collided with Player here
        # If yes, game over.
        # If not, idk.
        # return
    if position.distance_to(%NavigationAgent2D.target_position) / State.GRID_SIZE <= attacking_range:
        handle_switch_mode(Mode.ATTACKING)
    else:
        handle_switch_mode(Mode.STALKING)
    var next_position: Vector2 = %NavigationAgent2D.get_next_path_position()
    var new_velocity = global_position.direction_to(next_position) * MODE_SPEED[_mode]
    %NavigationAgent2D.velocity = new_velocity
    # move_and_slide()
    # sprite_holder.rotation = velocity.angle()



func _on_velocity_computed(safe_velocity: Vector2) -> void:
    velocity = safe_velocity
    move_and_slide()
    # sprite_holder.rotation = velocity.angle()

