class_name DirectionalPattern

var values: Array[float]
var num_sectors: int

func _init(num_sectors_: int):
	num_sectors = num_sectors_
	values = []
	values.resize(num_sectors)
	values.fill(0.0)

func set_value(sector: int, value: float) -> void:
	values[sector] = value

func get_value(sector: int) -> float:
	return values[sector]

func duplicate() -> DirectionalPattern:
	var copy = DirectionalPattern.new(num_sectors)
	for i in range(num_sectors):
		copy.values[i] = values[i]
	return copy

func interpolate_to(target: DirectionalPattern, factor: float) -> void:
	for i in range(num_sectors):
		values[i] = lerp(values[i], target.values[i], factor)
