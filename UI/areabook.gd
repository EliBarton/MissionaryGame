extends Control

@onready var global = get_node("/root/Game Master")
var open = true
const BASE_DAY_LENGTH = 40

var personrecord
var people
var progress
var map
var menu
# Called when the node enters the scene tree for the first time.
func _ready():
	people = $ColorRect/People
	personrecord = $ColorRect/PersonRecord
	progress = $ColorRect/Progress
	map = $ColorRect/Map
	menu = $ColorRect/Menu
	update_names()




func _on_back_to_people_button_pressed():
	personrecord.visible = false
	people.visible = true

func _on_person_record_pressed(first_name, last_name, location, level, xp, acceptance_factor, invite1, invite2, invite3, invite4):
	change_screen()
	$ColorRect/PersonRecord/TopBar/Name.set_text(first_name + " " + last_name)
	personrecord.visible = true
	$ColorRect/PersonRecord/PersonInfo/CurrentLevel/Level.set_text(str(level))
	$ColorRect/PersonRecord/PersonInfo/XPBar.max_value = global.calculate_level_xp()
	$ColorRect/PersonRecord/PersonInfo/XPBar.value = xp
	$ColorRect/PersonRecord/PersonInfo/A_Factor.set_text(str(acceptance_factor))
	$ColorRect/PersonRecord/PersonInfo/Commitments.update_invitations(invite1, invite2, invite3, invite4)

func change_screen():
	people.visible = false
	personrecord.visible = false
	progress.visible = false
	map.visible = false
	menu.visible = false


func _on_button_progress_pressed():
	change_screen()
	progress.visible = true


func _on_button_people_pressed():
	change_screen()
	people.visible = true

func _on_button_map_pressed():
	change_screen()
	map.visible = true



func update_names():
	$ColorRect/Progress/VBoxContainer/Missionaries/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)


func _on_button_toggle_pressed():
	if open:
		global.close_areabook()
		open = false
		$ColorRect/Buttons/ButtonToggle.set_text("o\np\ne\nn")
	else:
		global.open_areabook()
		open = true
		$ColorRect/Buttons/ButtonToggle.set_text("c\nl\no\ns\ne")


func _on_go_home_button_pressed():
	global.new_day()


func _on_button_menu_pressed():
	change_screen()
	menu.visible = true
