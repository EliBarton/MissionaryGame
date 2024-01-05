extends CharacterBody2D

@onready var companion = get_parent().get_node("Missionary")
@onready var followpoint = get_parent().get_node("Missionary/CollisionShape2D")

var follow_speed = 140.0
var stop_distance = 50.0
const ACCELERATION = 800.0

func _process(delta: float):
	if companion:
		if is_on_wall():
			velocity = velocity/2
			await get_tree().create_timer(.3).timeout
		# Calculate the direction to the player
		var direction = (companion.global_position - global_position).normalized()
		var distance = global_position.distance_to(companion.global_position)
		# Move the object towards the player
		if distance > stop_distance:
			velocity = velocity.move_toward(direction * follow_speed, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta * 0.5)
		if velocity != Vector2.ZERO:
			var angle = wrapi(ceil(direction.angle() / (PI/4)), 0, 8)
			$Sprite.play(str(angle))
		else:
			$Sprite.frame = 0
			$Sprite.pause()
		if velocity != Vector2.ZERO:
			move_and_slide()
