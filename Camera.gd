extends Camera2D

var lean_scale = 0.2

# Reference to the Player node
@onready var player := get_parent()

@export var decay = 2  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
var trauma = 0.0  # Current shake strength.
var trauma_power = 2

func _ready():
	randomize()
	#noise.octaves = 2.0

func _process(delta):
	#var mouse_position = get_viewport().get_mouse_position()
	var mouse_position = get_global_mouse_position()
	mouse_position = to_local(mouse_position)
	mouse_position.x = clamp(mouse_position.x, -get_viewport_rect().size.x/4, get_viewport_rect().size.x/4)
	mouse_position.y = clamp(mouse_position.y, -get_viewport_rect().size.y/4, get_viewport_rect().size.y/4)
	var direction_to_mouse := (mouse_position - position).normalized()
	var distance_to_mouse = mouse_position.distance_to(position)
	var lean = direction_to_mouse * distance_to_mouse * lean_scale
	print(mouse_position)
	
	offset = lerp(offset, lean, delta * 10.0)
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func shake():
	offset.x += randf_range(-10, 10)*trauma
	offset.y += randf_range(-10, 10)*trauma
