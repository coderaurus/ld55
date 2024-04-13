extends Line2D
class_name InvocationCircle

signal circle_ready

var next_invocation = 0
var active = false
var freq = 0.1
var cursor: InvocationCursor
# Called when the node enters the scene tree for the first time.
func setup(cur):
	cursor = cur
	var dots: Array[Vector2] = []
	for i in 360:
		var x = -sin(deg_to_rad(i)) * 200
		var y = cos(deg_to_rad(i)) * 200
		var new_point = Vector2(x, y)
		dots.append(new_point)
	points = dots
	
	for child: RitualBeat in get_children():
		var x = -sin(deg_to_rad(child.beat_at)) * 200
		var y = cos(deg_to_rad(child.beat_at)) * 200
		var new_point = Vector2(x, y)
		child.global_position = global_position + new_point
	
	circle_ready.emit(dots, global_position)
	active = true

func get_next_invocation():
	return get_child(next_invocation)

func _process(delta):
	if next_invocation < get_child_count():
		var next: RitualBeat = get_next_invocation()
		var distance = cursor.global_position.distance_to(next.global_position)
		if distance <= next.invocation_grace_range and not next.reached:
			next.reached = true
		elif distance >= next.invocation_grace_range and next.reached:
			if not next.invoked:
				next.fizzle()
			
			next_invocation += 1
			print("Moving to next invocation (%s)" % next_invocation)

func circle_complete():
	return next_invocation == get_child_count()
