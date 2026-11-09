extends Node

signal continue_and_stop_thread(cont: bool)

@export var input_images: VBoxContainer
@export var keep_list: VBoxContainer
@export var preview: TextureRect
@export var scroll_container: ScrollContainer
@export var discard: Button
@export var keep: Button
@export var revert: Button
@export var save_destination: Button
@export var current_loaded: Label
@export var total_images: Label
@export var confirmation_dialog: ConfirmationDialog
@export var file_dialog: FileDialog
@export var accept_dialog: AcceptDialog
@export var go_back: ConfirmationDialog
@export var done: AcceptDialog
@export var thread_warning: ConfirmationDialog
@export var status: Label
@export var continue_button: Button

@export var progress_bar: ProgressBar

var img_scene: PackedScene = preload("res://img.tscn")

var custom_thread: CustomThread = preload("res://scripts/img_thread.gd").new()

var tween: Tween

var current_img: CustomTextureRect:
	set(img):
		if not img:
			if current_img:
				current_img.selected_indicator.hide()
			preview.texture = null
			discard.disabled = true
			keep.disabled = true
			revert.disabled = true
			current_img = null
			return
			
		if current_img:
				current_img.selected_indicator.hide()
		
		if img.keep:
			discard.disabled = true
			keep.disabled = true
			revert.disabled = false
		else:
			discard.disabled = false
			keep.disabled = false
			revert.disabled = true
		current_img = img
		current_img.selected_indicator.show()
	get():
		return current_img


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if custom_thread.is_alive():
			custom_thread.stop() 


func _exit_tree() -> void:
	if custom_thread.is_started():
		custom_thread.wait_to_finish()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_img = null
	
	# Connect signals
	done.confirmed.connect(exit_to_menu)
	go_back.confirmed.connect(exit_to_menu)
	confirmation_dialog.confirmed.connect(save_images)
	thread_warning.canceled.connect(func(): continue_and_stop_thread.emit(false))
	thread_warning.confirmed.connect(func(): continue_and_stop_thread.emit(true))
	file_dialog.dir_selected.connect(out_dir_selected)
	Global.loaded.connect(update_progress_bar)
	Global.preview_img.connect(preview_image)
	
	var parse: bool = setup_progress_bar()
	if parse:
		custom_thread.parse_images(input_images)
	else:
		done.title = "No Images Found"
		done.dialog_text = "No Images were found in the selected directory."
		done.popup()


func out_dir_selected(n: String) -> void:
		Global.out_dir_name = n
		save_destination.text = n


func update_progress_bar() -> void:
	progress_bar.value += 1
	current_loaded.text = str(int(progress_bar.value))
	if progress_bar.value == progress_bar.max_value:
		progress_bar.hide()


func setup_progress_bar() -> bool:
	var n: int = 0
	var dir: DirAccess = DirAccess.open(Global.in_dir_name)
	if dir:
		var image_extensions := ["png", "jpg", "jpeg"]
		for file: StringName in dir.get_files():
			if file.get_extension().to_lower() in image_extensions:
				n += 1
				progress_bar.max_value = n
				total_images.text = str(n)
	if n == 0:
		return false
	else:
		return true


func preview_image(img_obj: CustomTextureRect) -> void:
	if img_obj != current_img:
		var img: Image = Image.new()
		tween = get_tree().create_tween()
		
		preview.self_modulate = Color.TRANSPARENT
		
		img.load(img_obj.img_path)
		preview.texture = ImageTexture.create_from_image(img)
		current_img = img_obj
		
		tween.tween_property(preview, "self_modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func save_images() -> void:
	for c: CustomTextureRect in keep_list.get_children():
		var new_path: StringName = str(c.img_dir, "/copy_", c.img_name)
		var e: Error = DirAccess.copy_absolute(c.img_path, new_path)
		if e != OK:
			push_error("Could not copy the file.")
		else:
			e = DirAccess.rename_absolute(new_path, str(Global.out_dir_name, "/", c.img_name))
			if e != OK:
				push_error("Could not move the file.")
	done.dialog_text += Global.out_dir_name
	done.popup()


func _on_discard_pressed() -> void:
	if current_img:
		var n: CustomTextureRect = input_images.get_node_or_null(str(current_img.name))
		if n:
			input_images.remove_child(n)
			n.queue_free()
			current_img = null


func _on_keep_pressed() -> void:
	current_img.keep = true
	current_img.reparent(keep_list)
	current_img = null
	continue_button.disabled = false


func _on_revert_pressed() -> void:
	current_img.keep = false
	current_img.reparent(input_images)
	current_img = null
	if keep_list.get_children().is_empty():
		continue_button.disabled = true


func _on_cocntinue_pressed() -> void:
	if not await img_loading_warning():
		return
	
	if Global.out_dir_name == "":
		accept_dialog.popup()
		return
	
	var item_count: int = keep_list.get_children().size()
	if item_count > 0:
		confirmation_dialog.dialog_text = str(
			"Copy ",
			item_count,
			" images from:\n\n",
			Global.in_dir_name,
			"  to  ",
			Global.out_dir_name
		)
		confirmation_dialog.popup()


func _on_save_destination_pressed() -> void:
	file_dialog.popup()


func _on_back_pressed() -> void:
	if not await img_loading_warning():
		return
	go_back.popup()


func img_loading_warning() -> bool:
	if custom_thread.is_alive():
		thread_warning.popup()
		var check: bool = await continue_and_stop_thread
		if check:
			custom_thread.stop()
			progress_bar.hide()
			status.text += " (Stopped)"
		return check
	return true


func exit_to_menu() -> void:
	get_tree().change_scene_to_file("res://root.tscn")
