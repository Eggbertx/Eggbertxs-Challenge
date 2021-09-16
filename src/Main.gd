extends Node

var df: DatFile

func load_file(file = ""):
	if file == "":
		$UI.alert("File path required", true)
		return
	Console.write_line("Loading %s" % file)
	var err = df.load_file(file)
	if err != "":
		$UI.alert(err, true)

func print_info():
	if df.file_path == "":
		Console.write_line("No dat file loaded")
		return
	Console.write_line("Currently loaded dat file: %s" % df.file_path)
	Console.write_line("Number of levels: %d" % df.num_levels)

func level_info(level):
	if df.file_path == "":
		$UI.alert("No dat file loaded", true)
		return
	if level == -1:
		$UI.alert("No level specified", true)
		return

	# Console.write_line("Level %d info:" % level)
	if !df.level_info(level):
		Console.write_line("Level #%d not found" % level)

func register_commands():
	Console.add_command("loadDAT", self, "load_file")\
		.set_description("Loads a Chip's Challenge-compatible DAT file")\
		.add_argument("file", TYPE_STRING, "The dat file to be loaded")\
		.register()

	Console.add_command("levelInfo", self, "level_info")\
		.set_description("Prints info about the current level")\
		.add_argument("level", TYPE_INT)\
		.register()

	Console.add_command("printInfo", self, "print_info")\
		.set_description("Prints info about the loaded dat file if one is currently loaded")\
		.register()

func _input(event):
	if event is InputEventKey:
		match event.scancode:
			KEY_ESCAPE:
				get_tree().quit(0)
			KEY_R:
				if event.control and !event.pressed:
					Console.write_line("Restarting level")

# Called when the node enters the scene tree for the first time.
func _ready():
	df = DatFile.new()
	register_commands()
	if df.default_exists():
		load_file("CHIPS.DAT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_UI_file_selected(path: String):
	load_file(path)
