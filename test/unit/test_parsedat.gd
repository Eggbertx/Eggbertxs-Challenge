class_name ParseDatTest
extends GdUnitTestSuite

var sample_dat := PackedByteArray([
	0xac, 0xaa, 0x02, 0x00, # magic header
	0x01, 0x00, # number of levels
	# level 1
	0x44, 0x00, # number of bytes in the level
	0x01, 0x00, # level number
	0x02, 0x00, # time limit in seconds
	0x01, 0x00, # number of chips
	0x01, 0x00, # map detail
	# layer 1
	0x15, 0x00, # 21 bytes in 1st layer
	0xff, 0xa7, 0x00, 0x02, 0xff, 0x1f,
	0x00, 0x6e, 0x15, 0xff, 0xff, 0x00, 0xff, 0xff, 0x00, 0xff, 0xff, 0x00,
	0xff, 0x3a, 0x00,
	# layer 2
	0x10, 0x00, # 16 bytes in 2nd layer
	0xff, 0xc7, 0x00, 0x2f, 0xff, 0xff, 0x00,
	0xff, 0xff, 0x00, 0xff, 0xff, 0x00, 0xff, 0x3b, 0x00,
	# Optional fields
	0x22, 0x00, # 34 bytes in optional fields
	0x03, # field type (title)
	0x08, # field length
	0x4c, 0x65, 0x76, 0x65, 0x6c, 0x20, 0x31, 0x00, # "Level 1\0"
	0x07, # field type (hint)
	0x0f, # field length
	0x54, 0x68, 0x69, 0x73, 0x20, 0x69, 0x73, 0x20, 0x61, 0x20, 0x68, 0x69, 0x6e, 0x74, 0x00, # "This is a hint\0"
	0x06, # field type (password)
	0x05, # field length
	0xcd, 0xdc, 0xca, 0xcd, 0x00, # "TEST\0" XORed with 0x99
])


var levelset :DatFile = DatFile.new()
var num_tests := 0
var tests_done := 0

func before():
	auto_free(levelset)

func test_parse_file():
	levelset.stream.data_array = sample_dat
	assert_str(levelset.parse_file(true)).is_empty()
	assert_int(levelset.num_levels).is_equal(1)
	assert_str(levelset.levels[0].map_title).is_equal("Level 1")
	assert_str(levelset.levels[0].hint).is_equal("This is a hint")
	assert_str(levelset.levels[0].password).is_equal("TEST")
