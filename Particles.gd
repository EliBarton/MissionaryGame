extends CPUParticles2D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(global_position)
	pass


func _on_timer_timeout():
	queue_free()
