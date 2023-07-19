extends Control

signal browse_activated
signal dialog_confirmed # activated when the OK button is pressed

const default_color = Color(1, 0, 1, 1)

var tileset_path = ""
# var chromakey_color: Color

func _ready() -> void:
	reset_values()

func reset_values():
	tileset_path = ""
	$Popup/VBoxContainer/HBoxContainer/ColorButton.color = default_color
	$Popup/VBoxContainer/HBoxContainer/ChromakeyCheckbox.set_pressed_no_signal(false)

func using_alpha() -> bool:
	return $Popup/VBoxContainer/HBoxContainer/ChromakeyCheckbox.is_pressed()

func chromakey_color() -> Color:
	return $Popup/VBoxContainer/HBoxContainer/ColorButton.color

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func show_dialog():
	$Popup.show()

func _on_BrowseButton_button_up():
	emit_signal("browse_activated")

func _on_OKButton_button_up():
	emit_signal("dialog_confirmed",
		tileset_path,
		using_alpha(),
		chromakey_color()
	)
	$Popup.hide()

func _on_CancelButton_button_up():
	$Popup.hide()
	reset_values()
