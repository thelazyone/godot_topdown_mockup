extends Node2D

var goon_scene = preload("res://goon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Adding some goons
	for i in range(1):
		var goon = goon_scene.instantiate()
		goon.position += Vector2(10, 10 + 10*i)
		goon.add_to_group("goons")
		goon.FACTION = 1
		add_child(goon)
		
	# Adding some enemies
	for i in range(1):
		var goon = goon_scene.instantiate()
		goon.position += Vector2(400, 10 + 10*i)
		goon.add_to_group("goons")
		goon.FACTION = 2
		add_child(goon)
		goon.set_move_order(Vector2(400, 100))

	
	pass # Replace with function body.
	

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_index == 2:
		if event.is_pressed():
			var goons = get_tree().get_nodes_in_group("goons")
			for goon in goons:
				if goon.FACTION == 1:
					goon.set_move_order(get_viewport().get_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
