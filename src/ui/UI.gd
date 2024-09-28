class_name UI
extends Control

signal file_selected
signal game_item_selected
signal level_item_selected
signal level_selected

enum {
	FILEMODE_DATFILE,
	FILEMODE_TILESET
}

@onready var game_menu: PopupMenu = $Panel/HBoxContainer/GameMenu.get_popup()
@onready var level_menu: PopupMenu = $Panel/HBoxContainer/LevelMenu.get_popup()
@onready var panku_shell: Control = Panku.module_manager.get_module("interactive_shell").interactive_shell

var file_mode := FILEMODE_DATFILE
var inventory_tiles: TileSet

func _ready() -> void:
	enable_level_menu(false)
	get_viewport().gui_embed_subwindows = false
	game_menu.connect("id_pressed", game_menu_selected)
	level_menu.connect("id_pressed", level_menu_selected)

	$ViewWindow.set_position(Vector2(16, 16 + $Panel.size.y))
	$ViewWindow.visible = false

func panku_output(text: String):
	print(text)
	panku_shell.output(text)

func alert(text:String, console = true):
	$AcceptDialog.dialog_text = text
	$AcceptDialog.visible = true
	if console:
		panku_output("Alert: %s" % text)

func set_time_display(time: int, display_visible = true):
	$TimeDisplay.set_number(time)
	$TimeDisplay.set_visible(display_visible)


func set_level_display(level: int, display_visible = true):
	$LevelDisplay.set_number(level)
	$LevelDisplay.set_visible(display_visible)


func add_inventory(id: int):
	var tex_rect := TextureRect.new()
	tex_rect.texture = inventory_tiles.tile_get_texture(id)
	tex_rect.name = ("inv%d" % id)
	var found := false

	var children := $InventoryContainer.get_children()
	for child in children:
		if child.name == ("inv%d" % id):
			found = true
			break
	if !found:
		$InventoryContainer.add_child(tex_rect)

func remove_inventory(id: int):
	var children := $InventoryContainer.get_children()
	for child in children:
		if child.name == ("inv%d" % id):
			$InventoryContainer.remove_child(child)

func show_goto():
	$GotoLevelDialog/Popup.show()

func game_menu_selected(id):
	game_item_selected.emit(id)

func level_menu_selected(id):
	level_item_selected.emit(id)
	
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
			$FileDialog.title = "Select Levelset file"
			$FileDialog.add_filter("*.dat ; CC levelset")
			$FileDialog.popup()
		FILEMODE_TILESET:
			$FileDialog.title = "Select Tileset"
			$TilesetSelectDialog.show_dialog()
			$TilesetSelectDialog.connect("browse_activated", $FileDialog.show)
			$FileDialog.add_filter("*.png, *.bmp, *.gif ; Tileset")

func set_hint_visible(hint_visible: bool, text: String):
	$HintPanel.visible = hint_visible
	$HintPanel/HintText.text = text

func _on_FileDialog_file_selected(path):
	file_selected.emit(path)


func _on_GotoLevelDialog_level_selected(level: int, password: String):
	level_selected.emit(level, password)

func _on_TilesetSelectDialog_browse_activated() -> void:
	pass # Replace with function body.
