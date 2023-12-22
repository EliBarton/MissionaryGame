extends CharacterBody2D

@onready var global = get_node("/root/Game Master")
@onready var areabook = get_node("/root/Game Master/UI/Areabook")
var icons = preload("res://characters/character supplements/conversion_icon.tscn")
var rejectionrange = preload("res://characters/character supplements/rejection_range.tscn")
var talkrange = preload("res://characters/character supplements/talk_range.tscn")
var book = preload("res://book.tscn")
var newicon = null
var newrejection = null
var rejectionInitiated = false
var newbook = null
var love = false
var talkmode = false
var teachmode = false
var newtalkrange = null
var level = 1
var xp = 0
var xp_total = 0
var person_record
var location = Vector2()
var acceptance_factor = 0.99
var new_person = false
var last_taught_day = 0
var levelformula = (level * 10) + 7.7

var pamphletInvite = 0
var bomInvite = 0
var churchInvite = 0
var baptismInvite = 0

@export var first_name = ""
@export var last_name = ""

signal being_taught
signal attended_church

func _ready():
	connect("being_taught", global.person_being_taught)
	connect("attended_church", global.person_at_church)

func _process(delta):
	if person_record:
		person_record.xp = xp
		person_record.level = level
		person_record.acceptance_factor = acceptance_factor
		location = global_position

func received_material(type):
	if love:
		pass
	else:
		rejectionInitiated = false
		if newicon != null:
			newicon.queue_free()
		if type == 1:
			newicon = icons.instantiate()
			add_child(newicon)
			newicon.position.y = -40
			newicon.play("thinking")
			newicon.connect("animation_finished", done_thinking)

func done_thinking():
	randomize()
	var random = randf()
	if random < acceptance_factor:
		loved_it()
	else:
		if not rejectionInitiated:
			acceptance_factor = acceptance_factor * .5
			if person_record:
				areabook._on_person_record_pressed(first_name, last_name, location,
			 level, xp, acceptance_factor)
			newrejection = rejectionrange.instantiate()
			add_child(newrejection)
			newrejection.connect("body_shape_entered", reject_player_in_range)
			rejectionInitiated = true
			newbook = book.instantiate()
			get_parent().add_child(newbook)
			newbook.rejected = true
			newbook.global_transform = $Muzzle.global_transform
			newicon.queue_free()
			if love:
				newtalkrange.position = Vector2(1000, 100000)
				newtalkrange.disconnect("body_shape_entered", talk_to_player_in_range)
				newtalkrange.disconnect("body_shape_exited", player_left)
				newtalkrange.queue_free()
	newicon.disconnect("animation_finished", done_thinking)

func reject_player_in_range(body_id, body, body_shape, area_shape):
	if body.is_in_group("israel"):
		$Muzzle.rotation = ($Muzzle.global_position - body.global_position).angle() + PI
		newrejection.disconnect("body_shape_entered", reject_player_in_range)
		
	else:
		$Muzzle.rotation_degrees = randf_range(0, 360)
	newbook.global_transform = $Muzzle.global_transform
	newrejection.queue_free()

func loved_it():
	newicon.play("love")
	acceptance_factor = acceptance_factor * 1.3
	if person_record:
		areabook._on_person_record_pressed(first_name, last_name, location, level, xp, acceptance_factor, pamphletInvite, bomInvite, churchInvite, baptismInvite)
	#newicon.pause()
	love = true
	if not person_record:
		newtalkrange = talkrange.instantiate()
		add_child(newtalkrange)
		newtalkrange.connect("body_shape_entered", talk_to_player_in_range)
		newtalkrange.connect("body_shape_exited", player_left)
		newtalkrange.connect("input_event", _on_talkrange_input_event)
	else:
		teachmode = true
		talkmode = false
	

func talk_to_player_in_range(body_id, body, body_shape, area_shape):
	if body.is_in_group("israel"):
		if not person_record:
			newicon.play("talk")
			body.talkmode = true
			talkmode = true
		else:
			if last_taught_day != global.day:
				newicon.play("teach")
				teachmode = true
				talkmode = false

func player_left(body_id, body, body_shape, area_shape):
	if body.is_in_group("israel"):
		if not newicon.animation == "thinking":
			newicon.play("love")
		body.talkmode = false
		talkmode = false
		teachmode = false


func _on_talkrange_input_event(viewport, event, shape_idx):
	if talkmode:
		if (event is InputEventMouseButton && event.pressed):
			person_record = global.create_new_person_record(
				first_name, last_name, position)
			$Name.set_text(first_name + " " + last_name)
			talkmode = false
			teachmode = true
			newicon.play("teach")
			global.connect("update_commitments", new_day)
	elif teachmode:
		if (event is InputEventMouseButton && event.pressed):
			emit_signal("being_taught", self)


func lesson_over():
	if xp != 0:
		if not new_person:
			global.new_person_found()
			new_person = true
			person_record.dot.update_color(Color("008c00"))
	last_taught_day = global.day
	teachmode = false
	newicon.speed_scale = 0.2
	newicon.play("thinking")
	add_xp(50)
	

func update_record():
	if person_record:
		person_record.location = position
		person_record.level = level
		person_record.xp = xp
		person_record.acceptance_factor = acceptance_factor
		person_record.pamphletInvite = pamphletInvite
		person_record.bomInvite = bomInvite
		person_record.churchInvite = churchInvite
		person_record.baptismInvite = baptismInvite
		person_record._on_pressed()

func new_day():
	randomize()
	var randnum = randf_range(0, level/2.0)
	if pamphletInvite == 1:
		if randnum < 1:
			pamphletInvite = 3
		else:
			pamphletInvite = 2
			add_xp(25)
	elif bomInvite == 1:
		if randnum < 2:
			bomInvite = 3
		else:
			bomInvite = 2
			add_xp(50)
	elif churchInvite == 1:
		if global.day % 7 == 0:
			if randnum < 3:
				churchInvite = 3
			else:
				churchInvite = 2
				emit_signal("attended_church")
				add_xp(100)
	elif baptismInvite == 1:
		pass
	update_record()

func add_xp(amount):
	xp_total += amount
	xp += amount
	var growth_data = []
	while xp >= levelformula:
		xp -= levelformula
		growth_data.append([levelformula, levelformula])
		
	growth_data.append([xp, levelformula])
	
	var xp_bar = areabook.get_node("ColorRect/PersonRecord/PersonInfo/XPBar")
	
	for x in growth_data:
		var target_xp = x[0]
		var max_xp = x[1]
		xp_bar.max_value = max_xp
		var tween = get_tree().create_tween()
		await tween.tween_property(xp_bar, "value", target_xp, 1.0/growth_data.size()).set_ease(Tween.EASE_OUT).finished
		if abs(xp_bar.max_value - xp_bar.value) < 0.01:
			xp_bar.value = xp_bar.min_value
			level_up()

func level_up():
	level += 1
	areabook.get_node("ColorRect/PersonRecord/PersonInfo/CurrentLevel/Level").set_text(str(level))
