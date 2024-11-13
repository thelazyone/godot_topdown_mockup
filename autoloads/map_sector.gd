class_name MapSector
extends Node2D

var sector_grid_size = Vector2(3, 4)
var sector_grid_data = []

var buildings: Array[Rect2] = []  # Array of Rect2 representing building positions and sizes
var enemies: Array[Vector2] = []  # Array of Vector2 representing enemy positions
var checkpoints: Array[Vector2] = []  # Array of Vector2 representing enemy positions

var sector_size

# Possibly TBR
var building_nodes = []     # Nodes representing the buildings (visuals)
var collision_shapes = []   # Collision shapes for navigation

@onready var checkpoint_scene = preload("res://scenes/checkpoint.tscn")

# Public Functions:
func generate_content(size: Vector2):
	sector_size = size
	_generate_buildings()
	_generate_checkpoints()
	_generate_enemies()
	
# Methods to access data
func get_building_rects() -> Array:
	return buildings

func get_enemy_positions() -> Array:
	return enemies
	
func get_checkpoint_positions() -> Array:
	return checkpoints
	
# Private Function

func _generate_buildings():
	# Generate Rect2 for where the buildings are and store them in "buildings"
	_populate_buildings()
	
func _generate_checkpoints():
	
	# TODO Temp - creating two checkpoints now.
	_add_checkpoint(Vector2(sector_size.x * .25, sector_size.y * .5))

func _generate_enemies():
	# Generate Vector2 for where the enemies are and store them in "enemies"
	# Ensure enemies do not overlap with buildings
	var num_enemies = 5  # Adjust as needed
	var max_attempts = 10
	for i in range(num_enemies):
		var enemy_pos = null
		for attempt in range(max_attempts):
			var pos = _random_point()
			if not _is_overlapping_building(pos):
				enemy_pos = pos
				break
		if enemy_pos:
			enemies.append(enemy_pos)

func _random_rect(i_rect: Vector2, weight = 0) -> Vector2:
	return (1 - weight) * Vector2(randf() * i_rect.x, randf() * i_rect.y) + weight * i_rect

func _random_point() -> Vector2:
	# Generate a random point within the sector bounds
	return Vector2(randf() * sector_size.x, randf() * sector_size.y)

func _populate_buildings():
	var sections = Vector2(2, 2)
	var building_size = Vector2(100, 100)
	for xi in range(int(sections.x)):
		for yi in range(int(sections.y)):
			# Adding a central building
			var center = Vector2(
				sector_size.x / sections.x * (xi + 0.5),
				sector_size.y / sections.y * (yi + 0.5)
			)
			
			_add_building(Rect2(center, _random_rect(building_size, 0.5)))
			
			# Adding side-buildings around it
			for i in range(4):
				var offset = _random_rect(building_size) - building_size / 2
				var size = _random_rect(building_size / 3, 0.7)
				_add_building(Rect2(center + offset, size))
				

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
	static_body.set_global_position(building_center)
	
	return {
		"building_node": building_node,
		"collision_shape": collision_shape
	}
	
func _add_checkpoint(pos : Vector2) -> void :
	var checkpoint = checkpoint_scene.instantiate()
	checkpoint.position = pos
	checkpoint.kill_if_blue = true
	add_child(checkpoint)
	
	
