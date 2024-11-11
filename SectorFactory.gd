extends Node2D

# Preload your sector scene
var SectorScene = preload("res://Scenes/Sector.tscn")

func create_sector():
	var sector_instance = SectorScene.instantiate()
	sector_instance.generate_content()
	return sector_instance
