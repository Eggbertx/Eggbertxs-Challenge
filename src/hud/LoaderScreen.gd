extends CanvasLayer

signal file_selected

var loaded_file = ""

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_LoadFileBtn_pressed() -> void:
	if $FileDialog.visible:
		return
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	$FileDialog.popup()

func _on_FileDialog_file_selected(path: String) -> void:
	loaded_file = path
	emit_signal("file_selected", path)

func _on_FileDialog_hide() -> void:
	loaded_file = ""
