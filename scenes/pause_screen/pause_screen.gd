extends Control


func _ready():
    %Resume.pressed.connect(_on_resume_pressed)
    %MainMenu.pressed.connect(_on_main_menu_pressed)
    %Restart.pressed.connect(_on_restart_pressed)
    %Levels.pressed.connect(_on_levels_pressed)
    %Options.pressed.connect(_on_options_pressed)


func _on_main_menu_pressed() -> void:
    Utils.goto_main_menu()


func _on_restart_pressed() -> void:
    Utils.goto_level(State.level)


func _on_levels_pressed() -> void:
    Utils.goto_levels()


func _on_options_pressed() -> void:
    Utils.goto_options()


func _on_resume_pressed() -> void:
    visible = false
    get_tree().paused = false
    queue_free()
