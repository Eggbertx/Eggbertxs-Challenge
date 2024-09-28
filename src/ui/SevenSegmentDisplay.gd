extends Node2D

class_name SevenSegmentDisplay

func _ready():
	set_number(0)

func set_number(num):
	if num < 1 or num > 999:
		num = 0
		set_digits(0, 0, 0)
	else:
		var arr := number_to_digits(num)
		set_digits(arr[0], arr[1], arr[2])

func set_digits(h: int, t: int, o: int):
	if h < 1:
		$Hundred.visible = false
	else:
		$Hundred.visible = true
	$Hundred.texture.region.position.x = h*16
	
	if t < 1 && h < 1:
		$Ten.visible = false
	else:
		$Ten.visible = true
	$Ten.texture.region.position.x = t*16

	if o < 0:
		o = 0
	$One.texture.region.position.x = o*16

func number_to_digits(num:int) -> Array[int]:
	var h := int(floor(num/100.0)) % 10
	var t := int(floor(num/10.0)) % 10
	var o := num % 10
	return [h, t, o]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
