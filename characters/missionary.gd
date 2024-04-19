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
var target_pos = Vector2()
var stop_distance = 30.0
var follow_speed = 140.0
const ACCELERATION = 800.0

func _ready():
	if apply_sr:
		spiritual_resilience = BASE_SPIRITUAL_RESILIENCE + 5
		RSBar.max_value = spiritual_resilience
		RSBar.value = spiritual_resilience

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	target_pos = $NavAgent.get_final_position()
	var direction = to_local($NavAgent.get_next_path_position()).normalized()
	var distance = global_position.distance_to(target_pos)
	
	if distance > stop_distance:
		velocity = velocity.move_toward(direction * follow_speed, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta * 0.5)
	
	#Handle the sprite animation
	if velocity != Vector2.ZERO:
		var angle = wrapi(ceil(direction.angle() / (PI/4)), 0, 8)
		$Sprite.play(str(angle))
	else:
		$Sprite.frame = 0
		$Sprite.pause()
	if velocity != Vector2.ZERO:
		move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
		$NavAgent.target_position = get_global_mouse_position()




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
