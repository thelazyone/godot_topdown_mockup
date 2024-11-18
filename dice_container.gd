extends Control

const margin = 20
const spacing = 10

var current_dice_values = []
var current_dice = []

func _ready():
	# Assuming `SelectionArea` is the node that emits the signals
	%InteractiveArea.option_area_hover.connect(_on_highlight_dice)
	%InteractiveArea.option_area_left.connect(_on_clear_dice_highlight)

func _on_highlight_dice(ranges : Array):
	
	# Highlight dice that fit the ranges
	for i in (current_dice.size()):
		var die_value = current_dice_values[i]
		if DiceMath.die_fits_slots(die_value, ranges):
			current_dice[i].modulate = Color(1, 1, 0)  # Highlight color (yellow)
		else:
			current_dice[i].modulate = Color(1, 1, 1)  # Normal color

func _on_clear_dice_highlight():
	# Reset all dice to normal color
	for die in current_dice:
		die.modulate = Color(1, 1, 1)
		
func display_dice(input_dice : Array):
	
	clear_dice()
	current_dice_values = input_dice
	var dice_size = Vector2(80, 80)
	var total_width = (dice_size.x + spacing) * current_dice_values.size() - spacing
	var start_x = 0 

	for i in range(current_dice_values.size()):
		var dice_value = current_dice_values[i]
		var dice_button = Button.new()
		dice_button.text = str(dice_value)
		dice_button.size = dice_size
		dice_button.position = Vector2(\
			margin + start_x + i * (dice_size.x + spacing),\
			get_viewport_rect().size.y - dice_size.y - margin)
		dice_button.pressed.connect(self._on_dice_pressed.bind(i))
		add_child(dice_button)
		current_dice.append(dice_button)

func clear_dice():
	for child in current_dice:
		child.queue_free()
	current_dice.clear()

func _on_dice_pressed(index):
	print("Dice", index, " pressed with value ", current_dice_values[index])
