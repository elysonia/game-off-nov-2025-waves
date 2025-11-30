extends Node

## STALKING: Enemy is outside of attacking range
## ATTACKING: Enemy is within attacking range
enum EnemyAction {STALKING, ATTACKING}

enum SoundType {BGM, BGS, SFX, MFX}

enum Result {LOSE, WIN}
enum Condition {ALIVE, CAPTURED, DROWNED, COLLAPSED_TILE}
