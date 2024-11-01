class_name DirectionalField
extends Node

const DEFAULT_NUM_SECTORS := 16
const DEFAULT_RESPONSE_TIME := 0.2

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

func set_step(delta: float) -> void:
	
	# Smoothly interpolate current pattern toward target
	var smooth_factor = 1.0 - exp(-delta / response_time)
	current_pattern.interpolate_to(target_pattern, smooth_factor)
	
	# Clear target pattern for next frame
	for i in range(num_sectors):
		target_pattern.set_value(i, 0.0)

		
func combine(other : DirectionalField):
	
	# Consistency checks from the propeties of the directional fields.
	# TODO
	
	# Clear target pattern for next frame
	for i in range(num_sectors):
		current_pattern.values[i] += other.current_pattern.values[i]

func clear():
	for i in range(num_sectors):
		current_pattern.values[i] = 0.

# TODO to validate, I'm not really liking this one.
func add_effect(value: float, angle: float, spread: float = 1.0) -> void:
	var main_sector : int = fposmod(angle, 2 * PI) / sector_size
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

# Interpolates the value to give a continuous angular result.
func get_peak() -> Vector2:
	var max_value := 0.0
	var max_sector := 0
	
	# First find the discrete maximum
	for i in range(num_sectors):
		var value = current_pattern.get_value(i)
		if value > max_value:
			max_value = value
			max_sector = i
			
	# Get the neighboring sectors (wrapping around)
	var prev_sector = (max_sector - 1 + num_sectors) % num_sectors
	var next_sector = (max_sector + 1) % num_sectors
	var prev_value = current_pattern.get_value(prev_sector)
	var next_value = current_pattern.get_value(next_sector)
	
	# Interpolate the angle based on neighboring values
	var angle_offset := 0.0
	
	# If next value is higher than prev, peak is shifted towards next
	if next_value > prev_value:
		var t = (next_value - max_value) / (2 * (max_value - prev_value))
		angle_offset = sector_size * t
	# If prev value is higher, peak is shifted towards prev
	else:
		var t = (prev_value - max_value) / (2 * (max_value - next_value))
		angle_offset = -sector_size * t
	
	# Calculate the interpolated angle in radians
	var angle = (max_sector * sector_size + sector_size/2 + angle_offset)
	
	# Convert to Vector2 using cos/sin
	return Vector2(cos(angle), sin(angle)) * max_value
	
func display_debug() -> String:
	var debug_string = "DEBUG: "
	for i in range(num_sectors):
		debug_string += str(current_pattern.values[i]) + " "
	return debug_string
