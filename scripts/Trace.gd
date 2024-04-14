extends Line2D

var target: Node2D

func setup(_target):
	target = _target

func stop():
	var current_points = points
	for i in current_points:
		remove_point(0)
		await get_tree().process_frame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target == null or (target is InvocationCursor and not (target as InvocationCursor).moving):
		return
	
	if points.size() == 90:
		remove_point(0)
	add_point(target.global_position)
