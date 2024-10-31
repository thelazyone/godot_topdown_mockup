class_name DirectionalField
extends Node

const DEFAULT_NUM_SECTORS := 8
const DEFAULT_RESPONSE_TIME := 0.2  # Time constant for smoothing

var sector_size: float
var num_sectors: int
var current_pattern: DirectionalPattern
var target_pattern: DirectionalPattern
var response_time: float

func _init(num_sectors_: int = DEFAULT_NUM_SECTORS):
	num_sectors = num_sectors_
	sector_size = 2 * PI / num_sectors
	current_pattern = DirectionalPattern.new(num_sectors)
	target_pattern = DirectionalPattern.new(num_sectors)
	response_time = DEFAULT_RESPONSE_TIME

func _process(delta: float) -> void:
	# Smoothly interpolate current pattern toward target
	var smooth_factor = 1.0 - exp(-delta / response_time)
	current_pattern.interpolate_to(target_pattern, smooth_factor)
	
	# Clear target pattern for next frame
	for i in range(num_sectors):
		target_pattern.set_value(i, 0.0)

func angle_to_sector(angle: float) -> int:
	return int(fposmod(angle, 2 * PI) / sector_size)

func add_to_target(value: float, angle: float, spread: float = 1.0) -> void:
	var main_sector := angle_to_sector(angle)
	var falloff := value * spread
	
	# Add to target pattern (will be processed next frame)
	target_pattern.set_value(main_sector, 
		target_pattern.get_value(main_sector) + value)
	target_pattern.set_value(
		(main_sector + 1) % num_sectors,
		target_pattern.get_value((main_sector + 1) % num_sectors) + falloff)
	target_pattern.set_value(
		(main_sector - 1 + num_sectors) % num_sectors,
		target_pattern.get_value((main_sector - 1 + num_sectors) % num_sectors) + falloff)

func get_value_at_angle(angle: float) -> float:
	angle = fposmod(angle, 2 * PI)
	
	var sector_f := angle / sector_size
	var sector1 := int(floor(sector_f)) % num_sectors
	var sector2 := int(ceil(sector_f)) % num_sectors
	
	var t := fmod(sector_f, 1.0)
	
	return lerp(
		current_pattern.get_value(sector1), 
		current_pattern.get_value(sector2), 
		t
	)

func get_peak() -> Dictionary:
	var max_value := 0.0
	var max_sector := 0
	
	for i in range(num_sectors):
		var value = current_pattern.get_value(i)
		if value > max_value:
			max_value = value
			max_sector = i
	
	return {
		"value": max_value,
		"angle": max_sector * sector_size + sector_size/2
	}
