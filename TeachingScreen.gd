extends Control

@onready var lesson1file = "res://Scriptures/lesson1scriptures.txt"
var dragable = preload("res://UI/dragable.tscn")
var dropable = preload("res://UI/dropable.tscn")
@onready var global = get_node("/root/Game Master")
var base_difficulty = 3
var difficulty = 3
var at_line = 0
var labels = []
var dropables = []
var dragables = []
var checkifcorrect = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Top/DialogBox.disabled = true
	#load_file(lesson1file)
	#create_game()
	#visible = false

func _process(delta):
	if checkifcorrect:
		if Worldwide.numwrong <= 0:
			all_words_correct()

func follow_up():
	$Top/DialogBox.disabled = false
	$Top/DialogBox.initialize("followup1")
	$Top/DialogBox.connect("finished", end_follow_up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func load_file(file):
	visible = true
	var f = FileAccess.open(file, FileAccess.READ)
	var line = f.get_line()
	var k = at_line
	while k > 0:
		line = f.get_line()
		k -= 1
	var splitline = line.split("|")
	var numlines = int(splitline[0])
	var reference = splitline[1]
	var text = splitline[2]
	at_line += 1
	var i = numlines
	while i > 1:
		text = text + "\n"
		text = text + f.get_line()
		at_line += 1
		i -= 1
	$DragandDrop/Reference.set_text(reference)
	$DragandDrop/TextContainer/Label2.set_text(text)
	if f.get_position() >= f.get_length():
		at_line = 0
	f.close()

func create_game():
	#get_tree().paused = true
	$DragandDrop/Reference.visible = true
	$DragandDrop/TextContainer.visible = true
	$DragandDrop/Invitation.visible = false
	checkifcorrect = true
	difficulty = base_difficulty
	difficulty = difficulty + global.person_taught.level
	var removed_words = []
	var text = $DragandDrop/TextContainer/Label2.get_text()
	text = text.replace("\n", " ")
	text = text.replace("—", " ")
	var splittext = text.split(" ")
	var splittext2 = splittext.duplicate()
	var blankamount = difficulty
	var tries = 35
	while blankamount > 0 and tries > 0:
		randomize()
		var randnum = randi_range(0, splittext.size()-1)
		if splittext[randnum].length() < 4:
			pass
		elif splittext[randnum].contains("_"):
			pass
		else:
			removed_words.append(randnum)
			var new_dragable = dragable.instantiate()
			new_dragable.initialize(splittext[randnum])
			$DragandDrop/GridContainer.add_child(new_dragable)
			dragables.append(new_dragable)
			
			
			
			splittext[randnum] = "_".repeat(splittext[randnum].length())
			blankamount -= 1
		tries -= 1
	var i = 0
	for w in splittext:
		text = "" 
		text = (text + w + " ")
		var new_label = $DragandDrop/TextContainer/Label2.duplicate()
		$DragandDrop/TextContainer.add_child(new_label)
		new_label.set_text(text)
		new_label.visible = true
		new_label.custom_minimum_size.x = (new_label.get_total_character_count() + .5) * 12
		new_label.get_rect().size.x = (new_label.get_total_character_count() + .5) * 12
		labels.append(new_label)
		if text.contains("___"):
			var new_dropable = dropable.instantiate()
			new_dropable.position.x = (new_label.get_total_character_count()) * 6
			Worldwide.numwrong += 1
			new_dropable.correct_word = splittext2[i]
			new_label.add_child(new_dropable)
			dropables.append(new_dropable)
		i += 1
	
	
	$DragandDrop/TextContainer/Label2.visible = false

func reset():
	reset_text()
	$DragandDrop/LessonToTeach.visible = true
	$DragandDrop/Invitation.visible = false
	$DragandDrop/Reference.visible = false
	$DragandDrop/TextContainer.visible = false

func reset_text():
	for label in labels:
		label.queue_free()
	for dro in dropables:
		dro.queue_free()
	for dra in dragables:
		dra.queue_free()
	labels.clear()
	dropables.clear()
	dragables.clear()

func all_words_correct():
	checkifcorrect = false
	$DragandDrop/Invitation.visible = true


func _on_pamphlet_pressed():
	end_lesson(0)


func _on_bom_pressed():
	end_lesson(1)


func _on_church_pressed():
	end_lesson(2)


func _on_baptized_pressed():
	end_lesson(3)

func end_lesson(invitation):
	global.person_done_being_taught(invitation)
	visible = false
	

func end_follow_up():
	$Top/DialogBox.disabled = true



func start_lesson(lesson):
	$DragandDrop/LessonToTeach.visible = false
	match lesson:
		0:
			load_file(lesson1file)
	create_game()

func _on_restoration_pressed():
	start_lesson(0)


func _on_planof_salvation_pressed():
	start_lesson(1)

func _on_gospel_pressed():
	start_lesson(2)

func _on_becoming_pressed():
	start_lesson(3)
