extends Node

var blank_record = preload("res://UI/personrecord.tscn")
var person_records = []
var dot = preload("res://UI/dot.tscn")
var dots = []
#@onready var lesson1file = "res://Scriptures/lesson1scriptures.txt"
var church_screen = preload("res://church_screen.tscn")
const STARTPLACE = Vector2(1450, 580)

var day : int = 1

var level = 1
var xp = 0
var xp_total = 0


var lessons = 0
var newpeeps = 0
var atchurch = 0
var ondate = 0
var baptized = 0


var person_taught = null
signal update_commitments

func _ready():
	Worldwide.start_session()
	if day > 1:
		new_day()
	$SubViewportContainer/SubViewport/Level.process_mode = Node.PROCESS_MODE_DISABLED
	$UI/DayScreen/Label.set_text("DAY " + str(day))
	$AnimationPlayer.play("beginning")
	$BookTogglePlayer.play("RESET")
	$UI/TeachingScreen.visible = false
	$UI/DayScreen/Control/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)
	

func save():
	var save_dict = {
		"path" : get_path(),
		"person_records" : person_records,
		"level" : level,
		"xp" : xp,
		"xp_total" : xp_total,
		"newpeeps" : newpeeps,
		"atchurch" : atchurch,
		"ondate" : ondate,
		"baptized" : baptized,
		"day" : day
	}
	return save_dict

func create_new_person_record(first_name, last_name, location):
	var new_person = blank_record.instantiate()
	new_person.first_name = first_name
	new_person.last_name = last_name
	new_person.location = location
	$UI/Areabook/ColorRect/People/PeopleContainer.add_child(new_person)
	new_person.connect("picked", $UI/Areabook._on_person_record_pressed)
	person_records.append(new_person)
	var new_dot = dot.instantiate()
	$UI/Areabook/ColorRect/Map/SubViewport.add_child(new_dot)
	new_dot.update_position(location)
	print(new_dot.position)
	new_dot.update_color(Color("yellow"))
	new_person.dot = new_dot
	return new_person

func person_being_taught(person):
	$SubViewportContainer/SubViewport/Level.process_mode = Node.PROCESS_MODE_DISABLED
	person_taught = person
	#$UI/Areabook.visible = false
	$UI/TeachingScreen.visible = true
	$UI/TeachingScreen.reset()
	#$UI/TeachingScreen.load_file(lesson1file)
	#$UI/TeachingScreen.create_game()
	person_taught.update_record()

func person_done_being_taught(invitation):
	$UI/Areabook.visible = true
	match invitation:
		0:
			person_taught.pamphletInvite = 1
		1:
			person_taught.bomInvite = 1
		2:
			person_taught.churchInvite = 1
		3:
			person_taught.baptismInvite = 1
	person_taught.update_record()
	person_taught.lesson_over()
	$SubViewportContainer/SubViewport/Level.process_mode = Node.PROCESS_MODE_INHERIT
	lessons += 1
	
	$UI/TeachingScreen.visible = false


func new_day():
	if Worldwide.autosave:
		Worldwide.save_game()
	day += 1
	$UI/Areabook.visible = true
	$UI/TeachingScreen.visible = false
	$SubViewportContainer/SubViewport/Level.process_mode = Node.PROCESS_MODE_DISABLED
	$UI/DayScreen/Control/Lessons.set_text("Day " + str(day-1) + " Lessons: " + str(lessons))
	$UI/Areabook/ColorRect/ProgressBar/Label.set_text("DAY " + str(day))
	$SubViewportContainer/SubViewport/Level/Missionary.new_day()
	$UI/DayScreen/Label.set_text("DAY " + str(day))
	$AnimationPlayer.play("new_day")
	$UI/DayScreen.new_day()
	if day % 7 == 0:
		$UI.visible = false
		$SubViewportContainer/SubViewport/Level.visible = false
		print("Time to go to church Elders")
		var newChurchScreen = church_screen.instantiate()
		add_child(newChurchScreen)
		newChurchScreen.set_people_present(atchurch)
		newChurchScreen.connect("continue_pressed", end_sunday)
		$AnimationPlayer.pause()
	await wait(1)
	gain_experience(lessons*15)
	await wait(1)
	emit_signal("update_commitments")
	$SubViewportContainer/SubViewport/Level/Missionary.position = STARTPLACE
	$SubViewportContainer/SubViewport/Level/Missionary2.position = STARTPLACE
	
	if day % 7 == 1:
		$UI.visible = true
		$SubViewportContainer/SubViewport/Level.visible = true
		newpeeps = 0
		atchurch = 0
		ondate = 0
		baptized = 0
		print("new week")

func calculate_level_xp(num = level):
	var levelformula = Expression.new()
	levelformula.parse("(x * 10) + 7.7", ["x"])
	return levelformula.execute([num])

func gain_experience(amount):
	print("xp added: " + str(amount))
	xp_total += amount
	xp += amount
	var growth_data = []
	var plus_what = 0
	while xp >= calculate_level_xp(level + plus_what):
		var to_next_level = calculate_level_xp(level + plus_what)
		print("xp required to level up:" + str(to_next_level))
		print("xp in bank" + str(xp))
		xp -= to_next_level
		growth_data.append([to_next_level, to_next_level])
		plus_what += 1
	growth_data.append([xp, calculate_level_xp(level + plus_what)])
	
	for x in growth_data:
		var target_xp = x[0]
		var max_xp = x[1]
		$UI/DayScreen/Control/XPBar.max_value = max_xp
		var tween = get_tree().create_tween()
		await tween.tween_property($UI/DayScreen/Control/XPBar, "value", target_xp, 1.0/growth_data.size()).set_ease(Tween.EASE_OUT).finished
		if abs($UI/DayScreen/Control/XPBar.max_value - $UI/DayScreen/Control/XPBar.value) < 0.01:
			$UI/DayScreen/Control/XPBar.value = $UI/DayScreen/Control/XPBar.min_value
			await level_up()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		Worldwide.save_game()
		print("game_saved")
	$UI/DayScreen/Control/CurrentLevel/Level.set_text(str(level))
	$UI/Areabook/ColorRect/Progress/VBoxContainer/CurrentLevel/Level.set_text(str(level))
	$UI/Areabook/ColorRect/Progress/VBoxContainer/XPBar.value = $UI/DayScreen/Control/XPBar.value
	$UI/Areabook/ColorRect/Progress/VBoxContainer/XPBar.max_value = $UI/DayScreen/Control/XPBar.max_value
	$UI/Areabook/ColorRect/Map/SubViewport/Camera2D.position = $SubViewportContainer/SubViewport/Level/Missionary.position
	$SubViewportContainer/SubViewport/Level/LevelWorld.update_shadow("player",$SubViewportContainer/SubViewport/Level/Missionary/Sprite.animation, $SubViewportContainer/SubViewport/Level/Missionary/Sprite.frame, $SubViewportContainer/SubViewport/Level/Missionary.global_position)
	$SubViewportContainer/SubViewport/Level/LevelWorld.update_shadow("companion",$SubViewportContainer/SubViewport/Level/Missionary2/Sprite.animation, $SubViewportContainer/SubViewport/Level/Missionary2/Sprite.frame, $SubViewportContainer/SubViewport/Level/Missionary2.global_position)
		#$UI/Areabook._on_person_record_pressed(
		#person_taught.first_name, person_taught.last_name, person_taught.location,
		#person_taught.level, person_taught.xp, person_taught.acceptance_factor)

func level_up():
	level += 1
	$AnimationPlayer.pause()
	$UI/SkillScreen.initialize()
	await $UI/SkillScreen.finished
	$AnimationPlayer.play()
	print("back in business")

func new_person_found():
	newpeeps += 1
	$UI/Areabook/ColorRect/Progress/VBoxContainer/NewPeeps/Number.set_text(str(newpeeps))

func person_at_church():
	atchurch += 1
	$UI/Areabook/ColorRect/Progress/VBoxContainer/AtChurch/Number.set_text(str(atchurch))



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "beginning":
		$SubViewportContainer/SubViewport/Level.process_mode = Node.PROCESS_MODE_INHERIT
	if anim_name == "new_day":
		if day % 7 != 0:
			$SubViewportContainer/SubViewport/Level.process_mode = Node.PROCESS_MODE_INHERIT
			$SubViewportContainer/SubViewport/Level/Missionary.new_day()
		
		lessons = 0
	update_names()

func wait(duration):  #Duration in seconds
	await get_tree().create_timer(duration).timeout

func close_areabook():
	$BookTogglePlayer.play("close_areabook")

func open_areabook():
	$BookTogglePlayer.play_backwards("close_areabook")

func end_sunday():
	print("Sunday over!")
	$UI.visible = true
	new_day()

func update_names():
	$UI/Areabook.update_names()
	$UI/SkillScreen.update_names()
	$UI/DayScreen.update_names()
