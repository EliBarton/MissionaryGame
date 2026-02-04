extends NinePatchRect

var dialog_file = "res://UI/dialog.json"
var in_progress = false
var selected_text = []
@export var closable = true
var disabled = false
var waiting_for_click = true

signal finished

var wait_time = .5

func initialize(text_code, pausegame):
	var file = FileAccess.open(dialog_file, FileAccess.READ)
	var dialog_library = JSON.parse_string(file.get_as_text())
	selected_text = dialog_library[text_code].duplicate()
	get_tree().paused = pausegame
	$Timer.start(wait_time)
	show_next_line()

func show_next_line():
	$Timer.start(wait_time)
	if selected_text.size() > 0:
		if selected_text[0] == "switch":
			waiting_for_click = false
			$Label.set_text("")
			selected_text.pop_front()
			$Option1/Label.set_text("> " + selected_text.pop_front())
			$Option2/Label.set_text("> " + selected_text.pop_front())
		else:
			waiting_for_click = true
			var next_text = selected_text.pop_front()
			if next_text.begins_with("$"):
				next_text = next_text.replace("$", "ELDER " + Worldwide.missionary1name.to_upper())
			$Label.set_text(next_text)
	else:
		get_tree().paused = false
		emit_signal("finished")
		queue_free()

func _unhandled_input(event):
	if disabled:
		return
	if not $Timer.is_stopped():
		return
	if not waiting_for_click:
		return
	if event.is_action_pressed("shoot"):
		if closable:
			show_next_line()
		else:
			print("next screen")
			emit_signal("finished")
		accept_event()


func _on_option_1_mouse_entered():
	$Option1/Label.label_settings.set_shadow_offset(Vector2(1.42, 3))
	$Option1/Label.position = Vector2(0, -2)
	$Option1/Label.label_settings.set_font_color(Color(.8, .8, .8))

func _on_option_1_mouse_exited():
	$Option1/Label.label_settings.set_shadow_offset(Vector2(1.42, 1))
	$Option1/Label.position = Vector2(0, 0)
	$Option1/Label.label_settings.set_font_color(Color(1, 1, 1))

func _on_option_2_mouse_entered():
	$Option2/Label.label_settings.set_shadow_offset(Vector2(1.42, 3))
	$Option2/Label.position = Vector2(0, -2)
	$Option2/Label.label_settings.set_font_color(Color(.8, .8, .8))

func _on_option_2_mouse_exited():
	$Option2/Label.label_settings.set_shadow_offset(Vector2(1.42, 1))
	$Option2/Label.position = Vector2(0, 0)
	$Option2/Label.label_settings.set_font_color(Color(1, 1, 1))


func _on_option_1_pressed():
	show_next_line()

func _on_option_2_pressed():
	show_next_line()
