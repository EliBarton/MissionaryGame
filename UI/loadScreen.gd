extends Control

var gamesavebutton = preload("res://UI/gamesavebutton.tscn")

var selected_save = null

var buttons = []

func _ready():
	load_saves()
	disable_buttons()

func load_saves():
	if not DirAccess.get_directories_at("user://").has("saves"):
		DirAccess.make_dir_absolute("user://saves/")
	for file in DirAccess.get_files_at("user://saves/"):
		if file.ends_with(".save"):
			var newgamesave = gamesavebutton.instantiate()
			$ScrollContainer/VBoxContainer.add_child(newgamesave)
			newgamesave.name = file
			newgamesave.set_text(file.left(-5))
			newgamesave.connect("selected", save_selected)
			buttons.append(newgamesave)

func save_selected(button):
	enable_buttons()
	for i in buttons:
		i.disabled = false
	button.disabled = true
	selected_save = button.text + ".save"
	var f = FileAccess.open("user://saves/" + selected_save, FileAccess.READ)
	while f.get_position() < f.get_length():
		var json_string = f.get_line()
		var json = JSON.new()
		json.parse(json_string)
		var node_data = json.get_data()
		if node_data.keys().has("day"):
			$VBoxContainer/DayLabel.set_text("Day " + str(node_data["day"] + 1))
			return


func _on_load_button_pressed():
	Worldwide.save_file = selected_save
	Worldwide.load_from_save = true
	get_tree().change_scene_to_file("res://game_master.tscn")


func _on_delete_button_pressed():
	var dir = DirAccess.open("user://saves/")
	var file_path = "user://saves/" + selected_save
	if dir.file_exists(file_path):
		var error = dir.remove(file_path)
		if error == OK:
			print("File deleted successfully!")
		else:
			print("Failed to delete file. Error code: ", error)
	else:
		print("File does not exist: ", file_path)
	for button in buttons:
		button.queue_free()
	buttons = []
	load_saves()
	disable_buttons()
	

func disable_buttons():
	$LoadButton.disabled = true
	$DeleteButton.disabled = true

func enable_buttons():
	$LoadButton.disabled = false
	$DeleteButton.disabled = false
