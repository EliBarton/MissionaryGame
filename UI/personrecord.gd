extends Button

var first_name = ""
var last_name = ""
var location = Vector2()
var level = 1
var acceptance_factor = 0.8
var xp = 0
var dot = null

var pamphletInvite = 0
var bomInvite = 0
var churchInvite = 0
var baptismInvite = 0

signal picked
# Called when the node enters the scene tree for the first time.
func _ready():
	$Name.set_text(first_name + " " + last_name)
	$AnimationPlayer.play("appear")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	emit_signal("picked", first_name, last_name, location, level, xp, acceptance_factor, pamphletInvite, bomInvite, churchInvite, baptismInvite)
