extends Control

signal file_selected
signal game_item_selected
signal level_item_selected

onready var game_menu = $Panel/HBoxContainer/GameMenu.get_popup()
onready var level_menu = $Panel/HBoxContainer/LevelMenu.get_popup()

var time_left = 100

var viewport_size: Vector2

func _ready() -> void:
	game_menu.connect("id_pressed", self, "game_menu_selected")
	level_menu.connect("id_pressed", self, "level_menu_selected")
	$UIImage.set_size(get_viewport().size, false)
	$UIImage.set_position(Vector2(0, $Panel.get_rect().size.y))

	$ReferenceRect.set_position(Vector2(16, 16 + $Panel.rect_size.y))
	$ReferenceRect.visible = false
	# print("tiles: (%d, %d)" % [$ReferenceRect.rect_size.x / 48, $ReferenceRect.rect_size.y / 48])
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

func game_menu_selected(id):
	emit_signal("game_item_selected", id)

func level_menu_selected(id):
	emit_signal("level_item_selected", id)

func _on_FileDialog_file_selected(path):
	Console.write_line("Loading %s" % path)
	emit_signal("file_selected", path)

func _on_Timer_timeout():
	time_left -= 1
	$TimeDisplay.set_number(time_left)
	if time_left == 0:
		alert("Ding!")
		$Timer.stop()
