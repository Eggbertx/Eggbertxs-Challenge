extends Node

class_name DatFile

enum { CORRECT_PASSWORD, NONEXISTENT_LEVEL, WRONG_PASSWORD }
const default_files = ["CHIPS.DAT", "chips.dat", "ec.dat", "ec_testing.dat"]
@export var file_path := ""
@export var num_levels := 0
var levels :Array[Level] = []
var stream := StreamPeerBuffer.new()
var signature := 0

func _init():
	pass

func load_file(filepath: String) -> String:
	file_path = filepath
	var file := FileAccess.open(filepath, FileAccess.READ)

	stream.data_array = file.get_buffer(file.get_length())
	file.close()
	return parse_file()

func filename() -> String:
	return file_path.get_file()

func get_default_file() -> String:
	for fn in default_files:
		if FileAccess.file_exists(fn):
			return fn
	return ""
	
func level_info(l:int):
	for level in levels:
		if level.level_num == l:
			level.print_info()
			return true
	return false

func valid_signature() -> bool:
	return signature == 0x0002AAAC or signature == 0x0102AAAC

func parse_file(debug = false) -> String:
	signature = stream.get_u32()
	if !valid_signature():
		return "Invalid datfile signature in %s" % file_path.get_file()

	num_levels = stream.get_u16()
	print("Number of levels: %d" % num_levels)
	var err := ""
	for _l in range(num_levels):
		var level := Level.new()
		err = level.parse_data(stream, debug)
		if err != "":
			level.queue_free()
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
