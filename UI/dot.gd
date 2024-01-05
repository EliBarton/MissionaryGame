extends Sprite2D

const OFFSET = Vector2(-10, -10)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func update_position(new_pos):
	position = new_pos + OFFSET

func update_color(new_col):
	modulate = new_col
