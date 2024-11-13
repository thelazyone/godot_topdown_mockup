extends Node2D

@onready var checkpoint_scene = preload("res://scenes/checkpoint.tscn")

# Adjustable parameters
var sectors = []                           		# List to keep track of active sectors
var sector_counter : int = 0
@onready var sector_size : Vector2 = Vector2(get_viewport().size.y / 2, get_viewport().size.y)
@onready var removal_distance = sector_size.x * 5    	# Distance after which sectors are removed

# References to child nodes
@onready var nav_region = $NavRegion       # NavigationRegion2D node

func _ready():
	# Generate the initial sector
	_generate_new_sector()
	# Initialize the FogOfWar
	$FogOfWar.size = Vector2(sector_size.x, get_viewport().size.y)
	$FogOfWar.position = Vector2(sector_size.x, 0)

# Camera Stuff
@onready var camera_offset = $Camera.position.x
var camera_position: float = 0
var camera_target_position : float = 0
const CAMERA_SPEED = 800

func move_camera(new_position : float):
	if new_position > camera_target_position:
		camera_target_position = new_position

func get_camera_position() -> float:
	return camera_position

func _process(delta):
	
	# Moving the camera if target has changed.
	var camera_spread = camera_target_position - camera_position
	if abs(camera_spread) > .1:
		var move_amount = CAMERA_SPEED * delta * sign(camera_spread)
		camera_position += min(abs(camera_spread), abs(move_amount)) * sign(camera_spread)
		$Camera.position.x = camera_position + camera_offset

	# Generate new sector if needed
	if camera_position > (sector_counter - 3) * sector_size.x:
		print("Generating Sector ", sector_counter)
		_generate_new_sector()
		sector_counter += 1

	# Remove old sectors if they're far left
	if sectors.size() > 0 and camera_position - sectors[0].position.x > removal_distance:
		_remove_old_sector()
		
	# Update FogOfWar position to the right of the latest sector
	$FogOfWar.position.x = sector_counter * sector_size.x
	$FogOfWar.position.y = 0
	
func _generate_new_sector():
	var sector_position_x = sector_counter * sector_size.x
	#var sector_position_x = sector_counter * sector_size.x

	# Create a new MapSector instance
	var sector_instance = MapSector.new()
	sector_instance.position.x = sector_position_x
	sector_instance.generate_content(sector_size)

	# Create buildings and collision shapes
	for building_rect in sector_instance.get_building_rects():
		var nodes = _add_building(building_rect, Vector2(sector_position_x, 0))
		
		# Tracking for removal only.
		sector_instance.building_nodes.append(nodes["building_node"])
		sector_instance.collision_shapes.append(nodes["collision_shape"])
	
	# Adding Checkpoints
	for checkpoint in sector_instance.get_checkpoint_positions():
		_add_checkpoint(checkpoint, Vector2(sector_position_x, 0))
	
	# Enemies can be handled similarly if needed
	# for enemy_pos in sector_instance.get_enemy_positions():
	#     spawn_enemy(enemy_pos + Vector2(sector_position_x, 0))

	sectors.append(sector_instance)

	# Rebake the navigation mesh
	_rebake_navigation()

func _add_building(rect: Rect2, sector_offset: Vector2) -> Dictionary:
	# Create visual representation
	var building_node = ColorRect.new()
	building_node.color = Color(0.5, 0.5, 0.5)  # Gray color
	building_node.position = sector_offset + rect.position
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
	nav_region.add_child(static_body)
	static_body.add_to_group("obstacles")
	static_body.set_global_position(building_center)
	
	return {
		"building_node": building_node,
		"collision_shape": collision_shape
	}
	
func _add_checkpoint(pos : Vector2, sector_offset: Vector2) -> void :
	var checkpoint = checkpoint_scene.instantiate()
	checkpoint.position = pos + sector_offset
	checkpoint.kill_if_blue = true
	add_child(checkpoint)
	

func _remove_old_sector():

	var old_sector = sectors.pop_front()

	# Remove building nodes
	for building_node in old_sector.building_nodes:
		building_node.queue_free()

	# Remove collision shapes
	for collision_shape in old_sector.collision_shapes:
		collision_shape.queue_free()

	# Rebake the navigation mesh
	_rebake_navigation()
	

func _rebake_navigation():

	# Move the navigation region centered where it should be, then bake
	nav_region.navigation_polygon.clear_outlines()
	var polygon = [
		Vector2(camera_position, 0),
		Vector2(get_viewport().size.x * 2 + camera_position, 0),
		Vector2(get_viewport().size.x * 2 + camera_position, get_viewport().size.y),
		Vector2(camera_position, get_viewport().size.y),
	]
	nav_region.navigation_polygon.add_outline(polygon)
	nav_region.bake_navigation_polygon()
