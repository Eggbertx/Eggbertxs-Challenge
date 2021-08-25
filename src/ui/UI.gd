extends Control

signal file_dialog_visible_changed
signal file_selected

onready var game_menu = $Panel/HBoxContainer/MenuButton.get_popup()

enum {ITEM_NEWGAME, ITEM_RESTARTLVL, ITEM_DATFILE, ITEM_MUSIC, SEPARATOR, ITEM_REPO, ITEM_QUIT}
const REPO_URL = "https://github.com/Eggbertx/Eggbertxs-Challenge"


func _ready() -> void:
	game_menu.connect("id_pressed", self, "handle_menu")
	$FileDialog.add_filter("*.dat ; CC levelset")

func handle_menu(id):
	# Console.write_line("Selected item text: %s" % menu.get_item_text(id))
	var checked = false
	if game_menu.is_item_checkable(id):
		game_menu.toggle_item_checked(id)
		checked = game_menu.is_item_checked(id)
	match id:
		ITEM_NEWGAME:
			Console.write_line("Starting a new game")
		ITEM_RESTARTLVL:
			Console.write_line("Restarting level")
		ITEM_DATFILE:
			if $FileDialog.visible:
				return
			$FileDialog.mode = FileDialog.MODE_OPEN_FILE
			$FileDialog.access = FileDialog.ACCESS_FILESYSTEM
			$FileDialog.popup()
		ITEM_MUSIC:
			if checked:
				Console.write_line("Playing music")
			else:
				Console.write_line("Stopped playing music")
		ITEM_REPO:
			OS.shell_open(REPO_URL)
		ITEM_QUIT:
			Console.write_line("Goodbye")
			get_tree().quit(0)


func _on_FileDialog_file_selected(path):
	Console.write_line("Loading %s" % path)
	emit_signal("file_selected", path)

func _on_FileDialog_about_to_show():
	emit_signal("file_dialog_visible_changed", true)

func _on_FileDialog_popup_hide():
	emit_signal("file_dialog_visible_changed", false)
