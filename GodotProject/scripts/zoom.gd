extends Control

@export var preview: TextureRect
@export var preview_panel: PanelContainer

var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.preview_img.connect(
		func(_img: CustomTextureRect):
			preview_panel.position = Vector2.ZERO
			preview_panel.scale = Vector2.ONE
	)


func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos: Vector2 = preview_panel.get_local_mouse_position()
	if self.get_rect().has_point(mouse_pos):
		if Input.is_action_just_pressed("zoom_in"):
			if preview_panel.scale != Vector2(4.0, 4.0):
				preview_panel.scale *= 1.1
				preview_panel.scale = clamp(preview_panel.scale, Vector2.ONE, Vector2(4.0, 4.0))
		elif Input.is_action_just_pressed("zoom_out"):
			preview_panel.scale *= 0.9
			preview_panel.scale = clamp(preview_panel.scale, Vector2.ONE, Vector2(4.0, 4.0))
			if preview_panel.scale == Vector2.ONE:
				preview_panel.position = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = preview_panel.get_local_mouse_position()
		if self.get_rect().has_point(mouse_pos):
			preview_panel.pivot_offset = preview_panel.get_local_mouse_position()


func _on_mouse_exited() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(preview_panel, "position", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(preview_panel, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
