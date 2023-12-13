extends ColorRect

@onready var global = get_node("/root/Game Master")
signal finished
# Called when the node enters the scene tree for the first time.
func _ready():
	$RightSide/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize():
	$continueButton.disabled = true
	if global.cardio >= 5:
		$LeftSide/Cardio/cardioButton.disabled = true
	else:
		$LeftSide/Cardio/cardioButton.disabled = false
	if global.getout >= 5:
		$LeftSide/GetOut/getOutButton.disabled = true
	else:
		$LeftSide/GetOut/getOutButton.disabled = false
	visible = true
	$RightSide/Day.set_text("Day " + str(global.day))
	$RightSide/CurrentLevel/Level.set_text(str(global.level))

func _on_cardio_button_pressed():
	global.cardio += 1
	$LeftSide/Cardio/ProgressBar.value  = global.cardio
	button_pressed()

func _on_get_out_button_pressed():
	global.getout += 1
	$LeftSide/GetOut/ProgressBar.value  = global.getout
	
	button_pressed()

func button_pressed():
	$continueButton.disabled = false
	$LeftSide/GetOut/getOutButton.disabled = true
	$LeftSide/Cardio/cardioButton.disabled = true

func _on_continue_button_pressed():
	visible = false
	emit_signal("finished")


