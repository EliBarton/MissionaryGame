extends ColorRect

@onready var pmgfile = "res://Scriptures/pmgquotes.txt"
var at_line = 0

func _ready():
	load_file(pmgfile)

func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	var line = f.get_line()
	var k = at_line
	while k > 0:
		line = f.get_line()
		k -= 1
	var splitline = line.split("|")
	var numlines = int(splitline[0])
	var reference = splitline[1]
	var text = splitline[2]
	at_line += 1
	var i = numlines
	while i > 1:
		text = text + " "
		text = text + f.get_line()
		at_line += 1
		i -= 1
	$Quotes/Reference.set_text(reference)
	$Quotes/QuoteLabel.set_text(text)
	if f.get_position() >= f.get_length():
		at_line = 0
	f.close()

func new_day():
	load_file(pmgfile)
