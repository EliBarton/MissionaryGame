extends Node2D

var people_present = 0
var win = false

signal continue_pressed

func _ready():
	pass # Replace with function body.

func set_people_present(amount):
	people_present = amount
	$PeoplePresent/amount.set_text(str(amount))
	if people_present > 0:
		win = true
	
	if win:
		$oneLabel.visible = true
		$zeroLabel.visible = false
	else:
		$zeroLabel.visible = true
		$oneLabel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_continue_button_pressed():
	if win:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	else:
		emit_signal("continue_pressed")
		queue_free()
