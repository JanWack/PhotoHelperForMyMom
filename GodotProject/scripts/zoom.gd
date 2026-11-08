extends Control

@export var preview: TextureRect

var edges: Array[Vector2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edges.resize(4)
	
	Global.preview_img.connect(
		func(_img: CustomTextureRect):
			preview.position = Vector2.ZERO
			preview.scale = Vector2.ONE
			calculate_edges()
	)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		if preview.scale != Vector2(4.0, 4.0):
			preview.pivot_offset = get_local_mouse_position()
			preview.scale *= 1.1
			preview.scale = clamp(preview.scale, Vector2.ONE, Vector2(4.0, 4.0))
			calculate_edges()
	elif Input.is_action_just_pressed("zoom_out"):
		preview.scale *= 0.9
		preview.scale = clamp(preview.scale, Vector2.ONE, Vector2(4.0, 4.0))
		calculate_edges()


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("grab"):
		if event is InputEventMouseMotion:
			preview.position += event.relative


func calculate_edges() -> void:
	for i in 4:
		match i:
			0:
				edges[0] = preview.global_position
			1:
				edges[1] = Vector2(preview.global_position.x, preview.global_position.y + preview.size.y)
			2:
				edges[2] = Vector2(preview.global_position.x + preview.size.x, preview.global_position.y + preview.size.y)
			3:
				edges[3] = Vector2(preview.global_position.x + preview.size.x, preview.global_position.y)
	
	fix_zoom()


func fix_zoom() -> void:
	print(edges)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
