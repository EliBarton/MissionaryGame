extends Button

signal selected


func _on_pressed():
	emit_signal("selected", self)
