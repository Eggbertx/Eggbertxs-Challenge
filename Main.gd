extends Node

var df: DatFile

func load_file(file):
	df.load_file(file)
	Console.write_line("Number of levels in %s: %d" % [file, df.num_levels])

func print_info():
	Console.write_line("Info:")

func register_commands():
	Console.add_command("loadDAT", self, "load_file")\
		.set_description("Loads a Chip's Challenge-compatible DAT file")\
		.add_argument("datfile", TYPE_STRING)\
		.register()
		
	Console.add_command("printInfo", self, "print_info")\
		.set_description("Prints info about the loaded DAT file if one is currently loaded")\
		.register()

func _input(event):
	if event is InputEventKey:
		match event.scancode:
			KEY_ESCAPE:
				get_tree().quit(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	df = DatFile.new()
	register_commands()
	# df.load_file("CHIPS.DAT")
	# print(df.num_levels)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
