extends Control

var people_present = 0
var win = false
@onready var global = get_node("/root/Game Master")
signal continue_pressed


func _ready():
	$Accounting/VBoxContainer2/Missionaries/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)

func set_people_present(amount):
	people_present = amount
	$Church/PeoplePresent/amount.set_text(str(amount))
	if people_present > 0:
		win = true
	
	if win:
		$Church/oneLabel.visible = true
		$Church/zeroLabel.visible = false
	else:
		$Church/zeroLabel.visible = true
		$Church/oneLabel.visible = false


func to_weekly_accounting():
	$Church.visible = false
	$Accounting/VBoxContainer/NewPeeps/Number.set_text(str(global.newpeeps))
	$Accounting/VBoxContainer/AtChurch/Number.set_text(str(global.atchurch))
	$Accounting/VBoxContainer/OnDate/Number.set_text(str(global.ondate))
	$Accounting/VBoxContainer/Baptized/Number.set_text(str(global.baptized))
	$Accounting/VBoxContainer2/CurrentLevel/Level.set_text(str(global.level))
	$Accounting/VBoxContainer2/XPBar.max_value = global.calculate_level_xp()
	$Accounting/VBoxContainer2/XPBar.value = global.xp
	$Accounting.visible = true

func _on_continue_button_pressed():
	emit_signal("continue_pressed")
	queue_free()
