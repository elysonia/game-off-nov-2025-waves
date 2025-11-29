extends Control


func _ready():
    %NextLevel.pressed.connect(_on_next_level_pressed)
    %Restart.pressed.connect(_on_restart_pressed)


func initialize(result: Enum.Result, condition: Enum.Condition = Enum.Condition.ALIVE) -> void:
    var condition_text = get_condition_text(condition)
    var result_text = get_result_text(result)

    var formatted_string = "[font_size={24}][b][color={color}]{result}[/color][/b][/font_size]\n{condition}".format(
       {
            "color": "#000000",
            "result": result_text,
            "condition": condition_text
        }
    )

    %Text.text = formatted_string
    var is_last_level = State.level >= LevelManager.MAX_LEVEL
    if is_last_level:
        %NextLevel.queue_free()


func get_result_text(result: Enum.Result) -> String:
    match (result):
        Enum.Result.LOSE:
            return "Failed"
    return "Success"


func get_condition_text(condition: Enum.Condition) -> String:
    match (condition):
        Enum.Condition.CAPTURED:
            return "Became croc feed"
        Enum.Condition.DROWNED:
            return "Missed a landing"
        Enum.Condition.COLLAPSED_TILE:
            return "Didn't jump in time"
    return "Stayed intact"


func _on_restart_pressed() -> void:
    Utils.goto_level(State.level)


func _on_next_level_pressed() -> void:
    var next_level = State.level + 1
    Utils.goto_level(next_level)
