extends Control

signal file_selected

onready var game_menu = $Panel/HBoxContainer/MenuButton.get_popup()

enum {ITEM_NEWGAME, ITEM_RESTARTLVL, ITEM_DATFILE, ITEM_TILESET, ITEM_MUSIC, SEPARATOR, ITEM_REPO, ITEM_QUIT}
const REPO_URL = "https://github.com/Eggbertx/Eggbertxs-Challenge"

var viewport_size: Vector2

func _ready() -> void:
	game_menu.connect("id_pressed", self, "handle_menu")

	$UIImage.set_size(get_viewport().size, false)
	$UIImage.set_position(Vector2(0, $Panel.get_rect().size.y))

	$ReferenceRect.set_position(Vector2(16, 16 + $Panel.rect_size.y))
	$ReferenceRect.visible = false
	print("tiles: (%d, %d)" % [$ReferenceRect.rect_size.x / 48, $ReferenceRect.rect_size.y / 48])
	viewport_size = get_viewport_rect().size

func alert(text:String, console = false):
	$AcceptDialog.dialog_text = text
	$AcceptDialog.visible = true
	var center = Vector2(
		viewport_size.x/2 - $AcceptDialog.get_rect().size.x/2,
		viewport_size.y/2 - $AcceptDialog.get_rect().size.y/2
	)
	$AcceptDialog.set_position(center)
	if console:
		Console.write_line(text)

func handle_menu(id):
	# Console.write_line("Selected item text: %s" % menu.get_item_text(id))
	$FileDialog.clear_filters()
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
			$FileDialog.add_filter("*.dat ; CC levelset")
			$FileDialog.popup()
		ITEM_TILESET:
			if $FileDialog.visible:
				return
			$FileDialog.add_filter("*.png, *.bmp, *.gif ; Tileset")
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
