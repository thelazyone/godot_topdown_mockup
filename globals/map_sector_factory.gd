class_name MapSectorFactory
extends Node

const grid_size = Vector2(5, 8)
var pixel_size = Vector2.ZERO
var roba = 3
var last_sector_column = []

func _init() -> void:
	last_sector_column.resize(grid_size.y)
	last_sector_column.fill(MapSector.GridContent.EMPTY)
	last_sector_column[randi() % int(grid_size.y)] = MapSector.GridContent.MAIN

func new_sector(parent: Node, position_x: float, new_spawn: Array) -> MapSector:
	var sector_instance = MapSector.new()
	parent.add_child(sector_instance)
	sector_instance.pixel_size = pixel_size
	sector_instance.position.x = position_x
	sector_instance.generate_content(last_sector_column, new_spawn)
	
	# Updating the "last column" before returning
	last_sector_column = sector_instance.grid_data[sector_instance.grid_data.size() - 1]
	
	return sector_instance
