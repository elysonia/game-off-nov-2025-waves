class_name Wave
extends Resource


## Number of enemy in this wave
@export var enemy_count: int = 10
## Modulate color of enemy in this wave
@export var enemy_color: Color = Color.TEAL
## Time to wait before spawning the next wave
@export var duration: float = 10.0

@export_category("Health")
## Enemy health this wave
@export var health: float = 1.0
## Health scaling when the wave is loaded after the first time
@export var health_increment_per_cycle: float = 10.0
## Maximum reachable health
@export var max_health: float = 50.0

@export_category("Actions")
## Enemy attacking range
@export var attacking_range: float = State.DEFAULT_ENEMY_ATTACKING_RANGE
## After the first load
@export var attacking_range_increment: float = 0.1

## Movement speed of enemy at each action
@export var speed_map: Dictionary[Enum.EnemyAction, float] = {
    Enum.EnemyAction.STALKING: 30.0,
    Enum.EnemyAction.ATTACKING: 40.0
}
## After the first load
@export var speed_increment_map: Dictionary[Enum.EnemyAction, float] = {
    Enum.EnemyAction.STALKING: 1.0,
    Enum.EnemyAction.ATTACKING: 1.0
}


func get_valid_spawn_position() -> Vector2:
    var x = Utils.get_valid_value_in_range(State.SPAWN_TOP_LEFT_BOUND.x, State.SPAWN_BOTTOM_RIGHT_BOUND.x, 0, 1280)
    var y = Utils.get_valid_value_in_range(State.SPAWN_TOP_LEFT_BOUND.y, State.SPAWN_BOTTOM_RIGHT_BOUND.y, 0, 720)
    return Vector2(x, y)


func get_spawn_positions(count: int) -> Array[Vector2]:
    var spawn_positions: Array[Vector2] = []

    for _i in count:
        spawn_positions.append(get_valid_spawn_position())

    return spawn_positions
