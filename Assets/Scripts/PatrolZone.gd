extends Area2D
class_name PatrolZone

func get_random_point() -> Vector2:
	var shape = get_node("CollisionShape2D").shape

	# Rectangular patrol zones
	if shape is RectangleShape2D:
		var extents = shape.extents
		var local = Vector2(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y)
		)
		return to_global(local)

	# Circular patrol zones
	if shape is CircleShape2D:
		var radius = shape.radius
		var angle = randf() * TAU
		var r = sqrt(randf()) * radius
		var local = Vector2(r * cos(angle), r * sin(angle))
		return to_global(local)

	# Other shapes can be added later
	return global_position


func contains_point(point: Vector2) -> bool:
	return get_overlapping_bodies().any(func(b): 
		return b.global_position.distance_to(point) < 5
	)
