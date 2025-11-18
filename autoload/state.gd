extends Node

const GRID_SIZE = 64
const DEFAULT_MAX_JUMPING_STRENGTH = 5.0
const DEFAULT_ENEMY_ATTACKING_RANGE = 3.0
const SPAWN_TOP_LEFT_BOUND = Vector2(-80, -80)
const SPAWN_BOTTOM_RIGHT_BOUND = Vector2(1352, 784)


## Level
var level: int = 1
var enemy_wave: int = 0
var max_enemy_wave: int = 0
var enemy_left: int = 0

## Character
var max_jumping_strength: float = DEFAULT_MAX_JUMPING_STRENGTH
