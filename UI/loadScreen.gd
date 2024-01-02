extends Control

var gamesavebutton = preload("res://UI/gamesavebutton.tscn")

var selected_save = null

var buttons = []

func _ready():
	load_saves()
	$LoadButton.disabled = true

func load_saves():
	for file in DirAccess.get_files_at("res://saves/"):
		if file.ends_with(".save"):
			var newgamesave = gamesavebutton.instantiate()
			$ScrollContainer/VBoxContainer.add_child(newgamesave)
			newgamesave.name = file
			newgamesave.set_text(file.left(-5))
			newgamesave.connect("selected", save_selected)
			buttons.append(newgamesave)

func save_selected(button):
	$LoadButton.disabled = false
	for i in buttons:
		i.disabled = false
	button.disabled = true
	selected_save = button.text + ".save"
	var f = FileAccess.open("res://saves/" + selected_save, FileAccess.READ)
	while f.get_position() < f.get_length():
		var json_string = f.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.get_data()
		if node_data.keys().has("day"):
			$VBoxContainer/DayLabel.set_text("Day " + str(node_data["day"] + 1))
			return


func _on_load_button_pressed():
	Worldwide.save_file = selected_save
	Worldwide.load_from_save = true
	get_tree().change_scene_to_file("res://game_master.tscn")
