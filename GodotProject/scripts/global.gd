extends Node

@warning_ignore("unused_signal")
signal preview_img(img: CustomTextureRect)
@warning_ignore("unused_signal")
signal loaded

var in_dir_name: StringName
var out_dir_name: StringName


func _ready() -> void:
	in_dir_name = ""
	out_dir_name = ""
