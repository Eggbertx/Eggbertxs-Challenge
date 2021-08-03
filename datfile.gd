extends Node

class_name DatFile

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
		push_error("Invalid datfile signature in %s" % datfile.get_path())
		return false

	num_levels = datfile.get_16()
	
	
