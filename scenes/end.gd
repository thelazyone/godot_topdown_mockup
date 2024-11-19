extends Control


func _ready():
	$QuitButton.pressed.connect(_on_quit_game_button_pressed)

func _on_quit_game_button_pressed():
	print("END OF THE GAME, THANK YOU!")
	get_tree().quit()
