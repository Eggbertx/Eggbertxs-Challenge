extends Node

var df: DatFile

enum {
	GAME_ITEM_NEWGAME,
	GAME_ITEM_PAUSE,
	GAME_ITEM_DATFILE,
	GAME_ITEM_TILESET,
	GAME_ITEM_MUSIC,
	GAME_ITEM_SEPARATOR,
	GAME_ITEM_REPO,
	GAME_ITEM_QUIT
}
enum {
	LEVEL_ITEM_RESTART,
	LEVEL_ITEM_NEXT,
	LEVEL_ITEM_PREVIOUS,
	LEVEL_ITEM_GOTO
}

const REPO_URL = "https://github.com/Eggbertx/Eggbertxs-Challenge"
var is_debug: bool

func load_file(file = ""):
	if file == "":
		$UI.alert("File path required", is_debug)
		return
	Console.write_line("Loading %s" % file)
	var err = df.load_file(file)
	if err != "":
		$UI.alert(err, is_debug)
		return

func print_info():
	if df.file_path == "":
		Console.write_line("No dat file loaded")
		return
	Console.write_line("Currently loaded dat file: %s" % df.file_path)
	Console.write_line("Number of levels: %d" % df.num_levels)

func level_info(level):
	if df.file_path == "":
		$UI.alert("No dat file loaded", is_debug)
		return
	if level == -1:
		$UI.alert("No level specified", is_debug)
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
				if is_debug:
					get_tree().quit(0)
			KEY_R:
				if event.control and !event.pressed:
					Console.write_line("Restarting level")

func _ready():
	is_debug = OS.is_debug_build()
	df = DatFile.new()
	register_commands()
	if df.default_exists():
		load_file("CHIPS.DAT")

	# var toolbar_height = $UI/Panel/HBoxContainer.rect_size.y
	$LevelMap.position = $UI/ViewWindow.rect_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_UI_file_selected(path: String):
	load_file(path)

func _on_UI_game_item_selected(id):
	$UI/FileDialog.clear_filters()
	match id:
		GAME_ITEM_NEWGAME:
			Console.write_line("Starting a new game")
		GAME_ITEM_PAUSE:
			Console.write_line("Pausing level")
		GAME_ITEM_DATFILE:
			if $UI/FileDialog.visible:
				return
			$UI/FileDialog.add_filter("*.dat ; CC levelset")
			$UI/FileDialog.popup()
		GAME_ITEM_TILESET:
			if $UI/FileDialog.visible:
				return
			$UI/FileDialog.add_filter("*.png, *.bmp, *.gif ; Tileset")
			$UI/FileDialog.popup()
		GAME_ITEM_MUSIC:
			$UI.game_menu.toggle_item_checked(id)
			if $UI.game_menu.is_item_checked(id):
				Console.write_line("Playing music")
			else:
				Console.write_line("Stopped playing music")
		GAME_ITEM_REPO:
			OS.shell_open(REPO_URL)
		GAME_ITEM_QUIT:
			get_tree().quit(0)

func _on_UI_level_item_selected(id):
	match id:
		LEVEL_ITEM_RESTART:
			Console.write_line("Restarting level")
		LEVEL_ITEM_NEXT:
			Console.write_line("Next level")
		LEVEL_ITEM_PREVIOUS:
			Console.write_line("Previous level")
		LEVEL_ITEM_GOTO:
			Console.write_line("Going to level")
