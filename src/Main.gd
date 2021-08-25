extends Node

var df: DatFile

func load_file(file = ""):
	if file == "":
		Console.write_line("File path required")
		return
	Console.write_line("Loading %s" % file)
	df.load_file(file)

func print_info():
	if df.file_path == "":
		Console.write_line("No dat file loaded")
		return
	Console.write_line("Currently loaded dat file: %s" % df.file_path)
	Console.write_line("Number of levels: %d" % df.num_levels)

func level_info(level = -1):
	if df.file_path == "":
		Console.write_line("No dat file loaded")
		return
	if level == -1:
		Console.write_line("No level specified")
		return

	Console.write_line("Level %d info:" % level)
	Console.write_line("(todo)")

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

# Called when the node enters the scene tree for the first time.
func _ready():
	df = DatFile.new()
	register_commands()
	load_file("CHIPS.DAT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LoaderScreen_file_selected(path: String) -> void:
	load_file(path)

func _on_UI_file_dialog_opened():
	$LoaderScreen.set_visibility(false)

func _on_UI_file_dialog_visible_changed(visibility: bool):
	$LoaderScreen.set_visibility(!visibility)
