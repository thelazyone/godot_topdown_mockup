extends Node2D


# Adjustable parameters
var sectors = []                           		# List to keep track of active sectors
var sector_counter : int = 0
@onready var sector_size : Vector2 = Vector2(get_viewport().size.y / 2, get_viewport().size.y)
@onready var removal_distance = sector_size.x * 5    	# Distance after which sectors are removed
@onready var sector_factory = MapSectorFactory.new()

# References to child nodes
@onready var nav_region = $NavRegion       # NavigationRegion2D node

func _ready():
	# Generate the initial sector
	sector_factory.sector_size = sector_size
	
	# Initialize the FogOfWar
	$FogOfWar.size = Vector2(sector_size.x, get_viewport().size.y)
	$FogOfWar.position = Vector2(sector_size.x, 0)

# Camera Stuff
@onready var camera_offset = $Camera.position.x
var camera_position: float = 0
var camera_target_position : float = 0
const CAMERA_SPEED = 150

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
		print("InfiniteMap: Generating Sector ", sector_counter)
		if sector_counter == 0:
			var main_node = get_node("/root/Main")
			var current_sector_handle = _generate_new_sector()
			var spaw_offset = current_sector_handle.get_grid_gateway()
			spaw_offset *= current_sector_handle.sector_size.y/current_sector_handle.sector_grid_size.y
			var spaw_position = Vector2(0, spaw_offset)
			main_node.add_units(main_node.start_goons, UnitParams.Types.SOLDIER, 1, spaw_position)
		else: 
			_generate_new_sector()
		sector_counter += 1

	# Remove old sectors if they're far left
	if sectors.size() > 0 and camera_position - sectors[0].position.x > removal_distance:
		_remove_old_sector()
		
	# Update FogOfWar position to the right of the latest sector
	$FogOfWar.position.x = sector_counter * sector_size.x
	$FogOfWar.position.y = 0

# Adding a new sector to the list.
func _generate_new_sector():
	var sector_position_x = sector_counter * sector_size.x
	#var sector_position_x = sector_counter * sector_size.x

	# Create a new MapSector instance
	var sector_instance = sector_factory.new_sector(self.nav_region, sector_position_x)
	#sector_instance.position.x = sector_position_x
	sectors.append(sector_instance) # TODO unelegant, double instancing!

	# Rebake the navigation mesh
	_rebake_navigation()
	
	return sector_instance

# Blindly destroying the oldest sector when the conditions require it.
func _remove_old_sector():

	var old_sector = sectors.pop_front()
	old_sector.queue_free()
	
	# Rebake the navigation mesh
	_rebake_navigation()
	
# Moving the navigation area rectangle to the current active sectors, and baking.
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
