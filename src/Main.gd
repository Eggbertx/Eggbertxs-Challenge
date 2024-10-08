extends Node

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
var df: DatFile
@export var time_left := -1
@export var current_level_no := 0
@onready var ui: UI = $CanvasLayer/UI
@onready var levelmap: LevelMap = $LevelMap
@onready var timer :Timer = $Timer

func load_file(file = ""):
	var err := ""
	if ui.file_mode == ui.FILEMODE_TILESET:
		err = levelmap.set_tileset(file, 32)
		if err != "":
			ui.alert(err)
		return
	if file == "":
		ui.alert("File path required", is_debug)
		return
	ui.panku_output("Loading %s" % file)
	err = df.load_file(file)
	if err != "":
		ui.alert(err, is_debug)
		return
	ui.set_max_level(df.num_levels)
	ui.enable_level_menu()
	load_level(1)

# load_level loads the level number (not the index in the array) and sets all the values (time, chips left, etc)
func load_level(level_no: int):
	var level_index := level_no - 1
	df.levels[level_index].apply_to(levelmap)
	levelmap.change_game_state(GameState.STATE_PAUSED)
	time_left = df.levels[level_index].time_limit
	
	ui.set_time_display(time_left, time_left > 0)
	ui.set_level_display(level_no)
	current_level_no = level_no
	ui.level_menu.set_item_disabled(LEVEL_ITEM_PREVIOUS, current_level_no < 2)
	ui.level_menu.set_item_disabled(LEVEL_ITEM_NEXT, current_level_no >= df.num_levels)

func print_info():
	if df.file_path == "":
		ui.panku_output("No dat file loaded")
		return
	ui.panku_output("Currently loaded dat file: %s" % df.file_path)
	ui.panku_output("Number of levels: %d" % df.num_levels)

func level_info(level):
	if df.file_path == "":
		ui.alert("No dat file loaded", is_debug)
		return
	if level == -1:
		ui.alert("No level specified", is_debug)
		return

	if !df.level_info(level):
		ui.alert("Level #%d not found" % level)

func quit(status:int = 0):
	df.queue_free()
	levelmap.queue_free()
	get_tree().quit(status)

func _input(event):
	if event is InputEventKey:
		var state := levelmap.get_game_state()
		match event.keycode:
			KEY_ESCAPE:
				if is_debug:
					quit()
			KEY_R:
				if event.control and !event.pressed: # Ctrl+R released
					ui.panku_output("Restarting level")
			KEY_PAUSE:
				if not event.pressed:
					if state == GameState.STATE_PAUSED:
						levelmap.change_game_state(GameState.STATE_PLAYING)
					elif state == GameState.STATE_PLAYING:
						levelmap.change_game_state(GameState.STATE_PAUSED)

func _init():
	PankuConfig.set_config({
		"native_logger": {
			"screen_overlay": PankuModuleNativeLogger.ScreenOverlayDisplayMode.NeverShow
		}
	})

func _ready():
	is_debug = OS.is_debug_build()
	df = DatFile.new()
	var datfile_path := df.get_default_file()
	if datfile_path == "":
		ui.alert("Unable to find a default super.dat file (checked CHIPS.DAT, chips.dat, and ec.dat)", "Error!")
		return
	load_file(datfile_path)
	ui.inventory_tiles = levelmap.tileset

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float):
# 	pass

func _on_ui_file_selected(path: String):
	load_file(path)

func _on_ui_game_item_selected(id):
	$CanvasLayer/UI/FileDialog.clear_filters()
	match id:
		GAME_ITEM_NEWGAME:
			ui.panku_output("Starting a new game")
		GAME_ITEM_PAUSE:
			var state := levelmap.get_game_state()
			if state == GameState.STATE_PAUSED:
				levelmap.change_game_state(GameState.STATE_PLAYING)
			elif state == GameState.STATE_PLAYING:
				levelmap.change_game_state(GameState.STATE_PAUSED)
		GAME_ITEM_DATFILE:
			ui.show_file_dialog(ui.FILEMODE_DATFILE)
		GAME_ITEM_TILESET:
			ui.show_file_dialog(ui.FILEMODE_TILESET)
		GAME_ITEM_MUSIC:
			ui.game_menu.toggle_item_checked(id)
			if ui.game_menu.is_item_checked(id):
				ui.panku_output("Playing music")
			else:
				ui.panku_output("Stopped playing music")
		GAME_ITEM_REPO:
			OS.shell_open(REPO_URL)
		GAME_ITEM_QUIT:
			quit()

func _on_ui_level_item_selected(id):
	match id:
		LEVEL_ITEM_RESTART:
			ui.panku_output("Restarting level")
			load_level(current_level_no)
		LEVEL_ITEM_NEXT:
			if df.num_levels > current_level_no:
				ui.panku_output("Loading next level")
				load_level(current_level_no + 1)
			else:
				ui.alert("No more levels", is_debug)
		LEVEL_ITEM_PREVIOUS:
			if current_level_no > 1:
				ui.panku_output("Loading previous level")
				load_level(current_level_no - 1)
		LEVEL_ITEM_GOTO:
			ui.show_goto()

func _on_ui_level_selected(level: int, password: String):
	if df.file_path == "":
		ui.alert("No datfile loaded")
		return

	var password_success := df.check_password(level, password)
	match password_success:
		DatFile.CORRECT_PASSWORD:
			ui.panku_output("Going to level %d" % level)
			load_level(level)
		DatFile.WRONG_PASSWORD:
			ui.alert("Wrong password")
		DatFile.NONEXISTENT_LEVEL:
			ui.alert("%s has fewer than %d levels" % [df.filename(), level])

func _on_LevelMap_update_chips_left(left: int):
	$CanvasLayer/UI/ChipsDisplay.show()
	$CanvasLayer/UI/ChipsDisplay.set_number(left)

func _on_level_map_player_reached_exit():
	if df.num_levels <= current_level_no:
		ui.panku_output("Finished last level")
		return
	ui.set_hint_visible(true, "Level cleared! Press Enter to continue.")

func _on_level_map_update_hint_status(visible: bool):
	ui.set_hint_visible(visible, levelmap.hint_text)

func _on_level_map_next_level_requested():
	if levelmap.get_game_state() != GameState.STATE_LEVEL_EXIT:
		return
	if df.num_levels <= current_level_no + 1:
		ui.alert("Finished last level")
		return
	ui.panku_output("Next level requested")
	load_level(current_level_no + 1)

func _on_level_map_pickup_item(item_code: int):
	ui.add_inventory(item_code)

func _on_level_map_remove_item(item_code: int):
	ui.remove_inventory(item_code)

func _on_Timer_timeout():
	if df.levels[current_level_no-1].time_limit == 0 or levelmap.get_game_state() != GameState.STATE_PLAYING:
		return
	time_left -= 1
	if time_left >= 0:
		$CanvasLayer/UI/TimeDisplay.set_number(time_left)
	if time_left <= 0:
		levelmap.change_game_state(GameState.STATE_OUT_OF_TIME)

func _on_level_map_game_state_changed(state: int, old_state: int):
	match state:
		GameState.STATE_PLAYING:
			ui.game_menu.set_item_disabled(GAME_ITEM_PAUSE, false)
			ui.game_menu.set_item_checked(GAME_ITEM_PAUSE, false)
			timer.start()
			if old_state == GameState.STATE_PAUSED:
				ui.panku_output("Game unpaused")
		GameState.STATE_PAUSED:
			ui.game_menu.set_item_disabled(GAME_ITEM_PAUSE, false)
			ui.game_menu.set_item_checked(GAME_ITEM_PAUSE, true)
			timer.stop()
			if old_state == GameState.STATE_PLAYING:
				ui.panku_output("Game paused")
		GameState.STATE_OUT_OF_TIME:
			ui.game_menu.set_item_disabled(GAME_ITEM_PAUSE, true)
			timer.stop()
			ui.alert("Out of time!", is_debug)
		GameState.STATE_LEVEL_EXIT:
			ui.game_menu.set_item_disabled(GAME_ITEM_PAUSE, true)
