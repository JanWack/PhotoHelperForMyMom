extends Thread
class_name CustomThread

var img_scene: PackedScene = preload("res://img.tscn")

var terminated: bool = false


func is_terminated() -> bool:
	return terminated


func stop() -> void:
	terminated = true


func parse_images(input_images: VBoxContainer) -> void:
	self.start(load_images.bind(input_images))


func load_images(input_images: VBoxContainer) -> void:
	var dir: DirAccess = DirAccess.open(Global.in_dir_name)
	if dir:
		var image_extensions := ["png", "jpg", "jpeg"]
		dir.list_dir_begin()
		for file: StringName in dir.get_files():
			if file.get_extension().to_lower() in image_extensions:
				var img_path: StringName = str(dir.get_current_dir() + "/" + file)
				var img: Image = Image.new()
				var texture_rect: CustomTextureRect = img_scene.instantiate()
				
				texture_rect.img_name = file
				texture_rect.img_dir = dir.get_current_dir()
				texture_rect.img_path = img_path
				
				img.load(img_path)
				
				# Calculate new image scale
				var target_scale: float = 128.0 / float(img.get_width())
				var new_x: float = img.get_width() * target_scale
				var new_y: float = img.get_height() * target_scale
				img.resize(int(new_x), int(new_y), Image.INTERPOLATE_LANCZOS)
				
				var img_texture: ImageTexture = ImageTexture.create_from_image(img)
				texture_rect.texture = img_texture
				
				input_images.add_child.call_deferred(texture_rect)
				Global.loaded.emit.call_deferred()
				
				if is_terminated():
					return
