extends Control

var is_name_picked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("RESET")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_name_picked:
		$newScreen/startButton.disabled = false
	else:
		$newScreen/startButton.disabled = true


func _on_quit_pressed():
	get_tree().quit()

func disable_main_buttons():
	$Main/newGame.disabled = true
	$Main/loadGame.disabled = true
	$Main/settings.disabled = true
	$Main/quit.disabled = true

func enable_main_buttons():
	$Main/newGame.disabled = false
	$Main/loadGame.disabled = false
	$Main/settings.disabled = false
	$Main/quit.disabled = false


func _on_new_game_pressed():
	disable_main_buttons()
	$newScreen.visible = true
	$AnimationPlayer.play("main2new")


func _on_start_button_pressed():
	$AnimationPlayer.play("startnewgame")
	


func _on_line_edit_text_changed(new_text):
	if new_text != "":
		Worldwide.missionary1name = new_text
		if Worldwide.missionary2name != "":
			is_name_picked = true
		else:
			is_name_picked = false


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "startnewgame":
		get_tree().change_scene_to_file("res://tutorial.tscn")


func _on_line_edit_2_text_changed(new_text):
	if new_text != "":
		Worldwide.missionary2name = new_text
		if Worldwide.missionary1name != "":
			is_name_picked = true
		else:
			is_name_picked = false



func _on_load_game_pressed():
	$AnimationPlayer.play("main2load")


func _on_back_button_pressed():
	$AnimationPlayer.play_backwards()
	enable_main_buttons()
