extends Node2D

var goon_scene = preload("res://goon.tscn")
var start_1 = Vector2(100,400)
var start_2 = Vector2(1000, 100)

var cumulateTime = 0

func addGoons(number : int) :
	# Adding some goons
	for i in range(number):
		var goon = goon_scene.instantiate()
		goon.position = start_1 + Vector2(0, 15*i)
		goon.add_to_group("goons")
		goon.FACTION = 1
		add_child(goon)
		#goon.set_move_order(get_viewport().size / 2)

	# Adding some enemies
	for i in range(number):
		var goon = goon_scene.instantiate()
		goon.position = start_2 + Vector2(0, 10*i)
		goon.add_to_group("goons")
		goon.FACTION = 2
		add_child(goon)
		#goon.set_move_order(get_viewport().size / 2)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#NavigationMap.setup(get_viewport().size)
	
	addGoons(8)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_index == 2:
		if event.is_pressed():
			var goons = get_tree().get_nodes_in_group("goons")
			for goon in goons:
				if goon.FACTION == 1:
					goon.set_move_order(get_viewport().get_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	cumulateTime += delta
	
	if cumulateTime > 1:
		cumulateTime = 0
		#addGoons(2)
	pass
