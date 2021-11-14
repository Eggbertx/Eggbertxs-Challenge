extends Control

signal level_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_max_level(level:int):
	$PopupDialog/VBoxContainer/GridContainer/LevelNoEdit.max_value = level

func _on_OkButton_pressed():
	print_debug($PopupDialog/VBoxContainer/GridContainer/LevelNoEdit.max_value)
	emit_signal("level_selected",
		$PopupDialog/VBoxContainer/GridContainer/LevelNoEdit.value,
		$PopupDialog/VBoxContainer/GridContainer/PasswordEdit.text
	)
	$PopupDialog.hide()


func _on_CancelButton_pressed():
	$PopupDialog.hide()
