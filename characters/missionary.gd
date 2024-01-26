extends CharacterBody2D


const SPEED = 8000.0
const BASE_SPIRITUAL_RESILIENCE = 100.0

var book = preload("res://book.tscn")
var talkmode = false
var mouse_in_viewport = true
var negative_sr = false
var movable = true
@onready var global = get_node("/root/Game Master")
@onready var RSBar = get_parent().get_node("UI/RSBar")
var spiritual_resilience = 0
@export var apply_sr = true

func _ready():
	if apply_sr:
		spiritual_resilience = BASE_SPIRITUAL_RESILIENCE + 5
		RSBar.max_value = spiritual_resilience
		RSBar.value = spiritual_resilience

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("east") - Input.get_action_strength("west")
	input_vector.y = Input.get_action_strength("south") - Input.get_action_strength("north")
	input_vector = input_vector.normalized()
	var movementspeed = SPEED + (500*Worldwide.cardio)
	if input_vector and movable:
		velocity = input_vector * movementspeed * delta
		if apply_sr:
			lose_sr(Vector2(0, 0).distance_to(velocity)/2000.0)
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
	if Input.is_action_just_pressed("shoot") and $Camera.mouse_position.distance_to(to_local(get_global_mouse_position())) < 5:
		if not talkmode:
			var newbook = book.instantiate()
			get_parent().add_child(newbook)
			newbook.global_transform = $Muzzle.global_transform
		else:
			pass
	if apply_sr:
		RSBar.value = lerp(RSBar.value, float(spiritual_resilience), .1)

func missionary():
	pass

func new_day():
	spiritual_resilience = BASE_SPIRITUAL_RESILIENCE + (5*global.day) + (10*Worldwide.diligence)
	RSBar.max_value = spiritual_resilience
	RSBar.value = spiritual_resilience
	negative_sr = false
	movable = true

func received_material(type):
	if type == 1:
		lose_sr(randi_range(25, 50))
	else:
		lose_sr(randi_range(15, 30))

func lose_sr(amount):
	spiritual_resilience -= amount
	if amount > 5:
		Worldwide.hit_stop()
		$Camera.add_trauma(1)
	if spiritual_resilience <= 0:
		var tween = get_tree().create_tween()
		movable = false
		await tween.tween_property(RSBar, "value", 0, .5).set_ease(Tween.EASE_OUT).finished
		if negative_sr == false:
			global.new_day()
			negative_sr = true
	





func _on_timer_timeout():
	lose_sr(1)
	$Timer.start()
