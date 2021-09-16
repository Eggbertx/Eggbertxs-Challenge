# Used for drawing tile images to the screen

extends Node2D

class_name LevelGfx

var df: DatFile

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Loading CC tileset graphics")



func attach_datfile(file: DatFile):
	df = file
	var err = $CCTileset.set_image("images/tiles.bmp")
	if err != OK:
		Console.write_line("Error loading tileset")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
