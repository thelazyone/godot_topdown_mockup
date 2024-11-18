extends Control

const margin = 20
const spacing = 10

var current_dice_values = []
var current_dice = []

var selecting_dice = false
var required_slots = []
var selected_dice_indices = []
var current_effect = null
var use_dice_button = null

signal dice_selection_complete()
signal dice_selection_canceled()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	%InteractiveArea.option_area_hover.connect(_on_highlight_dice)
	%InteractiveArea.option_area_left.connect(_on_clear_dice_highlight)

func start_dice_selection(cost, effect):
	print("DEBUG starting dice selection!")
	selecting_dice = true
	required_slots = cost
	current_effect = effect
	selected_dice_indices.clear()

	# Deselect all dice and enable them for selection
	for die in current_dice:
		die.modulate = Color(1, 1, 1)
		die.disabled = false  # Ensure dice can be clicked

	# Clear any existing UI elements
	_clear_selection_ui()

	# Create a VBoxContainer to hold the instruction label and buttons
	var vbox = VBoxContainer.new()
	vbox.name = "SelectionUI"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.anchor_left = 0
	vbox.anchor_right = 1
	vbox.anchor_top = 0
	vbox.anchor_bottom = 0
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse events
	add_child(vbox)

	# Position the VBoxContainer just above the dice
	vbox.position = Vector2(0, get_viewport_rect().size.y - 250)  # Adjust as needed

	# Create the instruction label
	var instruction_label = Label.new()
	instruction_label.text = "Choose which dice to use!"
	instruction_label.name = "InstructionLabel"
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	instruction_label.add_theme_font_size_override("font_size", 24)
	instruction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instruction_label.size_flags_vertical = Control.SIZE_FILL
	instruction_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse events
	vbox.add_child(instruction_label)

	# Create the buttons container
	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.size_flags_vertical = Control.SIZE_FILL
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.custom_minimum_size = Vector2(0, 50)
	button_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse events
	vbox.add_child(button_container)

	# Create the "Return" button
	var return_button = Button.new()
	return_button.text = "Return"
	return_button.name = "ReturnButton"
	return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return_button.size_flags_vertical = Control.SIZE_FILL
	return_button.pressed.connect(_on_return_button_pressed)
	button_container.add_child(return_button)

	# Create the "USE DICE" button
	use_dice_button = Button.new()
	use_dice_button.text = "USE DICE"
	use_dice_button.name = "UseDiceButton"
	use_dice_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	use_dice_button.size_flags_vertical = Control.SIZE_FILL
	use_dice_button.disabled = true  # Initially disabled
	use_dice_button.pressed.connect(_on_use_dice_button_pressed)
	button_container.add_child(use_dice_button)

func end_dice_selection():
	selecting_dice = false
	selected_dice_indices.clear()
	current_effect = null

	# Deselect all dice and disable them
	for die in current_dice:
		die.modulate = Color(1, 1, 1)
		die.disabled = true  # Disable clicking if needed

	# Remove instruction label and buttons if they exist
	_clear_selection_ui()

func _clear_selection_ui():
	if has_node("SelectionUI"):
		get_node("SelectionUI").queue_free()

func _on_return_button_pressed():
	print("Return button pressed, canceling dice selection")

	# Reset dice selection state
	end_dice_selection()

	# Emit a signal to inform `interactive_area.gd` to reset the selection
	emit_signal("dice_selection_canceled")

func _on_use_dice_button_pressed():
	print("Use Dice button pressed")
	
	# I cannot 
	var reverse_indices = selected_dice_indices
	reverse_indices.sort()
	reverse_indices.reverse()
	for index in reverse_indices:
		_delete_dice_at_index(index)
	display_dice()

	# Proceed to generate new sector
	emit_signal("dice_selection_complete")

func _on_highlight_dice(ranges: Array):
	# Highlight dice that fit the ranges
	for i in range(current_dice.size()):
		var die_value = current_dice_values[i]
		if DiceMath.die_fits_slots(die_value, ranges):
			current_dice[i].modulate = Color(1, 1, 0)  # Highlight color (yellow)
		else:
			current_dice[i].modulate = Color(1, 1, 1)  # Normal color

func _on_clear_dice_highlight():
	# Reset all dice to normal color
	for die in current_dice:
		die.modulate = Color(1, 1, 1)

func display_dice(input_dice: Array = []):
	clear_dice()
	if input_dice != []:
		current_dice_values = input_dice
	print("current dice are ", current_dice_values)
	var dice_size = Vector2(80, 80)
	var total_width = (dice_size.x + spacing) * current_dice_values.size() - spacing
	var start_x = (get_viewport_rect().size.x - total_width) / 2  # Center the dice

	for i in range(current_dice_values.size()):
		var dice_value = current_dice_values[i]
		var dice_button = Button.new()
		dice_button.text = str(dice_value)
		dice_button.size = dice_size
		dice_button.position = Vector2(
			start_x + i * (dice_size.x + spacing),
			get_viewport_rect().size.y - dice_size.y - margin)
		dice_button.pressed.connect(_on_dice_pressed.bind(i))
		dice_button.disabled = true  # Initially disabled until selection starts
		add_child(dice_button)
		current_dice.append(dice_button)

	## Bring dice buttons to the front
	#for die in current_dice:
		#die.set  # Ensure dice are above other controls

func clear_dice():
	for child in current_dice:
		child.queue_free()
	current_dice.clear()

func _on_dice_pressed(index: int):
	print("pressed dice ", index)

	if not selecting_dice:
		return  # Ignore clicks if not in selection mode

	# Toggle selection
	if index in selected_dice_indices:
		# Deselect
		print("deselecting dice ", index)
		selected_dice_indices.erase(index)
		current_dice[index].modulate = Color(1, 1, 1)  # Normal color
	else:
		# Check if we can select more dice
		if selected_dice_indices.size() < required_slots.size():
			# Select
			print("selecting dice ", index)
			selected_dice_indices.append(index)
			current_dice[index].modulate = Color(0, 1, 0)  # Selected color (green)
		else:
			# Cannot select more dice
			print("Cannot select more dice")

	# Update the "USE DICE" button state
	_update_use_dice_button_state()

func _update_use_dice_button_state():
	print("testing use_dice")
	if use_dice_button:
		if selected_dice_indices.size() == required_slots.size():
			# Gather the selected dice values
			var selected_values = []
			for idx in selected_dice_indices:
				selected_values.append(current_dice_values[idx])
			# Check if selected dice satisfy the criteria
			print("checking if ", selected_values, " satisfy ", required_slots)
			if DiceMath.dice_satisfy_slots(selected_values, required_slots):
				# Enable the "USE DICE" button
				use_dice_button.disabled = false
				return
		# Disable the "USE DICE" button
		use_dice_button.disabled = true
		
func _delete_dice_at_index(index):
	if current_dice.size() >= index or current_dice_values.size() >= index:
		print("ERROR - size mismatch in the dice metadata!")
	
	current_dice[index].queue_free()
	current_dice.remove_at(index)
	current_dice_values.remove_at(index)
