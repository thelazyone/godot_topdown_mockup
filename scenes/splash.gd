extends Control


func _ready():
	$StartButton.pressed.connect(_on_get_started_button_pressed)

func _on_get_started_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
