extends Node2D

const start_1 = Vector2(100,300)
const start_2 = Vector2(1000, 300)
const start_goons = 8	
const max_goons = 12

var cumulateTime = 0

func add_goons(faction : int, number : int, i_position : Vector2) :
	var params = UnitParams.new()
	params.melee = false
	
	# Adding some goons
	for i in range(number):
		$UnitFactory.create_unit(params, i_position + Vector2(0, 15 * i), faction, self)

func add_bugs(faction : int, number : int, i_position : Vector2) :
	var params = UnitParams.new()
	params.melee = true
	
	# Adding some goons
	for i in range(number):
		$UnitFactory.create_unit(params, i_position + Vector2(0, 15 * i), faction, self)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_goons(1, start_goons, start_1)
	add_bugs(2, start_goons, start_2)

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
