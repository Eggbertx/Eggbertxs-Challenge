extends Node2D
class_name CCTileset

enum {OK, NOT_SQUARE, INVALID_IMAGE_SIZE}

const tiles_x = 7.0
const tiles_y = 16.0

var _texture = ImageTexture.new()
var _size = Vector2(0, 0)

var tiles = []
var s = Sprite.new()

func _ready() -> void:
	pass

func get_sprite(num: int) -> Sprite:
	if(tiles.size() <= num):
		return null
	return tiles[num]

func set_image(path: String):
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		return err

	# calculate the individual tile size, tilesets are expected to be 7x16
	# square tiles
	_size.x = img.get_width()/tiles_x
	_size.y = img.get_height()/tiles_y
	if _size.x != _size.y:
		return NOT_SQUARE
	elif _size.x < 1 or _size.y < 1:
		Console.write_line("Invalid tile size: (%d,%d)" % [_size.x, _size.y])
		return INVALID_IMAGE_SIZE

	# reset and repopulate the tile array
	tiles.resize(0)
	for x in range(tiles_x):
		for y in range(tiles_y):
			var i = tiles.size()
			tiles.append(Sprite.new())
			tiles[i].texture = ImageTexture.new()
			tiles[i].texture.create_from_image(img.get_rect(Rect2(Vector2(x*_size.x,y*_size.y), _size)))

	return OK

func _draw():
	pass

func _exit_tree():
	s.queue_free()

func _process(delta: float) -> void:
	update()
