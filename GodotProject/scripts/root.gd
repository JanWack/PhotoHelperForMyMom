extends Node

@export var file_dialog: FileDialog
@export var accept_dialog: AcceptDialog
@export var choose_in_dir: Button
@export var ui: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	file_dialog.dir_selected.connect(
		func(n: String):
			if n != "":
				Global.in_dir_name = n
				choose_in_dir.text = n
				var next_scene: PackedScene = load("res://image_handler.tscn")
				get_tree().change_scene_to_packed(next_scene)
			else:
				accept_dialog.popup()
	)
	
	ui.position.y += 100
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(ui, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(ui, "position", Vector2(0.0, 0.0), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_choose_dir_pressed() -> void:
	file_dialog.popup()


func _on_exit_pressed() -> void:
	get_tree().quit()
