extends Control

func show_dialog():
	
	# Show the InteractiveArea
	_center_dialog()
	visible = true
	
	# Ensure it processes during pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Clear any existing children
	for n in get_children():
		remove_child(n)
		n.queue_free()

	# Set up the InteractiveArea properties (optional styling)
	anchor_left = 0
	anchor_right = 1
	anchor_top = 0
	anchor_bottom = 1
	modulate = Color(0, 0, 0, 0.5)  # Semi-transparent background

	print("Adding buttons to the interactive area!")

	# Create the buttons
	var button_texts = ["More Enemies", "Nah I'm Good"]  # Replace with actual options
	var button_width = 150
	var button_height = 50
	var spacing = 20
	var total_width = button_width * button_texts.size() + spacing * (button_texts.size() - 1)
	var start_x = (size.x - total_width) / 2

	for i in range(button_texts.size()):
		var button = Button.new()
		add_child(button)
		button.text = button_texts[i]
		button.size = Vector2(button_width, button_height)
		button.position = Vector2(start_x + i * (button_width + spacing), (size.y - button_height) / 2)
		button.process_mode = Node.PROCESS_MODE_ALWAYS 
		button.pressed.connect(self._on_interactive_button_pressed.bind(i))
		
func _center_dialog():
	position = %Camera.position - size/2

func _on_interactive_button_pressed(index):
	# Handle the choice based on index
	# For example, you might adjust game variables or state here

	# Hide and clear the InteractiveArea
	visible = false
	
	# Resume the game
	get_tree().paused = false
	
	# Generate the new sector and increment the counter
	var horde = []
	match index:
		0:	
			horde.resize(30)
			horde.fill(UnitParams.Types.BUG)
	%InfiniteMap._generate_new_sector(horde)
