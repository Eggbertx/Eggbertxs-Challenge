extends Control

signal level_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_OkButton_pressed():
	emit_signal("level_selected",
		$PopupDialog/VBoxContainer/GridContainer/LevelNoEdit.value,
		$PopupDialog/VBoxContainer/GridContainer/PasswordEdit.text
	)
	$PopupDialog.hide()


func _on_CancelButton_pressed():
	$PopupDialog.hide()
