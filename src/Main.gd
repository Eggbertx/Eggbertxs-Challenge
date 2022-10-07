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
var ticker = 0.0
var paused = true
var time_left = -1

func load_file(file = ""):
	if $UI.file_mode == $UI.FILEMODE_TILESET:
		var err = $LevelMap.set_tileset(file, 32)
		if err != "":
			$UI.alert(err)
		return
	if file == "":
		$UI.alert("File path required", is_debug)
		return
	Console.write_line("Loading %s" % file)
	var err = df.load_file(file)
	if err != "":
		$UI.alert(err, is_debug)
		return
	$UI.set_max_level(df.num_levels)
	$UI.enable_level_menu()
	paused = false
	$UI/TimeDisplay.show()
	$UI/LevelDisplay.set_number(1)
	$UI/LevelDisplay.show()
	df.levels[0].apply_to($LevelMap)
	$LevelMap.center_camera()

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


func quit(status:int = 0):
	df.queue_free()
	get_tree().quit(status)

func _input(event):
	if event is InputEventKey:
		match event.scancode:
			KEY_ESCAPE:
				if is_debug:
					quit()
			KEY_R:
				if event.control and !event.pressed: # Ctrl+R released
					Console.write_line("Restarting level")
			KEY_PAUSE:
				if not event.pressed:
					paused = not paused

func _ready():
	is_debug = OS.is_debug_build()
	df = DatFile.new()
	register_commands()
	$LevelMap.viewport_offset = $UI/ViewWindow.rect_position
	$LevelMap.position = $UI/ViewWindow.rect_position
	var datfile_path = df.get_default_file()
	if datfile_path == "":
		$UI.alert("Unable to find a default .dat file (checked CHIPS.DAT, chips.dat, and ec.dat)", "Error!")
		return
	load_file(datfile_path)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if not paused:
		ticker += delta
		if ticker >= 1:
			# if time_left < 0, no time limit
			if time_left > 0:
				time_left -= 1
				$UI/TimeDisplay.set_number(time_left)
			elif time_left == 0:
				print("out of time :(")
				$LevelMap.emit_signal("out_of_time")
				paused = true
			ticker = 0

func _on_UI_file_selected(path: String):
	load_file(path)

func _on_UI_game_item_selected(id):
	$UI/FileDialog.clear_filters()
	match id:
		GAME_ITEM_NEWGAME:
			Console.write_line("Starting a new game")
		GAME_ITEM_PAUSE:
			$UI.game_menu.toggle_item_checked(id)
			if $UI.game_menu.is_item_checked(id):
				Console.write_line("Pausing level")
				paused = true
			else:
				Console.write_line("Unpausing level")
				paused = false
		GAME_ITEM_DATFILE:
			$UI.show_file_dialog($UI.FILEMODE_DATFILE)
		GAME_ITEM_TILESET:
			$UI.show_file_dialog($UI.FILEMODE_TILESET)
		GAME_ITEM_MUSIC:
			$UI.game_menu.toggle_item_checked(id)
			if $UI.game_menu.is_item_checked(id):
				Console.write_line("Playing music")
			else:
				Console.write_line("Stopped playing music")
		GAME_ITEM_REPO:
			OS.shell_open(REPO_URL)
		GAME_ITEM_QUIT:
			quit()

func _on_UI_level_item_selected(id):
	match id:
		LEVEL_ITEM_RESTART:
			Console.write_line("Restarting level")
		LEVEL_ITEM_NEXT:
			Console.write_line("Next level")
		LEVEL_ITEM_PREVIOUS:
			Console.write_line("Previous level")
		LEVEL_ITEM_GOTO:
			$UI.show_goto()

func _on_UI_level_selected(level:int, password:String):
	if df.file_path == "":
		$UI.alert("No datfile loaded")
		return

	var password_success = df.check_password(level, password)
	match password_success:
		DatFile.CORRECT_PASSWORD:
			Console.write_line("Going to level %d" % level)
		DatFile.WRONG_PASSWORD:
			$UI.alert("Wrong password")
		DatFile.NONEXISTENT_LEVEL:
			$UI.alert("%s has fewer than %d levels" % [df.filename(), level])

func _on_LevelMap_update_chips_left(left: int):
	$UI/ChipsDisplay.show()
	$UI/ChipsDisplay.set_number(left)

func _on_LevelMap_player_reached_exit():
	print("Exit reached")

func _on_LevelMap_update_time_limit(limit: int):
	if limit > 0:
		$UI/TimeDisplay.set_number(limit)
		time_left = limit