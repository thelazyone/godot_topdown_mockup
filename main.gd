extends Node2D

const goon_scene = preload("res://scenes/actors/goon.tscn")
const start_1 = Vector2(100,300)
const start_2 = Vector2(1000, 300)
const max_goons = 20

var cumulateTime = 0

func add_goons(faction : int, number : int, position : Vector2) :
	# Adding some goons
	for i in range(number):
		var goon = goon_scene.instantiate()
		goon.position = position + Vector2(0, 15 * i)
		goon.add_to_group("goons")
		goon.FACTION = faction
		if (faction > 1):
			goon.get_node("Image").self_modulate = Color(1,.6,.6,1)
		else:
			goon.get_node("Image").self_modulate = Color(.6,.6,1,1)
		add_child(goon)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_goons(1, 8, start_1)
	add_goons(2, 8, start_2)

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
		
		var goon1 = 0
		var goon2 = 0
		
		var goons = get_tree().get_nodes_in_group("goons")
		for goon in goons:
			match goon.FACTION:
				1: goon1 += 1
				2: goon2 += 1
				
		if goon1 < max_goons:
			add_goons(1, min(max_goons - goon1, 2), start_1)
		if goon2 < max_goons:
			add_goons(2, min(max_goons - goon2, 2), start_2)
		cumulateTime = 0
		
	pass
