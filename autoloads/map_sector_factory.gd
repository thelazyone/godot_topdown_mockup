class_name MapSectorFactory
extends Node

const sector_grid_size = Vector2(3, 4)
var sector_size = Vector2.ZERO
var roba = 3
var last_sector_column = []

func _init() -> void:
	
	last_sector_column.resize(sector_grid_size.y)
	last_sector_column.fill(MapSector.GridContent.EMPTY)
	print("DEBUG - ", last_sector_column)

func new_sector(parent: Node, position_x: float) -> MapSector:
	var sector_instance = MapSector.new()
	parent.add_child(sector_instance)
	sector_instance.sector_size = sector_size
	sector_instance.position.x = position_x
	sector_instance.generate_content(last_sector_column)
	return sector_instance