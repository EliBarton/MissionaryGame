extends NinePatchRect

var dialog_file = "res://UI/dialog.json"
var in_progress = false
var selected_text = []
@export var closable = true
var disabled = false

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
		$Label.set_text(selected_text.pop_front())
	else:
		get_tree().paused = false
		emit_signal("finished")
		queue_free()

func _process(_delta):
	if not disabled:
		if $Timer.is_stopped():
			if closable:
				if Input.is_action_just_pressed("shoot"):
					show_next_line()
			else:
				if Input.is_action_just_pressed("shoot"):
					print("next screen")
					emit_signal("finished")
