extends Control

var dragable = false
var is_inside_dropable = false
var body_ref
var areaInitialPos: Vector2
var initialPos: Vector2
var offset: Vector2

var word = ""
var correct = false

@onready var global = get_node("/root/Game Master")

func _ready():
	#$Area2D/CollisionShape2D.shape.extents = $Label.get_rect().size
	pass

func initialize(text):
	word = text
	$Area2D/Label.set_text(text)
	var length = ($Area2D/Label.get_total_character_count() + .5) * 12
	$Area2D/Label.custom_minimum_size.x = length
	#$Area2D.position = $Area2D/Label.position
	$Area2D/CollisionShape2D.shape.extents.x = length/1.5
	custom_minimum_size.x = 40 + length
	#custom_minimum_size.y = length*3
	#$Area2D.position.x += length*2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if dragable:
		if not correct:
			if Input.is_action_just_pressed("shoot"):
				initialPos = global_position
				offset = get_global_mouse_position()
				global.is_dragging = true
				is_inside_dropable = false
				if body_ref:
					body_ref.occupied = false
			if Input.is_action_pressed("shoot"):
				global_position = get_global_mouse_position()
			if Input.is_action_just_released("shoot"):
				global.is_dragging = false
				var tween = get_tree().create_tween()
				if is_inside_dropable:
					tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
					body_ref.occupied = true
					if word == body_ref.correct_word:
						dragable = false
						correct = true
						global.numwrong -= 1
				else:
					await tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT).finished
					if body_ref:
						is_inside_dropable = false
						body_ref.occupied = false
					#body_ref = null


func _on_area_2d_mouse_entered():
	if not global.is_dragging:
		dragable = true
		scale = Vector2(1.05,1.05)
		if global.selected_draggable:
			global.selected_draggable.dragable = false
		global.selected_draggable = self


func _on_area_2d_mouse_exited():
	if not global.is_dragging:
		dragable = false
		scale = Vector2(1,1)
		if global.selected_draggable == self:
			global.selected_draggable = null



func _on_area_2d_body_entered(body):
	if body.is_in_group("dropzone"):
		if not body.occupied:
			is_inside_dropable = true
			body.modulate = Color(Color.MEDIUM_BLUE, 1)
			body_ref = body



func _on_area_2d_body_exited(body):
	if body.is_in_group("dropzone"):
		if body_ref:
			body_ref.occupied = false
		if body_ref == body:
			is_inside_dropable = false
		else:
			if not body.occupied:
				pass
				#body_ref = body
		body.modulate = Color(Color.MEDIUM_BLUE, 0.7)
