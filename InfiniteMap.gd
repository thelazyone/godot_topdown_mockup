extends Node2D


# Adjustable parameters
var sectors = []                           		# List to keep track of active sectors
var sector_counter : int = 0
var first_run = true
var hostile_sector_counter : int = 0
const sector_size_ratio = .75 #.5 is vertical, 2 is horizontal.
@onready var gaming_area_height = get_viewport().size.y 
@onready var sector_size : Vector2 = Vector2(gaming_area_height * sector_size_ratio, gaming_area_height)
@onready var removal_distance = sector_size.x * 5    	# Distance after which sectors are removed
@onready var sector_factory = $NavRegion/MapSectorFactory

# References to child nodes
@onready var nav_region = $NavRegion       # NavigationRegion2D node
@onready var fow = $NavRegion/FogOfWar
@onready var camera : Node = %Camera
@onready var cards_container = %CardsContainer
@onready var unit_factory = %UnitFactory
var interactive_area = null

signal navigation_baked

func _ready():
	sector_factory.pixel_size = sector_size
	
	interactive_area = %InteractiveArea
	interactive_area.visible = false
	
	# Initialize the FogOfWar
	fow.size = Vector2(sector_size.x, get_viewport().size.y)
	var static_body = StaticBody2D.new()
	fow.add_child(static_body)
	var collision_shape = CollisionShape2D.new()
	static_body.add_child(collision_shape)
	var shape = RectangleShape2D.new()
	shape.size = fow.size
	collision_shape.set_shape(shape)
	static_body.position = shape.size / 2
	

func _process(delta):
	
	# First Sector Initialization.
	if first_run == true:
		first_run = false
		var main_node = get_node("/root/Main")
		var current_sector_handle = generate_new_sector()
		print("Debug, map is:")
		current_sector_handle.display_debug()
		var spawn_position = Vector2(0, current_sector_handle.get_sector_entry_position())
		var player_starting_units = LevelData.player_units
		for i in range(player_starting_units.size()):
			var unit = player_starting_units[i]
			var offset = Vector2(50, 0) + Vector2(10 * (i%4 - 1.5), 10 * (i/4 - 1.5))
			unit_factory.create_unit_by_type(unit.type, spawn_position + offset, unit.id, 1)

		# Adding a second sector at the beginning.
		if nav_region.is_baking():
			nav_region.bake_finished.connect(generate_new_sector, CONNECT_ONE_SHOT)
		#generate_new_sector()


	# Generate new sector if needed
	var camera_position = camera.get_camera_position_h()
	
	# If it's a hostile sector, a modal dialog should appear.
	# TODO for now all sectors are hostile! 
	if sector_counter > 1 and camera_position > (sector_counter - 2) * sector_size.x + 100:
		if not interactive_area.visible:
			
			# Here a new sector is about to get generated - a new card choice appears! 
			get_tree().paused = true
			cards_container.set_active_card_index(hostile_sector_counter)
			interactive_area.show_dialog(hostile_sector_counter)
			hostile_sector_counter += 1

	# Remove old sectors if they're far left
	if sectors.size() > 0 and camera_position - sectors[0].position.x > removal_distance:
		_remove_old_sector()
		

# Adding a new sector to the list.
func generate_new_sector(new_spawn: Array = []):
	
	print("Generating sector #", sector_counter)
	
	var sector_position_x = sector_counter * sector_size.x
	#var sector_position_x = sector_counter * sector_size.x

	# Create a new MapSector instance
	var sector_instance = sector_factory.new_sector(self.nav_region, sector_position_x, new_spawn)
	#sector_instance.position.x = sector_position_x
	sectors.append(sector_instance) # TODO unelegant, double instancing!

	# Rebake the navigation mesh
	sector_counter +=1
	fow.position.x = sector_counter * sector_size.x
	_rebake_navigation()
	
	# Connect the navigation_baked signal to a lambda that calls populate
	nav_region.bake_finished.connect(sector_instance.populate)
	# With the Fog of War moved aside, baking navigation polygon.
	#sector_instance.populate()

	return sector_instance

# Blindly destroying the oldest sector when the conditions require it.
func _remove_old_sector():

	var old_sector = sectors.pop_front()
	old_sector.queue_free()
	
	# Rebake the navigation mesh
	_rebake_navigation()
	
	
# Moving the navigation area rectangle to the current active sectors, and baking.
func _rebake_navigation():
	var viewport = get_viewport()
	if not viewport:
		return
	
	# Move the navigation region centered where it should be, then bake
	nav_region.navigation_polygon.clear_outlines()
	var camera_position = camera.get_camera_position_h()
	var polygon = [
		Vector2(camera_position, 0),
		Vector2(get_viewport().size.x * 2 + camera_position, 0),
		Vector2(get_viewport().size.x * 2 + camera_position, get_viewport().size.y),
		Vector2(camera_position, get_viewport().size.y),
	]
	nav_region.navigation_polygon.add_outline(polygon)
	nav_region.navigation_polygon.agent_radius = 40
	
	nav_region.bake_navigation_polygon()
	
