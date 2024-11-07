extends Node2D

@onready var nav_region = $Region
@onready var checkpoint_scene = preload("res://scenes/checkpoint.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	seed(12345)
	# Prints a random integer between 0 and 49.
	print(randi() % 50)
	
	_populate(5)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
# Private Methods

func _random_rect(i_rect : Vector2i, weight = 0) -> Vector2:
	return (1-weight) * Vector2(randi() % i_rect.x, randi() % i_rect.y) + weight * Vector2(i_rect)

func _populate(num : int) -> void: 
	
	# TODO this is a very temp generation of buildings
	var sections = Vector2(3,2)
	var building_size = Vector2(200,200)
	for xi in range (sections.x): 
		for yi in range (sections.y):
			
			# Adding a central building:
			var center = Vector2(
				get_viewport_rect().size.x / sections.x * (xi + 0.5), 
				get_viewport_rect().size.y / sections.y * (yi + 0.5))
			_add_building(center, _random_rect(building_size, 0.5))
			
			# Adding side-buildings around it:
			for i in range (4):
				_add_building(center + _random_rect(building_size) - building_size / 2, _random_rect(building_size / 3, 0.7))
		
	nav_region.bake_navigation_polygon()
	
	# Adding the checkpoints too.
	#for xi in range (sections.x - 1): 
		#for yi in range (sections.y):
			#_add_checkpoint(Vector2(
				#get_viewport_rect().size.x / sections.x * (xi + 1), 
				#get_viewport_rect().size.y / sections.y * (yi + .5)))
	_add_checkpoint(Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y /2))

func _add_building(pos : Vector2, size : Vector2):
	
	# Creating a StaticBody2d
	var shape = RectangleShape2D.new()
	shape.size = size
	var collision_shape = CollisionShape2D.new()
	collision_shape.set_shape(shape)

	var static_body = StaticBody2D.new()
	static_body.add_child(collision_shape)
	static_body.set_position(pos)
		
	nav_region.add_child(static_body)
	
	# Adding a white polygon too.
	var visible_shape = Polygon2D.new()
	var extents = shape.extents
	var points = [
		Vector2(-extents.x, -extents.y),  # Bottom-left corner
		Vector2(extents.x, -extents.y),   # Bottom-right corner
		Vector2(extents.x, extents.y),    # Top-right corner
		Vector2(-extents.x, extents.y)    # Top-left corner
	]
	visible_shape.polygon = points
	visible_shape.set_position(pos)
	nav_region.add_child(visible_shape)

	collision_shape.set_shape(shape)

	pass

func _add_checkpoint(pos : Vector2) -> void :
	var checkpoint = checkpoint_scene.instantiate()
	checkpoint.position = pos
	add_child(checkpoint)
