class_name DirectionalPattern
extends Node

var values: Array[float]
var num_sectors: int

func _init(size: int):
	num_sectors = size
	values = []
	values.resize(size)
	values.fill(0.0)

func set_value(sector: int, value: float) -> void:
	values[sector] = value

func get_value(sector: int) -> float:
	return values[sector]

func interpolate_to(target: DirectionalPattern, factor: float) -> void:
	for i in range(num_sectors):
		values[i] = lerp(values[i], target.values[i], factor)
