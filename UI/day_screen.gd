extends ColorRect

@onready var pmgfile = "res://Scriptures/pmgquotes.json"
var at_line = 0

func _ready():
	load_file(pmgfile)

func load_file(file):
	#Loads JSON files
	var f = FileAccess.open(file, FileAccess.READ)
	var library = JSON.parse_string(f.get_as_text())
	var rand_list = library[str(randi_range(1, library.size()))].duplicate()
	var reference = rand_list[0]
	var quote = rand_list[1]
	$Quotes/Reference.set_text(reference)
	$Quotes/QuoteLabel.set_text(quote)
	f.close()

func new_day():
	load_file(pmgfile)

func update_names():
	$Control/Label.set_text("Elder " + Worldwide.missionary1name + " & Elder " + Worldwide.missionary2name)
