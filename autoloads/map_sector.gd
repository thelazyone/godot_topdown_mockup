class_name MapSector
extends Node2D

enum GridContent {EMPTY, CHECKPOINT, FILLED}

var sector_grid_data : Array = [] #Saved as Column Major.
@onready var sector_grid_size = MapSectorFactory.sector_grid_size

func _fill_grid(entry_points : Array) -> Array:
	
	sector_grid_data.clear()
	# Working Column after Column, making sure that as least one is connected.
	var temp_column = _fill_grid_column(entry_points)
	sector_grid_data.append(temp_column)
	for i in range(sector_grid_size.x - 1):
		temp_column = _fill_grid_column(temp_column)
		sector_grid_data.append(temp_column)
	
	return sector_grid_data
	
func get_grid_gateway() -> int :
	if sector_grid_data.is_empty():
		return -1
	
	var start_point = randi() % sector_grid_data[0].size()
	var gateway_idx = 0
	for i in range(sector_grid_data[0].size()):
		var wrap_idx = (i + start_point) % sector_grid_data[0].size()
		if sector_grid_data[0][wrap_idx] != GridContent.FILLED:
			gateway_idx = wrap_idx
	return gateway_idx
	
func _fill_grid_column(prev_points : Array):
	
	var out_column = []
	out_column.resize(sector_grid_size.y)
	out_column.fill(GridContent.FILLED)
	
	# First deciding which entry point is the sure gateway.
	out_column[get_grid_gateway()] = GridContent.EMPTY
	
	# Then populate straight channels.
	for i in range(prev_points.size()):
		if prev_points[i] == GridContent.EMPTY:
			if randf() > .8:
				out_column[i] = GridContent.EMPTY
	
	# Then check vertical channels.	
	for i in range(out_column.size()):
		var prev_idx = max(0, i - 1)
		var next_idx = min(i + 1, out_column.size() - 1)
		if out_column[prev_idx] == GridContent.EMPTY or out_column[next_idx] == GridContent.EMPTY:
			if randf() > .8:
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
func generate_content(latest_grid_column: Array):
	
	_fill_grid(latest_grid_column)

	_generate_buildings()
	_generate_checkpoints()
	_generate_enemies()

# Private Function
func _generate_buildings():

	for xi in range(int(sector_grid_size.x)):
		for yi in range(int(sector_grid_size.y)):
			if sector_grid_data[xi][yi] == GridContent.FILLED:
				var grid_elem_size = sector_size / sector_grid_size
				var building_position = Vector2(\
					(xi) * grid_elem_size.x,\
					(yi) * grid_elem_size.y)
				_add_building(Rect2(building_position, grid_elem_size))

func _get_free_spot(col_idx : int) -> Vector2:
	for i in range(	sector_grid_data[col_idx].size()):
		if sector_grid_data[col_idx][i] != GridContent.FILLED:
			var grid_elem_size = sector_size / sector_grid_size
			var central_position = Vector2(\
				col_idx * grid_elem_size.x,\
				i * grid_elem_size.y)
			return global_position + central_position + grid_elem_size / 2
	return Vector2.ZERO

func _generate_checkpoints():
	var checkpoint_pos = _get_free_spot(1)	
	print("checkpoint position at", checkpoint_pos)
	_add_checkpoint(checkpoint_pos)

func _generate_enemies():
	# TODO very temp)
	var num_enemies = 5  # Adjust as needed
	for i in range(num_enemies):
		var enemy_position = _get_free_spot(1)
		if enemy_position != Vector2.ZERO:
			get_node("/root/Main").add_units(1, UnitParams.Types.BUG, 2, enemy_position)

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
	checkpoint.global_position = pos
	checkpoint.kill_if_blue = true
	add_child(checkpoint)
	
	
