extends CharacterBody2D

@onready var global = get_node("/root/Game Master")
@onready var areabook = get_node("/root/Game Master/UI/Areabook")
@onready var player = get_node("/root/Game Master/SubViewportContainer/SubViewport/Level/Missionary")
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
var xp : int = 0
var xp_total = 0
var person_record
var location = Vector2()
@export var acceptance_factor = 0.95
var new_person = false
var last_taught_day = 0
var kept_last_commitment = false
var speed = 60.0
var stop_distance = 20.0
const ACCELERATION = 1200.0
var home_point = Vector2()

var dialog_box = preload("res://UI/dialog_box.tscn")

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
	home_point = global_position

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"path" : get_path(),
		"new_person" : new_person,
		#"first_name" : first_name,
		#"last_name" : last_name,
		"pos_x" : position.x,
		"pos_y" : position.y,
		#"icon" : newicon,
		"love" : love,
		"talkmode" : talkmode,
		"teachmode" : teachmode,
		#"talkrange" : talkrange,
		"level" : level,
		"xp" : xp,
		"xp_total" : xp_total,
		#"person_record" : null,
		"acceptance_factor" : acceptance_factor,
		"last_taught_day" : last_taught_day,
		"kept_last_commitment" : kept_last_commitment,
		"pamphletInvite" : pamphletInvite,
		"bomInvite" : bomInvite,
		"churchInvite" : churchInvite,
		"baptismInvite" : baptismInvite 
	}
	return save_dict

func _process(delta):
	if teachmode or talkmode:
		var look_vector = -(global_position - player.global_position).normalized()
		var angle = wrapi(int(look_vector.angle() / (PI/4)), 0, 8)
		$Sprite.play(str(angle))
		$Sprite.frame = 0
	else:
		var direction = to_local($NavAgent.get_next_path_position()).normalized()
		var distance = $NavAgent.distance_to_target()
		# Move the object towards the player
		if distance > stop_distance:
			velocity = velocity.move_toward(direction * speed, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta * 0.5)
		if velocity != Vector2.ZERO:
			var angle = wrapi(ceil(direction.angle() / (PI/4)), 0, 8)
			$Sprite.play(str(angle))
		else:
			$Sprite.frame = 0
			$Sprite.pause()
		move_and_slide()
	if person_record:
		person_record.xp = xp
		person_record.level = level
		person_record.acceptance_factor = acceptance_factor
		person_record.location = global_position

func received_material(type):
	if love:
		pass
	else:
		rejectionInitiated = false
		if newicon != null:
			newicon.queue_free()
		if type == 1:
			create_new_icon()
			newicon.play("thinking")

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
			 level, xp, acceptance_factor, null, null, null, null)
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

func reject_player_in_range(_body_id, body, _body_shape, _area_shape):
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
		create_new_talk_range()
	else:
		teachmode = true
		talkmode = false
	

func talk_to_player_in_range(_body_id, body, _body_shape, _area_shape):
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

func player_left(_body_id, body, _body_shape, _area_shape):
	if body.is_in_group("israel"):
		if not newicon.animation == "thinking":
			newicon.play("love")
		body.talkmode = false
		talkmode = false
		teachmode = false


func _on_talkrange_input_event(_viewport, event, _shape_idx):
	if talkmode:
		if (event is InputEventMouseButton && event.pressed):
			create_new_person_record()
			talkmode = false
			teachmode = true
			newicon.play("teach")
			global.connect("update_commitments", new_day)
			create_dialog_box("newperson1")
			$Name.set_text(first_name + " " + last_name)
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
	add_xp(randi_range(10, 20))
	

func update_record():
	if person_record:
		person_record.location = global_position
		person_record.level = level
		person_record.xp = xp
		person_record.acceptance_factor = acceptance_factor
		person_record.pamphletInvite = pamphletInvite
		person_record.bomInvite = bomInvite
		person_record.churchInvite = churchInvite
		person_record.baptismInvite = baptismInvite
		person_record._on_pressed()

func new_day():
	if not newicon:
		create_new_icon()
	newicon.play("love")
	randomize()
	var randnum = randf_range(0, level)
	if pamphletInvite == 1:
		if randnum < 1:
			pamphletInvite = 3
			kept_last_commitment = false
		else:
			pamphletInvite = 2
			kept_last_commitment = true
			add_xp(randi_range(15, 25))
	elif bomInvite == 1:
		if randnum < 3:
			kept_last_commitment = false
			bomInvite = 3
		else:
			bomInvite = 2
			kept_last_commitment = true
			add_xp(randi_range(25, 35))
	if churchInvite == 1:
		if global.day % 7 == 0:
			if randnum < 1:
				kept_last_commitment = false
				churchInvite = 3
			else:
				churchInvite = 2
				kept_last_commitment = true
				print("person came to church")
				emit_signal("attended_church", self)
				add_xp(randi_range(40, 75))
	if baptismInvite == 1:
		pass
	update_record()

func calculate_level_xp(num = level):
	var levelformula = Expression.new()
	levelformula.parse("(x * 5) + 7.7", ["x"])
	return levelformula.execute([num])

func add_xp(amount):
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

func create_dialog_box(text_code):
	var new_dialog = dialog_box.instantiate()
	global.get_node("UI").add_child(new_dialog)
	#new_dialog.scale = new_dialog.scale / $Missionary/Camera2D.zoom
	new_dialog.connect("finished", on_dialog_finished)
	new_dialog.initialize(text_code, true)
	global.process_mode = Node.PROCESS_MODE_DISABLED

func on_dialog_finished():
	global.process_mode = Node.PROCESS_MODE_ALWAYS
	areabook._on_button_people_pressed()

func create_new_person_record():
	person_record = global.create_new_person_record(first_name, last_name, global_position)
	update_record()

func create_new_icon():
	newicon = icons.instantiate()
	add_child(newicon)
	newicon.position.y = -40
	
	newicon.connect("animation_finished", done_thinking)

func create_new_talk_range():
	newtalkrange = talkrange.instantiate()
	add_child(newtalkrange)
	newtalkrange.connect("body_shape_entered", talk_to_player_in_range)
	newtalkrange.connect("body_shape_exited", player_left)
	newtalkrange.connect("input_event", _on_talkrange_input_event)

func load_profile():
	create_new_person_record()
	create_new_icon()
	newicon.play("love")
	create_new_talk_range()
	global.connect("update_commitments", new_day)
	$Name.set_text(first_name + " " + last_name)


func _on_timer_timeout():
	var rand_time = randf_range(10, 35)
	$Timer.start(rand_time)
	if randf() > .2:
		var rand_x = randi_range(-500, 500)
		var rand_y = randi_range(-500, 500)
		$NavAgent.target_position = global_position + Vector2(rand_x, rand_y)
	else:
		$NavAgent.target_position = home_point
