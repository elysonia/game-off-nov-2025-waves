class_name AnimatedButton
extends Button

func _ready():
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)

	pressed.connect(_on_pressed)


func _on_focus_entered() -> void:
	Utils.play_sound(Enum.SoundType.SFX, "button-hover")
	%ButtonAnim.play("hover")
	%FlowerAnim.play("hover")


func _on_focus_exited() -> void:
	%ButtonAnim.play_backwards("hover")
	%FlowerAnim.play_backwards("hover")
	await %ButtonAnim.animation_finished
	%FlowerAnim.stop()


func _on_pressed() -> void:
	Utils.play_sound(Enum.SoundType.SFX, "button-click")
	%ButtonAnim.play("click")
