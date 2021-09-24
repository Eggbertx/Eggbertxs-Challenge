extends Node

class_name Level

enum { _offset, FIELD_TIME_UNUSED, FIELD_CHIPS_UNUSED, FIELD_TITLE, FIELD_TRAPS, FIELD_CLONES, FIELD_PASSWORD, FIELD_HINT, FIELD_PASSWORD_UNUSED, FIELD_UNUSED, FIELD_MOVING}

const rle_too_large = "Invalid RLE header, number of bytes requested reaches beyond the file end"
const invalid_rle_byte = "Invalid RLE byte (byte should be 0xFF or >= 0x00 and <= 0x6F)"

var num_bytes = 0 # uint16
var level_num = 0 # uint16
var time_left = 0 # uint16
var chips_left = 0 # uint16
var level_detail = 0 # uint16

var layer1_numbytes = 0
var layer1_bytes = []
var layer2_numbytes = 0
var layer2_bytes = []

# optional fields
var map_title = ""
var brown_button_field = PoolByteArray()
var red_button_field = PoolByteArray()
var password = ""
var hint = ""
var monster_locations = []



var no_time_limit = false

func parse_data(stream: StreamPeerBuffer, debug = false):
	num_bytes = stream.get_u16()
	level_num = stream.get_u16()
	time_left = stream.get_u16() # if time_left == 0, no time limit
	no_time_limit = time_left == 0
	chips_left = stream.get_u16() 
	level_detail = stream.get_u16()
	if level_detail > 1:
		return "Level detail value must be 0 or 1, got %d in level %d" % [level_detail, level_num]

	layer1_numbytes = stream.get_u16()
	layer1_bytes = decode_rle(stream, layer1_numbytes)
	layer2_numbytes = stream.get_u16()
	layer2_bytes = decode_rle(stream, layer2_numbytes)

	var num_optional = stream.get_u16()
	var optional_read = 0
	# Console.write_line("\tNumber of optional field bytes: %d" % num_optional)
	# var optional_buf = file.get_buffer(num_optional)
	while optional_read <= num_optional and num_optional > 0:
		var field_type = stream.get_u8()
		var field_numbytes = stream.get_u8()
		# Console.write_line("Number of bytes in field type %d: %d" % [field_type, field_numbytes])
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
				for _b in range(field_numbytes):
					password += "%c" % (stream.get_u8() ^ 0x99)
			7:
				hint = stream.get_string(field_numbytes)
			8:
				return "Invalid map field (unencrypted password isn't used)"
			9:
				return "Field not used"
			10:
				if (field_numbytes % 2) > 0:
					return "Invalid monster field, must be a multiple of 2 bytes (got %d)" % field_numbytes
				for _f in range(field_numbytes / 2):
					var monster_x = stream.get_u8()
					var monster_y = stream.get_u8()
					monster_locations.append(Vector2(monster_x, monster_y))
			_:
				return "Unrecognized optional field type %d" % field_type
		optional_read += 3 + field_numbytes

	if debug:
		print_info()
	return ""

func decode_rle(stream: StreamPeerBuffer, num_rel_bytes: int):
	# 0xFF,<num_rel_bytes>,<byte_to_copy>
	var can_read = (stream.get_position() + num_rel_bytes) <= stream.get_size()
	if not can_read:
		Console.write_line(rle_too_large)
		return null
	var decoded = []
	while num_rel_bytes > 0:
		num_rel_bytes -= 1
		var byte = stream.get_u8()
		if byte >= 0x00 and byte <= 0x6F:
			decoded.append(byte)
		elif byte == 0xFF:
			var num_repeats = stream.get_u8()
			var data = stream.get_u8()
			num_rel_bytes -= 2
			while num_repeats > 0:
				num_repeats -= 1
				decoded.append(data)
		else:
			Console.write_line(invalid_rle_byte)
			return null
	return decoded

func print_info():
	Console.write_line("Level %d details:" % level_num)
	Console.write_line("\tNumber of compressed bytes in level: %d" % num_bytes)
	Console.write_line("\tTime left: %d" % time_left)
	Console.write_line("\tChips left: %d" % chips_left)
	Console.write_line("\tLevel detail: %d" % level_detail)
	Console.write_line("\tNumber of bytes in layer 1: %d" % layer1_numbytes)
	Console.write_line("\tNumber of bytes in layer 2: %d" % layer2_numbytes)
	Console.write_line("\tMap title: %s" % map_title)
	#Console.write_line("\tBrown button field: %d" % brown_button_field)
	#Console.write_line("\tRed button field: %d" % red_button_field)
	Console.write_line("\tPassword: %s" % password)
	Console.write_line("\tHint: %s" % hint)
	for loc in monster_locations:
		Console.write_line("\tMonster at %d,%d" % [loc.x, loc.y])


func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
