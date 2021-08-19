extends Node

class_name DatFile

const rle_too_large = "Invalid RLE header, number of bytes requested reaches beyond the file end"
const invalid_rle_byte = "Invalid RLE byte (byte should be 0xFF or >= 0x00 and <= 0x6F)"

var file_path = ""
var num_levels = 0

func _init():
	pass

func load_file(filepath: String):
	file_path = filepath
	var file = File.new()
	var err = file.open(filepath, File.READ)
	if err:
		return err

	file.set_endian_swap(false)
	parse_file(file)
	file.close()

func parse_file(datfile: File):
	var signature = datfile.get_32()
	if signature != 0x0002AAAC and signature != 0x0102AAAC:
		
		Console.write_line("Invalid datfile signature in %s" % datfile.get_path().get_file())
		return false

	num_levels = datfile.get_16()
	
func decode_rle(datfile: File, num_bytes: int):
	# 0xFF,<num_bytes>,<byte_to_copy>
	var can_read = (datfile.get_position() + num_bytes) <= datfile.get_len()
	if not can_read:
		Console.write_line(rle_too_large)
		return null
	
	var decoded = PoolByteArray()
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
