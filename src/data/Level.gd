extends Node

class_name Level

enum { _offset, FIELD_TIME_UNUSED, FIELD_CHIPS_UNUSED, FIELD_TITLE, FIELD_TRAPS, FIELD_CLONES, FIELD_PASSWORD, FIELD_HINT, FIELD_PASSWORD_UNUSED, FIELD_UNUSED, FIELD_MOVING}

const rle_too_large = "Invalid RLE header, number of bytes requested reaches beyond the file end"
const invalid_rle_byte = "Invalid RLE byte (byte should be 0xFF or >= 0x00 and <= 0x6F)"

var num_bytes := 0 # uint16
var level_num := 0 # uint16
var time_limit := 0 # uint16
var chips_left := 0 # uint16
var level_detail := 0 # uint16

var layer1_numbytes := 0
var layer1_bytes := PackedByteArray()
var layer2_numbytes := 0
var layer2_bytes := PackedByteArray()

# optional fields
var map_title := ""
var brown_button_field := PackedByteArray()
var red_button_field := PackedByteArray()
var password := ""
var hint := ""
var monster_locations: Array[Vector2] = []
var last_chip_index := -1
var chip_layer := 0


var no_time_limit := false


func parse_data(stream: StreamPeerBuffer, debug = false) -> String:
	num_bytes = stream.get_u16()
	level_num = stream.get_u16()
	time_limit = stream.get_u16() # if time_left == 0, no time limit
	no_time_limit = time_limit == 0
	chips_left = stream.get_u16() 
	level_detail = stream.get_u16()
	if level_detail > 1:
		return "Level detail value must be 0 or 1, got %d in level %d" % [level_detail, level_num]

	layer1_numbytes = stream.get_u16()
	var err := decode_rle(stream, layer1_numbytes, layer1_bytes)
	if err != "":
		return err
	layer2_numbytes = stream.get_u16()
	err = decode_rle(stream, layer2_numbytes, layer2_bytes)
	if err != "":
		return err

	var num_optional := stream.get_u16()
	var optional_read := 0
	# print("\tNumber of optional field bytes: %d" % num_optional)
	while optional_read <= num_optional and num_optional > 0:
		var field_type := stream.get_u8()
		var field_numbytes := stream.get_u8()
		# print("Number of bytes in field type %d: %d" % [field_type, field_numbytes])
		match field_type:
			1:
				return "Invalid map field (level time field isn't used)"
			2:
				return "Invalid map field (number of chips field isn't used"
			3:
				map_title = stream.get_string(field_numbytes)
			4:
				brown_button_field = stream.get_data(field_numbytes)
			5:
				red_button_field = stream.get_data(field_numbytes)
			6:
				for _b in range(field_numbytes-1):
					password += "%c" % (stream.get_u8() ^ 0x99)
				var _skip := stream.get_u8() # null byte
			7:
				hint = stream.get_string(field_numbytes)
			8:
				return "Invalid map field (unencrypted password isn't used)"
			9:
				return "Field not used"
			10:
				if (field_numbytes % 2) > 0:
					return "Invalid monster field, must be a multiple of 2 bytes (got %d)" % field_numbytes
				@warning_ignore("integer_division")
				var range_max := field_numbytes/2
				for _f in range(range_max):
					var monster_x := stream.get_u8()
					var monster_y := stream.get_u8()
					monster_locations.append(Vector2(monster_x, monster_y))
			_:
				return "Unrecognized optional field type %d" % field_type
		optional_read += 3 + field_numbytes

	if debug:
		print_info()
	return ""

func index_to_2d(num: int) -> Vector2i:
	var x := num % 32
	@warning_ignore("integer_division")
	var y:int = floor((num - x) / 32)
	return Vector2i(x, y)

func apply_to(map: LevelMap):
	var direction := "south"
	for b in range(1024):
		var pos := index_to_2d(b)
		map.set_tile(pos.x, pos.y, 1, layer1_bytes[b])
		map.set_tile(pos.x, pos.y, 2, layer2_bytes[b])
		if layer1_bytes[b] >= Objects.CHIP_N and layer1_bytes[b] <= Objects.CHIP_E:
			match layer1_bytes[b]:
				Objects.CHIP_N:
					direction = "north"
				Objects.CHIP_W:
					direction = "west"
				Objects.CHIP_E:
					direction = "east"
				_:
					direction = "south"
			last_chip_index = b
			chip_layer = 1
		if layer2_bytes[b] >= Objects.CHIP_N and layer2_bytes[b] <= Objects.CHIP_E:
			match layer1_bytes[b]:
				Objects.CHIP_N:
					direction = "north"
				Objects.CHIP_W:
					direction = "west"
				Objects.CHIP_E:
					direction = "east"
				_:
					direction = "south"
			last_chip_index = b
			chip_layer = 2
	map.hint_text = hint
	if last_chip_index > -1:
		var pos := index_to_2d(last_chip_index)
		map.init_player_pos(pos, chip_layer, direction)

	var window_title := "Eggbertx's Challenge - " + map_title
	map.update_window_title.emit(window_title)
	map.update_chips_left.emit(chips_left)

# RLE bytes are stored: 0xFF, num_rel_bytes, byte1, byte2, byte3, ...
func decode_rle(stream: StreamPeerBuffer, num_rel_bytes: int, decoded: PackedByteArray) -> String:
	var can_read = (stream.get_position() + num_rel_bytes) <= stream.get_size()
	if not can_read:
		return rle_too_large

	decoded.clear()
	var decoded_arr: Array[int] = []

	while num_rel_bytes > 0:
		num_rel_bytes -= 1
		var byte = stream.get_u8()
		if byte >= 0x00 and byte <= 0x6F:
			decoded_arr.append(byte)
		elif byte == 0xFF:
			var num_repeats = stream.get_u8()
			var data = stream.get_u8()
			num_rel_bytes -= 2
			while num_repeats > 0:
				num_repeats -= 1
				decoded_arr.append(data)
		else:
			return invalid_rle_byte

	decoded.append_array(PackedByteArray(decoded_arr))
	return ""

func print_info():
	print("Level %d details:" % level_num)
	print("\tNumber of compressed bytes in level: %d" % num_bytes)
	print("\tTime limit: %d" % time_limit)
	print("\tChips left: %d" % chips_left)
	print("\tLevel detail: %d" % level_detail)
	print("\tNumber of bytes in layer 1: %d" % layer1_numbytes)
	print("\tNumber of bytes in layer 2: %d" % layer2_numbytes)
	print("\tMap title: %s" % map_title)
	#print("\tBrown button field: %d" % brown_button_field)
	#print("\tRed button field: %d" % red_button_field)
	print("\tPassword: %s" % password)
	print("\tHint: %s" % hint)
	print("Chip found at byte index %d and layer %d" % [last_chip_index, chip_layer])
	for loc in monster_locations:
		print("\tMonster at %d,%d" % [loc.x, loc.y])


func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
