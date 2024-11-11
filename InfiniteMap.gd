extends Node2D

# Adjustable parameters
var sector_width = 1024  # Width of each sector
var sector_height = 600  # Height of each sector (adjust as needed)
var sectors = []         # List to keep track of active sectors
var player_node_path = NodePath("/root/Player")  # Path to your player node
var removal_distance = sector_width * 2          # Distance after which sectors are removed

# References to child nodes
@onready var nav_region = $NavRegion # NavigationRegion2D node

# Camera Stuff
@onready var camera_offset = $Camera.position.x
var camera_position: float = 0
const CAMERA_SPEED = 800

func move_camera():
	$Camera.position.x = camera_offset + camera_position

# Tracking Position 
func _process(delta):
	if Input.is_action_pressed("right"):
			camera_position += delta * CAMERA_SPEED
			move_camera()
	# Generate new sector if needed
	if camera_position > (sectors.size() - 2) * sector_width:
		generate_new_sector()

	# Remove old sectors if they're far left
	if sectors.size() > 0 and camera_position - sectors[0]["position_x"] > removal_distance:
		remove_old_sector()

func generate_new_sector():
	print("DEBUG: Generating new sector!")
	var sector_position_x = sectors.size() * sector_width
	var new_sector = {
		"position_x": sector_position_x,
		"buildings": [],
		"building_nodes": [],
		"collision_shapes": []
	}

	# Generate sector metadata
	var sector_instance = MapSector.new()
	sector_instance.generate_content()
	new_sector["buildings"] = sector_instance.buildings
	new_sector["enemies"] = sector_instance.enemies  # Enemies will be handled by you

	# Create buildings and collision shapes
	for building_rect in new_sector["buildings"]:
		var nodes = add_building(building_rect, Vector2(sector_position_x, 0))
		new_sector["building_nodes"].append(nodes["building_node"])
		new_sector["collision_shapes"].append(nodes["collision_shape"])

	sectors.append(new_sector)

	# Rebake the navigation mesh
	_rebake_navigation()

func add_building(rect: Rect2, sector_offset: Vector2) -> Dictionary:
	# Create visual representation
	var building_node = ColorRect.new()
	building_node.color = Color(0.5, 0.5, 0.5)  # Gray color
	building_node.position = sector_offset + rect.position
	building_node.size = rect.size
	add_child(building_node)

	# Create collision shape for navigation
	var collision_shape = CollisionPolygon2D.new()
	var polygon = [
		Vector2(0, 0),
		Vector2(rect.size.x, 0),
		Vector2(rect.size.x, rect.size.y),
		Vector2(0, rect.size.y)
	]
	collision_shape.polygon = polygon
	collision_shape.position = sector_offset + rect.position
	nav_region.add_child(collision_shape)

	return {
		"building_node": building_node,
		"collision_shape": collision_shape
	}

func remove_old_sector():
	print("Removing old sector")
	
	var old_sector = sectors.pop_front()

	# Remove building nodes
	for building_node in old_sector["building_nodes"]:
		building_node.queue_free()

	# Remove collision shapes
	for collision_shape in old_sector["collision_shapes"]:
		collision_shape.queue_free()

	# Rebake the navigation mesh
	_rebake_navigation()

func _rebake_navigation():
	
	# Moving the navigation region centered where it should be, then baking
	nav_region.position = $Camera.position
	nav_region.bake_navigation_polygon()
