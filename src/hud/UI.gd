extends Control

onready var game_menu = $Panel/HBoxContainer/MenuButton.get_popup()

enum {ITEM_NEWGAME, ITEM_RESTARTLVL, ITEM_HIGHSCORES, ITEM_MUSIC, SEPARATOR, ITEM_REPO, ITEM_QUIT}
const REPO_URL = "https://github.com/Eggbertx/Eggbertxs-Challenge"

func _ready() -> void:
	game_menu.connect("id_pressed", self, "handle_menu")

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
		ITEM_HIGHSCORES:
			Console.write_line("Showing high scores")
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
