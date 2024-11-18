class_name MapSector
extends Node2D

enum GridContent {EMPTY, CHECKPOINT, FILLED}

var sector_grid_data : Array = [] #Saved as Column Major.
@onready var sector_grid_size = MapSectorFactory.sector_grid_size
var sector_gateway_index = -1
var local_gateway_index = -1

func _fill_grid(entry_points : Array) -> Array:
	sector_grid_data.clear()
	# Working Column after Column, making sure that as least one is connected.
	var temp_column = _fill_grid_column(entry_points)
	sector_grid_data.append(temp_column)
	sector_gateway_index = local_gateway_index
	for i in range(sector_grid_size.x - 1):
		temp_column = _fill_grid_column(temp_column)
		sector_grid_data.append(temp_column)
	
	return sector_grid_data
	
func get_sector_entry_index() -> int:
	return sector_gateway_index
	
func get_sector_entry_position() -> float:
	print("debug: ", get_sector_entry_index(),  " ", (get_sector_entry_index() + .5) * (sector_size.y / sector_grid_size.y))
	return (get_sector_entry_index() + .5) * (sector_size.y / sector_grid_size.y)
	
func _get_grid_gateway(column: Array) -> int :
	if column.is_empty():
		return -1
	
	var start_point = randi() % column.size()
	var gateway_idx = 0
	for i in range(column.size()):
		var wrap_idx = (i + start_point) % column.size()
		if column[wrap_idx] != GridContent.FILLED:
			gateway_idx = wrap_idx
	return gateway_idx
	
func _fill_grid_column(prev_points : Array):
	
	var out_column = []
	out_column.resize(sector_grid_size.y)
	out_column.fill(GridContent.FILLED)
	
	# First deciding which entry point is the sure gateway.
	local_gateway_index = _get_grid_gateway(prev_points)
	out_column[local_gateway_index] = GridContent.EMPTY
	
	# Then populate straight channels.
	var straight_counter = 1
	for i in range(prev_points.size()):
		if prev_points[i] == GridContent.EMPTY:
			if randf() > .2 + straight_counter * .2:
				out_column[i] = GridContent.EMPTY
	
	# Then check vertical channels.	
	for i in range(out_column.size()):
		var prev_idx = max(0, i - 1)
		var next_idx = min(i + 1, out_column.size() - 1)
		if out_column[prev_idx] == GridContent.EMPTY or out_column[next_idx] == GridContent.EMPTY:
			if randf() > .3:
				out_column[i] = GridContent.EMPTY
	
	return out_column

var buildings: Array[Rect2] = []  # Array of Rect2 representing building positions and sizes
var enemies: Array[Vector2] = []  # Array of Vector2 representing enemy positions
var checkpoints: Array[Vector2] = []  # Array of Vector2 representing enemy positions

var sector_size

# Possibly TBR
var building_nodes = []     # Nodes representing the buildings (visuals)
var collision_shapes = []   # Collision shapes for navigation

@onready var checkpoint_scene = preload("res://scenes/checkpoint.tscn")

# Public Functions:
func generate_content(latest_grid_column: Array, new_spawn: Array):
	
	_fill_grid(latest_grid_column)

	_generate_buildings()
	_generate_checkpoints()
	_generate_units(new_spawn)

func display_debug():
	var out_string = ""
	for yi in range(sector_grid_size.y):
		for xi in range(sector_grid_size.x):
			if sector_grid_data[xi][yi] == GridContent.FILLED:
				out_string += "#"
			else:
				out_string += " "
		out_string += "\n"
	print(out_string)

# Private Function
func _generate_buildings():
	
	var main_building_rects = []
	for xi in range(int(sector_grid_size.x)):
		for yi in range(int(sector_grid_size.y)):
			if sector_grid_data[xi][yi] == GridContent.FILLED:
				var grid_elem_size = sector_size / sector_grid_size
				var building_position = Vector2(\
					(xi) * grid_elem_size.x,\
					(yi) * grid_elem_size.y)
				_add_building(Rect2(building_position, grid_elem_size * 1.05))
				main_building_rects.append(Rect2(building_position, grid_elem_size))
	
	#for each main rect, adding a few sub-rects
	for main_rect in main_building_rects:
		for i in range(randi() % 4):
			var local_pos = Vector2((randf() * .5) * main_rect.size.x, (randf() * .5) * main_rect.size.y)
			var protrusion_value = randf() * .55 * min(main_rect.size.x, main_rect.size.y)
			var random_sign = Vector2(sign(randf() - .5),sign(randf() - .5))
			var new_position = main_rect.position + local_pos * random_sign
			var new_size_x = min(main_rect.size.x - local_pos.x, local_pos.x) + protrusion_value 
			var new_size_y = min(main_rect.size.y - local_pos.y, local_pos.y) + protrusion_value 
			_add_building(Rect2(new_position, Vector2(new_size_x, new_size_y)))
	
	# Finally adding buildings on top and bottom.
	_add_building(Rect2(Vector2(0,-90), Vector2(sector_size.x, 100)))
	_add_building(Rect2(Vector2(0,sector_size.y - 10), Vector2(sector_size.x, 100)))

func _get_free_spot(col_idx : int) -> Vector2:
	for i in range(	sector_grid_data[col_idx].size()):
		var wrap_idx = i + randi() % sector_grid_data[col_idx].size()
		wrap_idx = wrap_idx % sector_grid_data[col_idx].size()
		if sector_grid_data[col_idx][wrap_idx] != GridContent.FILLED:
			var grid_elem_size = sector_size / sector_grid_size
			var corner_position = Vector2(\
				col_idx * grid_elem_size.x,\
				wrap_idx * grid_elem_size.y)
			return global_position + corner_position + grid_elem_size / 2
	return Vector2.ZERO

func _generate_checkpoints():
	var checkpoint_pos = _get_free_spot(1)	
	_add_checkpoint(checkpoint_pos)

func _generate_units(new_spawn: Array):
	for i in range(new_spawn.size()):
		var enemy_position = _get_free_spot(2)
		get_node("/root/Main").add_units(1, new_spawn[i], 0, 2, enemy_position + (Vector2(10 * i,10 * i)))

func _random_rect(i_rect: Vector2, weight = 0) -> Vector2:
	return (1 - weight) * Vector2(randf() * i_rect.x, randf() * i_rect.y) + weight * i_rect

func _random_point() -> Vector2:
	# Generate a random point within the sector bounds
	return Vector2(randf() * sector_size.x, randf() * sector_size.y)


func _is_overlapping_building(point: Vector2) -> bool:
	for building in buildings:
		if building.has_point(point):
			return true
	return false

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
	var checkpoint = checkpoint_scene.instantiate()
	add_child(checkpoint)
	checkpoint.global_position = pos
	checkpoint.kill_if_blue = true
