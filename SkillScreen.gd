extends ColorRect

@onready var global = get_node("/root/Game Master")
signal finished
# Called when the node enters the scene tree for the first time.
func _ready():
	$RightSide/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)


func initialize():
	#$continueButton.disabled = true
	if Worldwide.cardio >= 5:
		$LeftSide/Cardio/cardioButton.disabled = true
	else:
		$LeftSide/Cardio/cardioButton.disabled = false
	if Worldwide.getout >= 5:
		$LeftSide/GetOut/getOutButton.disabled = true
	else:
		$LeftSide/GetOut/getOutButton.disabled = false
	if Worldwide.diligence >= 5:
		$LeftSide/Diligence/diligenceButton.disabled = true
	else:
		$LeftSide/Diligence/diligenceButton.disabled = false
	visible = true
	$RightSide/Day.set_text("Day " + str(global.day))
	$RightSide/CurrentLevel/Level.set_text(str(global.level))
	$LeftSide/Cardio/ProgressBar.value = Worldwide.cardio
	$LeftSide/GetOut/ProgressBar.value = Worldwide.getout
	$LeftSide/Diligence/ProgressBar.value  = Worldwide.diligence

func _on_cardio_button_pressed():
	Worldwide.cardio += 1
	$LeftSide/Cardio/ProgressBar.value  = Worldwide.cardio
	button_pressed()

func _on_get_out_button_pressed():
	Worldwide.getout += 1
	$LeftSide/GetOut/ProgressBar.value  = Worldwide.getout
	
	button_pressed()

func button_pressed():
	$continueButton.disabled = false
	$LeftSide/GetOut/getOutButton.disabled = true
	$LeftSide/Cardio/cardioButton.disabled = true
	$LeftSide/Diligence/diligenceButton.disabled = true

func _on_continue_button_pressed():
	visible = false
	emit_signal("finished")

func update_names():
	$RightSide/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)


func _on_diligence_button_pressed():
	Worldwide.diligence += 1
	$LeftSide/Diligence/ProgressBar.value  = Worldwide.diligence
	
	button_pressed()
