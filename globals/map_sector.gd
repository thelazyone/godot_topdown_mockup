class_name MapSector
extends Node2D

# Sectors are generated on the go as the map advances, and each is currently organized in a grid.
# On a first approximation the grid is made of non-crossable cubes, but that should change.

enum GridContent {EMPTY, MAIN, FILLED}

# Input for creation:
var last_sector_column : Array = [] # to know where to create openings
var new_spawn : Array = [] # Where to add units.

# Geometric Data
var grid_data : Array = [] #Saved as Column Major.
var buildings: Array[Rect2] = []  # Array of Rect2 representing building positions and sizes
var enemies: Array[Vector2] = []  # Array of Vector2 representing enemy positions
var checkpoints: Array[Vector2] = []  # Array of Vector2 representing enemy positions
var pixel_size : Vector2 = Vector2.ZERO

# Storage for late deletion
var building_nodes = []     # Nodes representing the buildings (visuals)
var collision_shapes = []   # Collision shapes for navigation

@onready var grid_size = MapSectorFactory.grid_size
@onready var checkpoint_scene = preload("res://scenes/checkpoint.tscn")
var unit_factory = null

var rng : RandomNumberGenerator

func _init() -> void:
	
	# Here i'm setting the randomNumberGeneration with a fixed seed.
	# This helps with debugging and reproducibility - but i expected not to work.
	# Anyways, as TODO is to expose the seed, for different levels for sure!
	rng = RandomNumberGenerator.new()
	rng.seed = 124 #124 has a big block on the side

func _ready() -> void:
	_generate_environment(last_sector_column)
	
func populate() -> void:
	_generate_content(new_spawn)

# Public Functions:
func get_sector_entry_position() -> float:
	return (_get_sector_entry_index() + .5) * (pixel_size.y / grid_size.y)

func display_debug():
	var out_string = ""
	for yi in range(grid_size.y):
		for xi in range(grid_size.x):
			match grid_data[xi][yi]:
				GridContent.FILLED:
					out_string += "#"
				GridContent.MAIN:
					out_string += "*"
				_:
					out_string += " "
		out_string += "\n"
	print(out_string)

# Private Function
func _generate_environment(latest_grid_column: Array):
	_fill_grid(latest_grid_column)
	_generate_buildings()
	
func _generate_content(new_spawn: Array):
	_generate_checkpoints()
	_generate_units(new_spawn)
	
func _generate_buildings():
	var main_building_rects = []
	var grid_elem_size = pixel_size / grid_size
	for xi in range(int(grid_size.x)):
		for yi in range(int(grid_size.y)):
			var building_position = Vector2(\
					(xi) * grid_elem_size.x,\
					(yi) * grid_elem_size.y)
			if grid_data[xi][yi] == GridContent.FILLED:
				_add_building(Rect2(building_position, grid_elem_size * 1.05))
				main_building_rects.append(Rect2(building_position, grid_elem_size))
	
	# Finally adding buildings on top and bottom.
	_add_building(Rect2(Vector2(0,-90), Vector2(pixel_size.x, 100)))
	_add_building(Rect2(Vector2(0,pixel_size.y - 10), Vector2(pixel_size.x, 100)))

func _get_free_spot():
	var attempts = 10
	
	# a FEW WASTED ATTEMPTS IF THE TARGET IS SUPER FULL, BUT IN GENERAL IT SHOULD BE OK
	for i in range (attempts):
		var test_position = global_position + Vector2(pixel_size.x * randf(), pixel_size.y * randf())
		if not Utilities.is_point_in_collision_area(test_position):
			return test_position
	print("WARNING - NO FREE SPOT FOUND!")

	return null

func _generate_checkpoints():
	var checkpoint_pos = _get_free_spot()
	if checkpoint_pos:
		_add_checkpoint(checkpoint_pos)

func _generate_units(new_spawn: Array):
	for i in range(new_spawn.size()):
		var enemy_position = _get_free_spot()
		if enemy_position:
			unit_factory.create_unit_by_type(new_spawn[i], enemy_position, 0, 2)

func _random_rect(i_rect: Vector2, weight = 0) -> Vector2:
	return (1 - weight) * Vector2(rng.randf() * i_rect.x, rng.randf() * i_rect.y) + weight * i_rect

func _random_point() -> Vector2:
	# Generate a random point within the sector bounds
	return Vector2(rng.randf() * pixel_size.x, rng.randf() * pixel_size.y)

func _is_overlapping_building(point: Vector2) -> bool:
	for building in buildings:
		if building.has_point(point):
			return true
	return false

func _fill_grid(entry_points : Array) -> Array:
	grid_data.clear()
	# Working Column after Column, making sure that as least one is connected.
	var temp_column = _fill_grid_column(entry_points)
	grid_data.append(temp_column)
	for i in range(grid_size.x - 1):
		temp_column = _fill_grid_column(temp_column)
		grid_data.append(temp_column)
	return grid_data
	
func _get_sector_entry_index() -> int:
	if grid_data.size() < 1:
		return -1
		
	return _get_grid_gateway(grid_data[0])

func _get_grid_gateway(column: Array) -> int :
	if column.is_empty():
		return -1
		
	for i in range(column.size()):
		if column[i] == MapSector.GridContent.MAIN:
			return i
			
	# There should always be a MAIN, so this should never happen.
	return -1
	
func _fill_grid_column(prev_points : Array):
	
	var out_column = []
	out_column.resize(grid_size.y)
	out_column.fill(GridContent.FILLED)
	
	# First deciding which entry point is the sure gateway. The space in front is marked as empty
	# but it's not necessarily the next MAIN
	var previous_main_index = _get_grid_gateway(prev_points)
	out_column[previous_main_index] = GridContent.MAIN
	
	# Then populate straight channels.
	var straight_counter = 1
	for i in range(prev_points.size()):
		if prev_points[i] != GridContent.FILLED:
			if rng.randf() > .2 + straight_counter * .2:
				out_column[i] = GridContent.EMPTY
	
	# Then check vertical channels.	
	for i in range(out_column.size()):
		var prev_idx = max(0, i - 1)
		var next_idx = min(i + 1, out_column.size() - 1)
		if out_column[prev_idx] != GridContent.FILLED or out_column[next_idx] != GridContent.FILLED:
			if rng.randf() > .3:
				out_column[i] = GridContent.EMPTY
	
	# Finally check if the MAIN has space on the sides, and potentially move it all the way up or down.
	var direction_down : bool = rng.randf() - .5 > 0
	var new_main_index : int = previous_main_index
	for i in range(out_column.size()):
		var temp_index = new_main_index + (1 if direction_down else -1)
		if temp_index < 0 or temp_index >= out_column.size():
			out_column[new_main_index] = GridContent.MAIN
			break
		elif out_column[temp_index] == GridContent.EMPTY:
			out_column[new_main_index] = GridContent.EMPTY
			new_main_index = temp_index
			out_column[new_main_index] = GridContent.MAIN
		else:
			out_column[new_main_index] = GridContent.MAIN
			break
	
	return out_column

func _add_building(rect: Rect2) -> Dictionary:
	
	# Create visual representation
	var building_node = ColorRect.new()
	building_node.color = Color(0.5, 0.5, 0.5)  # Gray color
	building_node.position = rect.position
	building_node.size = rect.size
	var building_center = building_node.position + rect.size / 2
	add_child(building_node)
	
	# Creating the navigation collider	
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	var collision_shape = CollisionShape2D.new()
	collision_shape.set_shape(shape)
	var static_body = StaticBody2D.new()
	static_body.add_child(collision_shape)
	
	add_child(static_body)
	static_body.add_to_group("obstacles")
	static_body.set_position(building_center)
	
	return {
		"building_node": building_node,
		"collision_shape": collision_shape
	}
	
func _add_checkpoint(pos : Vector2) -> void :
	return # temporarly disabled checkpoints
	var checkpoint = checkpoint_scene.instantiate()
	add_child(checkpoint)
	checkpoint.global_position = pos
	checkpoint.kill_if_blue = true
