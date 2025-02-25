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
var target_pos = Vector2()
var stop_distance = 30.0
var follow_speed = 110.0
const ACCELERATION = 800.0
@export var apply_sr = true

var is_dragging := false
var drag_start_pos := Vector2.ZERO
var drag_threshold := 10.0
var drag_start_player_pos := Vector2.ZERO

func _ready():
	if apply_sr:
		spiritual_resilience = BASE_SPIRITUAL_RESILIENCE + 5
		RSBar.max_value = spiritual_resilience
		RSBar.value = spiritual_resilience

func _physics_process(delta):
	target_pos = $NavAgent.get_final_position()
	var direction = to_local($NavAgent.get_next_path_position()).normalized()
	var distance = global_position.distance_to(target_pos)
	
	if distance > stop_distance:
		velocity = velocity.move_toward(direction * follow_speed, ACCELERATION * delta)
		if apply_sr:
			lose_sr(0.1)
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_start_pos = get_global_mouse_position()
			drag_start_player_pos = global_position
			is_dragging = true
		else:
			is_dragging = false
			var drag_end_pos = get_global_mouse_position()
			var player_movement = global_position - drag_start_player_pos
			var adjusted_drag_end_pos = drag_end_pos - player_movement
			var drag_distance = drag_start_pos.distance_to(adjusted_drag_end_pos)
			
			if drag_distance < drag_threshold:
				# Short click: Move to position
				$NavAgent.target_position = drag_end_pos
			else:
				# Drag: Throw projectile
				$Muzzle.rotation = drag_start_pos.direction_to(drag_end_pos).angle()
				throw_book()

func throw_book():
	if not talkmode:
		var newbook = book.instantiate()
		get_parent().add_child(newbook)
		newbook.global_transform = $Muzzle.global_transform
	else:
		pass

func _process(delta):
	#Handle the throwing of the teaching material
	$Muzzle.look_at(get_global_mouse_position())
	
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
	stop_moving()

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
	

func stop_moving():
	$NavAgent.target_position = global_position + to_local($NavAgent.get_next_path_position()).normalized()*stop_distance



func _on_timer_timeout():
	lose_sr(1)
	$Timer.start()
