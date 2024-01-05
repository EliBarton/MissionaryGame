extends Area2D

@onready var global = get_node("/root/Game Master")
var direction
var rejected = false
@export var speed : float
@export var lifetime : float
@export var type : float
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start(lifetime)

func _physics_process(delta):
	if speed > 100:
		speed -= speed * delta
	else:
		speed -= speed*5 * delta
	position += transform.x * speed * delta
	$Sprite2D.rotate(speed/1000)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_area_entered(area):
	if rejected == false:
		if area.get_parent().is_in_group("gentiles") && area.name == "Hitbox":
			$HitParticles.emitting = true
			var target = area.get_parent()
			if target.has_method("received_material"):
				target.received_material(type)
			queue_free()
	else:
		if area.get_parent().is_in_group("israel") && area.name == "Hitbox":
			var target = area.get_parent()
			if target.has_method("received_material"):
				target.received_material(type)
			queue_free()


func _on_timer_timeout():
	queue_free()
