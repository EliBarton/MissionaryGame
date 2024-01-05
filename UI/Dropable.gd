extends StaticBody2D

var occupied = false

var correct_word = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.MEDIUM_BLUE,0.7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Worldwide.is_dragging:
		if not occupied:
			visible = true
	else:
		visible = false
