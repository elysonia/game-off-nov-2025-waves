class_name Wave
extends Resource

@export var enemy_count: int = 10
@export var enemy_color: Color = Color.TEAL
@export var attacking_range: float = State.DEFAULT_ENEMY_ATTACKING_RANGE
@export var speed_map: Dictionary[Enum.EnemyAction, float] = {
    Enum.EnemyAction.STALKING: 20.0,
    Enum.EnemyAction.ATTACKING: 30.0
}
