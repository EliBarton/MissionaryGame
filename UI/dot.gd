extends CanvasGroup

const OFFSET = Vector2(-10, -10)
# Called when the node enters the scene tree for the first time.
func _ready():
	print("new dot created")
	pass




func update_position(new_pos):
	global_position = new_pos + OFFSET

func update_color(new_col):
	$Dot.modulate = new_col
