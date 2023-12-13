extends Control

@onready var global = get_node("/root/Game Master")

const BASE_DAY_LENGTH = 40

var personrecord
var people
var progress
# Called when the node enters the scene tree for the first time.
func _ready():
	people = $ColorRect/People
	personrecord = $ColorRect/PersonRecord
	progress = $ColorRect/Progress
	$Timer.start(BASE_DAY_LENGTH)
	$ColorRect/Progress/VBoxContainer/Missionaries/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ColorRect/ProgressBar.value = $Timer.time_left
	pass


func _on_back_to_people_button_pressed():
	personrecord.visible = false
	people.visible = true

func _on_person_record_pressed(first_name, last_name, location, level, xp, acceptance_factor, invite1, invite2, invite3, invite4):
	change_screen()
	$ColorRect/PersonRecord/TopBar/Name.set_text(first_name + " " + last_name)
	personrecord.visible = true
	$ColorRect/PersonRecord/PersonInfo/CurrentLevel/Level.set_text(str(level))
	$ColorRect/PersonRecord/PersonInfo/XPBar.max_value = global.levelformula
	$ColorRect/PersonRecord/PersonInfo/XPBar.value = xp
	$ColorRect/PersonRecord/PersonInfo/A_Factor.set_text(str(acceptance_factor))
	$ColorRect/PersonRecord/PersonInfo/Commitments.update_invitations(invite1, invite2, invite3, invite4)

func change_screen():
	people.visible = false
	personrecord.visible = false
	progress.visible = false


func _on_button_progress_pressed():
	change_screen()
	progress.visible = true


func _on_button_people_pressed():
	change_screen()
	people.visible = true


func _on_timer_timeout():
	global.new_day()

func pause_day():
	$Timer.paused = true

func unpause_day():
	$Timer.paused = false
