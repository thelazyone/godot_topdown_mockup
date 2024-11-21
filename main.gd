extends Node2D

		
func _ready() -> void:
	
	
	# Testing the new UI TODO TBR
	LevelData.dice_values = [1, 1, 1, 2, 3, 4, 5, 5, 6]
	$UI/DiceContainer.display_dice(LevelData.dice_values)
	
	pass

func add_units(number : int, type : UnitParams.Types, i_id: int, faction : int, i_position : Vector2) :
	for i in range(number):
		$UnitFactory.create_unit(UnitParams.get_unit_params(type), i_position + Vector2(10 * i, 0), i_id, faction, self)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_index == 2:
		if event.is_pressed():
			var goons = get_tree().get_nodes_in_group("goons")
			for goon in goons:
				if goon.FACTION == 1:
					goon.set_move_order(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("debug"):
		Debug.debug_enabled = !Debug.debug_enabled
		
	if Input.is_action_just_pressed("debug_console"):
		Debug.debug_console_enabled = !Debug.debug_console_enabled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass
