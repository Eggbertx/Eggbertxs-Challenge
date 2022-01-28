# Used for drawing tile images to the screen

extends Node2D

class_name LevelGfx

var df: DatFile

func _init(n:int):
	Console.write("int: %d" % n)

# Called when the node enters the scene tree for the first time.
func _ready():
	Console.write("Loading CC tileset graphics")

func attach_datfile(file: DatFile):
	df = file
	var err = $CCTileset.set_image("res/tiles.bmp")
	if err != OK:
		Console.write_line("Error loading tileset")

func set_tile(pos: Vector2, tile: int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
