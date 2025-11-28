extends Node

const GRID_SIZE = 64
const DEFAULT_MAX_JUMPING_STRENGTH = 5.0
const DEFAULT_ENEMY_ATTACKING_RANGE = 3.0
const SPAWN_TOP_LEFT_BOUND = Vector2(-80, -80)
const SPAWN_BOTTOM_RIGHT_BOUND = Vector2(1352, 784)
const NOTIFICATION_DURATION = 5.0

# Level
var level: int = 1
var enemy_wave: int = 0
var enemies_left: int = 0
## Number of times the list of waves have been repeated
var enemy_wave_cycle: int = 0
var total_items: int = 0
var total_item_collected: int = 0
var items_spawned: int = 0

# Character
var max_jumping_strength: float = DEFAULT_MAX_JUMPING_STRENGTH
