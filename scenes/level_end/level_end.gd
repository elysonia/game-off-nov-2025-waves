extends Control


func initialize(result: Enum.Result, condition: Enum.Condition = Enum.Condition.ALIVE) -> void:
    var condition_text = get_condition_text(condition)
    var result_text = get_result_text(result)

    var formatted_string = "[font_size={24}][b][color={color}]{result}[/color][/b][/font_size]\n{condition}".format(
       { "color": "#000000",
        "result": result_text,
        "condition": condition_text,}
    )

    %Text.text = formatted_string



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
