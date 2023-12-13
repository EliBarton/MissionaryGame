extends CPUParticles2D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(global_position)


func _on_timer_timeout():
	queue_free()
