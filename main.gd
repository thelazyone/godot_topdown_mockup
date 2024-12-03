extends Node2D

		
func _ready() -> void:
	
	# Testing the new UI TODO TBR
	LevelData.dice_values = [1, 1, 1, 2, 3, 4, 5, 5, 6]
	$UI/DiceContainer.display_dice(LevelData.dice_values)
	
	pass

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("debug"):
		Debug.debug_enabled = !Debug.debug_enabled
		
	if Input.is_action_just_pressed("debug_console"):
		Debug.debug_console_enabled = !Debug.debug_console_enabled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass
