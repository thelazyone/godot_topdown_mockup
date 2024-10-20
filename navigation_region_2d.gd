extends NavigationRegion2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_world_tree_ready():
	var on_thread: bool = true
	bake_navigation_polygon(on_thread)
	
