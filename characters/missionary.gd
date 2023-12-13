extends CharacterBody2D


const SPEED = 6000.0
const BASE_SPIRITUAL_RESILIENCE = 50

var book = preload("res://book.tscn")
var talkmode = false
var mouse_in_viewport = true
@onready var global = get_node("/root/Game Master")
@onready var spiritual_resilience = BASE_SPIRITUAL_RESILIENCE


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("east") - Input.get_action_strength("west")
	input_vector.y = Input.get_action_strength("south") - Input.get_action_strength("north")
	input_vector = input_vector.normalized()
	var movementspeed = SPEED + (500*global.cardio)
	if input_vector:
		velocity = input_vector * movementspeed * delta
	else:
		velocity -= velocity*10 * delta
	
	#Handle the sprite animation
	if input_vector.length() != 0:
		var angle = wrapi(int(input_vector.angle() / (PI/4)), 0, 8)
		$Sprite.play(str(angle))
	else:
		$Sprite.frame = 0
		$Sprite.pause()

	move_and_slide()

func _process(_delta):
	#Handle the throwing of the teaching material
	$Muzzle.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot") and get_viewport().NOTIFICATION_VP_MOUSE_ENTER:
		if not talkmode:
			var newbook = book.instantiate()
			get_parent().add_child(newbook)
			newbook.global_transform = $Muzzle.global_transform
		else:
			pass

func missionary():
	pass

func new_day():
	$RSBar.value = BASE_SPIRITUAL_RESILIENCE

func received_material(type):
	if type == 1:
		lose_sr(randi_range(25, 50))
	else:
		lose_sr(randi_range(15, 30))

func lose_sr(amount):
	spiritual_resilience -= amount
	var tween = get_tree().create_tween()
	if spiritual_resilience <= 0:
		await tween.tween_property($RSBar, "value", 0, .5).set_ease(Tween.EASE_OUT).finished
		global.new_day()
	else:
		tween.tween_property($RSBar, "value", spiritual_resilience, .5).set_ease(Tween.EASE_OUT)
