extends TextureRect
class_name CustomTextureRect

@export var button: Button
@export var selected_indicator: PanelContainer

var img_path: StringName
var img_dir: StringName
var img_name: StringName
var keep: bool = false


func _on_button_pressed() -> void:
	Global.preview_img.emit(self)
