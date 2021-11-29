extends Node2D

var tiles_img: Image
var tiles_tex: ImageTexture

func _ready():
	# print("tile_set: %s" % $TileMap.tile_set.to_string())
	tiles_img = Image.new()
	set_tileset("res://images/old/tileset.png", 32)
	#$Layer1.tile_set.tile_get_texture()
	#$Layer2.tile_set.tile_get_texture()

func set_tileset(path: String, tile_size: int) -> String:
	var ts_res = load(path)
	if ts_res == null:
		return "Unable to load tileset texture %s" % path
	return ""
	# $Layer1.tile_set.tile_set_texture(0, load(path))
	# $Layer2.tile_set.tile_set_texture(0, load(path))
#	var tex = AtlasTexture.new()
	var s = ImageTexture.new()
	var i = Image.new()
	#i.save_png()
	return ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
