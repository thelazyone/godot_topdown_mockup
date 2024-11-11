extends Node2D

# Adjustable parameters
var sector_size : Vector2 = Vector2(800, 600)
var sectors = []                           # List to keep track of active sectors
var removal_distance = sector_size.x * 2    # Distance after which sectors are removed
var sector_counter : int = 0

# References to child nodes
@onready var nav_region = $NavRegion       # NavigationRegion2D node

# Camera Stuff
@onready var camera_offset = $Camera.position.x
var camera_position: float = 0
const CAMERA_SPEED = 800

func move_camera():
	$Camera.position.x = camera_offset + camera_position

func _process(delta):
	if Input.is_action_pressed("right"):
		camera_position += delta * CAMERA_SPEED
		move_camera()

	# Generate new sector if needed
	if camera_position > (sector_counter - 2) * sector_size.x:
		generate_new_sector()
		sector_counter += 1
		print ("sector counter is ", sector_counter)

	# Remove old sectors if they're far left
	if sectors.size() > 0 and camera_position - sectors[0].position.x > removal_distance:
		remove_old_sector()

func generate_new_sector():
	print("DEBUG: Generating new sector!")
	var sector_position_x = sector_counter * sector_size.x

	# Create a new MapSector instance
	var sector_instance = MapSector.new()
	sector_instance.position.x = sector_position_x
	sector_instance.generate_content(Vector2(sector_size))

	# Create buildings and collision shapes
	for building_rect in sector_instance.get_building_rects():
		var nodes = add_building(building_rect, Vector2(sector_position_x, 0))
		
		# Tracking for removal only.
		sector_instance.building_nodes.append(nodes["building_node"])
		sector_instance.collision_shapes.append(nodes["collision_shape"])

	# Enemies can be handled similarly if needed
	# for enemy_pos in sector_instance.get_enemy_positions():
	#     spawn_enemy(enemy_pos + Vector2(sector_position_x, 0))

	sectors.append(sector_instance)

	# Rebake the navigation mesh
	_rebake_navigation()

func add_building(rect: Rect2, sector_offset: Vector2) -> Dictionary:
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
	static_body.set_global_position(building_center)



	# Create collision shape for navigation
	#var collision_shape = CollisionPolygon2D.new()
	#var polygon = [
		#Vector2(0, 0),
		#Vector2(rect.size.x, 0),
		#Vector2(rect.size.x, rect.size.y),
		#Vector2(0, rect.size.y)
	#]
	#collision_shape.polygon = polygon
	#collision_shape.position = sector_offset + rect.position
	#nav_region.add_child(collision_shape)

	return {
		"building_node": building_node,
		"collision_shape": collision_shape
	}

func remove_old_sector():

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
	
	## Thanks to https://www.reddit.com/r/godot/comments/rzmfh3/is_there_a_way_to_get_the_rect2_of_the_camera/
	#var camera_rect = get_canvas_transform().affine_inverse().basis_xform(get_viewport_rect().size)

	

	# Move the navigation region centered where it should be, then bake
	nav_region.navigation_polygon.clear_outlines()
	var polygon = [
		Vector2(camera_position + 60, 0),
		Vector2(get_viewport().size.x * 2 + camera_position, 0),
		Vector2(get_viewport().size.x * 2 + camera_position, get_viewport().size.y),
		Vector2(camera_position + 60, get_viewport().size.y),
	]
	nav_region.navigation_polygon.add_outline(polygon)
	print("adding nav polygon at ", polygon)
	nav_region.bake_navigation_polygon()
