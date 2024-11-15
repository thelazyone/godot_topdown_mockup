extends Control

var dice_values = []  # Array of numbers representing dice values
const margin = 20
const spacing = 10

func display_dice(values: Array):
	
	clear_dice()
	dice_values = values
	var dice_size = Vector2(80, 80)
	var total_width = (dice_size.x + spacing) * values.size() - spacing
	var start_x = 0 

	for i in range(values.size()):
		var dice_value = values[i]
		var dice_button = Button.new()
		dice_button.text = str(dice_value)
		dice_button.size = dice_size
		dice_button.position = Vector2(\
			margin + start_x + i * (dice_size.x + spacing),\
			get_viewport_rect().size.y - dice_size.y - margin)
		dice_button.pressed.connect(self._on_dice_pressed.bind(i))
		add_child(dice_button)

func clear_dice():
	for child in get_children():
		child.queue_free()

func _on_dice_pressed(index):
	print("Dice", index, " pressed with value ", dice_values[index])
