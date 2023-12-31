extends Control

var dragable = false
var is_inside_dropable = false
var body_ref
var areaInitialPos: Vector2
var initialPos: Vector2
var offset: Vector2

var word = ""
var correct = false

func _ready():
	initialPos = global_position
	pass

func initialize(text):
	word = text
	$Area2D/Label.set_text(text)
	var length = ($Area2D/Label.get_total_character_count() + .5) * 12
	$Area2D/Label.custom_minimum_size.x = length
	#$Area2D.position = $Area2D/Label.position
	$Area2D/CollisionShape2D.shape.extents.x = length/1.5
	custom_minimum_size.x = 40 + length
	initialPos = global_position
	
	#custom_minimum_size.y = length*3
	#$Area2D.position.x += length*2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if dragable:
		if not correct:
			if Input.is_action_just_pressed("shoot"):
				initialPos = global_position
				offset = get_global_mouse_position()
				Worldwide.is_dragging = true
				is_inside_dropable = false
				if body_ref:
					body_ref.occupied = false
			if Input.is_action_pressed("shoot"):
				global_position = get_global_mouse_position()
			if Input.is_action_just_released("shoot"):
				Worldwide.is_dragging = false
				var tween = get_tree().create_tween()
				print(tween.is_running())
				if is_inside_dropable:
					print("inside droppable")
					tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
					body_ref.occupied = true
					if word == body_ref.correct_word:
						dragable = false
						correct = true
						Worldwide.numwrong -= 1
				else:
					print("returning to previous position " + str(initialPos))
					#tween.stop()
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
					#global_position = initialPos
					if body_ref:
						is_inside_dropable = false
						body_ref.occupied = false
					#body_ref = null


func _on_area_2d_mouse_entered():
	if not Worldwide.is_dragging:
		dragable = true
		scale = Vector2(1.05,1.05)
		if Worldwide.selected_draggable:
			Worldwide.selected_draggable.dragable = false
		Worldwide.selected_draggable = self


func _on_area_2d_mouse_exited():
	if not Worldwide.is_dragging:
		dragable = false
		scale = Vector2(1,1)
		if Worldwide.selected_draggable == self:
			Worldwide.selected_draggable = null



func _on_area_2d_body_entered(body):
	print("body entered")
	if body.is_in_group("dropzone"):
		if not body.occupied:
			is_inside_dropable = true
			body.modulate = Color(Color.MEDIUM_BLUE, 1)
			body_ref = body



func _on_area_2d_body_exited(body):
	if body.is_in_group("dropzone"):
		if body_ref == body:
			is_inside_dropable = false
			body_ref.occupied = false
		else:
			if not body.occupied:
				pass
				#body_ref = body
		body.modulate = Color(Color.MEDIUM_BLUE, 0.7)
