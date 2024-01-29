extends Node

var missionary1name = ""
var missionary2name = ""

var is_dragging = false
var selected_draggable = null
var numwrong = 0

var cardio = 0
var getout = 0
var diligence = 0

var load_from_save = false
var save_file = null

var autosave = false

func _ready():
	add_to_group("persist")
	pass


func save():
	var save_dict = {
		"path" : get_path(),
		"missionary1name" : missionary1name,
		"missionary2name" : missionary2name,
		"cardio" : cardio,
		"diligence" : diligence
	}
	return save_dict

func start_session():
	if load_from_save:
		autosave = true
		load_game("user://saves/" + save_file)
		print("save loaded")

func save_game():
	var save_name = missionary1name + "_" + missionary2name
	var game_save = FileAccess.open("user://saves/" + save_name + ".save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	#save_nodes.append(self)
	for node in save_nodes:
		var node_data = node.save()
		var json_string = JSON.stringify(node_data)
		game_save.store_line(json_string)

func load_game(file):
	var game_save = FileAccess.open(file, FileAccess.READ)
	while game_save.get_position() < game_save.get_length():
		var json_string = game_save.get_line()
		var json = JSON.new()
		json.parse(json_string)
		var node_data = json.get_data()
		var target_node = get_node(node_data["path"])
		
		for i in node_data.keys():
			if i == "path":
				continue
			if i == "last_taught_day":
				if node_data[i] != 0:
					target_node.load_profile()
			target_node.set(i, node_data[i])

func hit_stop():
	Engine.time_scale = 0
	await get_tree().create_timer(0.2, true, false, true).timeout
	Engine.time_scale = 1
