extends Node2D

func is_point_in_navigation_polygon(point: Vector2) -> bool:
	var nav_region = get_node("/root/Main/InfiniteMap/NavRegion")

	# Convert navigation polygon to a NavigationPolygon resource
	var nav_poly = nav_region.navigation_polygon

	# Get the actual navigation mesh from the NavigationPolygon
	var navigation_mesh = nav_poly.get_navigation_mesh()
	
	# Use NavigationServer2D for more reliable checking
	var world_2d = get_world_2d()
	var space_state = world_2d.direct_space_state

	# Perform a point intersection test
	var params = PhysicsPointQueryParameters2D.new()
	params.position = point
	params.collision_mask = nav_region.navigation_layers

	var result = space_state.intersect_point(params, 1)

	return not result.is_empty()

func get_latest_containing_rect_for_faction(i_faction : int) -> Rect2:
	var unit_factory = get_node("/root/Main/UnitFactory")
	return unit_factory.get_latest_containing_rect_for_faction(i_faction)
