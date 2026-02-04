extends Control

@onready var lesson1file = "res://Scriptures/lesson1scriptures.json"
@onready var lesson2file = "res://Scriptures/lesson2scriptures.json"
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
# Quiz game variables
var quiz_buttons = []
var correct_reference = ""
var quiz_question_label = null
var quiz_quote_label = null
var current_lesson_data = null
# Called when the node enters the scene tree for the first time.
func _ready():
	$Top/DialogBox.disabled = true

func _process(_delta):
	if checkifcorrect:
		if Worldwide.numwrong <= 0:
			all_words_correct()

func follow_up():
	if global.person_taught.last_taught_day != 0:
		$Top/DialogBox.disabled = false
		if global.person_taught.kept_last_commitment:
			$Top/DialogBox.initialize("followup1", false)
		else:
			$Top/DialogBox.initialize("followup2", false)
		$Top/DialogBox.connect("finished", end_follow_up)
	else:
		$Top/DialogBox.disabled = true
	$LessonWith.set_text("Lesson with " + global.person_taught.first_name + " " + global.person_taught.last_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func load_txt_file(file):
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

func load_file(file):
	#Loads JSON files
	var f = FileAccess.open(file, FileAccess.READ)
	var library = JSON.parse_string(f.get_as_text())
	current_lesson_data = library  # Store for quiz game
	var rand_list = library[str(randi_range(1, library.size()))].duplicate()
	var reference = rand_list[0]
	var quote = rand_list[1]
	$DragandDrop/Reference.set_text(reference)
	$DragandDrop/TextContainer/Label2.set_text(quote)
	f.close()

func create_game():
	#get_tree().paused = true
	$DragandDrop/Reference.visible = true
	$DragandDrop/TextContainer.visible = true
	$DragandDrop/GridContainer.visible = true
	$DragandDrop/Invitation.visible = false
	checkifcorrect = true
	difficulty = base_difficulty
	difficulty = difficulty + global.person_taught.level/3.0
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
		new_label.custom_minimum_size.x = (new_label.get_total_character_count() + .5) * 6
		new_label.get_rect().size.x = (new_label.get_total_character_count() + .5) * 6
		labels.append(new_label)
		if text.contains("___"):
			var new_dropable = dropable.instantiate()
			new_dropable.position.x = (new_label.get_total_character_count()) * 5.5
			Worldwide.numwrong += 1
			new_dropable.correct_word = splittext2[i]
			new_label.add_child(new_dropable)
			dropables.append(new_dropable)
		i += 1
	
	
	$DragandDrop/TextContainer/Label2.visible = false

func create_reference_quiz():
	"""Reference identification game - show quote and ask for correct reference"""
	# Hide drag and drop elements
	$DragandDrop/Reference.visible = false
	$DragandDrop/TextContainer.visible = false
	$DragandDrop/GridContainer.visible = false
	$DragandDrop/Invitation.visible = false
	checkifcorrect = false
	
	# Get a random scripture from current lesson data
	if current_lesson_data == null:
		return
	
	var scripture_keys = current_lesson_data.keys()
	var correct_key = scripture_keys[randi_range(0, scripture_keys.size() - 1)]
	var correct_scripture = current_lesson_data[correct_key]
	correct_reference = correct_scripture[0]
	var quote = correct_scripture[1]
	
	# Generate wrong answers from other scriptures in same lesson
	var wrong_references = []
	for key in scripture_keys:
		if key != correct_key:
			wrong_references.append(current_lesson_data[key][0])
	
	# Shuffle and pick 3 wrong answers
	wrong_references.shuffle()
	var answer_options = [correct_reference]
	for i in range(min(3, wrong_references.size())):
		answer_options.append(wrong_references[i])
	
	# Shuffle all options
	answer_options.shuffle()
	
	# Create question label
	quiz_question_label = Label.new()
	quiz_question_label.text = "What is the reference for this scripture?"
	quiz_question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quiz_question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var question_font = load("res://fonts/bpdots.squares-bold.otf")
	if question_font:
		quiz_question_label.add_theme_font_override("font", question_font)
		quiz_question_label.add_theme_font_size_override("font_size", 24)
	$DragandDrop.add_child(quiz_question_label)
	quiz_question_label.position = Vector2(50, 100)
	quiz_question_label.size = Vector2(650, 50)
	
	# Create quote label
	quiz_quote_label = Label.new()
	quiz_quote_label.text = '"' + quote + '"'
	quiz_quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quiz_quote_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	quiz_quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if question_font:
		quiz_quote_label.add_theme_font_override("font", question_font)
		quiz_quote_label.add_theme_font_size_override("font_size", 20)
	$DragandDrop.add_child(quiz_quote_label)
	quiz_quote_label.position = Vector2(50, 160)
	quiz_quote_label.size = Vector2(650, 240)
	
	# Create buttons for each option
	var button_labels = ["A", "B", "C", "D"]
	var button_y = 420
	
	for i in range(answer_options.size()):
		var button = Button.new()
		button.text = button_labels[i] + ". " + answer_options[i]
		button.custom_minimum_size = Vector2(650, 50)
		if question_font:
			button.add_theme_font_override("font", question_font)
			button.add_theme_font_size_override("font_size", 18)
		$DragandDrop.add_child(button)
		button.position = Vector2(50, button_y + i * 60)
		button.pressed.connect(_on_quiz_button_pressed.bind(answer_options[i]))
		quiz_buttons.append(button)

func _on_quiz_button_pressed(selected_reference):
	"""Handle quiz button click"""
	if selected_reference == correct_reference:
		# Correct answer - show invitation screen
		for btn in quiz_buttons:
			btn.disabled = true
		# Visual feedback - change color to green
		for btn in quiz_buttons:
			if btn.text.contains(correct_reference):
				btn.modulate = Color(0.5, 1.0, 0.5)  # Green
		await get_tree().create_timer(0.5).timeout
		$DragandDrop/Invitation.visible = true
	else:
		# Wrong answer - show feedback
		for btn in quiz_buttons:
			if btn.text.contains(selected_reference):
				btn.modulate = Color(1.0, 0.5, 0.5)  # Red
				await get_tree().create_timer(0.5).timeout
				btn.modulate = Color(1.0, 1.0, 1.0)  # Reset color

func reset():
	reset_text()
	$DragandDrop/LessonToTeach.visible = true
	$DragandDrop/Invitation.visible = false
	$DragandDrop/Reference.visible = false
	$DragandDrop/TextContainer.visible = false
	follow_up()

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
	# Clean up quiz game elements
	for btn in quiz_buttons:
		btn.queue_free()
	quiz_buttons.clear()
	if quiz_question_label != null:
		quiz_question_label.queue_free()
		quiz_question_label = null
	if quiz_quote_label != null:
		quiz_quote_label.queue_free()
		quiz_quote_label = null

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
		1:
			load_file(lesson2file)
	
	# Randomly choose game type (50/50 chance)
	var game_type = randi() % 2
	if game_type == 0:
		create_game()  # Fill-in-the-blank
	else:
		create_reference_quiz()  # Reference identification

func _on_restoration_pressed():
	start_lesson(0)


func _on_planof_salvation_pressed():
	start_lesson(1)

func _on_gospel_pressed():
	start_lesson(2)

func _on_becoming_pressed():
	start_lesson(3)


func _on_back_button_pressed():
	end_lesson(null)
