extends Control

signal file_selected
signal game_item_selected
signal level_item_selected
signal level_selected

enum {
	FILEMODE_DATFILE,
	FILEMODE_TILESET
}

@onready var game_menu = $Panel/HBoxContainer/GameMenu.get_popup()
@onready var level_menu = $Panel/HBoxContainer/LevelMenu.get_popup()

var file_mode = FILEMODE_DATFILE
var viewport_size: Vector2
var inventory_tiles: TileSet

func _ready() -> void:
	enable_level_menu(false)
	game_menu.connect("id_pressed", Callable(self, "game_menu_selected"))
	level_menu.connect("id_pressed", Callable(self, "level_menu_selected"))
	$UIImage.set_size(get_viewport().size, false)
	$UIImage.set_position(Vector2(0, $Panel.get_rect().size.y))

	$ViewWindow.set_position(Vector2(16, 16 + $Panel.size.y))
	$ViewWindow.visible = false
	viewport_size = get_viewport_rect().size

func alert(text:String, console = false):
	$AcceptDialog.dialog_text = text
	$AcceptDialog.visible = true
	var center = Vector2(
		viewport_size.x/2 - $AcceptDialog.get_rect().size.x/2,
		viewport_size.y/2 - $AcceptDialog.get_rect().size.y/2
	)
	$AcceptDialog.set_position(center)
	#if console:
	#	Console.write_line(text)

func set_time_display(time: int, visible = true):
	$TimeDisplay.set_number(time)
	$TimeDisplay.set_visible(visible)


func set_level_display(level: int, visible = true):
	$LevelDisplay.set_number(level)
	$LevelDisplay.set_visible(visible)


func add_inventory(id: int):
	var tr = TextureRect.new()
	tr.texture = inventory_tiles.tile_get_texture(id)
	tr.name = ("inv%d" % id)
	var found = false

	var children = $InventoryContainer.get_children()
	for child in children:
		if child.name == ("inv%d" % id):
			found = true
			break
	if !found:
		$InventoryContainer.add_child(tr)

func remove_inventory(id: int):
	var children = $InventoryContainer.get_children()
	for child in children:
		if child.name == ("inv%d" % id):
			$InventoryContainer.remove_child(child)

func show_goto():
	$GotoLevelDialog/Popup.show()

func game_menu_selected(id):
	emit_signal("game_item_selected", id)

func level_menu_selected(id):
	emit_signal("level_item_selected", id)
	
func set_max_level(levels:int):
	$GotoLevelDialog/Popup/VBoxContainer/GridContainer/LevelNoEdit.max_value = levels

func enable_level_menu(enabled = true):
	$Panel/HBoxContainer/LevelMenu.disabled = !enabled

func show_file_dialog(filemode = FILEMODE_DATFILE):
	file_mode = filemode
	if $FileDialog.visible:
		return
	$FileDialog.clear_filters()
	match filemode:
		FILEMODE_DATFILE:
			$FileDialog.add_filter("*.dat ; CC levelset")
		FILEMODE_TILESET:
			$TilesetSelectDialog.show_dialog()
			$FileDialog.add_filter("*.png, *.bmp, *.gif ; Tileset")
	$FileDialog.popup()

func set_hint_visible(visible: bool, text: String):
	$HintPanel.visible = visible
	$HintPanel/HintText.text = text

func _on_FileDialog_file_selected(path):
	emit_signal("file_selected", path)


func _on_GotoLevelDialog_level_selected(level: int, password: String):
	emit_signal("level_selected", level, password)


func _on_TilesetSelectDialog_browse_activated() -> void:
	pass # Replace with function body.
