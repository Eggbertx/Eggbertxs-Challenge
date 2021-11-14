extends Node

class_name DatFile

enum { CORRECT_PASSWORD, NONEXISTENT_LEVEL, WRONG_PASSWORD }

var file_path = ""
var num_levels = 0
var levels = []
var stream = StreamPeerBuffer.new()
var signature = 0

func _init():
	pass

func load_file(filepath: String):
	file_path = filepath
	var file = File.new()
	var err = file.open(filepath, File.READ)
	if err:
		return err

	stream.data_array = file.get_buffer(file.get_len())
	file.close()
	return parse_file()

func filename() -> String:
	return file_path.get_file()

func default_exists():
	var file = File.new()
	var exists = file.file_exists("CHIPS.DAT")
	file.close()
	return exists
	
func level_info(l:int):
	for level in levels:
		if level.level_num == l:
			level.print_info()
			return true
	return false

func valid_signature():
	return signature == 0x0002AAAC or signature == 0x0102AAAC

func parse_file(debug = false):
	signature = stream.get_u32()
	if !valid_signature():
		return "Invalid datfile signature in %s" % file_path.get_file()

	num_levels = stream.get_u16()
	Console.write_line("Number of levels: %d" % num_levels)
	for _l in range(num_levels):
		var level = Level.new()
		var err = level.parse_data(stream, debug)
		if err != "":
			return err
		levels.append(level)
	return ""

func check_password(level:int, password:String) -> int:
	if num_levels < level or level < 1:
		return NONEXISTENT_LEVEL
	for _l in range(num_levels):
		if _l + 1 == level and levels[_l].password.c_escape() == password:
			return CORRECT_PASSWORD
	return WRONG_PASSWORD

# clean up
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for level in levels:
			level.free()
