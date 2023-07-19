extends Control

signal level_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_OkButton_pressed():
	emit_signal("level_selected",
		$Popup/VBoxContainer/GridContainer/LevelNoEdit.value,
		$Popup/VBoxContainer/GridContainer/PasswordEdit.text
	)
	$Popup.hide()


func _on_CancelButton_pressed():
	$Popup.hide()
