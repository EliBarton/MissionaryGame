extends Node2D

var dialog_box = preload("res://UI/dialog_box.tscn")
var phase = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	create_dialog_box("tutorial1")
	

func on_dialog_finished():
	match phase:
		1:
			$Missionary/Camera2D.zoom = Vector2(2, 2)
	phase += 1

func _process(delta):
	if $Timer.is_stopped():
		match phase:
			2:
				if Input.is_action_just_pressed("south") or Input.is_action_just_pressed("east"):
					$Timer.start(3)
			3:
				if Input.is_action_just_pressed("shoot"):
					$Timer.start(3)
			4:
				$Timer.start(5)

func _on_plane_body_entered(body):
	get_tree().change_scene_to_file("res://game_master.tscn")


func _on_timer_timeout():
	match phase:
		2:
			create_dialog_box("tutorial2")
		3:
			create_dialog_box("tutorial3")
		4:
			create_dialog_box("tutorial4")

func create_dialog_box(text_code):
	var new_dialog = dialog_box.instantiate()
	$UI.add_child(new_dialog)
	#new_dialog.scale = new_dialog.scale / $Missionary/Camera2D.zoom
	new_dialog.connect("finished", on_dialog_finished)
	new_dialog.initialize(text_code)
