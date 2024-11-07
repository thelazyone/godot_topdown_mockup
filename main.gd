extends Node2D

const start_1 = Vector2(100,300)
const start_2 = Vector2(1000, 300)
const start_goons = 8	
const max_goons = 16

var cumulateTime = 0

func add_goons(number : int, i_position : Vector2) :
	var params = UnitParams.new()
	params.melee = false
	params.speed = 80
	params.shoot_speed = 50

	# Adding some goons
	for i in range(number):
		$UnitFactory.create_unit(params, i_position + Vector2(0, 15 * i), 1, self)

func add_bugs(number : int, i_position : Vector2) :
	var params = UnitParams.new()
	params.melee = true
	params.speed = 120
	
	# Adding some goons
	for i in range(number):
		$UnitFactory.create_unit(params, i_position + Vector2(0, 15 * i), 2, self)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_goons(start_goons, start_1)
	add_bugs(start_goons, start_2)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_index == 2:
		if event.is_pressed():
			var goons = get_tree().get_nodes_in_group("goons")
			for goon in goons:
				if goon.FACTION == 1:
					goon.set_move_order(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("debug"):
		Debug.debug_enabled = !Debug.debug_enabled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	cumulateTime += delta
	
	if cumulateTime > 1:
		
		var goons_counter = 0
		var bugs_counter = 0
		
		var goons = get_tree().get_nodes_in_group("goons")
		for goon in goons:
			match goon.FACTION:
				1: goons_counter += 1
				2: bugs_counter += 1
				
		if goons_counter < max_goons:
			add_goons(min(max_goons - goons_counter, 1), start_1)
		if bugs_counter < max_goons * 2:
			add_bugs(min(max_goons - bugs_counter, 5), start_2)
		cumulateTime = 0
		
	pass
