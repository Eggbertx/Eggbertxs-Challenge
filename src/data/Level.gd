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

func read_file(file: File, debug = false):
	num_bytes = file.get_16()
	level_num = file.get_16()
	time_left = file.get_16() # if time_left == 0, no time limit
	no_time_limit = time_left == 0
	chips_left = file.get_16() 
	level_detail = file.get_16()
	if level_detail > 1:
		Console.write_line("Level detail value must be 0 or 1, got %d in level %d" % [level_detail, level_num])
		return false

	layer1_numbytes = file.get_16()
	layer1_bytes = decode_rle(file, layer1_numbytes)
	layer2_numbytes = file.get_16()
	layer2_bytes = decode_rle(file, layer2_numbytes)

	var num_optional = file.get_16()
	var optional_read = 0
	# Console.write_line("\tNumber of optional field bytes: %d" % num_optional)
	# var optional_buf = file.get_buffer(num_optional)
	while optional_read <= num_optional and num_optional > 0:
		var field_type = file.get_8()
		var field_numbytes = file.get_8()
		# Console.write_line("Number of bytes in field type %d: %d" % [field_type, field_numbytes])
		match field_type:
			1:
				Console.write_line("Invalid map field (level time field isn't used)")
				return false
			2:
				Console.write_line("Invalid map field (number of chips field isn't used")
				return false
			3:
				map_title = file.get_buffer(field_numbytes).get_string_from_ascii()
			4:
				brown_button_field = file.get_buffer(field_numbytes)
			5:
				red_button_field = file.get_buffer(field_numbytes)
			6:
				for b in range(field_numbytes):
					password += "%c" % (file.get_8() ^ 0x99)
			7:
				hint = file.get_buffer(field_numbytes).get_string_from_ascii()
			8:
				Console.write_line("Invalid map field (unencrypted password isn't used)")
				return false
			9:
				Console.write_line("Field not used")
				return false
			10:
				if (field_numbytes % 2) > 0:
					Console.write_line("Invalid monster field, must be a multiple of 2 bytes (got %d)" % field_numbytes)
					return false
				for f in range(field_numbytes / 2):
					var monster_x = file.get_8()
					var monster_y = file.get_8()
					monster_locations.append(Vector2(monster_x, monster_y))
			_:
				Console.write_line("Unrecognized optional field type %d" % field_type)
				return false
				file.get_buffer(field_numbytes)
		optional_read += 3 + field_numbytes

	if debug:
		print_info()
	return true

func decode_rle(datfile: File, num_bytes: int):
	# 0xFF,<num_bytes>,<byte_to_copy>
	var can_read = (datfile.get_position() + num_bytes) <= datfile.get_len()
	if not can_read:
		Console.write_line(rle_too_large)
		return null
	var decoded = []
	# var decoded = PoolByteArray()
	while num_bytes > 0:
		num_bytes -= 1
		var byte = datfile.get_8()
		if byte >= 0x00 and byte <= 0x6F:
			decoded.append(byte)
		elif byte == 0xFF:
			var num_repeats = datfile.get_8()
			var data = datfile.get_8()
			num_bytes -= 2
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
