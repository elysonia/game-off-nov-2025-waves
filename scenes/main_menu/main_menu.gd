class_name MainMenu
extends Control

var _is_button_mouse_entered: bool = false

func _ready():
    %FrogArea.mouse_entered.connect(_on_frog_area_mouse_entered)
    %FrogArea.mouse_exited.connect(_on_frog_area_mouse_exited)
    %Play.mouse_entered.connect(_on_button_mouse_entered)
    %Play.mouse_exited.connect(_on_button_mouse_exited)
    %Levels.mouse_entered.connect(_on_button_mouse_entered)
    %Levels.mouse_exited.connect(_on_button_mouse_exited)
    %Options.mouse_entered.connect(_on_button_mouse_entered)
    %Options.mouse_exited.connect(_on_button_mouse_exited)

    %Play.pressed.connect(_on_play_pressed)
    %Levels.pressed.connect(_on_levels_pressed)
    %Options.pressed.connect(_on_options_pressed)


    %Frog.play("idle")
    %Croc.play("stalk")
    %Croc2.play("stalk")
    %MenuContainer.visible = false
    handle_croc_movement(%Croc)
    handle_croc_movement(%Croc2)


func handle_croc_movement(croc: Node2D) -> void:
    var direction: Vector2
    var flip_h
    if croc.position.x < 200:
        flip_h = false
        direction = Vector2.RIGHT

    if croc.position.x > 1100.0:
        flip_h = true
        direction = Vector2.LEFT

    var tween = croc.create_tween().set_loops()
    tween.tween_property(croc, "flip_h", flip_h, 0.5)
    tween.tween_property(croc, "position", Vector2(croc.position.x + 400 * direction.x, croc.position.y), 15)
    tween.tween_property(croc, "flip_h", not flip_h, 0.5)
    tween.tween_property(croc, "position", Vector2(croc.position.x - 400 * direction.x, croc.position.y), 15)
    tween.tween_interval(2.0)


func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("lmb") and not _is_button_mouse_entered:
        %MenuContainer.visible = false
        _on_frog_area_mouse_exited()


func _on_frog_area_mouse_entered() -> void:
    %Frog.play("ready")
    %Croc.play("attack")
    %Croc2.play("attack")
    %MenuContainer.visible = true


func _on_frog_area_mouse_exited() -> void:
    if %MenuContainer.visible:
        return

    %Frog.play("idle")
    %Croc.play("stalk")
    %Croc2.play("stalk")


func _on_play_pressed() -> void:
    Utils.goto_level(State.level)


func _on_levels_pressed() -> void:
    pass


func _on_options_pressed() -> void:
    pass


func _on_button_mouse_entered() -> void:
    _is_button_mouse_entered = true


func _on_button_mouse_exited() -> void:
    _is_button_mouse_entered = false
