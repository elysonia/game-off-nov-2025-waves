class_name PreviewDetail
extends HBoxContainer


func initialize(item_name: String, texture: String, count: int) -> void:
    %TextureRect.texture = load(texture)
    %RichTextLabel.text = item_name + " X " + str(count)
