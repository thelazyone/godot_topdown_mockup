class_name MapSector
extends Node2D

var buildings = []  # Array of Rect2 representing building positions and sizes
var enemies = []    # Array of Vector2 representing enemy positions

func generate_content():
	_generate_buildings()
	_generate_enemies()

func _generate_buildings():
	# Generate Rect2 for where the buildings are and store them in "buildings"
	_populate_buildings()

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
	var sector_size = Vector2(1024, 600)  # Adjust as needed
	return Vector2(randf() * sector_size.x, randf() * sector_size.y)

func _populate_buildings():
	var sections = Vector2(3, 2)
	var building_size = Vector2(200, 200)
	for xi in range(int(sections.x)):
		for yi in range(int(sections.y)):
			# Adding a central building
			var center = Vector2(
				1024 / sections.x * (xi + 0.5),
				600 / sections.y * (yi + 0.5)
			)
			_add_building(center, _random_rect(building_size, 0.5))
			# Adding side-buildings around it
			for i in range(4):
				var offset = _random_rect(building_size) - building_size / 2
				var size = _random_rect(building_size / 3, 0.7)
				_add_building(center + offset, size)

func _add_building(pos: Vector2, size: Vector2):
	# Add the building's Rect2 to the list
	var rect = Rect2(pos - size / 2, size)
	buildings.append(rect)

func _is_overlapping_building(point: Vector2) -> bool:
	for building in buildings:
		if building.has_point(point):
			return true
	return false
